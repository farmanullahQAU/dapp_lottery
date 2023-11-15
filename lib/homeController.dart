import 'dart:convert';
import 'package:dapp2/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

import 'package:web3dart/web3dart.dart';


class HomeController extends GetxController {
  final TextEditingController addressController =
      TextEditingController(text: "");

  final TextEditingController nameController = TextEditingController(text: "");
  final RxString greeting = ''.obs;
  RxBool isLoading = false.obs;
  dynamic abiJson;
  String? contractAddress = "0xd030488Ae2107695CED467fF369a1f83179fc709";//deployed contract address
  DeployedContract? contract;
  ContractEvent? addPlayerEvent;
  ContractEvent? winnerPickedEvent;

  Web3Client? client;
  String rpcUrl = "${dotenv.env['INFURA_URL']}";
  Uri? uri;
  double? balance = 0;
  EthereumAddress? manager;

  List<Player> players = [];

  @override
  void onInit() async {

        client = Web3Client(rpcUrl, Client());
   
      await initData();
  



    super.onInit();
  }

Future initData() async {
  try {
    final abiString = await rootBundle
        .loadString("backend/build/contracts/Lottery.json");

    abiJson = jsonDecode(abiString);

    contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abiJson["abi"]), 'Lottery'),
      EthereumAddress.fromHex(contractAddress!),
    );

    winnerPickedEvent = contract?.event("WinnerPicked");
  //  listenToAddPlayerEvent();
    listenToPickWinnerEvent();
    
    await getTotalPlayers();
    await totalBalance();
    await getManager();
    
  
   
  } catch (err) {
    Get.snackbar("Error", err.toString());
  }
}

  Future<String> contractFunction(String functionName, List<dynamic> args,
      String key, EtherAmount? contribution) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(key);
    final ethFunction = contract!.function(functionName);

    // final maxGas=await getEstimatedGasLimit(credentials);  
    final result = await client!.sendTransaction(
        credentials,
        
        Transaction.callContract(
            contract: contract!,
            function: ethFunction,
            parameters: args,
            value: contribution, 
  ),
        chainId: null,
        
        
        fetchChainIdFromNetworkId: true);
    update();
    return result;
  }
Future<BigInt> getEstimatedGasLimit(Credentials credentials)async{

  return  await client!.estimateGas(
    sender: credentials.address,
  
  );
}
  Future getManager() async {
    await client
        ?.call(
      function: contract!.function('manager'),
      params: [],
      contract: contract!,
    )
        .then((result) {
      manager = result[0];
      update();
    });
  }

  Future getTotalPlayers() async {

    
    try {
      final result = await client?.call(
          contract: contract!,
          function: contract!.function("getTotalMapping"),
          params: []);

   players.clear();

      if (result != null) {

        for (var element in result[0]) {
          
          final map = element.asMap();
          players.add(Player.fromMap(map));

          update();
        }
      }
      totalBalance();
    } catch (error) {
      Get.snackbar("Error", error.toString());
    }
  }

  enterLottery() async {
    isLoading.value = true;

    try {
      final value = EtherAmount.inWei(BigInt.from(1e15));
      await contractFunction(
          "enter", [nameController.text], addressController.text, value);

      Get.snackbar("Success","You have been added to the lottery");

    } catch (error) {
    
    
      Get.snackbar("Error", error.toString());
    }

    isLoading.value = false;
    update();
  }



  pickWinner() async {
    try {
      await contractFunction("pickWinner", [], addressController.text, null);
      

    } catch (error) {
      Get.snackbar("Error", error.toString());
    }
  }

 /*
  listenToAddPlayerEvent() {
    client
        ?.events(FilterOptions.events(
          contract: contract!,
          event: addPlayerEvent!,
        ))
        .take(1)
        .listen((event)async {


      final decoded = addPlayerEvent?.decodeResults(event.topics!, event.data!);

      final map = decoded![0].asMap();
       players.add(Player.fromMap(map));

     await totalBalance();
   
      update();
    }).onError((error){

  Get.snackbar("Error", error);

    });
  }

  */

  listenToPickWinnerEvent() {
    client
        ?.events(FilterOptions.events(
          contract: contract!,
          event: winnerPickedEvent!,
        ))
        .take(1)
        .listen((event) {
      final decoded =
          winnerPickedEvent?.decodeResults(event.topics!, event.data!);

      final map = decoded![0].asMap();

      final winner = Player.fromMap(map);


      Get.defaultDialog(
          barrierDismissible: false,
          title: winner.playerName,
          content: Column(
            children: [
              const Icon(
                Icons.emoji_events,
                size: 40,
              ),
              const SizedBox(
                height: 16,
              ),
              Text("${winner.playerName} has won the lottery. "),
            ],
          ),
          onConfirm: () async {
        players.clear();
        addressController.clear();
        balance=0;
      update();

            Get.back();

          });


  
    });
  }
  Future totalBalance() async {
    final funciton = contract?.function("totalBalance");

    final res = await client?.call(
      contract: contract!,
      function: funciton!,
      params: [],
    );

    if (res != null) {
      final weiValue = BigInt.parse("${res[0]}");
      balance = EtherAmount.fromBigInt(EtherUnit.wei, weiValue)
          .getValueInUnit(EtherUnit.ether);
    }

    update();
  }
}
