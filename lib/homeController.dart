// home_controller.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

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
}

// data() {
//   Future<DeployedContract> loadContract() async {
//     String abi = await rootBundle.loadString('assets/abi.json');
//     String contractAddress = "";
//     final contract = DeployedContract(ContractAbi.fromJson(abi, 'Election'),
//         EthereumAddress.fromHex(contractAddress));
//     return contract;
//   }

//   Future<String> callFunction(String funcname, List<dynamic> args,
//       Web3Client ethClient, String privateKey) async {
//     EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
//     DeployedContract contract = await loadContract();
//     final ethFunction = contract.function(funcname);
//     final result = await ethClient.sendTransaction(
//         credentials,
//         Transaction.callContract(
//           contract: contract,
//           function: ethFunction,
//           parameters: args,
//         ),
//         chainId: null,
//         fetchChainIdFromNetworkId: true);
//     return result;
//   }

//   Future<String> startElection(String name, Web3Client ethClient) async {
//     var response = await callFunction(
//         'startElection', [name], ethClient, owner_private_key);
//     print('Election started successfully');
//     return response;
//   }

//   Future<String> addCandidate(String name, Web3Client ethClient) async {
//     var response = await callFunction(
//         'addCandidate', [name], ethClient, owner_private_key);
//     print('Candidate added successfully');
//     return response;
//   }

//   Future<String> authorizeVoter(String address, Web3Client ethClient) async {
//     var response = await callFunction('authorizeVoter',
//         [EthereumAddress.fromHex(address)], ethClient, owner_private_key);
//     print('Voter Authorized successfully');
//     return response;
//   }

//   Future<List> getCandidatesNum(Web3Client ethClient) async {
//     List<dynamic> result = await ask('getNumCandidates', [], ethClient);
//     return result;
//   }

//   Future<List> getTotalVotes(Web3Client ethClient) async {
//     List<dynamic> result = await ask('getTotalVotes', [], ethClient);
//     return result;
//   }

//   Future<List> candidateInfo(int index, Web3Client ethClient) async {
//     List<dynamic> result =
//         await ask('candidateInfo', [BigInt.from(index)], ethClient);
//     return result;
//   }

//   Future<List<dynamic>> ask(
//       String funcName, List<dynamic> args, Web3Client ethClient) async {
//     final contract = await loadContract();
//     final ethFunction = contract.function(funcName);
//     final result =
//         ethClient.call(contract: contract, function: ethFunction, params: args);
//     return result;
//   }

//   Future<String> vote(int candidateIndex, Web3Client ethClient) async {
//     var response = await callFunction(
//         "vote", [BigInt.from(candidateIndex)], ethClient, voter_private_key);
//     print("Vote counted successfully");
//     return response;
//   }
// }
