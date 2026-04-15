import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:share_plus/share_plus.dart';
import '../models/card_model.dart';
import '../models/payment_category_model.dart';
import '../models/payment_subcategory_model.dart';
import '../services/card_service.dart';
import '../services/payment_service.dart';
import '../theme/app_theme.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<PaymentCategoryModel> _categories = [];
  List<PaymentSubcategoryModel> _subcategories = [];
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  bool _isLoading = true;

  final TextEditingController _referenciaController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();

  List<CardModel> _tarjetas = [];
  CardModel? _selectedCard;
  bool _loadingCards = false;
  bool _processingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCards();
  }

  @override
  void dispose() {
    _referenciaController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cats = await PaymentService.getCategories();
    if (mounted) {
      setState(() {
        _categories = cats;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCards() async {
    setState(() => _loadingCards = true);
    final cards = await CardService.getUserCards();
    if (mounted) {
      setState(() {
        _tarjetas = cards.where((c) => c.activa).toList();
        _selectedCard = _tarjetas.isNotEmpty ? _tarjetas.first : null;
        _loadingCards = false;
      });
    }
  }

  Future<void> _selectCategory(String categoryId) async {
    final subcats = await PaymentService.getSubcategories(categoryId);
    if (mounted) {
      setState(() {
        _selectedCategoryId = categoryId;
        _selectedSubcategoryId = null;
        _subcategories = subcats;
        _referenciaController.clear();
        _montoController.clear();
      });
    }
  }

  void _selectSubcategory(String subcategoryId) {
    setState(() {
      _selectedSubcategoryId = subcategoryId;
      _referenciaController.clear();
      _montoController.clear();
    });
  }

  void _goBack() {
    setState(() {
      _selectedCategoryId = null;
      _selectedSubcategoryId = null;
      _subcategories = [];
      _referenciaController.clear();
      _montoController.clear();
    });
  }

  Future<void> _processPay() async {
    final referencia = _referenciaController.text.trim();
    final montoTexto = _montoController.text.trim();

    if (referencia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa el número de referencia'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (montoTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un monto válido'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final monto = double.tryParse(montoTexto);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto debe ser mayor a 0'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una tarjeta para el pago'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_selectedCard!.saldo < monto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saldo insuficiente. Disponible: \$${_selectedCard!.saldo.toStringAsFixed(2)} MXN',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _processingPayment = true);

    final result = await PaymentService.processPayment(
      serviceId: _selectedSubcategoryId ?? '',
      referencia: referencia,
      monto: montoTexto,
      cuentaDebito: _selectedCard!.id,
    );

    if (!mounted) return;
    setState(() => _processingPayment = false);

    if (result['success'] == true) {
      // Actualizar saldo local de la tarjeta
      final cardIdx = _tarjetas.indexWhere((c) => c.id == _selectedCard!.id);
      final cardPagada = _selectedCard!;
      if (cardIdx != -1) {
        final actualizada = CardModel(
          id: cardPagada.id,
          tipoCuenta: cardPagada.tipoCuenta,
          numeroCuenta: cardPagada.numeroCuenta,
          saldo: cardPagada.saldo - monto,
          moneda: cardPagada.moneda,
          imagenTarjeta: cardPagada.imagenTarjeta,
          activa: cardPagada.activa,
          nombreUsuario: cardPagada.nombreUsuario,
          apellidoUsuario: cardPagada.apellidoUsuario,
          fechaVencimiento: cardPagada.fechaVencimiento,
          nombreTitular: cardPagada.nombreTitular,
          categoria: cardPagada.categoria,
          creditoDisponible: cardPagada.creditoDisponible,
          limiteCredito: cardPagada.limiteCredito,
          cvv: cardPagada.cvv,
          nip: cardPagada.nip,
          cuentaId: cardPagada.cuentaId,
          numeroTarjetaRaw: cardPagada.numeroTarjetaRaw,
        );
        setState(() {
          _tarjetas[cardIdx] = actualizada;
          _selectedCard = actualizada;
        });
      }

      final subcategoria = _subcategories.firstWhere(
        (s) => s.id == _selectedSubcategoryId,
        orElse: () => PaymentSubcategoryModel(id: '', categoryId: '', nombre: 'Servicio', codigo: '', orden: 0),
      );
      _showComprobante(
        servicioNombre: subcategoria.nombre,
        referencia: referencia,
        monto: monto,
        tarjeta: cardPagada,
        fecha: DateTime.now(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al procesar el pago'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showComprobante({
    required String servicioNombre,
    required String referencia,
    required double monto,
    required CardModel tarjeta,
    required DateTime fecha,
  }) {
    final fechaFormateada =
        '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}  '
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    final textoComprobante =
        'COMPROBANTE DE PAGO - NorthwestBank\n'
        '─────────────────────────────\n'
        'Servicio:   $servicioNombre\n'
        'Referencia: $referencia\n'
        'Tarjeta:    ${tarjeta.tipoCuenta} ${tarjeta.numeroCuenta}\n'
        'Monto:      \$${monto.toStringAsFixed(2)} MXN\n'
        'Fecha:      $fechaFormateada\n'
        '─────────────────────────────\n'
        'Pago procesado exitosamente';

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
              // Ícono de éxito
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppTheme.accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Pago exitoso!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              // Filas del comprobante
              _ComprobanteRow(label: 'Servicio', value: servicioNombre),
              const SizedBox(height: 10),
              _ComprobanteRow(label: 'Referencia', value: referencia),
              const SizedBox(height: 10),
              _ComprobanteRow(
                label: 'Tarjeta',
                value: '${tarjeta.tipoCuenta}\n${tarjeta.numeroCuenta}',
              ),
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
              const SizedBox(height: 10),
              _ComprobanteRow(label: 'Fecha', value: fechaFormateada),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Botones
              Row(
                children: [
                  // Compartir (share nativo del sistema)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Share.share(
                          textoComprobante,
                          subject: 'Comprobante de pago NorthwestBank',
                        );
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
                  // Cerrar
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _goBack();
                      },
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
      appBar: AppBar(
        title: const Text('Pagos y Servicios'),
        leading: _selectedCategoryId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedCategoryId == null
              ? _buildCategoriesGrid()
              : _buildPaymentFlow(),
    );
  }

  Widget _buildCategoriesGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona un servicio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return _CategoryCard(
                category: category,
                onTap: () => _selectCategory(category.id),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentFlow() {
    final category = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => PaymentCategoryModel(id: '', nombre: '', icono: '', orden: 0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subcategorías
          if (_selectedSubcategoryId == null && _subcategories.isNotEmpty) ...[
            Text(
              'Elige una empresa en ${category.nombre}:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: _subcategories.map((subcat) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _selectSubcategory(subcat.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        subcat.nombre,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Formulario de pago
          if (_selectedSubcategoryId != null) ...[
            const SizedBox(height: 8),
            const Text(
              'Información del pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Número de referencia (solo números)
            TextField(
              controller: _referenciaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Número de referencia',
                hintText: 'Ej: número de medidor, cuenta',
                prefixIcon: Icon(Icons.tag_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Tarjeta a debitar
            _loadingCards
                ? const Center(child: CircularProgressIndicator())
                : _tarjetas.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No tienes tarjetas activas para realizar el pago',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<CardModel>(
                        key: ValueKey(_selectedCard?.id),
                        initialValue: _selectedCard,
                        isExpanded: true,
                        itemHeight: 64,
                        decoration: const InputDecoration(
                          labelText: 'Tarjeta a debitar',
                          prefixIcon: Icon(Icons.credit_card_outlined),
                        ),
                        // Texto compacto en el campo (una sola línea)
                        selectedItemBuilder: (context) => _tarjetas.map((card) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${card.tipoCuenta}  ${card.numeroCuenta}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        // Detalle completo en el menú desplegable
                        items: _tarjetas.map((card) {
                          return DropdownMenuItem<CardModel>(
                            value: card,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${card.tipoCuenta}  ${card.numeroCuenta}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Saldo: \$${card.saldo.toStringAsFixed(2)} MXN',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (card) {
                          if (card != null) setState(() => _selectedCard = card);
                        },
                      ),
            const SizedBox(height: 16),

            // Monto
            TextField(
              controller: _montoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixIcon: Icon(Icons.attach_money),
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 32),

            // Botón pagar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (_processingPayment || _tarjetas.isEmpty)
                    ? null
                    : _processPay,
                icon: _processingPayment
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Pagar servicio', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
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

// ─── Tarjeta de categoría ────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final PaymentCategoryModel category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  IconData get _icon {
    switch (category.icono) {
      case 'bolt':
        return Icons.bolt;
      case 'water':
        return Icons.water_drop;
      case 'wifi':
        return Icons.wifi;
      case 'phone':
        return Icons.phone;
      case 'tv':
        return Icons.tv;
      case 'local_gas_station':
        return Icons.local_gas_station;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.8),
                AppTheme.primaryColor.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                category.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
