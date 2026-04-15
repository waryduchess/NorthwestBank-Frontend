import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificaciones();
  }

  Future<void> _loadNotificaciones() async {
    setState(() => _isLoading = true);
    final data = await NotificationService.getNotifications();
    if (mounted) {
      setState(() {
        _notificaciones = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _marcarLeida(NotificationModel notif) async {
    if (notif.leida) return;
    await NotificationService.markAsRead(notif.id);
    if (mounted) {
      setState(() {
        final index = _notificaciones.indexWhere((n) => n.id == notif.id);
        if (index != -1) {
          _notificaciones[index] = notif.copyWith(leida: true);
        }
      });
    }
  }

  Future<void> _marcarTodasLeidas() async {
    await NotificationService.markAllAsRead();
    if (mounted) {
      setState(() {
        _notificaciones = _notificaciones
            .map((n) => n.copyWith(leida: true))
            .toList();
      });
    }
  }

  int get _noLeidas => _notificaciones.where((n) => !n.leida).length;

  String _tiempoRelativo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          if (_noLeidas > 0)
            TextButton(
              onPressed: _marcarTodasLeidas,
              child: const Text(
                'Leer todas',
                style: TextStyle(color: AppTheme.accentColor),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notificaciones.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: AppTheme.textSecondary),
                      SizedBox(height: 12),
                      Text('Sin notificaciones', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotificaciones,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notificaciones.length,
                    itemBuilder: (context, index) {
                      final notif = _notificaciones[index];
                      return _NotificationTile(
                        notif: notif,
                        tiempoRelativo: _tiempoRelativo(notif.fecha),
                        onTap: () => _marcarLeida(notif),
                      );
                    },
                  ),
                ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notif;
  final String tiempoRelativo;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notif,
    required this.tiempoRelativo,
    required this.onTap,
  });

  IconData get _icono {
    if (notif.titulo.toLowerCase().contains('transferen')) return Icons.swap_horiz;
    if (notif.titulo.toLowerCase().contains('recib')) return Icons.arrow_downward;
    if (notif.titulo.toLowerCase().contains('deposit')) return Icons.arrow_downward;
    if (notif.titulo.toLowerCase().contains('compra') || notif.titulo.toLowerCase().contains('cobro')) return Icons.shopping_cart_outlined;
    if (notif.titulo.toLowerCase().contains('seguridad')) return Icons.shield_outlined;
    return Icons.notifications_outlined;
  }

  Color get _iconoColor {
    if (notif.titulo.toLowerCase().contains('recib') || notif.titulo.toLowerCase().contains('deposit')) {
      return AppTheme.accentColor;
    }
    if (notif.titulo.toLowerCase().contains('seguridad')) return AppTheme.errorColor;
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: notif.leida ? Colors.white : AppTheme.primaryColor.withValues(alpha: 0.04),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _iconoColor.withValues(alpha: 0.15),
            child: Icon(_icono, color: _iconoColor, size: 22),
          ),
          title: Text(
            notif.titulo,
            style: TextStyle(
              fontWeight: notif.leida ? FontWeight.normal : FontWeight.w600,
              fontSize: 15,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notif.mensaje, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                tiempoRelativo,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          isThreeLine: true,
          trailing: notif.leida
              ? null
              : Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}
