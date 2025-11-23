import 'package:equatable/equatable.dart';

class WorkspaceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkspaceInitial extends WorkspaceState {}

class WorkspaceLoading extends WorkspaceState {}

class WorkspaceLoaded extends WorkspaceState {
  final List<Map<String, dynamic>> workspaces;
  final String? selectedId;
  final String? selectedName;

  WorkspaceLoaded({
    required this.workspaces,
    this.selectedId,
    this.selectedName,
  });

  @override
  List<Object?> get props => [workspaces, selectedId, selectedName];
}

class WorkspaceMembersLoaded extends WorkspaceState {
  final List<String> members;

  WorkspaceMembersLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class WorkspaceCreated extends WorkspaceState {}

class WorkspaceError extends WorkspaceState {
  final String message;

  WorkspaceError(this.message);

  @override
  List<Object?> get props => [message];
}
