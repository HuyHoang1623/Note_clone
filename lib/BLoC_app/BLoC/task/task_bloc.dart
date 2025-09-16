import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_clone/core/models/task.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_even.dart';
import 'package:note_clone/BLoC_app/BLoC/task/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(const TaskState()) {
    on<AddTask>((event, emit) {
      final updated = [...state.tasks, event.task];
      emit(state.copyWith(tasks: updated));
    });

    on<DeleteTask>((event, emit) {
      final updated = state.tasks.where((t) => t.id != event.id).toList();
      emit(state.copyWith(tasks: updated));
    });

    on<ToggleTask>((event, emit) {
      final updated = state.tasks.map((t) {
        if (t.id == event.task.id) {
          return Task(
            id: t.id,
            title: t.title,
            createdAt: t.createdAt,
            status: t.status == TaskStatus.ongoing
                ? TaskStatus.completed
                : TaskStatus.ongoing,
          );
        }
        return t;
      }).toList();
      emit(state.copyWith(tasks: updated));
    });
  }
}
