class ToDoListPage extends StatelessWidget {
  const ToDoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = TextEditingController();
    final theme = Theme.of(context);

    void addTask() {
      final title = taskController.text.trim();
      if (title.isNotEmpty) {
        final task = Task(title: title, createdAt: DateTime.now());
        context.read<TaskBloc>().add(AddTask(task));
        taskController.clear();
      }
    }
