import 'package:flutter/material.dart';
import '../core/api_config.dart';
import '../core/utils.dart';
import '../data/models/product.dart';
import 'app_network_image.dart';

class ProductCard extends StatelessWidget {
  final Product p;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: AppNetworkImage(url: ApiConfig.img(p.foto), radius: 0),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.nama, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${rupiah(p.priceFor(1))}/kg', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                if (p.stok <= 25)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(p.stok < 1 ? 'Habis' : 'Stok ${kg(p.stok)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFA32D2D))),
                  ),
              ]),
            ),
          ]),
        ),
      );
}
