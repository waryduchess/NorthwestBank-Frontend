import 'package:flutter/material.dart';
import '../models/faq_model.dart';
import '../services/faq_service.dart';
import '../theme/app_theme.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FaqModel> _faqs = [];
  List<FaqModel> _filteredFaqs = [];
  List<String> _categorias = [];
  String? _selectedCategoria;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
    _searchController.addListener(_filterFaqs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFaqs() async {
    final faqs = await FaqService.getFaqs();
    final categorias = await FaqService.getCategorias();

    if (mounted) {
      setState(() {
        _faqs = faqs;
        _filteredFaqs = faqs;
        _categorias = categorias;
        _isLoading = false;
      });
    }
  }

  void _filterFaqs() async {
    final query = _searchController.text;
    List<FaqModel> filtered;

    if (query.isEmpty && _selectedCategoria == null) {
      filtered = _faqs;
    } else if (_selectedCategoria != null) {
      filtered = await FaqService.getFaqsByCategoria(_selectedCategoria!);
      if (query.isNotEmpty) {
        filtered = filtered
            .where((faq) =>
                faq.pregunta.toLowerCase().contains(query.toLowerCase()) ||
                faq.respuesta.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    } else {
      filtered = await FaqService.searchFaqs(query);
    }

    if (mounted) {
      setState(() {
        _filteredFaqs = filtered;
      });
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedCategoria = null;
      _filteredFaqs = _faqs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas Frecuentes'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SearchBar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Busca una pregunta...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                _filterFaqs();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categorías (Chips)
                  if (_categorias.isNotEmpty) ...[
                    Row(
                      children: [
                        const Text(
                          'Categorías:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_selectedCategoria != null)
                          TextButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Limpiar'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categorias.map((cat) {
                        final isSelected = _selectedCategoria == cat;
                        return FilterChip(
                          label: Text(
                            _capitalizarCategoria(cat),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoria = selected ? cat : null;
                            });
                            _filterFaqs();
                          },
                          backgroundColor: Colors.transparent,
                          selectedColor: AppTheme.primaryColor,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // FAQs List
                  if (_filteredFaqs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron preguntas',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        children: List.generate(
                          _filteredFaqs.length,
                          (index) {
                            final faq = _filteredFaqs[index];
                            return Column(
                              children: [
                                ExpansionTile(
                                  title: Text(
                                    faq.pregunta,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _capitalizarCategoria(faq.categoria),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  leading: Icon(
                                    _getIconForCategoria(faq.categoria),
                                    color: AppTheme.primaryColor,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Divider(),
                                          const SizedBox(height: 8),
                                          Text(
                                            faq.respuesta,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.textSecondary,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (index < _filteredFaqs.length - 1)
                                  const Divider(height: 1),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  IconData _getIconForCategoria(String categoria) {
    switch (categoria) {
      case 'transacciones':
        return Icons.swap_horiz;
      case 'seguridad':
        return Icons.security;
      case 'tarjetas':
        return Icons.credit_card;
      case 'general':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _capitalizarCategoria(String cat) {
    return cat[0].toUpperCase() + cat.substring(1);
  }
}
