import 'package:flutter/material.dart';
import 'package:pharmadex/models/task.dart';
import 'package:pharmadex/services/task_service.dart';
import 'package:pharmadex/services/notification_service.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final _taskService = TaskService();
  final _titleController = TextEditingController();
  late final Stream<List<Task>> _tasksStream;

  @override
  void initState() {
    super.initState();
    _tasksStream = _taskService.getTasks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $error')),
    );
  }

  // CREATE
  void _showAddTaskDialog() {
    _titleController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Tugas'),
        content: TextField(
          controller: _titleController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Judul tugas'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _titleController.text.trim();
              if (title.isEmpty) return;

              _taskService
                  .addTask(title)
                  .then((_) => NotificationService.show(
                        title: 'Tugas tersimpan ✅',
                        body: '"$title" sudah aman tersimpan di server',
                        payload: 'task',
                      ))
                  .catchError((e) => _showError(e));
              Navigator.pop(dialogContext);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // UPDATE (judul)
  void _showEditDialog(Task task) {
    _titleController.text = task.title;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Tugas'),
        content: TextField(
          controller: _titleController,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = _titleController.text.trim();
              if (newTitle.isEmpty) return;

              _taskService
                  .updateTask(task.id, title: newTitle)
                  .catchError((e) => _showError(e));
              Navigator.pop(dialogContext);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // DELETE
  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: Text(
          'Tugas "${task.title}" bakal dihapus permanen dan gak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              NotificationService.cancelReminder(task.id);   // BARU: batalin pengingatnya dulu
              _taskService
                  .deleteTask(task.id)
                  .catchError((e) => _showError(e));
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminder(Task task) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Ingatkan "${task.title}" jam',
    );

    if (picked == null) return; // user tekan Batal

    final exact = await NotificationService.scheduleReminder(
      taskId: task.id,
      taskTitle: task.title,
      hour: picked.hour,
      minute: picked.minute,
    );

    if (!mounted) return; // halaman udah ditutup selama nunggu
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exact
              ? 'Pengingat dipasang jam ${picked.format(context)}'
              : 'Pengingat dipasang jam ${picked.format(context)}, '
                  'Telat karena izin alarm tepat belum aktif',
        ),
      ),
    );
  }

  // READ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tugas')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Task>>(
        stream: _tasksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(child: Text('Belum ada tugas, yuk tambahkan'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (value) => _taskService
                        .updateTask(task.id, isDone: value)
                        .catchError((e) => _showError(e)),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(                                         // BARU
                        icon: const Icon(Icons.alarm_add, color: Colors.orange),
                        tooltip: 'Pasang pengingat',
                        onPressed: () => _pickReminder(task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(task),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}