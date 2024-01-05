import 'dart:convert';

import 'package:convert/convert.dart'; // Import the 'convert' package for hex encoding
import 'package:dapp2/model.dart';
import 'package:dapp2/utils/constants/wallet_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

import 'models/chain_metadata.dart';

enum WalletStatus {
  initializing,
  initialized,
  notInstalled,
  successful,
  authenticating,
  userdenied,
  connectError,
  receivedSignature
}

class HomeController extends GetxController {
  WalletStatus? currentState;

  Web3App? wcClient;
  String? connectedAddress;
  final ChainMetadata _chainMetadata = WalletConstants.sepoliaTestnetMetaData;
  final TextEditingController addressController =
      TextEditingController(text: "");

  final TextEditingController nameController = TextEditingController(text: "");
  final RxString greeting = ''.obs;
  RxBool isLoading = false.obs;
  dynamic abiJson;
  String? contractAddress =
      "0xd030488Ae2107695CED467fF369a1f83179fc709"; //deployed contract address
  DeployedContract? contract;
  ContractEvent? addPlayerEvent;
  ContractEvent? winnerPickedEvent;
  SessionData? sessionData;
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
      final abiString =
          await rootBundle.loadString("backend/build/contracts/Lottery.json");

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

  Future<BigInt> getEstimatedGasLimit(Credentials credentials) async {
    return await client!.estimateGas(
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

      Get.snackbar("Success", "You have been added to the lottery");
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
            balance = 0;
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
  } //wallate SignClient wcClient;

  // Future<bool> onDisplayUri(Uri? uri) async {
  //   final link =
  //       formatNativeUrl(WalletConstants.deepLinkMetamask, uri.toString());
  //   var url = link.toString();
  //   if (!await canLaunchUrlString(url)) {
  //     return false;
  //   }
  //   return await launchUrlString(url);
  // }

  Future<void> disconnectWallet({required String topic}) async {
    await wcClient?.disconnectSession(
        topic: topic, reason: Errors.getSdkError(Errors.USER_DISCONNECTED));
  }

  WalletStatus? state;

  _initWallet() async {
    wcClient = await Web3App.createInstance(
      relayUrl: _chainMetadata.relayUrl,
      projectId: _chainMetadata.projectId,
      metadata: PairingMetadata(
        name: "MetaMask",
        description: "MetaMask login",
        url: _chainMetadata.walletConnectUrl,
        icons: ["https://wagmi.sh/icon.png"],
        // redirect: Redirect(universal: _chainMetadata.redirectUrl)
      ),
    );

    _updateWalletSate(WalletStatus.initialized);
  }

  connectMetaMask() async {
    try {
      if (wcClient == null) {
        await _initWallet();
      }
      ConnectResponse? resp = await wcClient?.connect(requiredNamespaces: {
        _chainMetadata.type: RequiredNamespace(
          chains: [_chainMetadata.chainId], // Ethereum chain
          methods: [_chainMetadata.method], // Requestable Methods
          events: _chainMetadata.events, // Requestable Events
        )
      });

      Uri? uri = resp?.uri;

      if (uri != null) {
        // bool canLaunch = await onDisplayUri(uri);

        await launchUrl(uri);

        sessionData = await resp?.session.future;

        if (resp!.session.isCompleted) {
          connectedAddress = NamespaceUtils.getAccount(
            sessionData!.namespaces.values.first.accounts.first,
          );

          // wcClient?.registerEventHandler(
          //   chainId: _chainMetadata.chainId,
          //   event: 'accountsChanged',
          // );
          // wcClient?.onSessionEvent.subscribe((SessionEvent? session) {
          //   print("SSSSSSSSSSSSSSSSSSSSSSSSS");
          //   print(session?.data.toString());
          // });
          _updateWalletSate(WalletStatus.successful);
        }
      }
    } catch (err) {
      debugPrint("Catch wallet connect error $err");
    }
  }

  enterToLottery() async {
    final transactionData = Transaction.callContract(
        from: EthereumAddress.fromHex(contractAddress!),
        contract: contract!,
        function: contract!
            .function('enter'), // Adjust based on your contract's function
        parameters: [
          "Aslif "
        ], // Adjust based on your contract's function parameters

        value: EtherAmount.inWei(BigInt.from(1e15)));
    String paramJson = '0x${hex.encode(transactionData.data!)}';

    await wcClient?.request(
      topic: sessionData!.topic,
      chainId: _chainMetadata.chainId,
      request: SessionRequestParams(
        method: 'eth_sendTransaction',
        params: [
          // unSignedMessage,walletAddress
          // transactionData.data,

          {
            'from': transactionData.from?.hex,
            'to': EthereumAddress.fromHex(contractAddress!).hex,
            'value':
                '0x${transactionData.value?.getInWei.toRadixString(16)}', // Convert to hex string
            'gas': '53552', // Adjust gas as needed
            // 'gasPrice': '20000000000', // Adjust gas price as needed
            'data': paramJson
          },
        ],
      ),
    );
  }

  _updateWalletSate(WalletStatus status) {
    currentState = status;
    update();
  }
}
