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

    on<CreateWorkspace>((event, emit) async {
      emit(WorkspaceLoading());
      try {
        await CloudStorage.createWorkspace(event.ownerUid, event.name);

        if (event.emails.isNotEmpty) {
          final snapshot = await CloudStorage.db
              .collection('workspaces')
              .where('ownerUid', isEqualTo: event.ownerUid)
              .orderBy('createdAt', descending: true)
              .limit(1)
              .get();

          final newWorkspaceId = snapshot.docs.first.id;

          await CloudStorage.addMembersToWorkspace(
            newWorkspaceId,
            event.emails,
          );
        }

        emit(WorkspaceCreated());
      } catch (e) {
        emit(WorkspaceError(e.toString()));
      }
    });
