import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'errorsinfo.dart';
import 'errorsinfo_parameters.dart';
import 'errorsinfo_service.dart';
import 'errorsinfo_splash.dart';

class ErrorsInfoWebViewWidget extends StatefulWidget {
  const ErrorsInfoWebViewWidget({super.key});

  @override
  State<ErrorsInfoWebViewWidget> createState() =>
      _ErrorsInfoWebViewWidgetState();
}

class _ErrorsInfoWebViewWidgetState extends State<ErrorsInfoWebViewWidget>
    with WidgetsBindingObserver {
  InAppWebViewController? errorsInfoWebViewController;

  bool errorsInfoShowLoading = true;

  bool errorsInfoWasOpenNotification =
      errorsInfoSharedPreferences.getBool(
            errorsInfoWasOpenNotificationKey,
          ) ??
          false;

  bool errorsInfoSavePermission = errorsInfoSharedPreferences.getBool(
        errorsInfoSavePermissionKey,
      ) ??
      false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    errorsInfoSyncNotificationState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  Future<void> errorsInfoSyncNotificationState() async {
    final bool systemNotificationsEnabled =
        await ErrorsInfoService().isSystemPermissionGranted();

    errorsInfoWasOpenNotification = systemNotificationsEnabled;
    errorsInfoSharedPreferences.setBool(
      errorsInfoWasOpenNotificationKey,
      systemNotificationsEnabled,
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> errorsInfoAfterSetting() async {
    final deviceState = OneSignal.User.pushSubscription;

    bool havePermission = deviceState.optedIn ?? false;
    final bool systemNotificationsEnabled =
        await ErrorsInfoService().isSystemPermissionGranted();

    if (havePermission || systemNotificationsEnabled) {
      errorsInfoSharedPreferences.setBool(
          errorsInfoWasOpenNotificationKey, true);
      errorsInfoWasOpenNotification = true;
      errorsInfoSharedPreferences.setBool(errorsInfoSavePermissionKey, false);
      errorsInfoSavePermission = false;
      ErrorsInfoService().sendRequestToBackend();
    }

    setState(() {});
  }

  Future<void> errorsInfoHandlePushPermissionFlow() async {
    await ErrorsInfoService().requestPermissionOneSignal();

    final bool systemNotificationsEnabled =
        await ErrorsInfoService().isSystemPermissionGranted();

    if (systemNotificationsEnabled) {
      errorsInfoSharedPreferences.setBool(
          errorsInfoWasOpenNotificationKey, true);
      errorsInfoWasOpenNotification = true;
      errorsInfoSharedPreferences.setBool(errorsInfoSavePermissionKey, false);
      errorsInfoSavePermission = false;
      ErrorsInfoService().sendRequestToBackend();
    } else {
      errorsInfoSharedPreferences.setBool(errorsInfoSavePermissionKey, true);
      errorsInfoSavePermission = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: errorsInfoShowLoading ? 0 : 1,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: InAppWebView(
                      onCreateWindow: (controller,
                          CreateWindowAction createWindowRequest) async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => _ErrorsInfoPopupWebView(
                              windowId: createWindowRequest.windowId,
                              initialRequest: createWindowRequest.request,
                            ),
                          ),
                        );
                        return true;
                      },
                      initialUrlRequest: URLRequest(
                        url: WebUri(errorsInfoLink!),
                      ),
                      initialSettings: InAppWebViewSettings(
                        allowsBackForwardNavigationGestures: false,
                        javaScriptEnabled: true,
                        allowsInlineMediaPlayback: true,
                        mediaPlaybackRequiresUserGesture: false,
                        supportMultipleWindows: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                        cacheEnabled: true,
                        clearCache: false,
                        cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
                        useOnLoadResource: false,
                        useShouldInterceptAjaxRequest: false,
                        useShouldInterceptFetchRequest: false,
                        hardwareAcceleration: true,
                        thirdPartyCookiesEnabled: true,
                        sharedCookiesEnabled: true,
                        disallowOverScroll: true,
                      ),
                      onWebViewCreated: (controller) {
                        errorsInfoWebViewController = controller;
                      },
                      onLoadStop: (controller, url) async {
                        errorsInfoShowLoading = false;
                        setState(() {});
                        if (errorsInfoWasOpenNotification) return;

                        final bool systemNotificationsEnabled =
                            await ErrorsInfoService()
                                .isSystemPermissionGranted();

                        await Future.delayed(const Duration(seconds: 3));

                        if (systemNotificationsEnabled) {
                          errorsInfoSharedPreferences.setBool(
                            errorsInfoWasOpenNotificationKey,
                            true,
                          );
                          errorsInfoWasOpenNotification = true;
                          ErrorsInfoService().sendRequestToBackend();
                          ErrorsInfoService().notifyOneSignalAccepted();
                        }

                        if (!systemNotificationsEnabled) {
                          errorsInfoWasOpenNotification = true;
                          await errorsInfoHandlePushPermissionFlow();
                        }

                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                return errorsInfoBuildWebBottomBar(orientation);
              },
            ),
          ),
        ),
        if (errorsInfoShowLoading) const ErrorsInfoSplash(),
      ],
    );
  }

  Widget errorsInfoBuildWebBottomBar(Orientation orientation) {
    return Container(
      color: Colors.black,
      height: orientation == Orientation.portrait ? 25 : 30,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (errorsInfoWebViewController != null &&
                  await errorsInfoWebViewController!.canGoBack()) {
                errorsInfoWebViewController!.goBack();
              }
            },
          ),
          const SizedBox.shrink(),
          IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.arrow_forward),
            onPressed: () async {
              if (errorsInfoWebViewController != null &&
                  await errorsInfoWebViewController!.canGoForward()) {
                errorsInfoWebViewController!.goForward();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorsInfoPopupWebView extends StatelessWidget {
  const _ErrorsInfoPopupWebView({
    required this.windowId,
    required this.initialRequest,
  });

  final int? windowId;
  final URLRequest? initialRequest;

  @override
  Widget build(BuildContext context) {
    return _ErrorsInfoPopupWebViewBody(
      windowId: windowId,
      initialRequest: initialRequest,
    );
  }
}

class _ErrorsInfoPopupWebViewBody extends StatefulWidget {
  const _ErrorsInfoPopupWebViewBody({
    required this.windowId,
    required this.initialRequest,
  });

  final int? windowId;
  final URLRequest? initialRequest;

  @override
  State<_ErrorsInfoPopupWebViewBody> createState() =>
      _ErrorsInfoPopupWebViewBodyState();
}

class _ErrorsInfoPopupWebViewBodyState
    extends State<_ErrorsInfoPopupWebViewBody> {
  InAppWebViewController? popupController;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.3),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.3),
        foregroundColor: Colors.white,
        toolbarHeight: 36,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: progress < 1 ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: LinearProgressIndicator(
                value: progress < 1 ? progress : null,
                minHeight: 2,
                backgroundColor: Colors.white12,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xff007AFF)),
              ),
            ),
            Expanded(
              child: InAppWebView(
                windowId: widget.windowId,
                initialUrlRequest: widget.initialRequest,
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  supportMultipleWindows: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  allowsInlineMediaPlayback: true,
                ),
                onWebViewCreated: (controller) {
                  popupController = controller;
                },
                onProgressChanged: (controller, newProgress) {
                  setState(() {
                    progress = newProgress / 100;
                  });
                },
                onLoadStop: (controller, uri) {
                  setState(() {
                    progress = 1;
                  });
                },
                onCloseWindow: (controller) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
