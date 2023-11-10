import 'dart:convert';
import 'package:dapp2/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

import 'package:web3dart/web3dart.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import 'package:web3modal_flutter/services/w3m_service/w3m_service.dart';

class HomeController extends GetxController {
  final TextEditingController addressController =
      TextEditingController(text: "");

  final TextEditingController nameController = TextEditingController(text: "");
  final RxString greeting = ''.obs;
  RxBool isLoading = false.obs;
  dynamic abiJson;
  String? contractAddress = "0x438B8A1c89482A7a0426DacAD25A0928F5B55211";
  // "f4db5f7f9cb31f768245dec6c9472657ca6ac6b5dd74cd9d28634ab7e9e5487b"
  DeployedContract? contract;
  ContractEvent? addPlayerEvent;
  ContractEvent? winnerPickedEvent;

  Web3Client? client;
  String rpcUrl = "${dotenv.env['INFURA_URL']}";
  W3MService? w3mService;
  Uri? uri;
  double? balance = 0;
  EthereumAddress? manager;

  dynamic res;
  List<Player> players = [];

  @override
  void onInit() async {
    await Future.wait([
      initData(),
    ]);

    listToEvent();
    listToPickWinnerEvent();

    super.onInit();
  }

  Future initData() async {
    try {
      rootBundle
          .loadString("backend/build/contracts/Lottery.json")
          .then((abiString) async {
        abiJson = jsonDecode(abiString);

        client = Web3Client(rpcUrl, Client());

        contract = DeployedContract(
            ContractAbi.fromJson(jsonEncode(abiJson["abi"]), 'Lottery'),
            EthereumAddress.fromHex(contractAddress!));

        addPlayerEvent = contract?.event("PlayerEntered");
        winnerPickedEvent = contract?.event("WinnerPicked");
        await getTotalPlayers();
        await getManager();
        await totalBalance();
      });
    } catch (err) {
      Get.snackbar("Error", err.toString());
    }
  }

  Future<String> contractFunction(String functionName, List<dynamic> args,
      String publicKey, EtherAmount? contribution) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(publicKey);
    final ethFunction = contract!.function(functionName);
    final result = await client!.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract!,
            function: ethFunction,
            parameters: args,
            value: contribution),
        chainId: null,
        fetchChainIdFromNetworkId: true);
    update();
    return result;
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
      if (result != null) {
        for (var element in result[0]) {
          print(element);
          final map = element.asMap();
          players.add(Player.fromMap(map));

          update();
        }
      }
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
    } catch (error) {
      isLoading.value = false;

      Get.snackbar("Error", error.toString());
    }

    isLoading.value = false;
    update();
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

  pickWinner() async {
    try {
      await contractFunction("pickWinner", [], addressController.text, null);
    } catch (error) {
      Get.snackbar("Error", error.toString());
    }
  }

  // initWallet() async {
  //   final web3App = await Web3App.createInstance(
  //     projectId: '5c0084b2871e8713252aa018c78e9a52',
  //     metadata: const PairingMetadata(
  //       name: 'Web3Modal Flutter Example',
  //       description: 'Web3Modal Flutter Example',
  //       url: 'https://www.walletconnect.com/',
  //       icons: ['https://walletconnect.com/walletconnect-logo.png'],
  //       redirect: Redirect(
  //         native: 'flutterdapp://',
  //         universal: 'https://www.walletconnect.com',
  //       ),
  //     ),
  //   );

  //   w3mService = W3MService(web3App: web3App);
  //   update();

  //   await w3mService?.init();

  //   await w3mService!.launchConnectedWallet();
  //   update();

  //   res = await w3mService!.web3App?.request(
  //     topic: w3mService!.session!.topic,
  //     chainId: 'eip155:1',
  //     request: SessionRequestParams(
  //       method: 'transferFrom',
  //       params: [
  //         '0xdeadbeef', // The address of the account that you are transferring Ether from.
  //         '0x1234567890abcdef1234567890abcdef12345678', // The address of the account that you are transferring Ether to.
  //         EtherAmount.inWei(BigInt.from(
  //             1e15)), // The amount of Ether that you want to transfer.
  //       ],
  //     ),
  //   );
  // }
/*
  void listenToBlocks() {
    client!.addedBlocks().listen((block) async {
      final events = await client!.getLogs(
        FilterOptions.events(contract: contract!, event: addPlayerEvent!),
      );
      if (events.isNotEmpty) {

  events.forEach((element) {
    print("data");
    print(element.data);
    print("topic ${element.topics}");});

  


      }
      // for (var log in events) {
      //   handlePlayerEnteredEvent(log);
      // }
    });
  }

*/
  listToEvent() {
    client
        ?.events(FilterOptions.events(
          contract: contract!,
          event: addPlayerEvent!,
        ))
        .take(1)
        .listen((event) {
      final decoded = addPlayerEvent?.decodeResults(event.topics!, event.data!);

      final map = decoded![0].asMap();

      players.add(Player.fromMap(map));

      totalBalance();

      update();
    });
  }

  listToPickWinnerEvent() {
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
            Get.back();
            await getTotalPlayers();
            await totalBalance();
          });

      update();

      // Use the values as needed
      // print('Player entered: $playerName with address $sender');
    });
  }

  void handlePlayerEnteredEvent(FilterEvent log) {
    final decodedData = addPlayerEvent!.decodeResults(log.topics!, log.data!);
    // Update the players' list in your Flutter UI with the new player data
    print('Player Entered: $decodedData');
  }
}
