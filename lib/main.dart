// main.dart

import 'package:dapp2/homeController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

void main()async {
   await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GetX Simple Form',
      themeMode: ThemeMode.dark,
    
      theme: ThemeData.dark(useMaterial3: true),
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

        appBar: AppBar(

          centerTitle: true,
          title:        Text("TrioLotto",style: context.textTheme.titleLarge,),
        ),
        //f4db5f7f9cb31f768245dec6c9472657ca6ac6b5dd74cd9d28634ab7e9e5487b
        body: Container(
          child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
           
          
            children: [
                        
                       SizedBox(
                width: Get.width*0.7,
                child: Card(
                
                  
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                     Icon(Icons.sentiment_satisfied_alt,size: 100,),
                        Text('Total Contribution ${controller.balance} Ether',style: context.textTheme.titleMedium,),
                      ],
                    ),
                  )),
              ),

              SizedBox(height: 32,),
              TextField(
                controller: controller.nameController,
                decoration:
                    const InputDecoration(
                      
                      border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                      labelText: 'Enter your name'),
              ),
                          SizedBox(height: 32,),

              TextField(
                        
                
                controller: controller.addressController,
                        
            obscureText: true,
            
                decoration:
                    const InputDecoration(
                      
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.key),
                      
                      labelText: 'Paste your address'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.enterLottery,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text('Enter TrioLotto'),
                ),
              ),


                               SizedBox(height: 32,),

               if(controller.players.isNotEmpty)
              Column(
           
              
                children: controller.players
                    .map((e) => ListTile(

                      
                      tileColor:     e.playerAddress==controller.manager?const Color.fromARGB(255, 136, 13, 4):null,
                          leading: CircleAvatar(
                              child: Text(e.playerName.characters.first
                                  .toUpperCase())),
                          title: Text(e.playerName,),
                          subtitle: Text(e.playerAddress!.hex,overflow: TextOverflow.ellipsis,),
trailing:
                        e.playerAddress==controller.manager?

                        ElevatedButton(onPressed: controller.pickWinner, child: const Icon(Icons.touch_app_outlined)):null
                       
                        ))
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
