import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'errorsinfo_parameters.dart';
import 'errorsinfo_service.dart';
import 'errorsinfo_splash.dart';

late SharedPreferences errorsInfoSharedPreferences;

dynamic errorsInfoConversionData;
String? errorsInfoTrackingPermissionStatus;
String? errorsInfoAdvertisingId;
String? errorsInfoLink;

String? errorsInfoAppsflyerId;
String? errorsInfoExternalId;

int errorsInfoWebViewType = 1;
bool errorsInfoConversionHandled = false;

class ErrorsInfo extends StatefulWidget {
  const ErrorsInfo({super.key});

  @override
  State<ErrorsInfo> createState() => _ErrorsInfoState();
}

class _ErrorsInfoState extends State<ErrorsInfo> {
  @override
  void initState() {
    super.initState();
    errorsInfoInitAll();
  }

  Future<void> errorsInfoInitAll() async {
    await Future.delayed(const Duration(milliseconds: 10));
    errorsInfoSharedPreferences = await SharedPreferences.getInstance();
    final bool sentAnalytics =
        errorsInfoSharedPreferences.getBool(errorsInfoSentFlagKey) ??
            false;
    errorsInfoLink =
        errorsInfoSharedPreferences.getString(errorsInfoLinkKey);
    errorsInfoWebViewType = errorsInfoSharedPreferences
            .getInt(errorsInfoWebViewTypeKey) ??
        1;

    if (errorsInfoLink != null && errorsInfoLink!.isNotEmpty) {
      errorsInfoWebViewType =
          errorsInfoDetectWebViewType(errorsInfoLink!);
      errorsInfoSharedPreferences.setInt(
        errorsInfoWebViewTypeKey,
        errorsInfoWebViewType,
      );
    }

    if (errorsInfoLink != null &&
        errorsInfoLink!.isNotEmpty &&
        !sentAnalytics) {
      ErrorsInfoService().navigateToWebView(context);
    } else if (sentAnalytics) {
      await ErrorsInfoService().navigateToStandardApp(context);
    } else {
      await errorsInfoInitializeMainPart();
    }
  }

  Future<void> errorsInfoInitializeMainPart() async {
    final attRequest = ErrorsInfoService().requestTrackingPermission();
    final oneSignalInit = ErrorsInfoService().initializeOneSignal();

    await attRequest;
    await errorsInfoTakeParams();
    await oneSignalInit;
  }

  int errorsInfoDetectWebViewType(String link) {
    try {
      final uri = Uri.parse(link);
      final params = uri.queryParameters;
      return int.tryParse(params['wtype'] ?? '') ?? 1;
    } catch (_) {
      return 1;
    }
  }

  Future<void> errorsInfoCreateLink() async {
    final Map<dynamic, dynamic> parameters = errorsInfoConversionData;

    parameters.addAll({
      "tracking_status": errorsInfoTrackingPermissionStatus,
      "${errorsInfoKeyword}_id": errorsInfoAdvertisingId,
      "external_id": errorsInfoExternalId,
      "appsflyer_id": errorsInfoAppsflyerId,
    });
    final String? link =
        await ErrorsInfoService().sendErrorsInfoRequest(parameters);

    errorsInfoLink = link;

    if (errorsInfoLink == null || errorsInfoLink!.isEmpty) {
      await ErrorsInfoService().navigateToStandardApp(context);
    } else {
      errorsInfoWebViewType =
          errorsInfoDetectWebViewType(errorsInfoLink!);
      errorsInfoSharedPreferences.setInt(
        errorsInfoWebViewTypeKey,
        errorsInfoWebViewType,
      );
      errorsInfoSharedPreferences.setString(
        errorsInfoLinkKey,
        errorsInfoLink!,
      );
      errorsInfoSharedPreferences.setBool(errorsInfoSuccessKey, true);
      ErrorsInfoService().navigateToWebView(context);
    }
  }

  Future<void> errorsInfoTakeParams() async {
    final appsFlyerOptions = ErrorsInfoService().createAppsFlyerOptions();
    final AppsflyerSdk appsFlyerSdk = AppsflyerSdk(appsFlyerOptions);

    await appsFlyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    errorsInfoAppsflyerId = await appsFlyerSdk.getAppsFlyerUID();

    appsFlyerSdk.onInstallConversionData((res) async {
      if (errorsInfoConversionHandled) {
        return;
      }
      errorsInfoConversionHandled = true;
      errorsInfoConversionData = res;
      await errorsInfoCreateLink();
    });

    appsFlyerSdk.startSDK(
      onError: (errorCode, errorMessage) {
        ErrorsInfoService().navigateToStandardApp(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const ErrorsInfoSplash();
  }
}
