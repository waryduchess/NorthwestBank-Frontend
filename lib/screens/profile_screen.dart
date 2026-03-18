import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImageUrl;
  bool _uploadingPhoto = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Carga inmediata desde caché local
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('foto_url');
    final cachedName = prefs.getString('user_name');
    if (mounted) {
      setState(() {
        if (cached != null) _profileImageUrl = cached;
        if (cachedName != null) _userName = cachedName;
      });
    }

    // Refresca desde la API para tener los datos más actualizados
    final result = await ApiService.getProfile();
    if (result['success'] == true && mounted) {
      final data = result['data'];
      final nombre = data['nombre'] ?? '';
      final apellidoPaterno = data['apellido_paterno'] ?? '';
      final apellidoMaterno = data['apellido_materno'] ?? '';
      final fullName = '$nombre $apellidoPaterno $apellidoMaterno'.trim();
      setState(() {
        _profileImageUrl = data['foto_url'];
        _userName = fullName;
        _userEmail = data['email'] ?? '';
        _userPhone = data['telefono'] ?? '';
      });
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    Navigator.pop(context); // Cierra el bottom sheet

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);

    final result = await ApiService.uploadProfilePhoto(File(picked.path));

    if (!mounted) return;
    setState(() => _uploadingPhoto = false);

    if (result['success'] == true) {
      setState(() => _profileImageUrl = result['foto_url']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto actualizada correctamente'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al subir la foto'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Foto de perfil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _pickAndUploadImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Seleccionar imagen'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pickAndUploadImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Tomar foto'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar con botón de editar
            Stack(
              alignment: Alignment.center,
              children: [
                _uploadingPhoto
                    ? const SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryColor,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null
                            ? Text(
                                _userName.isNotEmpty
                                    ? _userName.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
           ////////////////////
            const SizedBox(height: 4),
            Text(
              _userName.isNotEmpty ? _userName : '—',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              _userEmail.isNotEmpty ? _userEmail : '—',
              style: const TextStyle(color: AppTheme.textSecondary),
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
                        builder: (context) => _PersonalDataDialog(
                          userName: _userName,
                          userEmail: _userEmail,
                          userPhone: _userPhone,
                        ),
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
  final String userName;
  final String userEmail;
  final String userPhone;

  const _PersonalDataDialog({
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<_PersonalDataDialog> createState() => _PersonalDataDialogState();
}

class _PersonalDataDialogState extends State<_PersonalDataDialog> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userEmail);
    _phoneController = TextEditingController(text: widget.userPhone);
  }

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
              child: Text(
                widget.userName.isNotEmpty ? widget.userName : '—',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
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
