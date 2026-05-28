import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Displays a coin price that smoothly rolls to the new value and briefly
/// flashes a green (up) or red (down) background whenever the price changes.
///
/// Animation type: **explicit** — [AnimationController] + [Tween<double>].
/// The same controller drives two animations in parallel:
///   • [_priceAnim]  — rolls the numeric value from old to new (easeOut)
///   • [_flashAnim]  — fades a color highlight in then out (TweenSequence)
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

  // Tween<double>: rolls the numeric price value from old → new.
  late Animation<double> _priceAnim;

  // Opacity (0.0 – 0.18) for the background color flash.
  late Animation<double> _flashAnim;

  Color _flashColor = AppColors.positive;

  @override
  void initState() {
    super.initState();
    // Static initial state — no animation until the first price change.
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

    // Roll the price from the previous value to the new value.
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

  /// Builds a [TweenSequence] that rises to peak opacity then fades out:
  ///   0 %  → 25 % : 0.0 → 0.18  (flash in)
  ///  25 % → 100 % : 0.18 → 0.0  (fade out)
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
