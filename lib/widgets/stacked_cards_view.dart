import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../theme/app_theme.dart';

class StackedCardsView extends StatefulWidget {
  final List<CardModel> cards;
  final Function(CardModel) onCardTap;
  final VoidCallback? onRequestCard;

  const StackedCardsView({
    super.key,
    required this.cards,
    required this.onCardTap,
    this.onRequestCard,
  });

  @override
  State<StackedCardsView> createState() => _StackedCardsViewState();
}

class _StackedCardsViewState extends State<StackedCardsView> {
  int _selectedCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.credit_card,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes tarjetas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: widget.onRequestCard,
              child: const Text('Solicitar tarjeta'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Tarjeta principal (apilada)
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(
              widget.cards.length,
              (index) {
                final isVisible = index <= _selectedCardIndex;
                final offsetY = (index - _selectedCardIndex) * 8.0;
                final scale = 1.0 - ((index - _selectedCardIndex) * 0.02);

                return isVisible
                    ? Transform.translate(
                        offset: Offset(0, offsetY),
                        child: Transform.scale(
                          scale: scale,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCardIndex = index;
                              });
                              widget.onCardTap(widget.cards[index]);
                            },
                            child: _buildCardWidget(widget.cards[index]),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Indicador de tarjeta activa y opción de solicitar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedCardIndex + 1}/${widget.cards.length}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            ElevatedButton.icon(
              onPressed: widget.onRequestCard,
              icon: const Icon(Icons.add),
              label: const Text('Solicitar tarjeta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardWidget(CardModel card) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(card.imagenTarjeta),
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
              card.tipoCuenta,
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
                  card.numeroCuenta,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${card.saldo.toStringAsFixed(2)} ${card.moneda}',
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
}
