import '../../domain/models/portfolio_models.dart';

enum PortfolioStatus { initial, loading, ready }

class PortfolioState {
  const PortfolioState({
    this.status = PortfolioStatus.initial,
    this.content,
    this.selectedProjectId,
  });

  final PortfolioStatus status;
  final PortfolioContent? content;
  final String? selectedProjectId;

  ProjectItem? get selectedProject {
    final projects = content?.projects;
    final selectedId = selectedProjectId;

    if (projects == null || projects.isEmpty) {
      return null;
    }

    for (final project in projects) {
      if (project.id == selectedId) {
        return project;
      }
    }

    return projects.first;
  }

  PortfolioState copyWith({
    PortfolioStatus? status,
    PortfolioContent? content,
    String? selectedProjectId,
  }) {
    return PortfolioState(
      status: status ?? this.status,
      content: content ?? this.content,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
    );
  }

  Map<String, dynamic> toJson() {
    return {'selectedProjectId': selectedProjectId};
  }

  factory PortfolioState.fromJson(Map<String, dynamic> json) {
    return PortfolioState(
      selectedProjectId: json['selectedProjectId'] as String?,
    );
  }
}
