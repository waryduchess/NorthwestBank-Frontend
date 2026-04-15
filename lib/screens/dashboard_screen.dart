import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/card_model.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/card_service.dart';
import '../services/notification_service.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/transaction_tile.dart';
import 'card_detail_screen.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<CardModel>> _cardsFuture;
  String _userName = '';
  int _noLeidas = 0;
  Timer? _notifTimer;
  List<Transaction> _ultimosMovimientos = [];
  bool _isLoadingMovimientos = false;

  @override
  void initState() {
    super.initState();
    _cardsFuture = CardService.getUserCards();
    _loadUserName();
    _loadUltimosMovimientos();
    _checkNotificaciones();
    _notifTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkNotificaciones(),
    );
  }

  @override
  void dispose() {
    _notifTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkNotificaciones() async {
    final notifs = await NotificationService.getNotifications();
    if (mounted) {
      setState(() {
        _noLeidas = notifs.where((n) => !n.leida).length;
      });
    }
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
    });
  }

  Future<void> _loadUltimosMovimientos() async {
    setState(() => _isLoadingMovimientos = true);
    final data = await ApiService.getTransactions();
    if (mounted) {
      final todas = data.map((t) => Transaction.fromBackend(t)).toList();
      todas.sort((a, b) => b.fecha.compareTo(a.fecha));
      setState(() {
        _ultimosMovimientos = todas.take(5).toList();
        _isLoadingMovimientos = false;
      });
    }
  }

  String _formatFecha(DateTime fecha) {
    const meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return '${fecha.day} ${meses[fecha.month - 1]} · ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  void _openCardDetail(BuildContext context, CardModel card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardDetailScreen(card: card),
      ),
    );
  }

  void _openRequestCardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solicitar tarjeta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona el tipo de tarjeta que deseas solicitar:',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            _buildRequestOption(
              context,
              'Tarjeta de Credito',
              'Limites de credito flexibles',
              Icons.credit_card,
            ),
            const SizedBox(height: 12),
            _buildRequestOption(
              context,
              'Tarjeta Platinum',
              'Beneficios exclusivos y recompensas',
              Icons.star,
            ),
            const SizedBox(height: 12),
            _buildRequestOption(
              context,
              'Tarjeta Debit Plus',
              'Mayor seguridad y proteccion',
              Icons.security,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestOption(
    BuildContext context,
    String titulo,
    String descripcion,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(descripcion),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Solicitud enviada. El backend la procesara pronto'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCuentasButton(BuildContext context, List<CardModel> cards) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/cards-gallery');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Cuentas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NorthwestBank'),
        actions: [
          IconButton(
            icon: _noLeidas > 0
                ? Badge(
                    label: Text('$_noLeidas'),
                    child: const Icon(Icons.notifications_outlined),
                  )
                : const Icon(Icons.notifications_outlined),
            onPressed: () async {
              await Navigator.pushNamed(context, '/notifications');
              _checkNotificaciones();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CardModel>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Error al cargar tarjetas'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _cardsFuture = CardService.getUserCards();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final cards = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $_userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Tarjetas de dinero (originales)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cuenta de Ahorro',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '\$12,450.75 USD',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cuenta Corriente',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '\$3,200.00 USD',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Título de tarjetas
                const Text(
                  'Mis tarjetas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Botón Cuentas
                _buildCuentasButton(context, cards),

                const SizedBox(height: 24),

                // Acciones rapidas
                const Text(
                  'Acciones rapidas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    QuickActionButton(
                      icon: Icons.swap_horiz,
                      label: 'Transferir',
                      onTap: () => Navigator.pushNamed(context, '/transfers')
                          .then((_) => _loadUltimosMovimientos()),
                    ),
                    QuickActionButton(
                      icon: Icons.receipt_long,
                      label: 'Historial',
                      onTap: () => Navigator.pushNamed(context, '/transactions')
                          .then((_) => _loadUltimosMovimientos()),
                    ),
                    QuickActionButton(
                      icon: Icons.payment,
                      label: 'Pagos',
                      onTap: () => Navigator.pushNamed(context, '/payments')
                          .then((_) => _loadUltimosMovimientos()),
                    ),
                    QuickActionButton(
                      icon: Icons.person_outline,
                      label: 'Perfil',
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Ultimos movimientos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ultimos movimientos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/transactions')
                          .then((_) => _loadUltimosMovimientos()),
                      child: const Text('Ver todos'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isLoadingMovimientos)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_ultimosMovimientos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Sin movimientos recientes',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  ...(_ultimosMovimientos.map((t) => GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionDetailScreen(transaction: t),
                      ),
                    ),
                    child: TransactionTile(
                      titulo: t.titulo,
                      descripcion: t.descripcion,
                      monto: t.monto,
                      fecha: _formatFecha(t.fecha),
                      icono: t.icono,
                    ),
                  ))),
              ],
            ),
          );
        },
      ),
    );
  }
}
