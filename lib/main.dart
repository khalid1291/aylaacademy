
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

void main() => runApp(const MaterialApp(home: WebViewExample()));



class WebViewExample extends StatefulWidget {
const WebViewExample({super.key});

@override
State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
late final WebViewController _controller;

@override
void initState() {
super.initState();

// #docregion platform_features
late final PlatformWebViewControllerCreationParams params;
if (WebViewPlatform.instance is WebKitWebViewPlatform) {
params = WebKitWebViewControllerCreationParams(
allowsInlineMediaPlayback: true,
mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
);
} else {
params = const PlatformWebViewControllerCreationParams();
}

final WebViewController controller =
WebViewController.fromPlatformCreationParams(params);
// #enddocregion platform_features

controller
..setJavaScriptMode(JavaScriptMode.unrestricted)
..setBackgroundColor(const Color(0x00000000))
..setNavigationDelegate(
NavigationDelegate(
onProgress: (int progress) {
debugPrint('WebView is loading (progress : $progress%)');
},
onPageStarted: (String url) {
debugPrint('Page started loading: $url');
},
onPageFinished: (String url) {
debugPrint('Page finished loading: $url');
},
onWebResourceError: (WebResourceError error) {
debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
},
  onNavigationRequest: (NavigationRequest request) {
    // التحقق مما إذا كانت الصفحة تنتمي إلى https://www.aylaacademy.com
    if (request.url.startsWith('https://www.aylaacademy.com')) {
      // فتح الصفحة داخل WebView
      return NavigationDecision.navigate;
    } else {
      // فتح الصفحة في متصفح الجهاز
      launch(request.url);
      // منع فتح الرابط داخل WebView
      return NavigationDecision.prevent;
    }
  },



onUrlChange: (UrlChange change) {
debugPrint('url change to ${change.url}');
},
onHttpAuthRequest: (HttpAuthRequest request) {
openDialog(request);
},
),
)
..addJavaScriptChannel(
'Toaster',
onMessageReceived: (JavaScriptMessage message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(message.message)),
);
},
)
..loadRequest(Uri.parse('https://www.aylaacademy.com/'));

// #docregion platform_features
if (controller.platform is AndroidWebViewController) {
AndroidWebViewController.enableDebugging(true);
(controller.platform as AndroidWebViewController)
    .setMediaPlaybackRequiresUserGesture(false);
}
// #enddocregion platform_features

_controller = controller;
}

@override
Widget build(BuildContext context) {
  return WillPopScope(
      onWillPop: () async {
        _showExitConfirmationDialog(context);
        return false;
      },
  child: Scaffold(
backgroundColor: Colors.green,
appBar: AppBar(
title: const Text(''),
// This drop down menu demonstrates that Flutter widgets can be shown over the web view.
actions: <Widget>[
NavigationControls(webViewController: _controller),
],
),
body: WebViewWidget(controller: _controller
,


),

        ),

  );
}



Future<void> openDialog(HttpAuthRequest httpRequest) async {
final TextEditingController usernameTextController =
TextEditingController();
final TextEditingController passwordTextController =
TextEditingController();
/*

return showDialog(
context: context,
barrierDismissible: false,
builder: (BuildContext context) {
return AlertDialog(
title: Text('${httpRequest.host}: ${httpRequest.realm ?? '-'}'),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: <Widget>[
TextField(
decoration: const InputDecoration(labelText: 'Username'),
autofocus: true,
controller: usernameTextController,
),
TextField(
decoration: const InputDecoration(labelText: 'Password'),
controller: passwordTextController,
),
],
),
),
actions: <Widget>[
// Explicitly cancel the request on iOS as the OS does not emit new
// requests when a previous request is pending.
TextButton(
onPressed: () {
httpRequest.onCancel();
Navigator.of(context).pop();
},
child: const Text('Cancel'),
),
TextButton(
onPressed: () {
httpRequest.onProceed(
WebViewCredential(
user: usernameTextController.text,
password: passwordTextController.text,
),
);
Navigator.of(context).pop();
},
child: const Text('Authenticate'),
),
],
);
},

);

 */

}
}

void _showExitConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('تأكيد الخروج'),
        content: Text('هل تود الخروج من التطبيق؟'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('لا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              SystemNavigator.pop();
            },
            child: Text('نعم'),
          ),
        ],
      );
    },
  );
}
/*
enum MenuOptions {
showUserAgent,
listCookies,
clearCookies,
addToCache,
listCache,
clearCache,
navigationDelegate,
doPostRequest,
loadLocalFile,
loadFlutterAsset,
loadHtmlString,
transparentBackground,
setCookie,
logExample,
basicAuthentication,
}

 */


class NavigationControls extends StatelessWidget {
const NavigationControls({super.key, required this.webViewController});

final WebViewController webViewController;

@override
Widget build(BuildContext context) {
return Row(
children: <Widget>[
Center(child: Text("back"),),

IconButton(
icon: const Icon(Icons.arrow_back_ios),

onPressed: () async {
if (await webViewController.canGoBack()) {
await webViewController.goBack();
}
else {
if (context.mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('لا توجد عناصر في سجل التاريخ للعودة')),
);

Future.delayed(Duration(milliseconds: 1000), () { // زمن الانتظار بالثواني
ScaffoldMessenger.of(context).hideCurrentSnackBar(); // لإخفاء الSnackBar بعد الزمن المحدد
});
}
}
},

),
IconButton(
icon: const Icon(Icons.arrow_forward_ios),
onPressed: () async {
if (await webViewController.canGoForward()) {
await webViewController.goForward();
} else {
if (context.mounted) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('لا توجد عناصر في سجل التاريخ للإبتعاد')),
);
Future.delayed(Duration(milliseconds: 1000), () { // زمن الانتظار بالثواني
ScaffoldMessenger.of(context).hideCurrentSnackBar(); // لإخفاء الSnackBar بعد الزمن المحدد
});              }
}
},
),
Center(child: Text("front "),),

IconButton(
icon: const Icon(Icons.replay),
onPressed: () => webViewController.reload(),
),

],

)

;


}


}