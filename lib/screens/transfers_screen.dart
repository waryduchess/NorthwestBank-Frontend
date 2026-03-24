import 'package:flutter/material.dart';
import '../models/bank_model.dart';
import '../models/beneficiary_model.dart';
import '../services/transfer_service.dart';
import '../theme/app_theme.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  String _transferType = 'entre_mis_cuentas'; // entre_mis_cuentas | a_terceros

  // Entre mis cuentas
  String _cuentaOrigen = 'ahorro';
  String _cuentaDestino = 'corriente';

  // A terceros
  List<BankModel> _bancos = [];
  List<BeneficiaryModel> _beneficiarios = [];
  String? _selectedBankId;
  String? _selectedBeneficiaryId;
  bool _isLoadingBancos = false;

  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _nombreBeneficiarioController = TextEditingController();
  final TextEditingController _cuentaBeneficiarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBancosAndBeneficiarios();
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _nombreBeneficiarioController.dispose();
    _cuentaBeneficiarioController.dispose();
    super.dispose();
  }

  Future<void> _loadBancosAndBeneficiarios() async {
    setState(() => _isLoadingBancos = true);
    final bancos = await TransferService.getBanks();
    final beneficiarios = await TransferService.getBeneficiaries();
    if (mounted) {
      setState(() {
        _bancos = bancos;
        _beneficiarios = beneficiarios;
        _isLoadingBancos = false;
      });
    }
  }

  void _changeTransferType(String type) {
    setState(() {
      _transferType = type;
      _montoController.clear();
      _descripcionController.clear();
      _selectedBankId = null;
      _selectedBeneficiaryId = null;
    });
  }

  void _showAddBeneficiaryModal() {
    _nombreBeneficiarioController.clear();
    _cuentaBeneficiarioController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agregar beneficiario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nombreBeneficiarioController,
              decoration: const InputDecoration(
                labelText: 'Nombre del beneficiario',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cuentaBeneficiarioController,
              decoration: const InputDecoration(
                labelText: 'Número de cuenta',
                prefixIcon: Icon(Icons.account_balance),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nombreBeneficiarioController.text.isEmpty ||
                      _cuentaBeneficiarioController.text.isEmpty ||
                      _selectedBankId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completa todos los campos'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                    return;
                  }

                  final success = await TransferService.addBeneficiary(
                    nombre: _nombreBeneficiarioController.text,
                    numeroCuenta: _cuentaBeneficiarioController.text,
                    bankId: _selectedBankId!,
                  );

                  if (!mounted) return;

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Beneficiario agregado correctamente'),
                        backgroundColor: AppTheme.accentColor,
                      ),
                    );
                    _loadBancosAndBeneficiarios();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al agregar beneficiario'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                child: const Text('Guardar beneficiario'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _processTransfer() {
    if (_montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un monto válido'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transferencia realizada correctamente'),
        backgroundColor: AppTheme.accentColor,
      ),
    );

    _montoController.clear();
    _descripcionController.clear();
  }

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
                  child: GestureDetector(
                    onTap: () => _changeTransferType('entre_mis_cuentas'),
                    child: _TransferTypeCard(
                      icon: Icons.account_balance_wallet,
                      label: 'Entre mis cuentas',
                      selected: _transferType == 'entre_mis_cuentas',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _changeTransferType('a_terceros'),
                    child: _TransferTypeCard(
                      icon: Icons.people_outline,
                      label: 'A terceros',
                      selected: _transferType == 'a_terceros',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Campos dinámicos según tipo de transferencia
            if (_transferType == 'entre_mis_cuentas')
              _buildEntreMiscuentas()
            else
              _buildAlterceros(),
          ],
        ),
      ),
    );
  }

  Widget _buildEntreMiscuentas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cuenta origen
        DropdownButtonFormField<String>(
          value: _cuentaOrigen,
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
          onChanged: (value) => setState(() => _cuentaOrigen = value!),
        ),
        const SizedBox(height: 16),

        // Cuenta destino
        DropdownButtonFormField<String>(
          value: _cuentaDestino,
          decoration: const InputDecoration(
            labelText: 'Cuenta destino',
            prefixIcon: Icon(Icons.person_outline),
          ),
          items: const [
            DropdownMenuItem(
              value: 'corriente',
              child: Text('Corriente **** 7833'),
            ),
            DropdownMenuItem(
              value: 'ahorro',
              child: Text('Ahorro **** 4521'),
            ),
          ],
          onChanged: (value) => setState(() => _cuentaDestino = value!),
        ),
        const SizedBox(height: 16),

        // Monto
        TextField(
          controller: _montoController,
          decoration: const InputDecoration(
            labelText: 'Monto',
            prefixIcon: Icon(Icons.attach_money),
            hintText: '0.00',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 16),

        // Descripción
        TextField(
          controller: _descripcionController,
          decoration: const InputDecoration(
            labelText: 'Descripción (opcional)',
            prefixIcon: Icon(Icons.notes),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 32),

        // Botón transferir
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _processTransfer,
            icon: const Icon(Icons.send),
            label: const Text(
              'Realizar transferencia',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlterceros() {
    return _isLoadingBancos
        ? const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cuenta origen
              DropdownButtonFormField<String>(
                value: _cuentaOrigen,
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
                onChanged: (value) => setState(() => _cuentaOrigen = value!),
              ),
              const SizedBox(height: 16),

              // Banco destino
              DropdownButtonFormField<String>(
                value: _selectedBankId,
                decoration: const InputDecoration(
                  labelText: 'Banco destino',
                  prefixIcon: Icon(Icons.business),
                ),
                items: _bancos
                    .map((bank) => DropdownMenuItem(
                          value: bank.id,
                          child: Text(bank.nombre),
                        ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedBankId = value;
                  _selectedBeneficiaryId = null;
                }),
              ),
              const SizedBox(height: 16),

              // Beneficiario
              if (_selectedBankId != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedBeneficiaryId,
                        decoration: const InputDecoration(
                          labelText: 'Beneficiario',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: _beneficiarios
                            .where((b) => b.banco.id == _selectedBankId)
                            .map((benef) => DropdownMenuItem(
                                  value: benef.id,
                                  child: Text(benef.nombre),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedBeneficiaryId = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppTheme.primaryColor),
                      onPressed: _showAddBeneficiaryModal,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Monto
              TextField(
                controller: _montoController,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Descripción
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // Botón transferir
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _processTransfer,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'Realizar transferencia',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
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
