// main.dart

import 'package:dapp2/homeController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:web3modal_flutter/widgets/buttons/connect_button.dart';
import 'package:web3modal_flutter/widgets/w3m_connect_wallet_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Simple Form',
      theme: ThemeData(useMaterial3: true),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomeScreen({super.key}); // Initialize the controller

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) => Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              controller.pickWinner();
            },
            child: const Icon(Icons.touch_app_outlined)),
        appBar: AppBar(
          title: const Text('GetX Simple Form'),
        ),
        //f4db5f7f9cb31f768245dec6c9472657ca6ac6b5dd74cd9d28634ab7e9e5487b
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.balance.toString()),
                TextField(
                  controller: controller.nameController,
                  decoration:
                      const InputDecoration(labelText: 'Enter your name'),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: controller.addressController,
                  decoration:
                      const InputDecoration(labelText: 'Paste your address'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.enterLottery,
                  child: const Text('Participate'),
                ),
                ListView(
                  shrinkWrap: true,
                  children: controller.players
                      .map((e) => ListTile(
                        tileColor: e.isWinner?Colors.green:null,
                            leading: CircleAvatar(
                                child: Text(e.playerName.characters.first
                                    .toUpperCase())),
                            title: Text(e.playerName),
                            trailing:
                                Text(e.isWinner == true ? "Winner" : ".."),
                          ))
                      .toList(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class INWEBView extends StatefulWidget {
  const INWEBView({super.key});

  @override
  State<INWEBView> createState() => _INWEBViewState();
}

class _INWEBViewState extends State<INWEBView> {
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: InAppWebView(
        initialUrlRequest:
            URLRequest(url: Uri.parse('https://example.walletconnect.org')),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
          ),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        shouldOverrideUrlLoading: (controller, navAction) async {
          final url = navAction.request.url.toString();
          debugPrint('URL $url');
          if (url.contains('wc?uri=')) {
            final wcUri = Uri.parse(
                Uri.decodeFull(Uri.parse(url).queryParameters['uri']!));

            return NavigationActionPolicy.CANCEL;
          } else if (url.startsWith('wc:')) {
            return NavigationActionPolicy.CANCEL;
          } else {
            return NavigationActionPolicy.ALLOW;
          }
        },
      ),
    );
  }
}
