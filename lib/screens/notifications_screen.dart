import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _NotificationTile(
            titulo: 'Transferencia exitosa',
            mensaje: 'Se envio \$500.00 a Juan Perez correctamente.',
            fecha: 'Hace 2 horas',
            leida: false,
            icono: Icons.check_circle,
            iconoColor: AppTheme.accentColor,
          ),
          _NotificationTile(
            titulo: 'Deposito recibido',
            mensaje: 'Recibiste \$3,500.00 por concepto de nomina.',
            fecha: 'Hace 3 dias',
            leida: false,
            icono: Icons.arrow_downward,
            iconoColor: AppTheme.secondaryColor,
          ),
          _NotificationTile(
            titulo: 'Pago procesado',
            mensaje: 'Tu pago de electricidad por \$85.50 fue procesado.',
            fecha: 'Hace 5 dias',
            leida: false,
            icono: Icons.payment,
            iconoColor: AppTheme.primaryColor,
          ),
          _NotificationTile(
            titulo: 'Alerta de seguridad',
            mensaje: 'Se inicio sesion desde un nuevo dispositivo.',
            fecha: 'Hace 1 semana',
            leida: true,
            icono: Icons.shield,
            iconoColor: AppTheme.errorColor,
          ),
          _NotificationTile(
            titulo: 'Actualizacion de cuenta',
            mensaje: 'Tus datos de perfil fueron actualizados exitosamente.',
            fecha: 'Hace 2 semanas',
            leida: true,
            icono: Icons.info_outline,
            iconoColor: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String fecha;
  final bool leida;
  final IconData icono;
  final Color iconoColor;

  const _NotificationTile({
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    required this.leida,
    required this.icono,
    required this.iconoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: leida ? Colors.white : AppTheme.primaryColor.withValues(alpha: 0.04),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconoColor.withValues(alpha: 0.15),
          child: Icon(icono, color: iconoColor, size: 22),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: leida ? FontWeight.normal : FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(mensaje, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              fecha,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: leida ? null : Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
