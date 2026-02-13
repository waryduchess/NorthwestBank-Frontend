import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TransfersScreen extends StatelessWidget {
  const TransfersScreen({super.key});

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
                  child: _TransferTypeCard(
                    icon: Icons.account_balance_wallet,
                    label: 'Entre mis cuentas',
                    selected: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TransferTypeCard(
                    icon: Icons.people_outline,
                    label: 'A terceros',
                    selected: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Cuenta origen
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Cuenta origen',
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

            // Cuenta destino
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Cuenta destino / Beneficiario',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'corriente',
                  child: Text('Corriente **** 7833'),
                ),
                DropdownMenuItem(
                  value: 'juan',
                  child: Text('Juan Perez - **** 1234'),
                ),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),

            // Monto
            const TextField(
              decoration: InputDecoration(
                labelText: 'Monto',
                prefixIcon: Icon(Icons.attach_money),
                hintText: '0.00',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),

            // Descripcion
            const TextField(
              decoration: InputDecoration(
                labelText: 'Descripcion (opcional)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Boton transferir
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send),
                label: const Text(
                  'Realizar transferencia',
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
