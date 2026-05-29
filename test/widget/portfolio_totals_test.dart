import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_folio/core/l10n/app_localizations.dart';
import 'package:crypto_folio/features/portfolio/domain/models/portfolio_item_model.dart';
import 'package:crypto_folio/features/portfolio/presentation/providers/portfolio_provider.dart';
import 'package:crypto_folio/features/portfolio/presentation/screens/portfolio_screen.dart';

void main() {
  final testItem = PortfolioItemModel(
    id: 'bitcoin',
    coinId: 'bitcoin',
    coinName: 'Bitcoin',
    coinSymbol: 'btc',
    coinImage: '',
    quantity: 1.0,
    buyPrice: 40000.0,
    addedAt: DateTime(2024, 1, 1),
  );

  const testTotals = PortfolioTotals(
    totalInvested: 100000,
    totalCurrentValue: 130000,
    totalProfitLoss: 30000,
    totalProfitLossPercent: 30.0,
  );

  testWidgets('PortfolioScreen totals card displays overridden values',
      (tester) async {
    final itemWithPrice = PortfolioItemWithPrice(
      item: testItem,
      currentPrice: 65000.0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [

          portfolioWithPricesProvider.overrideWithValue(
            AsyncData([itemWithPrice]),
          ),

          portfolioTotalsProvider.overrideWithValue(testTotals),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: PortfolioScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('130,000'), findsOneWidget);

    expect(find.textContaining('+30'), findsOneWidget);
  });
}
