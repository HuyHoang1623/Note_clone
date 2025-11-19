import 'package:equatable/equatable.dart';

abstract class WorkspaceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWorkspaces extends WorkspaceEvent {
  final String uid;
  LoadWorkspaces(this.uid);

  @override
  List<Object?> get props => [uid];
}

class CreateWorkspace extends WorkspaceEvent {
  final String name;
  final String ownerUid;
  final List<String> emails;

  CreateWorkspace(this.name, this.ownerUid, this.emails);

  @override
  List<Object?> get props => [name, ownerUid, emails];
}

class LoadWorkspaceMembers extends WorkspaceEvent {
  final String workspaceId;

  LoadWorkspaceMembers(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
