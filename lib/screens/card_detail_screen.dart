import 'dart:async';
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../services/biometric_service.dart';
import '../theme/app_theme.dart';

class CardDetailScreen extends StatefulWidget {
  final CardModel card;

  const CardDetailScreen({
    super.key,
    required this.card,
  });

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  String activeTab = 'movimientos';
  bool _showSensitiveData = false;
  int _timerSeconds = 0;
  Timer? _countdownTimer;
  final BiometricService _biometricService = BiometricService();

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _revealSensitiveData() async {
    final available = await _biometricService.isAvailable();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autenticación biométrica no disponible')),
      );
      return;
    }

    final authenticated = await _biometricService.authenticate();
    if (!authenticated) return;

    setState(() {
      _showSensitiveData = true;
      _timerSeconds = 30;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timerSeconds--;
      });
      if (_timerSeconds <= 0) {
        timer.cancel();
        setState(() {
          _showSensitiveData = false;
        });
      }
    });
  }
  Widget build(BuildContext context) {
    var isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card.tipoCuenta),
      ),
      body: isMobile
          ? _buildMobileLayout()
          : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Datos del usuario
                _buildUserDataCard(),
                const SizedBox(height: 24),

                // Tarjeta grande
                _buildCardWidget(),
              ],
            ),
          ),

          // TabBar
          _buildTabBar(),

          // Contenido dinámico según la pestaña
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Izquierda: Datos del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos del usuario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildUserDataCard(),
              ],
            ),
          ),

          const SizedBox(width: 32),

          // Derecha: Tarjeta y TabBar
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tarjeta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCardWidget(),
                  const SizedBox(height: 24),

                  // TabBar
                  _buildTabBar(),
                  const SizedBox(height: 16),

                  // Contenido
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWidget() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.card.imagenTarjeta),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.card.tipoCuenta,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.card.numeroCuenta,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '\$${widget.card.saldo.toStringAsFixed(2)} ${widget.card.moneda}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDataCard() {
    final inicial = (widget.card.nombreUsuario?.isNotEmpty ?? false)
        ? widget.card.nombreUsuario![0].toUpperCase()
        : 'U';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header con gradiente
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.card.nombreUsuario ?? '',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.card.tipoCuenta,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: widget.card.activa
                              ? AppTheme.accentColor
                              : Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.card.activa ? 'Activa' : 'Inactiva',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Saldo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo disponible',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${widget.card.saldo.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        widget.card.moneda,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton('Movimientos', 'movimientos'),
          _buildTabButton('Información', 'informacion'),
          _buildTabButton('Estado de cuenta', 'estado'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String tabValue) {
    final isActive = activeTab == tabValue;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            activeTab = tabValue;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppTheme.primaryColor : Colors.transparent,
                width: isActive ? 3 : 0,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (activeTab) {
      case 'movimientos':
        return _buildMovimientosTab();
      case 'informacion':
        return _buildInformacionTab();
      case 'estado':
        return _buildEstadoTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMovimientosTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Últimos movimientos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildMovimiento(
          'Transferencia enviada',
          'A Juan Pérez',
          -500.00,
          '12 Feb 2026',
          Icons.arrow_upward,
        ),
        const SizedBox(height: 12),
        _buildMovimiento(
          'Depósito recibido',
          'Nómina mensual',
          3500.00,
          '10 Feb 2026',
          Icons.arrow_downward,
        ),
        const SizedBox(height: 12),
        _buildMovimiento(
          'Pago de servicio',
          'Electricidad',
          -85.50,
          '8 Feb 2026',
          Icons.bolt,
        ),
        const SizedBox(height: 12),
        _buildMovimiento(
          'Compra en línea',
          'Amazon',
          -120.00,
          '5 Feb 2026',
          Icons.shopping_bag,
        ),
      ],
    );
  }

  Widget _buildMovimiento(
    String titulo,
    String descripcion,
    double monto,
    String fecha,
    IconData icono,
  ) {
    final isPositive = monto > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fecha,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : '-'}\$${monto.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardDetailsCard(),
      ],
    );
  }

  Widget _buildCardDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles de la Tarjeta',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildSensitiveRow(
              'Número de Tarjeta',
              _showSensitiveData
                  ? (widget.card.numeroTarjetaRaw ?? widget.card.numeroCuenta)
                  : widget.card.numeroCuenta,
            ),
            if (widget.card.numeroCuentaBancaria != null) ...[
              const Divider(),
              _buildDetailRow('Número de Cuenta', widget.card.numeroCuentaBancaria!),
            ],
            const Divider(),
            _buildDetailRow('Titular', widget.card.nombreTitular ?? 'N/A'),
            if (widget.card.fechaVencimiento != null) ...[
              const Divider(),
              _buildDetailRow('Fecha de Vencimiento', widget.card.fechaVencimiento!),
            ],
            const Divider(),
            _buildSensitiveRow('CVV', _showSensitiveData ? (widget.card.cvv ?? '***') : '***'),
            const Divider(),
            _buildSensitiveRow('NIP', _showSensitiveData ? (widget.card.nip ?? '****') : '****'),
            const Divider(),
            _buildDetailRow('Moneda', widget.card.moneda),
            const Divider(),
            _buildDetailRow('Estado', widget.card.activa ? 'Activa' : 'Inactiva'),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoTab() {
    final card = widget.card;
    final esCredito = card.categoria == 'credito';
    final porcentaje = esCredito && card.limiteCredito != null && card.limiteCredito! > 0
        ? (card.saldo / card.limiteCredito! * 100).clamp(0.0, 100.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado de cuenta',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      esCredito ? 'Deuda acumulada' : 'Saldo disponible',
                      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                    Text(
                      '\$${card.saldo.toStringAsFixed(2)} MXN',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
                if (esCredito) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Crédito disponible', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                      Text(
                        card.creditoDisponible != null
                            ? '\$${card.creditoDisponible!.toStringAsFixed(2)} MXN'
                            : 'Sin límite',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Límite de crédito', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                      Text(
                        card.limiteCredito != null
                            ? '\$${card.limiteCredito!.toStringAsFixed(2)} MXN'
                            : 'Sin límite',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  if (card.limiteCredito != null) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Porcentaje utilizado', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                        Text(
                          '${porcentaje.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: porcentaje > 80 ? Colors.red : porcentaje > 50 ? Colors.orange : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitiveRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              if (!_showSensitiveData)
                IconButton(
                  icon: const Icon(Icons.fingerprint, size: 22, color: AppTheme.primaryColor),
                  tooltip: 'Autenticar con huella',
                  onPressed: _revealSensitiveData,
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$_timerSeconds s',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _timerSeconds <= 10 ? Colors.red : Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
