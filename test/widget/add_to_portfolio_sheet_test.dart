import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_folio/core/l10n/app_localizations.dart';
import 'package:crypto_folio/features/coin_detail/domain/models/coin_detail_model.dart';
import 'package:crypto_folio/features/portfolio/presentation/widgets/add_to_portfolio_sheet.dart';

const _testDetail = CoinDetailModel(
  id: 'bitcoin',
  symbol: 'btc',
  name: 'Bitcoin',
  image: '',
  currentPrice: 40000.0,
  marketCap: 1200000000000.0,
  totalVolume: 30000000000.0,
);

Widget _buildSubject() {
  return const ProviderScope(
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: AddToPortfolioSheet(detail: _testDetail),
        ),
      ),
    ),
  );
}

void main() {
  group('AddToPortfolioSheet validation', () {
    testWidgets('shows "Must be greater than 0" when quantity is empty on submit',
        (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      await tester.tap(find.text('Add to Portfolio'));
      await tester.pump();

      expect(find.text('Must be greater than 0'), findsOneWidget);
    });

    testWidgets('shows no validation error after entering a valid quantity',
        (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, '2.5');
      await tester.pump();

      expect(find.text('Must be greater than 0'), findsNothing);
    });
  });
}
