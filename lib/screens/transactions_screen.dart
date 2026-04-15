import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import 'transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // Filtros activos
  String? selectedTipo;
  String? selectedMonto;
  DateTimeRange? selectedDateRange;
  double? montoEspecifico;
  String searchQuery = '';
  final TextEditingController _montoEspecificoController = TextEditingController();

  // Controladores
  late TextEditingController searchController;

  // Lista de todas las transacciones
  List<Transaction> allTransactions = [];
  List<Transaction> filteredTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _loadTransactions();
  }

  @override
  void dispose() {
    searchController.dispose();
    _montoEspecificoController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getTransactions();
    if (mounted) {
      final lista = data.map((t) => Transaction.fromBackend(t)).toList();
      lista.sort((a, b) => b.fecha.compareTo(a.fecha));
      setState(() {
        allTransactions = lista;
        filteredTransactions = lista;
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    filteredTransactions = allTransactions.where((transaction) {
      // Filtro por búsqueda
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!transaction.titulo.toLowerCase().contains(query) &&
            !transaction.descripcion.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Filtro por tipo
      if (selectedTipo != null && selectedTipo != 'Todos') {
        if (transaction.tipo != selectedTipo) return false;
      }

      // Filtro por monto
      if (selectedMonto != null) {
        if (selectedMonto == 'Ingresos' && !transaction.isIncome) return false;
        if (selectedMonto == 'Egresos' && !transaction.isExpense) return false;
      }

      // Filtro por rango de fechas (incluye todo el día final)
      if (selectedDateRange != null) {
        final endOfDay = selectedDateRange!.end.copyWith(
          hour: 23, minute: 59, second: 59, millisecond: 999,
        );
        if (transaction.fecha.isBefore(selectedDateRange!.start) ||
            transaction.fecha.isAfter(endOfDay)) {
          return false;
        }
      }

      // Filtro por monto específico
      if (montoEspecifico != null) {
        if (transaction.monto.abs() != montoEspecifico) return false;
      }

      return true;
    }).toList();

    // Ordenar por fecha descendente
    filteredTransactions.sort((a, b) => b.fecha.compareTo(a.fecha));
    setState(() {});
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
      _applyFilters();
    }
  }

  void _showTipoFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por tipo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              onTap: () {
                setState(() => selectedTipo = null);
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              title: const Text('Transferencia'),
              onTap: () {
                setState(() => selectedTipo = 'Transferencia');
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              title: const Text('Deposito'),
              onTap: () {
                setState(() => selectedTipo = 'Deposito');
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              title: const Text('Pago'),
              onTap: () {
                setState(() => selectedTipo = 'Pago');
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              title: const Text('Retiro'),
              onTap: () {
                setState(() => selectedTipo = 'Retiro');
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              title: const Text('Servicio'),
              onTap: () {
                setState(() => selectedTipo = 'Servicio');
                Navigator.pop(context);
                _applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMontoFilter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por monto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              onTap: () {
                setState(() {
                  selectedMonto = null;
                  montoEspecifico = null;
                  _montoEspecificoController.clear();
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              title: const Text('Ingresos'),
              onTap: () {
                setState(() {
                  selectedMonto = 'Ingresos';
                  montoEspecifico = null;
                  _montoEspecificoController.clear();
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            ListTile(
              title: const Text('Egresos'),
              onTap: () {
                setState(() {
                  selectedMonto = 'Egresos';
                  montoEspecifico = null;
                  _montoEspecificoController.clear();
                });
                Navigator.pop(context);
                _applyFilters();
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _montoEspecificoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto exacto',
                  hintText: 'Ej: 150.00',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final valor = double.tryParse(_montoEspecificoController.text.trim());
                setState(() {
                  montoEspecifico = valor;
                  if (valor != null) selectedMonto = null;
                });
                Navigator.pop(context);
                _applyFilters();
              },
              child: const Text('Aplicar monto exacto'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      selectedTipo = null;
      selectedMonto = null;
      selectedDateRange = null;
      montoEspecifico = null;
      searchQuery = '';
      searchController.clear();
      _montoEspecificoController.clear();
    });
    _applyFilters();
  }

  String _getMonthYear(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de movimientos')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/tarjeta_tres.png'),
            opacity: 0.08,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Filtros
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  // Barra de búsqueda
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                      _applyFilters();
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar movimientos...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                setState(() => searchQuery = '');
                                _applyFilters();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _selectDateRange(context),
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: const Text('Fecha'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showTipoFilter(context),
                          icon: const Icon(Icons.filter_list, size: 18),
                          label: const Text('Tipo'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showMontoFilter(context),
                          icon: const Icon(Icons.sort, size: 18),
                          label: const Text('Monto'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (selectedTipo != null ||
                      selectedMonto != null ||
                      selectedDateRange != null ||
                      montoEspecifico != null ||
                      searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Limpiar filtros'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Lista de transacciones agrupadas
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadTransactions,
                      child: filteredTransactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No hay transacciones',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _buildGroupedList().length,
                              itemBuilder: (context, index) {
                                final item = _buildGroupedList()[index];
                                if (item is String) {
                                  return _buildSectionHeader(item);
                                } else {
                                  final transaction = item as Transaction;
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TransactionDetailScreen(
                                            transaction: transaction,
                                          ),
                                        ),
                                      );
                                    },
                                    child: TransactionTile(
                                      titulo: transaction.titulo,
                                      descripcion: transaction.descripcion,
                                      monto: transaction.monto,
                                      fecha: '${transaction.fecha.day} ${_getMonthYear(transaction.fecha)} · ${transaction.fecha.hour.toString().padLeft(2, '0')}:${transaction.fecha.minute.toString().padLeft(2, '0')}',
                                      icono: transaction.icono,
                                    ),
                                  );
                                }
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> _buildGroupedList() {
    final grouped = <String, List<Transaction>>{};

    for (var transaction in filteredTransactions) {
      final key = _getMonthYear(transaction.fecha);
      grouped.putIfAbsent(key, () => []).add(transaction);
    }

    final result = <dynamic>[];
    grouped.forEach((month, transactions) {
      result.add(month);
      result.addAll(transactions);
    });

    return result;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
