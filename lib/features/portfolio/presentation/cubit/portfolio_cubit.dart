import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../data/mock_portfolio_repository.dart';
import 'portfolio_state.dart';

class PortfolioCubit extends HydratedCubit<PortfolioState> {
  PortfolioCubit({
    required MockPortfolioRepository repository,
  })  : _repository = repository,
        super(const PortfolioState());

  final MockPortfolioRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: PortfolioStatus.loading));
    final content = await _repository.fetchContent();
    emit(
      state.copyWith(
        status: PortfolioStatus.ready,
        content: content,
        selectedProjectId:
            state.selectedProjectId ?? content.projects.first.id,
      ),
    );
  }

  void selectProject(String projectId) {
    emit(state.copyWith(selectedProjectId: projectId));
  }

  @override
  PortfolioState? fromJson(Map<String, dynamic> json) {
    return PortfolioState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(PortfolioState state) {
    return state.toJson();
  }
}
