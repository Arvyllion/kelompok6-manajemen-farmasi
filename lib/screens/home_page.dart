import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kelompok6_manajemen_farmasi/screens/detail_page.dart';
import 'package:kelompok6_manajemen_farmasi/services/permission_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Akses Kamera'),
            onTap: () {
              PermissionService.requestPermission(
                context,
                Permission.camera,
                'Kamera',
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('Akses Mikrofon'),
            onTap: () {
              PermissionService.requestPermission(
                context,
                Permission.microphone,
                'Mikrofon',
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.contacts),
            title: const Text('Akses Kontak'),
            onTap: () {
              PermissionService.requestPermission(
                context,
                Permission.contacts,
                'Kontak',
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Akses Galeri'),
            onTap: () {
              PermissionService.requestPermission(
                context,
                Permission.photos,
                'Galeri',
              );
            },
          ),

          const Divider(),

          ListTile(
            title: const Text('Lihat Detail'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const DetailPage(namaBarang: 'Sepatu');
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
