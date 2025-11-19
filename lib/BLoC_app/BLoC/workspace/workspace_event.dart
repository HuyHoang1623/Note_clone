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
