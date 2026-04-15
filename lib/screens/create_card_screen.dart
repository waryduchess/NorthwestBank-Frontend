import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Tipos de tarjeta débito disponibles según el backend.
/// IDs y prefijos definidos en tarjetas.md.
class _CardTypeOption {
  final int id;
  final String nombre;
  final String prefijo;

  const _CardTypeOption({
    required this.id,
    required this.nombre,
    required this.prefijo,
  });
}

const _debitTypes = [
  _CardTypeOption(id: 1, nombre: 'Nexus', prefijo: '4040'),
  _CardTypeOption(id: 2, nombre: 'Vertex', prefijo: '4050'),
];

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({super.key});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroTarjetaController = TextEditingController();
  final _nipController = TextEditingController();
  final _cvvController = TextEditingController();
  final _fechaVencimientoController = TextEditingController();

  _CardTypeOption _selectedType = _debitTypes.first;
  bool _detectedDebito = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _numeroTarjetaController.addListener(_onCardNumberChanged);
  }

  @override
  void dispose() {
    _numeroTarjetaController.removeListener(_onCardNumberChanged);
    _numeroTarjetaController.dispose();
    _nipController.dispose();
    _cvvController.dispose();
    _fechaVencimientoController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged() {
    final number = _numeroTarjetaController.text;
    if (number.length >= 4) {
      final prefix = number.substring(0, 4);
      final isDebito = _debitTypes.any((t) => t.prefijo == prefix);
      // Auto-seleccionar el tipo según el prefijo ingresado
      final matched = _debitTypes.where((t) => t.prefijo == prefix).firstOrNull;
      setState(() {
        _detectedDebito = isDebito;
        if (matched != null) _selectedType = matched;
      });
    } else if (_detectedDebito) {
      setState(() => _detectedDebito = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final result = await ApiService.registerCard(
      tipoTarjetaId: _selectedType.id,
      numeroTarjeta: _numeroTarjetaController.text,
      cvv: _cvvController.text,
      fechaExpiracion: _fechaVencimientoController.text,
      nip: _nipController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarjeta agregada exitosamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Error al agregar tarjeta')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Tarjeta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa los datos de tu tarjeta de débito',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Tipo de tarjeta débito (Nexus / Vertex)
              DropdownButtonFormField<_CardTypeOption>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de tarjeta débito',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                items: _debitTypes.map((type) {
                  return DropdownMenuItem<_CardTypeOption>(
                    value: type,
                    child: Text('${type.nombre}  —  prefijo ${type.prefijo}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              const SizedBox(height: 16),

              // Número de tarjeta (16 dígitos)
              TextFormField(
                controller: _numeroTarjetaController,
                decoration: InputDecoration(
                  labelText: 'Número de tarjeta',
                  hintText: 'Debe iniciar con ${_selectedType.prefijo}',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.credit_card_outlined),
                  suffixIcon: _detectedDebito
                      ? Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedType.nombre.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa el número de tarjeta';
                  }
                  if (value.length != 16) {
                    return 'Debe tener exactamente 16 dígitos';
                  }
                  final prefix = value.substring(0, 4);
                  final validPrefixes =
                      _debitTypes.map((t) => t.prefijo).toList();
                  if (!validPrefixes.contains(prefix)) {
                    return 'La tarjeta debe iniciar con 4040 (Nexus) o 4050 (Vertex)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fecha de vencimiento MM/YY
              TextFormField(
                controller: _fechaVencimientoController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de vencimiento',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  _ExpirationDateFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa la fecha de vencimiento';
                  }
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                    return 'Formato inválido. Usa MM/YY';
                  }
                  final month = int.tryParse(value.split('/')[0]) ?? 0;
                  if (month < 1 || month > 12) {
                    return 'Mes inválido (01–12)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CVV (3 dígitos)
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '3 dígitos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa el CVV';
                  if (value.length != 3) return 'El CVV debe tener 3 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // NIP (4 dígitos)
              TextFormField(
                controller: _nipController,
                decoration: const InputDecoration(
                  labelText: 'NIP',
                  hintText: '4 dígitos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pin),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa el NIP';
                  if (value.length != 4) return 'El NIP debe tener 4 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón Agregar Tarjeta
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor:
                        AppTheme.primaryColor.withOpacity(0.6),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Agregar Tarjeta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inserta automáticamente el "/" después de 2 dígitos para el formato MM/YY
class _ExpirationDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text;
    if (digits.length <= 2) return newValue;
    final formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
