import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_clone/core/models/note.dart';
import 'package:note_clone/core/models/task.dart';

class CloudStorage {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<void> createWorkspace(String ownerUid, String name) async {
    final docRef = db.collection('workspaces').doc();
    await docRef.set({
      'id': docRef.id,
      'name': name,
      'ownerUid': ownerUid,
      'members': [ownerUid],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<Map<String, dynamic>>> getUserWorkspaces(
    String uid,
  ) async {
    final snapshot = await db
        .collection('workspaces')
        .where('members', arrayContains: uid)
        .get();

    return snapshot.docs.map((d) => d.data()).toList();
  }

  static Future<void> addMember(String workspaceId, String newMemberUid) async {
    await db.collection('workspaces').doc(workspaceId).update({
      'members': FieldValue.arrayUnion([newMemberUid]),
    });
  }

  static Future<void> addMembersToWorkspace(
    String workspaceId,
    List<String> emails,
  ) async {
    for (final email in emails) {
      final uid = await getUidByEmail(email);
      if (uid != null) {
        await addMember(workspaceId, uid);
      }
    }
  }

  static Future<String?> getUidByEmail(String email) async {
    final snapshot = await db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data()['uid'];
  }

  static Future<List<String>> getWorkspaceMembers(String workspaceId) async {
    final doc = await db.collection('workspaces').doc(workspaceId).get();
    if (!doc.exists) return [];
    return List<String>.from(doc['members'] ?? []);
  }

  static Future<void> addNote(Note note, String uid) async {
    await db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(note.id)
        .set(note.toJson());
  }

  static Future<void> updateNote(Note note, String uid) async {
    await db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(note.id)
        .set(note.toJson(), SetOptions(merge: true));
  }

  static Future<void> deleteNote(String id, String uid) async {
    await db.collection('users').doc(uid).collection('notes').doc(id).delete();
  }

  static Future<List<Note>> getNotes(String uid) async {
    try {
      final snapshot = await db
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();
      return snapshot.docs.map((doc) => Note.fromJson(doc.data())).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addTask(Task task, String uid) async {
    await db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson());
  }

  static Future<void> updateTask(Task task, String uid) async {
    await db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson(), SetOptions(merge: true));
  }

  static Future<void> deleteTask(String id, String uid) async {
    await db.collection('users').doc(uid).collection('tasks').doc(id).delete();
  }

  static Future<List<Task>> getTasks(String uid) async {
    try {
      final snapshot = await db
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .get();
      return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addWorkspaceTask(String workspaceId, Task task) async {
    await db
        .collection('workspaces')
        .doc(workspaceId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson());
  }

  static Future<void> updateWorkspaceTask(String workspaceId, Task task) async {
    await db
        .collection('workspaces')
        .doc(workspaceId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toJson(), SetOptions(merge: true));
  }

  static Future<void> deleteWorkspaceTask(String workspaceId, String id) async {
    await db
        .collection('workspaces')
        .doc(workspaceId)
        .collection('tasks')
        .doc(id)
        .delete();
  }

  static Future<List<Task>> getWorkspaceTasks(String workspaceId) async {
    try {
      final snapshot = await db
          .collection('workspaces')
          .doc(workspaceId)
          .collection('tasks')
          .get();
      return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
    } catch (_) {
      return [];
    }
  }
}
