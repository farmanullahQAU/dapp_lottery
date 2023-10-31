// home_controller.dart
import 'dart:convert';

import 'package:dapp2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:walletconnect_flutter_v2/apis/auth_api/models/auth_client_models.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/json_rpc_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/proposal_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/sign_client_models.dart';
import 'package:walletconnect_flutter_v2/apis/web3app/web3app.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3modal_flutter/services/w3m_service/w3m_service.dart';

class HomeController extends GetxController {
  final TextEditingController addressController = TextEditingController(
      text: "f4db5f7f9cb31f768245dec6c9472657ca6ac6b5dd74cd9d28634ab7e9e5487b");
  final RxString greeting = ''.obs;
  dynamic abiJson;
  String? contractAddress = "0x8c5F513fa9AB9Ee51Ed4aEf0B80fd9FfDB3f7746";
  // "f4db5f7f9cb31f768245dec6c9472657ca6ac6b5dd74cd9d28634ab7e9e5487b"
  DeployedContract? contract;
  Web3Client? client;
  String rpcUrl =
      "https://sepolia.infura.io/v3/8d21c6343f4a4797b4896a3e2aa677e6";
  W3MService? w3mService;
  Uri? uri;
  dynamic res;
  List<dynamic> players = [];

  @override
  void onInit() async {
    await initData();
    await getTotalPlayers();
    super.onInit();
  }

  Future initData() async {
    final abiString =
        await rootBundle.loadString("backend/build/contracts/Lottery.json");

    abiJson = jsonDecode(abiString);

    client = Web3Client(rpcUrl, Client());

    contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(abiJson["abi"]), 'Lottery'),
        EthereumAddress.fromHex(contractAddress!));
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

  Future getTotalPlayers() async {
    await client!.call(
        contract: contract!,
        function: contract!.function("getTotalMapping"),
        params: []).then((result) {
      print(result);
      for (int i = 0; i < result.length; i++) {
        players[i] = result;
        update();
      }
    });
  }

  enterLottery() async {
    try {
      final value = EtherAmount.fromInt(EtherUnit.ether, 1);
      await contractFunction("enter", ["ali"], addressController.text, value);
      print("Entered successfully");
    } catch (err) {
      print(err);
    }
  }

  totalBalance() async {
    final ethFunction = contract!.function("totalBalance");

    final res = await client!.call(
      contract: contract!,
      function: ethFunction,
      params: [],
    );

    print(res);
  }

  pickWinner() async {
    await contractFunction("pickWinner", [], addressController.text, null);
  }

  printD() async {
    print(res);
  }

  initWallet() async {
    final web3App = await Web3App.createInstance(
      projectId: '5c0084b2871e8713252aa018c78e9a52',
      metadata: const PairingMetadata(
        name: 'Web3Modal Flutter Example',
        description: 'Web3Modal Flutter Example',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'flutterdapp://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );

    w3mService = W3MService(web3App: web3App);
    update();

    await w3mService?.init();

    await w3mService!.launchConnectedWallet();
    update();

    res = await w3mService!.web3App?.request(
      topic: w3mService!.session!.topic,
      chainId: 'eip155:1',
      request: SessionRequestParams(
        method: 'transferFrom',
        params: [
          '0xdeadbeef', // The address of the account that you are transferring Ether from.
          '0x1234567890abcdef1234567890abcdef12345678', // The address of the account that you are transferring Ether to.
          BigInt.from(
              1000000000000000000), // The amount of Ether that you want to transfer.
        ],
      ),
    );
  }
}
