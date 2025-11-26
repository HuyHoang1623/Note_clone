import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_bloc.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_event.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_state.dart';
import 'package:note_clone/core/models/task.dart';
import 'package:note_clone/core/cloud_storage.dart';
import 'package:note_clone/BLoC_app/pages/home_page.dart';
import 'package:note_clone/BLoC_app/pages/cat_api_page.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController taskController = TextEditingController();
  late TabController _tabController;

  List<Map<String, dynamic>> workspaces = [];
  String? selectedWorkspaceId;
  String? selectedWorkspaceName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<TaskBloc>().add(LoadTasks(user.uid));
      _loadWorkspaces(user.uid);
    }
  }

  Future<void> _loadWorkspaces(String uid) async {
    final data = await CloudStorage.getUserWorkspaces(uid);
    setState(() => workspaces = data);
  }

  void addPersonalTask() {
    final title = taskController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (title.isNotEmpty && user != null) {
      final task = Task(uid: user.uid, title: title, createdAt: DateTime.now());
      context.read<TaskBloc>().add(AddTask(task, user.uid));
      taskController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void addWorkspaceTask() {
    final title = taskController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (title.isNotEmpty && user != null && selectedWorkspaceId != null) {
      final task = Task(uid: user.uid, title: title, createdAt: DateTime.now());
      context.read<TaskBloc>().add(
        AddWorkspaceTask(selectedWorkspaceId!, task),
      );
      taskController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showCreateWorkspaceDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailsController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Tạo Workspace"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Tên workspace",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailsController,
                    decoration: const InputDecoration(
                      labelText: "Email thành viên (phân cách bằng dấu ,)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final emailsText = emailsController.text.trim();
                          final owner = FirebaseAuth.instance.currentUser;
                          if (name.isEmpty || owner == null) return;

                          setState(() => isLoading = true);
                          try {
                            final docRef = CloudStorage.db
                                .collection('workspaces')
                                .doc();
                            List<String> members = [owner.uid];

                            if (emailsText.isNotEmpty) {
                              final emails = emailsText
                                  .split(',')
                                  .map((e) => e.trim())
                                  .toList();
                              final snapshot = await CloudStorage.db
                                  .collection('users')
                                  .where('email', whereIn: emails)
                                  .get();
                              for (var doc in snapshot.docs) {
                                members.add(doc.id);
                              }
                              if (snapshot.docs.length != emails.length) {
                                final foundEmails = snapshot.docs
                                    .map((d) => d['email'] as String)
                                    .toSet();
                                final missing = emails
                                    .where((e) => !foundEmails.contains(e))
                                    .join(', ');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Một số email không tồn tại: $missing",
                                    ),
                                  ),
                                );
                              }
                            }

                            await docRef.set({
                              'id': docRef.id,
                              'name': name,
                              'ownerUid': owner.uid,
                              'members': members,
                              'createdAt': DateTime.now(),
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Tạo workspace thành công!"),
                              ),
                            );

                            Navigator.pop(context);
                            _loadWorkspaces(owner.uid);
                          } catch (e) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                          }
                          setState(() => isLoading = false);
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Tạo"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWorkspaceMembers(String workspaceId) async {
    final snapshot = await CloudStorage.db
        .collection('workspaces')
        .doc(workspaceId)
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

  void _showAddMemberDialog(String workspaceId) {
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
                    .doc(workspaceId)
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Việc cần làm"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Cá nhân"),
            Tab(text: "Workspace"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPersonalTaskTab(theme), _buildWorkspaceTaskTab(theme)],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.checklist, size: 28),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.pets, size: 28),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CatApiPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTaskTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: taskController,
                  decoration: const InputDecoration(
                    hintText: "Nhập việc cần làm...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: addPersonalTask,
                child: const Text("Thêm"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is! TaskLoaded || state.personalTasks.isEmpty) {
                  return const Center(child: Text("Chưa có việc nào!"));
                }

                final ongoing = state.personalTasks
                    .where((t) => t.status == TaskStatus.ongoing)
                    .toList();
                final completed = state.personalTasks
                    .where((t) => t.status == TaskStatus.completed)
                    .toList();

                return _buildTaskList(
                  context,
                  theme,
                  ongoing,
                  completed,
                  false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceTaskTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Workspace của bạn", style: TextStyle(fontSize: 16)),
              TextButton.icon(
                onPressed: () => _showCreateWorkspaceDialog(context),
                icon: const Icon(Icons.add),
                label: const Text("Tạo mới"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedWorkspaceId,
            hint: const Text("Chọn workspace"),
            isExpanded: true,
            items: workspaces.map((ws) {
              return DropdownMenuItem<String>(
                value: ws['id'],
                child: Text(ws['name']),
              );
            }).toList(),
            onChanged: (id) {
              setState(() {
                selectedWorkspaceId = id;
                selectedWorkspaceName = workspaces
                    .firstWhere((w) => w['id'] == id)['name']
                    .toString();
              });
              if (id != null) {
                context.read<TaskBloc>().add(LoadWorkspaceTasks(id));
              }
            },
          ),
          const SizedBox(height: 8),
          if (selectedWorkspaceId != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.people),
                  label: const Text("Xem thành viên"),
                  onPressed: () => _showWorkspaceMembers(selectedWorkspaceId!),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Thêm thành viên"),
                  onPressed: () => _showAddMemberDialog(selectedWorkspaceId!),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: taskController,
                  decoration: InputDecoration(
                    hintText: selectedWorkspaceId == null
                        ? "Chọn workspace trước..."
                        : "Nhập việc trong workspace...",
                    border: const OutlineInputBorder(),
                  ),
                  enabled: selectedWorkspaceId != null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: selectedWorkspaceId != null
                    ? addWorkspaceTask
                    : null,
                child: const Text("Thêm"),
              ),
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
                    state.workspaceId != selectedWorkspaceId ||
                    state.workspaceTasks.isEmpty) {
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

                return _buildTaskList(context, theme, ongoing, completed, true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    ThemeData theme,
    List<Task> ongoing,
    List<Task> completed,
    bool isWorkspace,
  ) {
    return ListView(
      children: [
        Text("Chưa hoàn thành", style: theme.textTheme.titleLarge),
        ...ongoing.map(
          (task) => ListTile(
            leading: Checkbox(
              value: false,
              onChanged: (_) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  if (isWorkspace && selectedWorkspaceId != null) {
                    context.read<TaskBloc>().add(
                      ToggleWorkspaceTask(selectedWorkspaceId!, task),
                    );
                  } else {
                    context.read<TaskBloc>().add(ToggleTask(task, user.uid));
                  }
                }
              },
            ),
            title: Text(task.title),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  if (isWorkspace && selectedWorkspaceId != null) {
                    context.read<TaskBloc>().add(
                      DeleteWorkspaceTask(selectedWorkspaceId!, task.id),
                    );
                  } else {
                    context.read<TaskBloc>().add(DeleteTask(task.id, user.uid));
                  }
                }
              },
            ),
          ),
        ),
        const Divider(height: 30, thickness: 1),
        Text("Đã hoàn thành", style: theme.textTheme.titleLarge),
        ...completed.map(
          (task) => ListTile(
            leading: Checkbox(
              value: true,
              onChanged: (_) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  if (isWorkspace && selectedWorkspaceId != null) {
                    context.read<TaskBloc>().add(
                      ToggleWorkspaceTask(selectedWorkspaceId!, task),
                    );
                  } else {
                    context.read<TaskBloc>().add(ToggleTask(task, user.uid));
                  }
                }
              },
            ),
            title: Text(
              task.title,
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  if (isWorkspace && selectedWorkspaceId != null) {
                    context.read<TaskBloc>().add(
                      DeleteWorkspaceTask(selectedWorkspaceId!, task.id),
                    );
                  } else {
                    context.read<TaskBloc>().add(DeleteTask(task.id, user.uid));
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
