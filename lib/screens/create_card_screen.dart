import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({super.key});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tipoCuentaController = TextEditingController();
  final _numeroCuentaController = TextEditingController();
  final _nipController = TextEditingController();
  final _cvcController = TextEditingController();
  final _fechaVencimientoController = TextEditingController();
  final _monedaController = TextEditingController(text: 'USD');

  @override
  void dispose() {
    _tipoCuentaController.dispose();
    _numeroCuentaController.dispose();
    _nipController.dispose();
    _cvcController.dispose();
    _fechaVencimientoController.dispose();
    _monedaController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Aquí iría la lógica para enviar al backend
      // Por ahora, solo mostramos un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarjeta solicitada exitosamente. Pendiente de aprobación.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar nueva tarjeta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete los datos para solicitar su nueva tarjeta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Tipo de cuenta
              TextFormField(
                controller: _tipoCuentaController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Cuenta',
                  hintText: 'Ej: Débito, Crédito',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el tipo de cuenta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Número de cuenta
              TextFormField(
                controller: _numeroCuentaController,
                decoration: const InputDecoration(
                  labelText: 'Número de Cuenta',
                  hintText: 'Ej: 1234 5678 9012 3456',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el número de cuenta';
                  }
                  if (value.length < 16) {
                    return 'El número debe tener al menos 16 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // NIP
              TextFormField(
                controller: _nipController,
                decoration: const InputDecoration(
                  labelText: 'NIP',
                  hintText: '4 dígitos',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el NIP';
                  }
                  if (value.length != 4) {
                    return 'El NIP debe tener 4 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CVC
              TextFormField(
                controller: _cvcController,
                decoration: const InputDecoration(
                  labelText: 'CVC',
                  hintText: '3 dígitos',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el CVC';
                  }
                  if (value.length != 3) {
                    return 'El CVC debe tener 3 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fecha de vencimiento
              TextFormField(
                controller: _fechaVencimientoController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de Vencimiento',
                  hintText: 'MM/YY',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la fecha de vencimiento';
                  }
                  // Validación básica de formato MM/YY
                  final regex = RegExp(r'^\d{2}/\d{2}$');
                  if (!regex.hasMatch(value)) {
                    return 'Formato inválido. Use MM/YY';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Moneda
              TextFormField(
                controller: _monedaController,
                decoration: const InputDecoration(
                  labelText: 'Moneda',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la moneda';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón de enviar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Solicitar Tarjeta',
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