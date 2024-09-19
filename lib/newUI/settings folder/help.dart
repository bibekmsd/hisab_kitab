import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserManualPage extends StatefulWidget {
  const UserManualPage({Key? key}) : super(key: key);

  @override
  State<UserManualPage> createState() => _UserManualPageState();
}

class _UserManualPageState extends State<UserManualPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://baebabe.github.io/Hisab_kitab-Docs/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Manual'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

