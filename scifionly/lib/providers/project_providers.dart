import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scifionly/models/project.dart';
import 'package:scifionly/models/track.dart';
import 'package:scifionly/features/persistence/project_repository.dart';
import 'package:scifionly/features/persistence/track_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  return TrackRepository();
});

final projectListProvider =
    StateNotifierProvider<ProjectListNotifier, AsyncValue<List<Project>>>(
        (ref) {
  return ProjectListNotifier(ref.read(projectRepositoryProvider));
});

class ProjectListNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final ProjectRepository _repo;

  ProjectListNotifier(this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _repo.getAll();
      state = AsyncValue.data(projects);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Project project) async {
    await _repo.insert(project);
    await load();
  }

  Future<void> update(Project project) async {
    await _repo.update(project);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }
}

final selectedProjectIdProvider = StateProvider<String?>((ref) => null);

final selectedProjectProvider = Provider<AsyncValue<Project?>>((ref) {
  final id = ref.watch(selectedProjectIdProvider);
  if (id == null) return const AsyncValue.data(null);
  final projects = ref.watch(projectListProvider);
  return projects.whenData(
      (list) => list.where((p) => p.id == id).firstOrNull);
});

final projectTracksProvider =
    FutureProvider.family<List<Track>, String>((ref, projectId) async {
  final repo = ref.read(trackRepositoryProvider);
  return repo.getByProject(projectId);
});
