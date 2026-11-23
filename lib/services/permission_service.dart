import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestPermission(
    BuildContext context,
    Permission permission,
    String namaFitur,
  ) async {
    final status = await permission.request();

    if (!context.mounted) return;

    if (status.isGranted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Izin $namaFitur diberikan')));
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Izin $namaFitur diblokir. Aktifkan melalui Settings.'),
        ),
      );

      await openAppSettings();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Izin $namaFitur ditolak')));
    }
  }
}
