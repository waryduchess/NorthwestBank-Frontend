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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _EditContactScreen(
                            userName: _userName,
                            userEmail: _userEmail,
                            userPhone: _userPhone,
                            onSaved: (newEmail, newPhone) {
                              setState(() {
                                _userEmail = newEmail;
                                _userPhone = newPhone;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _ProfileOption(
                    icon: Icons.lock_outline,
                    title: 'Seguridad',
                    subtitle: 'Contraseña',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const _EditPasswordScreen(),
                      ),
                    ),
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
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
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
                    onTap: () => Navigator.pushNamed(context, '/faq'),
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

class _EditContactScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhone;
  final void Function(String email, String phone) onSaved;

  const _EditContactScreen({
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.onSaved,
  });

  @override
  State<_EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<_EditContactScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userEmail);
    _phoneController = TextEditingController(text: widget.userPhone);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final email = _emailController.text.trim();
    final telefono = _phoneController.text.trim();

    if (email.isEmpty || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El email y el teléfono no pueden estar vacíos'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final result = await ApiService.updateProfile(email: email, telefono: telefono);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      widget.onSaved(email, telefono);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados correctamente'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al actualizar'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar contacto')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              const Text(
                'Datos de contacto',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Actualiza tu correo y número de teléfono',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),

              // Nombre (solo lectura)
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: const Icon(Icons.person_rounded),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                controller: TextEditingController(text: widget.userName),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Teléfono
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 32),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _guardarCambios,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Guardar cambios',
                          style: TextStyle(fontSize: 16),
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

// ─── Pantalla: Cambiar contraseña ────────────────────────────────────────────

class _EditPasswordScreen extends StatefulWidget {
  const _EditPasswordScreen();

  @override
  State<_EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<_EditPasswordScreen> {
  final _actualController = TextEditingController();
  final _nuevaController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _obscureActual = true;
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _actualController.dispose();
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cambiarPassword() async {
    final actual = _actualController.text;
    final nueva = _nuevaController.text;
    final confirmar = _confirmarController.text;

    if (actual.isEmpty || nueva.isEmpty || confirmar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los campos son obligatorios'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (nueva != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas nuevas no coinciden'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final result = await ApiService.updatePassword(
      passwordActual: actual,
      passwordNueva: nueva,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada correctamente'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al cambiar la contraseña'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seguridad')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cambiar contraseña',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ingresa tu contraseña actual y define una nueva',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),

              // Contraseña actual
              TextField(
                controller: _actualController,
                obscureText: _obscureActual,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  prefixIcon: const Icon(Icons.lock_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureActual ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureActual = !_obscureActual),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nueva contraseña
              TextField(
                controller: _nuevaController,
                obscureText: _obscureNueva,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_open_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNueva ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureNueva = !_obscureNueva),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirmar nueva contraseña
              TextField(
                controller: _confirmarController,
                obscureText: _obscureConfirmar,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_open_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmar
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirmar = !_obscureConfirmar),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _cambiarPassword,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Cambiar contraseña',
                          style: TextStyle(fontSize: 16),
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
