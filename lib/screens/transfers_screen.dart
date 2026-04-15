import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import '../models/beneficiary_model.dart';
import '../models/card_model.dart';
import '../services/api_service.dart';
import '../services/card_service.dart';
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
  List<BeneficiaryModel> _beneficiarios = [];
  String? _selectedBankId;
  String? _selectedBeneficiaryId;
  bool _isLoadingBancos = false;

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
    setState(() => _isLoadingBancos = true);
    final bancos = await TransferService.getBanks();
    final beneficiarios = await TransferService.getBeneficiaries();
    if (mounted) {
      setState(() {
        _bancos = bancos;
        _beneficiarios = beneficiarios;
        _isLoadingBancos = false;
      });
    }
  }

  void _changeTransferType(String type) {
    setState(() {
      _transferType = type;
      _montoController.clear();
      _descripcionController.clear();
      _numeroTarjetaDestinoController.clear();
      _selectedBankId = null;
      _selectedBeneficiaryId = null;
    });
  }

  void _showAddBeneficiaryModal() {
    _nombreBeneficiarioController.clear();
    _cuentaBeneficiarioController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agregar beneficiario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nombreBeneficiarioController,
              decoration: const InputDecoration(
                labelText: 'Nombre del beneficiario',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cuentaBeneficiarioController,
              decoration: const InputDecoration(
                labelText: 'Número de cuenta',
                prefixIcon: Icon(Icons.account_balance),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nombreBeneficiarioController.text.isEmpty ||
                      _cuentaBeneficiarioController.text.isEmpty ||
                      _selectedBankId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completa todos los campos'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                    return;
                  }

                  final navigator = Navigator.of(context);
                  final scaffold = ScaffoldMessenger.of(context);

                  final success = await TransferService.addBeneficiary(
                    nombre: _nombreBeneficiarioController.text,
                    numeroCuenta: _cuentaBeneficiarioController.text,
                    bankId: _selectedBankId!,
                  );

                  if (!mounted) return;

                  if (success) {
                    navigator.pop();
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text('Beneficiario agregado correctamente'),
                        backgroundColor: AppTheme.accentColor,
                      ),
                    );
                    _loadBancosAndBeneficiarios();
                  } else {
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text('Error al agregar beneficiario'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                child: const Text('Guardar beneficiario'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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
        _montoController.clear();
        _descripcionController.clear();
        await _loadCuentas();
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Transferencia realizada · Ref: ${result['data']['referencia']}'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
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
        _montoController.clear();
        _descripcionController.clear();
        _numeroTarjetaDestinoController.clear();
        await _loadTarjetas();
        scaffold.showSnackBar(
          SnackBar(
            content: Text('Transferencia realizada · Ref: ${result['data']['referencia']}'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      } else {
        scaffold.showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Error'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
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
    return _isLoadingBancos
        ? const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cuenta origen
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

              // Banco destino
              DropdownButtonFormField<String>(
                initialValue: _selectedBankId,
                decoration: const InputDecoration(
                  labelText: 'Banco destino',
                  prefixIcon: Icon(Icons.business),
                ),
                items: _bancos
                    .map((bank) => DropdownMenuItem(
                          value: bank.id,
                          child: Text(bank.nombre),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedBankId = value;
                  _selectedBeneficiaryId = null;
                }),
              ),
              const SizedBox(height: 16),

              // Beneficiario
              if (_selectedBankId != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedBeneficiaryId,
                        decoration: const InputDecoration(
                          labelText: 'Beneficiario',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _beneficiarios
                            .where((b) => b.banco.id == _selectedBankId)
                            .map((benef) => DropdownMenuItem(
                                  value: benef.id,
                                  child: Text(benef.nombre),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedBeneficiaryId = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppTheme.primaryColor),
                      onPressed: _showAddBeneficiaryModal,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Monto
              TextField(
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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

              // Botón transferir
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _processTransfer,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Realizar transferencia',
                    style: TextStyle(fontSize: 16),
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
