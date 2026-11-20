import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:va_bookats/app/modules/dailyClosing/models/daily_closing_model.dart';
import 'package:va_bookats/app/modules/dailyClosing/views/widgets/daily_closing_card.dart';
import 'package:va_bookats/network/service/auth_service.dart';
import 'package:va_bookats/services/translation_service.dart';

void main() {
  testWidgets('daily closing card preview', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    final auth = Get.put(AuthService());
    auth.permissions.addAll(const [
      'daily-closings.index',
      'daily-closings.show',
      'daily-closings.create',
      'daily-closings.update',
    ]);
    auth.permissionsVersion.value++;
    final ts = Get.put(TranslationService());
    await ts.loadTranslations('en');

    final closing = DailyClosingModel(
      id: 1,
      status: 'pending',
      closingDate: '2025-01-15',
      openingBalance: '6500.00',
      branch: const ClosingBranch(id: 1, name: 'Salmiya Branch', currencySymbol: 'KD'),
      creator: const ClosingUser(id: 2, name: 'Abdullah'),
    );

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              DailyClosingCard(
                closing: closing,
                onViewDetails: () {},
                onChangeStatus: () {},
              ),
              DailyClosingCard(
                closing: closing.copyWith(status: 'approved'),
                onViewDetails: () {},
                onChangeStatus: () {},
                isBusy: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(ListView),
      matchesGoldenFile('../images/daily_closing_card.png'),
    );
  });
}
