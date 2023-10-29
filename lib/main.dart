// main.dart

import 'package:dapp2/homeController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart';

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
            onPressed: controller.getTotalPlayers,
            child: const Icon(Icons.touch_app_outlined)),
        appBar: AppBar(
          title: const Text('GetX Simple Form'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Obx(() => Text(
                    controller.greeting.value,
                    style: const TextStyle(fontSize: 20),
                  )),
              Text(controller.players.length.toString()),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.players.length,
                  itemBuilder: (_, index) {
                    final rs = controller.players[index];

                    return Text(rs.toString());
                  })
            ],
          ),
        ),
      ),
    );
  }
}
