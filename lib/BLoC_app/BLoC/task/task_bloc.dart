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
        tasks = await CloudStorage.getTasks(event.uid);
        for (var t in tasks) {
          await LocalStorage.saveTask(t);
        }
      } catch (e) {
        tasks = await LocalStorage.loadTasks();
      }
      emit(state.copyWith(tasks: tasks));
    });

    on<AddTask>((event, emit) async {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        await CloudStorage.addTask(event.task, event.uid);
        await LocalStorage.saveTask(event.task);
        final updated = List<Task>.from(current.personalTasks)..add(event.task);
        emit(current.copyWith(personalTasks: updated));
      }
    });
    on<DeleteTask>((event, emit) async {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        await CloudStorage.deleteTask(event.id, event.uid);
        await LocalStorage.deleteTask(event.id);
        final updated = current.personalTasks
            .where((t) => t.id != event.id)
            .toList();
        emit(current.copyWith(personalTasks: updated));
      }
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
            await CloudStorage.updateTask(t, event.uid);
          } catch (_) {}
          break;
        }
    on<LoadWorkspaceTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await CloudStorage.getWorkspaceTasks(event.workspaceId);
        emit(
          TaskLoaded(
            personalTasks: [],
            workspaceTasks: tasks,
            workspaceId: event.workspaceId,
          ),
        );
      } catch (e) {
        emit(TaskError("Không tải được task workspace"));
      }
    });
    on<AddWorkspaceTask>((event, emit) async {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        await CloudStorage.addWorkspaceTask(event.workspaceId, event.task);

        final updated = List<Task>.from(current.workspaceTasks)
          ..add(event.task);
        emit(current.copyWith(workspaceTasks: updated));
      }
    });

    on<DeleteWorkspaceTask>((event, emit) async {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;
        await CloudStorage.deleteWorkspaceTask(event.workspaceId, event.taskId);

        final updated = current.workspaceTasks
            .where((t) => t.id != event.taskId)
            .toList();
        emit(current.copyWith(workspaceTasks: updated));
      }
    });

    on<ToggleWorkspaceTask>((event, emit) async {
      if (state is TaskLoaded) {
        final current = state as TaskLoaded;

        final toggled = event.task.copyWith(
          status: event.task.status == TaskStatus.ongoing
              ? TaskStatus.completed
              : TaskStatus.ongoing,
        );
      }
    });
  }
}
