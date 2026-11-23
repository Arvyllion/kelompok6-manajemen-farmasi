import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String namaBarang;
  const DetailPage({super.key, required this.namaBarang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
            Text('Barangnya adalah : $namaBarang'),
          ],
        ),
      ),
    );
  }
}
