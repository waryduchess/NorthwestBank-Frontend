import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bank_model.dart';
import '../models/card_model.dart';
import '../services/api_service.dart';
import '../services/card_service.dart';
import '../services/payment_service.dart';
import '../services/transfer_service.dart';
import '../theme/app_theme.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  String _transferType = 'entre_mis_cuentas';

  // Entre mis cuentas — datos reales
  List<Map<String, dynamic>> _cuentas = [];
  Map<String, dynamic>? _cuentaOrigen;
  Map<String, dynamic>? _cuentaDestino;
  bool _isLoadingCuentas = false;
  bool _isProcessing = false;

  // Entre mis tarjetas
  List<CardModel> _tarjetas = [];
  CardModel? _tarjetaOrigen;
  bool _isLoadingTarjetas = false;
  final TextEditingController _numeroTarjetaDestinoController = TextEditingController();

  // A terceros
  List<BankModel> _bancos = [];
  String? _selectedBankId;

  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _nombreBeneficiarioController = TextEditingController();
  final TextEditingController _cuentaBeneficiarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCuentas();
    _loadTarjetas();
    _loadBancosAndBeneficiarios();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _nombreBeneficiarioController.dispose();
    _cuentaBeneficiarioController.dispose();
    _numeroTarjetaDestinoController.dispose();
    super.dispose();
  }

  Future<void> _loadCuentas() async {
    setState(() => _isLoadingCuentas = true);
    final result = await ApiService.getAccounts();
    if (mounted && result['success']) {
      final List<dynamic> data = result['data'];
      final cuentas = data.map((c) => Map<String, dynamic>.from(c)).toList();
      setState(() {
        _cuentas = cuentas;
        if (cuentas.isNotEmpty) _cuentaOrigen = cuentas[0];
        if (cuentas.length >= 2) _cuentaDestino = cuentas[1];
        _isLoadingCuentas = false;
      });
    } else {
      setState(() => _isLoadingCuentas = false);
    }
  }

  Future<void> _loadTarjetas() async {
    setState(() => _isLoadingTarjetas = true);
    final cards = await CardService.getUserCards();
    if (mounted) {
      setState(() {
        _tarjetas = cards;
        if (cards.isNotEmpty) _tarjetaOrigen = cards[0];
        _isLoadingTarjetas = false;
      });
    }
  }

  Future<void> _loadBancosAndBeneficiarios() async {
    final bancos = await TransferService.getBanks();
    if (mounted) {
      setState(() => _bancos = bancos);
    }
  }

  void _changeTransferType(String type) {
    setState(() {
      _transferType = type;
      _montoController.clear();
      _descripcionController.clear();
      _numeroTarjetaDestinoController.clear();
      _selectedBankId = null;
      _nombreBeneficiarioController.clear();
      _cuentaBeneficiarioController.clear();
    });
  }

  Future<void> _processTransfer() async {
    final monto = double.tryParse(_montoController.text);

    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido'), backgroundColor: AppTheme.errorColor),
      );
      return;
    }

    if (_transferType == 'entre_mis_cuentas') {
      if (_cuentaOrigen == null || _cuentaDestino == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona las cuentas'), backgroundColor: AppTheme.errorColor),
        );
        return;
      }
      if (_cuentaOrigen!['id'] == _cuentaDestino!['id']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La cuenta origen y destino no pueden ser la misma'), backgroundColor: AppTheme.errorColor),
        );
        return;
      }

      setState(() => _isProcessing = true);
      final scaffold = ScaffoldMessenger.of(context);

      final result = await ApiService.transfer(
        cuentaOrigenId: _cuentaOrigen!['id'],
        numeroCuentaDestino: _cuentaDestino!['numero_cuenta'],
        monto: monto,
        descripcion: _descripcionController.text,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result['success']) {
        final referencia = result['data']['referencia']?.toString() ?? '—';
        final origenLabel =
            '${_cuentaOrigen!['tipo'].toString().toUpperCase()} · **** ${_cuentaOrigen!['numero_cuenta'].toString().substring(_cuentaOrigen!['numero_cuenta'].toString().length - 4)}';
        final destinoLabel =
            '${_cuentaDestino!['tipo'].toString().toUpperCase()} · **** ${_cuentaDestino!['numero_cuenta'].toString().substring(_cuentaDestino!['numero_cuenta'].toString().length - 4)}';
        final descripcion = _descripcionController.text;
        _montoController.clear();
        _descripcionController.clear();
        await _loadCuentas();
        if (mounted) {
          _showComprobanteTransferencia(
            tipo: 'Entre mis cuentas',
            origen: origenLabel,
            destino: destinoLabel,
            monto: monto,
            referencia: referencia,
            descripcion: descripcion,
            fecha: DateTime.now(),
          );
        }
      } else {
        scaffold.showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error'), backgroundColor: AppTheme.errorColor),
        );
      }
    } else if (_transferType == 'entre_mis_tarjetas') {
      final numeroDestino = _numeroTarjetaDestinoController.text.trim();

      if (_tarjetaOrigen == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona la tarjeta origen'), backgroundColor: AppTheme.errorColor),
        );
        return;
      }
      if (numeroDestino.length != 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El número de tarjeta destino debe tener 16 dígitos'), backgroundColor: AppTheme.errorColor),
        );
        return;
      }
      if (_tarjetaOrigen!.numeroTarjetaRaw == numeroDestino) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La tarjeta origen y destino no pueden ser la misma'), backgroundColor: AppTheme.errorColor),
        );
        return;
      }
      if (_tarjetaOrigen!.cuentaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: tarjeta sin cuenta asociada'), backgroundColor: AppTheme.errorColor),
        );
        return;
      }

      setState(() => _isProcessing = true);
      final scaffold = ScaffoldMessenger.of(context);

      final result = await ApiService.transferByCard(
        cuentaOrigenId: _tarjetaOrigen!.cuentaId!,
        numeroTarjetaDestino: numeroDestino,
        monto: monto,
        descripcion: _descripcionController.text,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result['success']) {
        final referencia = result['data']['referencia']?.toString() ?? '—';
        final origenLabel =
            '${_tarjetaOrigen!.tipoCuenta.toUpperCase()} · ${_tarjetaOrigen!.numeroCuenta}';
        final last4 = numeroDestino.substring(numeroDestino.length - 4);
        final destinoLabel = 'Tarjeta · **** $last4';
        final descripcion = _descripcionController.text;
        _montoController.clear();
        _descripcionController.clear();
        _numeroTarjetaDestinoController.clear();
        await _loadTarjetas();
        if (mounted) {
          _showComprobanteTransferencia(
            tipo: 'Por tarjeta',
            origen: origenLabel,
            destino: destinoLabel,
            monto: monto,
            referencia: referencia,
            descripcion: descripcion,
            fecha: DateTime.now(),
          );
        }
      } else {
        scaffold.showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error'), backgroundColor: AppTheme.errorColor),
        );
      }
    } else if (_transferType == 'a_terceros') {
      if (_tarjetaOrigen == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona la tarjeta origen'), backgroundColor: AppTheme.errorColor),
        );
        return;
      }
      if (_nombreBeneficiarioController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa el nombre del beneficiario'), backgroundColor: AppTheme.errorColor),
        );
        return;
      }
      if (_selectedBankId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona el banco destino'), backgroundColor: AppTheme.errorColor),
        );
        return;
      }
      if (_cuentaBeneficiarioController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa el número de cuenta del beneficiario'), backgroundColor: AppTheme.errorColor),
        );
        return;
      }

      setState(() => _isProcessing = true);
      final scaffold = ScaffoldMessenger.of(context);

      final result = await PaymentService.processPayment(
        tarjetaId: int.parse(_tarjetaOrigen!.id),
        monto: monto,
        descripcion: _descripcionController.text,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result['success'] == true) {
        final banco = _bancos.firstWhere(
          (b) => b.id == _selectedBankId,
          orElse: () => BankModel(id: '', nombre: 'Banco', codigo: ''),
        );
        final referencia = 'TRF${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        final origenLabel = '${_tarjetaOrigen!.tipoCuenta.toUpperCase()} · ${_tarjetaOrigen!.numeroCuenta}';
        final destinoLabel = '${_nombreBeneficiarioController.text.trim()}\n${banco.nombre} · ${_cuentaBeneficiarioController.text.trim()}';
        final descripcion = _descripcionController.text;

        _montoController.clear();
        _descripcionController.clear();
        _nombreBeneficiarioController.clear();
        _cuentaBeneficiarioController.clear();
        setState(() => _selectedBankId = null);

        await _loadTarjetas();
        if (mounted) {
          _showComprobanteTransferencia(
            tipo: 'A terceros',
            origen: origenLabel,
            destino: destinoLabel,
            monto: monto,
            referencia: referencia,
            descripcion: descripcion,
            fecha: DateTime.now(),
          );
        }
      } else {
        scaffold.showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error al procesar la transferencia'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  void _showComprobanteTransferencia({
    required String tipo,
    required String origen,
    required String destino,
    required double monto,
    required String referencia,
    required DateTime fecha,
    String descripcion = '',
  }) {
    final fechaFormateada =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}  '
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    final repaintKey = GlobalKey();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Área capturada como imagen al compartir
              RepaintBoundary(
                key: repaintKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'NorthwestBank',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const Text(
                        'Comprobante de transferencia',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '¡Transferencia exitosa!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _ComprobanteRow(label: 'Tipo', value: tipo),
                      const SizedBox(height: 10),
                      _ComprobanteRow(label: 'Origen', value: origen),
                      const SizedBox(height: 10),
                      _ComprobanteRow(label: 'Destino', value: destino),
                      const SizedBox(height: 10),
                      _ComprobanteRow(
                        label: 'Monto',
                        value: '\$${monto.toStringAsFixed(2)} MXN',
                        valueStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      if (descripcion.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _ComprobanteRow(label: 'Descripción', value: descripcion),
                      ],
                      const SizedBox(height: 10),
                      _ComprobanteRow(label: 'Referencia', value: referencia),
                      const SizedBox(height: 10),
                      _ComprobanteRow(label: 'Fecha', value: fechaFormateada),
                      const SizedBox(height: 8),
                      const Divider(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botones (fuera del RepaintBoundary, no se capturan)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          final boundary = repaintKey.currentContext!
                              .findRenderObject() as RenderRepaintBoundary;
                          final image = await boundary.toImage(pixelRatio: 3.0);
                          final byteData = await image.toByteData(
                            format: ui.ImageByteFormat.png,
                          );
                          final pngBytes = byteData!.buffer.asUint8List();

                          final dir = await getTemporaryDirectory();
                          final file = File('${dir.path}/comprobante_transferencia.png');
                          await file.writeAsBytes(pngBytes);

                          await Share.shareXFiles(
                            [XFile(file.path)],
                            subject: 'Comprobante de transferencia NorthwestBank',
                          );
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Error al compartir el comprobante'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Compartir'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                      label: const Text('Cerrar'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transferencias')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de transferencia
            const Text(
              'Tipo de transferencia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeTransferType('entre_mis_cuentas'),
                    child: _TransferTypeCard(
                      icon: Icons.account_balance_wallet,
                      label: 'Entre mis cuentas',
                      selected: _transferType == 'entre_mis_cuentas',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeTransferType('entre_mis_tarjetas'),
                    child: _TransferTypeCard(
                      icon: Icons.credit_card,
                      label: 'Por tarjeta',
                      selected: _transferType == 'entre_mis_tarjetas',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeTransferType('a_terceros'),
                    child: _TransferTypeCard(
                      icon: Icons.people_outline,
                      label: 'A terceros',
                      selected: _transferType == 'a_terceros',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Campos dinámicos según tipo de transferencia
            if (_transferType == 'entre_mis_cuentas')
              _buildEntreMiscuentas()
            else if (_transferType == 'entre_mis_tarjetas')
              _buildEntreMisTarjetas()
            else
              _buildAlterceros(),
          ],
        ),
      ),
    );
  }

  Widget _buildEntreMiscuentas() {
    if (_isLoadingCuentas) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    if (_cuentas.isEmpty) {
      return const Center(child: Text('No tienes cuentas disponibles'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<Map<String, dynamic>>(
          value: _cuentaOrigen,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Cuenta origen',
            prefixIcon: Icon(Icons.account_balance),
          ),
          items: _cuentas.map((c) => DropdownMenuItem(
            value: c,
            child: Text(
              '${c['tipo'].toString().toUpperCase()} · **** ${c['numero_cuenta'].toString().substring(c['numero_cuenta'].toString().length - 4)} · \$${double.parse(c['saldo'].toString()).toStringAsFixed(2)}',
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
          onChanged: (value) => setState(() => _cuentaOrigen = value),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<Map<String, dynamic>>(
          value: _cuentaDestino,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Cuenta destino',
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          items: _cuentas.map((c) => DropdownMenuItem(
            value: c,
            child: Text(
              '${c['tipo'].toString().toUpperCase()} · **** ${c['numero_cuenta'].toString().substring(c['numero_cuenta'].toString().length - 4)}',
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
          onChanged: (value) => setState(() => _cuentaDestino = value),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _montoController,
          decoration: const InputDecoration(
            labelText: 'Monto',
            prefixIcon: Icon(Icons.attach_money),
            hintText: '0.00',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _descripcionController,
          decoration: const InputDecoration(
            labelText: 'Descripción (opcional)',
            prefixIcon: Icon(Icons.notes),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processTransfer,
            icon: _isProcessing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send),
            label: Text(
              _isProcessing ? 'Procesando...' : 'Realizar transferencia',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntreMisTarjetas() {
    if (_isLoadingTarjetas) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }

    if (_tarjetas.isEmpty) {
      return const Center(child: Text('No tienes tarjetas disponibles'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<CardModel>(
          value: _tarjetaOrigen,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Tarjeta origen',
            prefixIcon: Icon(Icons.credit_card),
          ),
          items: _tarjetas.map((c) => DropdownMenuItem(
            value: c,
            child: Text(
              '${c.tipoCuenta.toUpperCase()} · ${c.numeroCuenta} · \$${c.saldo.toStringAsFixed(2)}',
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
          onChanged: (value) => setState(() => _tarjetaOrigen = value),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _numeroTarjetaDestinoController,
          decoration: const InputDecoration(
            labelText: 'Número de tarjeta destino',
            prefixIcon: Icon(Icons.credit_card_outlined),
            hintText: '16 dígitos',
          ),
          keyboardType: TextInputType.number,
          maxLength: 16,
        ),
        const SizedBox(height: 8),

        TextField(
          controller: _montoController,
          decoration: const InputDecoration(
            labelText: 'Monto',
            prefixIcon: Icon(Icons.attach_money),
            hintText: '0.00',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _descripcionController,
          decoration: const InputDecoration(
            labelText: 'Descripción (opcional)',
            prefixIcon: Icon(Icons.notes),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processTransfer,
            icon: _isProcessing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send),
            label: Text(
              _isProcessing ? 'Procesando...' : 'Realizar transferencia',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlterceros() {
    if (_isLoadingTarjetas) {
      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    }
    if (_tarjetas.isEmpty) {
      return const Center(child: Text('No tienes tarjetas disponibles'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tarjeta origen
        DropdownButtonFormField<CardModel>(
          value: _tarjetaOrigen,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Tarjeta origen',
            prefixIcon: Icon(Icons.credit_card),
          ),
          items: _tarjetas.map((c) => DropdownMenuItem(
            value: c,
            child: Text(
              '${c.tipoCuenta.toUpperCase()} · ${c.numeroCuenta} · \$${c.saldo.toStringAsFixed(2)}',
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
          onChanged: (value) => setState(() => _tarjetaOrigen = value),
        ),
        const SizedBox(height: 24),

        // Datos del beneficiario
        const Text(
          'Datos del beneficiario',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _nombreBeneficiarioController,
          decoration: const InputDecoration(
            labelText: 'Nombre del beneficiario',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: _selectedBankId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Banco destino',
            prefixIcon: Icon(Icons.account_balance),
          ),
          items: _bancos.map((bank) => DropdownMenuItem(
            value: bank.id,
            child: Text(bank.nombre, overflow: TextOverflow.ellipsis),
          )).toList(),
          onChanged: (value) => setState(() => _selectedBankId = value),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _cuentaBeneficiarioController,
          decoration: const InputDecoration(
            labelText: 'Número de cuenta',
            prefixIcon: Icon(Icons.numbers),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),

        // Monto
        TextField(
          controller: _montoController,
          decoration: const InputDecoration(
            labelText: 'Monto',
            prefixIcon: Icon(Icons.attach_money),
            hintText: '0.00',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),

        // Descripción
        TextField(
          controller: _descripcionController,
          decoration: const InputDecoration(
            labelText: 'Descripción (opcional)',
            prefixIcon: Icon(Icons.notes),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _processTransfer,
            icon: _isProcessing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send),
            label: Text(
              _isProcessing ? 'Procesando...' : 'Realizar transferencia',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Fila del comprobante ────────────────────────────────────────────────────

class _ComprobanteRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _ComprobanteRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: valueStyle ??
                const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
          ),
        ),
      ],
    );
  }
}

class _TransferTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _TransferTypeCard({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: selected ? AppTheme.primaryColor : AppTheme.textSecondary, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
