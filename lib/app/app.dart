import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../core/theme/app_theme.dart';
import '../features/portfolio/data/mock_portfolio_repository.dart';
import '../features/portfolio/presentation/cubit/portfolio_cubit.dart';
import '../features/portfolio/presentation/pages/portfolio_page.dart';

class App extends StatelessWidget {
  const App({required this.storage, super.key});

  final Storage storage;

  @override
  Widget build(BuildContext context) {
    HydratedBloc.storage = storage;

    return RepositoryProvider<MockPortfolioRepository>(
      create: (_) => const MockPortfolioRepository(),
      child: Builder(
        builder: (context) {
          return BlocProvider<PortfolioCubit>(
            create: (_) => PortfolioCubit(
              repository: context.read<MockPortfolioRepository>(),
            )..load(),
            child: MaterialApp(
              title: 'Mohsin Ali Portfolio',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkTheme,
              home: const PortfolioPage(),
            ),
          );
        },
      ),
    );
  }
}
