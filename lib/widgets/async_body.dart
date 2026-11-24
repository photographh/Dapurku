import 'package:flutter/material.dart';
import '../core/api_client.dart';

/// Tarik-untuk-segarkan + loading + error, dipakai semua layar yang ambil data.
/// [builder] harus mengembalikan widget yang bisa di-scroll (ListView, dll).
class AsyncBody<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;
  final Future<void> Function() onRefresh;

  const AsyncBody({super.key, required this.future, required this.builder, required this.onRefresh});

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: FutureBuilder<T>(
          future: future,
          builder: (c, s) {
            if (s.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (s.hasError) {
              return ListView(children: [
                Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(errMsg(s.error!)))),
              ]);
            }
            return builder(s.data as T);
          },
        ),
      );
}
