import 'package:flutter/material.dart';
import '../models/payment_category_model.dart';
import '../models/payment_subcategory_model.dart';
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
  String _selectedAccount = 'ahorro';

  @override
  void initState() {
    super.initState();
    _loadCategories();
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

  void _processPay() {
    if (_montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un monto válido'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pago procesado correctamente'),
        backgroundColor: AppTheme.accentColor,
      ),
    );

    _goBack();
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

  /// Grid de categorías principales
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

  /// Flujo de pago: Subcategorías + Formulario
  Widget _buildPaymentFlow() {
    final category = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => PaymentCategoryModel(
        id: '',
        nombre: '',
        icono: '',
        orden: 0,
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subcategorías (si está seleccionada una categoría)
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

          // Formulario de pago (si está seleccionada una subcategoría)
          if (_selectedSubcategoryId != null) ...[
            const SizedBox(height: 24),
            Text(
              'Información del pago',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Número de referencia
            TextField(
              controller: _referenciaController,
              decoration: const InputDecoration(
                labelText: 'Número de referencia',
                hintText: 'Ej: número de medidor, cuenta',
                prefixIcon: Icon(Icons.tag_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Cuenta a debitar
            DropdownButtonFormField<String>(
              value: _selectedAccount,
              decoration: const InputDecoration(
                labelText: 'Cuenta a debitar',
                prefixIcon: Icon(Icons.account_balance),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'ahorro',
                  child: Text('Ahorro **** 4521 - \$12,450.75'),
                ),
                DropdownMenuItem(
                  value: 'corriente',
                  child: Text('Corriente **** 7833 - \$3,200.00'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAccount = value);
                }
              },
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 32),

            // Botón pagar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _processPay,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Pagar servicio', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para tarjeta de categoría
class _CategoryCard extends StatelessWidget {
  final PaymentCategoryModel category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

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
              Icon(
                _icon,
                size: 40,
                color: Colors.white,
              ),
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
