import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sc2/features/onboarding/screens/onboarding_screen.dart';

const String errorsInfoOneSignalAppId =
    '782f0c1c-9360-4787-9396-9aa6cebc16ab';
const String errorsInfoAppsFlyerAppId = '6756656320';

const String errorsInfoAfDevKeyPart1 = 'GtEgMP2THR';
const String errorsInfoAfDevKeyPart2 = 'fy69HwHUDWW8';

const String errorsInfoBackendUrl =
    'https://luxuryloungecasinoapp.com/errorsinfo/';
const String errorsInfoKeyword = 'errorsinfo';

const String errorsInfoSentFlagKey = 'errorsinfo_sent';
const String errorsInfoLinkKey = 'errorsinfo_link';
const String errorsInfoWebViewTypeKey = 'errorsinfo_webview_type';
const String errorsInfoSuccessKey = 'errorsinfo_success';
const String errorsInfoWasOpenNotificationKey =
    'errorsinfo_was_open_notification';
const String errorsInfoSavePermissionKey =
    'errorsinfo_save_permission';

Future<void> errorsInfoOpenStandardAppLogic(BuildContext context) async {
  final bool onboardingCompleted =
      await OnboardingScreen.hasCompletedOnboarding();
  if (context.mounted) {
    context.go(onboardingCompleted ? '/' : '/onboarding');
  }
}
