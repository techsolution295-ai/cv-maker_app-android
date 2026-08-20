import 'package:flutter/material.dart';

class FavoriteHeartIcon extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;
  final Color? inactiveColor;
  final Color activeColor;
  final bool animated;

  const FavoriteHeartIcon({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 22,
    this.inactiveColor,
    this.activeColor = const Color(0xFFE11D48),
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!animated) {
      return _HeartButton(
        isFavorite: isFavorite,
        onTap: onTap,
        size: size,
        color: _color(context),
      );
    }
    return _AnimatedHeartButton(
      isFavorite: isFavorite,
      onTap: onTap,
      size: size,
      color: _color(context),
      activeColor: activeColor,
    );
  }

  Color _color(BuildContext context) {
    if (isFavorite) return activeColor;
    return inactiveColor ??
        IconTheme.of(context).color ??
        const Color(0xFF334155);
  }
}

class _HeartButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;
  final Color color;

  const _HeartButton({
    required this.isFavorite,
    required this.onTap,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isFavorite ? 'Remove favorite' : 'Add favorite',
      child: IconButton(
        onPressed: onTap,
        tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        visualDensity: VisualDensity.compact,
        splashRadius: 22,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: size,
          color: color,
          shadows: const [
            Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 1)),
            Shadow(color: Color(0xCCFFFFFF), blurRadius: 6),
          ],
        ),
      ),
    );
  }
}

class _AnimatedHeartButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final Color activeColor;

  const _AnimatedHeartButton({
    required this.isFavorite,
    required this.onTap,
    required this.size,
    required this.color,
    required this.activeColor,
  });

  @override
  State<_AnimatedHeartButton> createState() => _AnimatedHeartButtonState();
}

class _AnimatedHeartButtonState extends State<_AnimatedHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void didUpdateWidget(covariant _AnimatedHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _pop.forward(from: 0).whenComplete(() {
        if (mounted) _pop.reverse();
      });
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.22).animate(
        CurvedAnimation(parent: _pop, curve: Curves.elasticOut),
      ),
      child: _HeartButton(
        isFavorite: widget.isFavorite,
        onTap: widget.onTap,
        size: widget.size,
        color: widget.color,
      ),
    );
  }
}
