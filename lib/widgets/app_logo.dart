import 'package:flutter/material.dart';
import '../core/app_assets.dart';

enum LogoType { icon, full }

class AppLogo extends StatelessWidget {
  final LogoType type;
  final double size;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.type = LogoType.icon,
    this.size = 64,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final icon = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        AppAssets.logoIcon,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(context),
      ),
    );

    if (type == LogoType.icon) return icon;

    final theme = Theme.of(context);
    final color = textColor ?? theme.colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(width: size * 0.25),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dapurku',
                style: theme.textTheme.headlineSmall?.copyWith(
                    color: color, fontWeight: FontWeight.w800, height: 1.0)),
            Text('Segar & Murah',
                style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFFBA7517),
                    fontWeight: FontWeight.w800,
                    height: 1.0)),
          ],
        ),
      ],
    );
  }

  Widget _fallback(BuildContext context) => Container(
        width: size,
        height: size,
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.center,
        child: Text('W',
            style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.5,
                fontWeight: FontWeight.w700)),
      );
}
