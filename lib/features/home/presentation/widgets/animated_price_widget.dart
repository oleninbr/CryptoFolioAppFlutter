import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class AnimatedPriceWidget extends StatefulWidget {
  const AnimatedPriceWidget({
    super.key,
    required this.price,
    required this.currency,
    this.style,
  });

  final double price;
  final String currency;
  final TextStyle? style;

  @override
  State<AnimatedPriceWidget> createState() => _AnimatedPriceWidgetState();
}

class _AnimatedPriceWidgetState extends State<AnimatedPriceWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  late Animation<double> _priceAnim;

  late Animation<double> _flashAnim;

  Color _flashColor = AppColors.positive;

  @override
  void initState() {
    super.initState();

    _priceAnim = Tween<double>(
      begin: widget.price,
      end: widget.price,
    ).animate(_controller);
    _flashAnim = _buildFlashTween().animate(_controller);
  }

  @override
  void didUpdateWidget(AnimatedPriceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.price == widget.price) return;

    _flashColor = widget.price > oldWidget.price
        ? AppColors.positive
        : AppColors.negative;

    _priceAnim = Tween<double>(
      begin: oldWidget.price,
      end: widget.price,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _flashAnim = _buildFlashTween().animate(_controller);

    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TweenSequence<double> _buildFlashTween() {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.18),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.18, end: 0.0),
        weight: 75,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(
            color: _flashColor.withValues(alpha: _flashAnim.value),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            CurrencyFormatter.formatPrice(_priceAnim.value, widget.currency),
            style: widget.style,
          ),
        );
      },
    );
  }
}
