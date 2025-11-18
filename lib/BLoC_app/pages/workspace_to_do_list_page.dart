import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_event.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_state.dart';
import 'package:note_clone/core/models/task.dart';
import 'package:note_clone/core/cloud_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkspaceTaskPage extends StatefulWidget {
  final String workspaceId;
  final String workspaceName;

  const WorkspaceTaskPage({
    super.key,
    required this.workspaceId,
    required this.workspaceName,
  });

  @override
  State<WorkspaceTaskPage> createState() => _WorkspaceTaskPageState();
}

class _WorkspaceTaskPageState extends State<WorkspaceTaskPage> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadWorkspaceTasks(widget.workspaceId));
  }

  void _addTask() {
    final title = _taskController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (title.isNotEmpty && user != null) {
      final task = Task(uid: user.uid, title: title, createdAt: DateTime.now());
      context.read<TaskBloc>().add(AddWorkspaceTask(widget.workspaceId, task));
      _taskController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showWorkspaceMembers() async {
    final snapshot = await CloudStorage.db
        .collection('workspaces')
        .doc(widget.workspaceId)
        .get();
    final data = snapshot.data();
    if (data == null) return;
    final members = List<String>.from(data['members']);

    final usersSnapshot = await CloudStorage.db
        .collection('users')
        .where(FieldPath.documentId, whereIn: members)
        .get();

    final userEmails = usersSnapshot.docs
        .map((doc) => doc['email'] ?? 'Không rõ')
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thành viên Workspace"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: userEmails
                .map(
                  (email) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(email),
                  ),
                )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Đóng"),
            ),
          ],
        );
      },
    );
  }

  void _showAddMemberDialog() {
    final emailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Thêm thành viên"),
          content: TextField(
            controller: emailsController,
            decoration: const InputDecoration(
              labelText: "Email (phân cách bằng dấu ,)",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                final emailsText = emailsController.text.trim();
                if (emailsText.isEmpty) return;

                final emails = emailsText
                    .split(',')
                    .map((e) => e.trim())
                    .toList();

                final snapshot = await CloudStorage.db
                    .collection('users')
                    .where('email', whereIn: emails)
                    .get();

                if (snapshot.docs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Không tìm thấy email nào")),
                  );
                  return;
                }

                final memberIds = snapshot.docs.map((doc) => doc.id).toList();

                await CloudStorage.db
                    .collection('workspaces')
                    .doc(widget.workspaceId)
                    .update({'members': FieldValue.arrayUnion(memberIds)});

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thêm thành viên thành công!")),
                );
              },
              child: const Text("Thêm"),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildTaskItems(List<Task> tasks, bool completed) {
    return tasks
        .map(
          (task) => ListTile(
            leading: Checkbox(
              value: completed,
              onChanged: (_) {
                context.read<TaskBloc>().add(
                  ToggleWorkspaceTask(widget.workspaceId, task),
                );
              },
            ),
            title: Text(
              task.title,
              style: completed
                  ? const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    )
                  : null,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                context.read<TaskBloc>().add(
                  DeleteWorkspaceTask(widget.workspaceId, task.id),
                );
              },
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Workspace: ${widget.workspaceName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _showWorkspaceMembers,
            tooltip: "Xem thành viên",
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddMemberDialog,
            tooltip: "Thêm thành viên",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: "Nhập việc cần làm trong workspace...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTask, child: const Text("Thêm")),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is! TaskLoaded ||
                      state.workspaceTasks.isEmpty ||
                      state.workspaceId != widget.workspaceId) {
                    return const Center(
                      child: Text("Chưa có việc nào trong workspace này!"),
                    );
                  }

                  final ongoing = state.workspaceTasks
                      .where((t) => t.status == TaskStatus.ongoing)
                      .toList();
                  final completed = state.workspaceTasks
                      .where((t) => t.status == TaskStatus.completed)
                      .toList();

                  return ListView(
                    children: [
                      Text(
                        "Chưa hoàn thành",
                        style: theme.textTheme.titleLarge,
                      ),
                      ..._buildTaskItems(ongoing, false),
                      const Divider(height: 30, thickness: 1),
                      Text("Đã hoàn thành", style: theme.textTheme.titleLarge),
                      ..._buildTaskItems(completed, true),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
