import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kelompok6_manajemen_farmasi/models/task.dart';

// Kurir yang bolak-balik antara halaman dan Firestore.
// Halaman gak pernah ngobrol langsung sama Firestore, semua lewat sini.
class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;   // pintu ke database
  final FirebaseAuth _auth = FirebaseAuth.instance;           // buat tau siapa yang login

  // Alamat folder tugas milik user yang sedang login: users/{uid}/tasks
  // Pakai getter biar alamatnya dihitung ulang tiap dipakai,
  // jadi kalau ganti akun, alamatnya ikut ganti
  CollectionReference<Map<String, dynamic>> get _taskCollection {
    final uid = _auth.currentUser!.uid; // "!" aman karena halaman ini cuma bisa dibuka setelah login
    return _db.collection('users').doc(uid).collection('tasks');
  }

  // ─────────────────────────── READ ───────────────────────────
  // R1. Dipanggil SEKALI dari initState di task_list_page.dart
  Stream<List<Task>> getTasks() {
    return _taskCollection
        // R2. Urutkan dari yang paling baru
        .orderBy('createdAt', descending: true)

        // R3. Pantau terus. Tiap ada perubahan di Firestore,
        //     snapshot baru (isi semua dokumen) langsung dikirim
        .snapshots()

        // R4. Setiap snapshot datang, ubah isinya:
        //     snapshot.docs = daftar dokumen mentah
        //     R5. tiap dokumen dilempar ke Task.fromFirestore (di task.dart)
        //     .toList() = kumpulin hasilnya jadi List<Task>
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());

    // R6. List<Task> ini dikirim balik ke StreamBuilder di halaman
  }

  // ────────────────────────── CREATE ──────────────────────────
  // C1. Dipanggil dari tombol Simpan di task_list_page.dart
  Future<void> addTask(String title) async {
    // C2. Bikin Map langsung (model Task gak dipakai di sini)
    //     lalu kirim ke Firestore. ID dokumen dibikin otomatis oleh Firestore
    await _taskCollection.add({
      'title': title,                               // dari ketikan user
      'isDone': false,                              // tugas baru pasti belum selesai
      'createdAt': FieldValue.serverTimestamp(),    // jam diisi server, bukan jam HP
    });

    // C3. Firestore berubah → Stream di R3 otomatis kebangun lagi
    //     → R4, R5, R6 jalan sendiri → tugas baru muncul di layar
  }

  // UPDATE, bisa sebagian field aja
  Future<void> updateTask(String id, {String? title, bool? isDone}) async {
    final Map<String, dynamic> updatedData = {};

    if (title != null) updatedData['title'] = title;
    if (isDone != null) updatedData['isDone'] = isDone;

    // Gak ada yang diubah, gak usah kirim apa-apa ke Firestore
    if (updatedData.isEmpty) return;

    await _taskCollection.doc(id).update(updatedData);
  }

  // DELETE
  Future<void> deleteTask(String id) async {
    await _taskCollection.doc(id).delete();
  }
}