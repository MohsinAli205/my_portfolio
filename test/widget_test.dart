import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:my_portfolio/app/app.dart';

void main() {
  testWidgets('portfolio page renders main sections', (tester) async {
    await tester.pumpWidget(App(storage: _InMemoryStorage()));
    await tester.pumpAndSettle();

    expect(find.text('Hi, I\'m Mohsin Ali'), findsOneWidget);
    expect(find.text('Featured projects'), findsOneWidget);
    expect(find.text('FitTrack Pro'), findsWidgets);
  });
}

class _InMemoryStorage implements Storage {
  final Map<String, dynamic> _cache = {};

  @override
  dynamic read(String key) => _cache[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _cache[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> clear() async {
    _cache.clear();
  }

  @override
  Future<void> close() async {}
}
