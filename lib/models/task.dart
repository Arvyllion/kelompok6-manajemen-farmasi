import 'package:cloud_firestore/cloud_firestore.dart';

// Cetakan bentuk data satu tugas.
// File ini cuma dipakai waktu READ, waktu CREATE gak disentuh.
class Task {
  final String id;     // nama dokumen di Firestore, dipakai buat update & delete (P7)
  final String title;  // judul tugas
  final bool isDone;   // true = selesai, false = belum

  // Cara bikin objek Task, ketiga laci wajib diisi
  Task({
    required this.id,
    required this.title,
    required this.isDone,
  });

  // R5. Penerjemah: dokumen mentah Firestore → objek Task
  //     Dipanggil oleh TaskService, satu kali untuk setiap dokumen
  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    // Ambil isi dokumen, kalau kosong pakai Map kosong biar gak crash
    final data = doc.data() ?? {};

    return Task(
      id: doc.id, // ID ada di luar isi dokumen, jadi diambil dari doc.id
      title: data['title'] as String? ?? 'Tanpa Judul', // kalau gak ada, pakai cadangan
      isDone: data['isDone'] as bool? ?? false,          // kalau gak ada, anggap belum selesai
    );
  }
}