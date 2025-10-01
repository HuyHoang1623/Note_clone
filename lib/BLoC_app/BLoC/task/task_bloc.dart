import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_clone/core/models/task.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_event.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_state.dart';
import 'package:note_clone/core/local_storage.dart';
import 'package:note_clone/core/cloud_storage.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(const TaskState()) {
    on<LoadTasks>((event, emit) async {
      List<Task> tasks = [];
      try {
        tasks = await CloudStorage.getTasks();
        for (var t in tasks) await LocalStorage.saveTask(t);
      } catch (_) {
        final local = await LocalStorage.loadTasks();
        tasks = local
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      emit(state.copyWith(tasks: tasks));
    });

    on<AddTask>((event, emit) async {
      final updated = [...state.tasks, event.task];
      emit(state.copyWith(tasks: updated));

      await LocalStorage.saveTask(event.task);
      try {
        await CloudStorage.addTask(event.task);
      } catch (_) {}
    });

    on<DeleteTask>((event, emit) async {
      final updated = state.tasks.where((t) => t.id != event.id).toList();
      emit(state.copyWith(tasks: updated));

      await LocalStorage.deleteTask(event.id);
      try {
        await CloudStorage.deleteTask(event.id);
      } catch (_) {}
    });

    on<ToggleTask>((event, emit) async {
      final updated = state.tasks.map((t) {
        if (t.id == event.task.id) {
          return t.copyWith(
            status: t.status == TaskStatus.ongoing
                ? TaskStatus.completed
                : TaskStatus.ongoing,
          );
        }
        return t;
      }).toList();

      emit(state.copyWith(tasks: updated));

      for (var t in updated) {
        if (t.id == event.task.id) {
          await LocalStorage.saveTask(t);
          try {
            await CloudStorage.updateTask(t);
          } catch (_) {}
          break;
        }
      }
    });
  }
}
