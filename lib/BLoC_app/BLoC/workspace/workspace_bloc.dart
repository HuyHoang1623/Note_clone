import 'package:flutter_bloc/flutter_bloc.dart';
import 'workspace_event.dart';
import 'workspace_state.dart';
import 'package:note_clone/core/cloud_storage.dart';

class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  WorkspaceBloc() : super(WorkspaceInitial()) {
    on<LoadWorkspaces>((event, emit) async {
      emit(WorkspaceLoading());
      try {
        final workspaces = await CloudStorage.getUserWorkspaces(event.uid);

        emit(
          WorkspaceLoaded(
            workspaces: workspaces,
            selectedId: workspaces.isNotEmpty ? workspaces.first['id'] : null,
            selectedName: workspaces.isNotEmpty
                ? workspaces.first['name']
                : null,
          ),
        );
      } catch (e) {
        emit(WorkspaceError(e.toString()));
      }
    });
