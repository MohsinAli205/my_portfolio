import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/portfolio_cubit.dart';
import '../cubit/portfolio_state.dart';
import '../widgets/portfolio_view.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioCubit, PortfolioState>(
      builder: (context, state) {
        if (state.status != PortfolioStatus.ready || state.content == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return PortfolioView(
          state: state,
          onProjectSelected: context.read<PortfolioCubit>().selectProject,
        );
      },
    );
  }
}
