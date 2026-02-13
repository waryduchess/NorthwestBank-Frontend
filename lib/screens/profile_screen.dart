import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar y nombre
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                'EG',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Erik Garcia',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const Text(
              'erik.garcia@email.com',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            // Opciones
            Card(
              child: Column(
                children: [
                  _ProfileOption(
                    icon: Icons.person_outline,
                    title: 'Datos personales',
                    subtitle: 'Nombre, email, telefono',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _ProfileOption(
                    icon: Icons.lock_outline,
                    title: 'Seguridad',
                    subtitle: 'Contrasena, PIN, 2FA',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _ProfileOption(
                    icon: Icons.fingerprint,
                    title: 'Biometria',
                    subtitle: 'Huella dactilar / Face ID',
                    trailing: Switch(value: true, onChanged: (_) {}),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _ProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    subtitle: 'Alertas push y email',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _ProfileOption(
                    icon: Icons.help_outline,
                    title: 'Ayuda y soporte',
                    subtitle: 'Preguntas frecuentes',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _ProfileOption(
                    icon: Icons.info_outline,
                    title: 'Acerca de',
                    subtitle: 'Version 1.0.0',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                label: const Text(
                  'Cerrar sesion',
                  style: TextStyle(color: AppTheme.errorColor, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
