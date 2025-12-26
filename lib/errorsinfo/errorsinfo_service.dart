import 'dart:convert';
import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uuid/uuid.dart';
import 'errorsinfo.dart';
import 'errorsinfo_parameters.dart';
import 'errorsinfo_web_view.dart';
import 'errorsinfo_web_view_two.dart';

class ErrorsInfoService {
  void navigateToWebView(BuildContext context) {
    final bool useCustomTab =
        errorsInfoWebViewType == 2 && errorsInfoLink != null;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            useCustomTab
                ? ErrorsInfoWebViewTwo(link: errorsInfoLink!)
                : const ErrorsInfoWebViewWidget(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> initializeOneSignal() async {
    await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    await OneSignal.Location.setShared(false);
    OneSignal.initialize(errorsInfoOneSignalAppId);
    errorsInfoExternalId = const Uuid().v1();
  }

  Future<void> requestPermissionOneSignal() async {
    await OneSignal.Notifications.requestPermission(true);
    errorsInfoExternalId = const Uuid().v1();
    try {
      OneSignal.login(errorsInfoExternalId!);
      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (_) {}
  }

  void notifyOneSignalAccepted() {
    try {
      OneSignal.login(errorsInfoExternalId ?? const Uuid().v1());
      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (_) {}
  }

  void sendRequestToBackend() {
    try {
      OneSignal.login(errorsInfoExternalId!);
      OneSignal.User.pushSubscription.addObserver((state) {});
    } catch (_) {}
  }

  Future<void> navigateToStandardApp(BuildContext context) async {
    errorsInfoSharedPreferences.setBool(errorsInfoSentFlagKey, true);
    errorsInfoOpenStandardAppLogic(context);
  }

  Future<bool> isSystemPermissionGranted() async {
    if (!Platform.isIOS) return false;
    try {
      final status = await OneSignal.Notifications.permissionNative();
      return status == OSNotificationPermission.authorized ||
          status == OSNotificationPermission.provisional ||
          status == OSNotificationPermission.ephemeral;
    } catch (_) {
      return false;
    }
  }

  AppsFlyerOptions createAppsFlyerOptions() {
    return AppsFlyerOptions(
      afDevKey: (errorsInfoAfDevKeyPart1 + errorsInfoAfDevKeyPart2),
      appId: errorsInfoAppsFlyerAppId,
      timeToWaitForATTUserAuthorization: 5,
      showDebug: true,
      disableAdvertisingIdentifier: false,
      disableCollectASA: false,
      manualStart: true,
    );
  }

  Future<void> requestTrackingPermission() async {
    if (Platform.isIOS) {
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();
      errorsInfoTrackingPermissionStatus = status.toString();

      if (status == TrackingStatus.authorized) {
        await _getAdvertisingId();
      }
    }
  }

  Future<void> _getAdvertisingId() async {
    try {
      errorsInfoAdvertisingId = await AdvertisingId.id(true);
    } catch (_) {}
  }

  Future<String?> sendErrorsInfoRequest(
      Map<dynamic, dynamic> parameters) async {
    try {
      final jsonString = json.encode(parameters);
      final base64Parameters = base64.encode(utf8.encode(jsonString));

      final requestBody = {errorsInfoKeyword: base64Parameters};

      final response = await http.post(
        Uri.parse(errorsInfoBackendUrl),
        body: requestBody,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
