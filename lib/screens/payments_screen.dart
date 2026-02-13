import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago de servicios')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona un servicio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: const [
                _ServiceCard(icon: Icons.bolt, label: 'Electricidad'),
                _ServiceCard(icon: Icons.water_drop, label: 'Agua'),
                _ServiceCard(icon: Icons.phone_android, label: 'Telefono'),
                _ServiceCard(icon: Icons.wifi, label: 'Internet'),
                _ServiceCard(icon: Icons.tv, label: 'Cable TV'),
                _ServiceCard(icon: Icons.local_gas_station, label: 'Gas'),
              ],
            ),

            const SizedBox(height: 32),

            // Formulario de pago
            const Text(
              'Datos del pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Numero de referencia',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
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
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Monto a pagar',
                prefixIcon: Icon(Icons.attach_money),
                hintText: '0.00',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.payment),
                label: const Text(
                  'Pagar servicio',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
