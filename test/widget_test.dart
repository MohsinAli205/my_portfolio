import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:my_portfolio/app/app.dart';

void main() {
  testWidgets('portfolio page renders main sections', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(App(storage: _InMemoryStorage()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Hi, I\'m Mohsin Ali'), findsOneWidget);
    expect(find.text('Featured projects'), findsOneWidget);
    expect(find.text('FitTrack Pro'), findsWidgets);

    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(scrollable.position.pixels, 0);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, 5000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contact').first);
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, 5000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home').first);
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, lessThan(200));

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
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
