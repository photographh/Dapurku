import 'package:flutter/material.dart';

/// Untuk foto yang datang dari server (foto produk, bukti transfer, avatar).
/// Contoh: AppNetworkImage(url: '$baseUrl/uploads/${product.foto}')
/// Kalau url kosong atau gagal dimuat, tampil kotak cadangan.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final double radius;
  final IconData fallbackIcon;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 12,
    this.fallbackIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(fallbackIcon,
          color: Theme.of(context).colorScheme.onPrimaryContainer),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: (url == null || url!.isEmpty)
          ? box
          : Image.network(
              url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => box,
              loadingBuilder: (c, child, p) => p == null ? child : box,
            ),
    );
  }
}
