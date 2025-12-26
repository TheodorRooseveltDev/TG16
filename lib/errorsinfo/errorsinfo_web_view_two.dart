import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'errorsinfo.dart';
import 'errorsinfo_parameters.dart';
import 'errorsinfo_service.dart';
import 'errorsinfo_splash.dart';

class ErrorsInfoWebViewTwo extends StatefulWidget {
  const ErrorsInfoWebViewTwo({super.key, required this.link});

  final String link;

  @override
  State<ErrorsInfoWebViewTwo> createState() => _ErrorsInfoWebViewTwoState();
}

class _ErrorsInfoWebViewTwoState extends State<ErrorsInfoWebViewTwo>
    with WidgetsBindingObserver {
  late _ErrorsInfoChromeSafariBrowser _browser;
  bool showLoading = true;
  bool wasOpenNotification =
      errorsInfoSharedPreferences.getBool(
            errorsInfoWasOpenNotificationKey,
          ) ??
          false;
  bool savePermission = errorsInfoSharedPreferences.getBool(
        errorsInfoSavePermissionKey,
      ) ??
      false;
  bool _isOpening = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _browser = _ErrorsInfoChromeSafariBrowser(
      onClosedCallback: _handleBrowserClosed,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openBrowser();
    });
  }

  Future<void> _openBrowser() async {
    if (_isOpening || _disposed) return;
    _isOpening = true;
    try {
      await _browser.open(
        url: WebUri(widget.link),
        settings: ChromeSafariBrowserSettings(
          barCollapsingEnabled: true,
          entersReaderIfAvailable: false,
        ),
      );
      showLoading = false;
      if (mounted) setState(() {});
      if (!wasOpenNotification) {
        await Future.delayed(const Duration(seconds: 3));
        await _handlePushPermissionFlow();
      }
    } finally {
      _isOpening = false;
    }
  }

  void _handleBrowserClosed() {
    if (_disposed) return;
    _openBrowser();
  }

  Future<void> _handlePushPermissionFlow() async {
    final bool systemNotificationsEnabled =
        await ErrorsInfoService().isSystemPermissionGranted();

    if (systemNotificationsEnabled) {
      errorsInfoSharedPreferences.setBool(
          errorsInfoWasOpenNotificationKey, true);
      wasOpenNotification = true;
      errorsInfoSharedPreferences.setBool(errorsInfoSavePermissionKey, false);
      savePermission = false;
      ErrorsInfoService().sendRequestToBackend();
      ErrorsInfoService().notifyOneSignalAccepted();
      return;
    }

    await ErrorsInfoService().requestPermissionOneSignal();

    final bool systemNotificationsEnabledAfter =
        await ErrorsInfoService().isSystemPermissionGranted();

    if (systemNotificationsEnabledAfter) {
      errorsInfoSharedPreferences.setBool(
          errorsInfoWasOpenNotificationKey, true);
      wasOpenNotification = true;
      errorsInfoSharedPreferences.setBool(errorsInfoSavePermissionKey, false);
      savePermission = false;
      ErrorsInfoService().sendRequestToBackend();
      ErrorsInfoService().notifyOneSignalAccepted();
    } else {
      errorsInfoSharedPreferences.setBool(errorsInfoSavePermissionKey, true);
      savePermission = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ErrorsInfoSplash(),
        if (showLoading)
          const Positioned.fill(
            child: ColoredBox(color: Colors.transparent),
          ),
      ],
    );
  }
}

class _ErrorsInfoChromeSafariBrowser extends ChromeSafariBrowser {
  _ErrorsInfoChromeSafariBrowser({required this.onClosedCallback});

  final VoidCallback onClosedCallback;

  @override
  void onOpened() {
  }

  @override
  void onClosed() {
    onClosedCallback();
  }
}
