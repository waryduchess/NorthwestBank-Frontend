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
              'Erik hernandez',
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
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const _PersonalDataDialog(),
                      );
                    },
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

class _PersonalDataDialog extends StatefulWidget {
  const _PersonalDataDialog();

  @override
  State<_PersonalDataDialog> createState() => _PersonalDataDialogState();
}

class _PersonalDataDialogState extends State<_PersonalDataDialog> {
  final _emailController = TextEditingController(text: 'erik.garcia@email.com');
  final _phoneController = TextEditingController(text: '+52 123 456 7890');

  bool _isEditingEmail = false;
  bool _isEditingPhone = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Datos Personales', style: TextStyle(color: AppTheme.primaryColor)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre completo',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Text(
                'Erik Hernandez',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Email',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _isEditingEmail
                      ? TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'Ingresa tu email',
                            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.email_outlined, color: Colors.grey[600], size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _emailController.text,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isEditingEmail ? Icons.check : Icons.edit,
                    color: _isEditingEmail ? AppTheme.accentColor : AppTheme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditingEmail = !_isEditingEmail;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Teléfono',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _isEditingPhone
                      ? TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            hintText: 'Ingresa tu teléfono',
                            prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
                          ),
                          keyboardType: TextInputType.phone,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.phone_outlined, color: Colors.grey[600], size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _phoneController.text,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _isEditingPhone ? Icons.check : Icons.edit,
                    color: _isEditingPhone ? AppTheme.accentColor : AppTheme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditingPhone = !_isEditingPhone;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            // Guardar cambios
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Datos actualizados correctamente'),
                backgroundColor: AppTheme.accentColor,
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
