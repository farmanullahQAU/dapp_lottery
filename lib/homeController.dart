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
import 'package:web3modal_flutter/utils/eth_util.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
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

class SSS extends StatefulWidget {
  const SSS({super.key, required this.swapTheme});
  final void Function() swapTheme;

  @override
  State<SSS> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SSS> {
  IWeb3App? _web3App;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    _web3App = await Web3App.createInstance(
      projectId: "5c0084b2871e8713252aa018c78e9a52",
      metadata: const PairingMetadata(
        name: 'Web3Modal Flutter Example',
        description: 'Web3Modal Flutter Example',
        url: 'https://www.walletconnect.com/',
        icons: ['https://web3modal.com/images/rpc-illustration.png'],
        redirect: Redirect(
          native: 'flutterdapp://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );

    _web3App!.onSessionPing.subscribe(_onSessionPing);
    _web3App!.onSessionEvent.subscribe(_onSessionEvent);

    await _web3App!.init();

    // Loop through all the chain data

    _web3App!.registerEventHandler(
      chainId: 'kadena:mainnet01',
      event: "kadena_transaction_updated",
      handler: null,
    );

    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _web3App!.onSessionPing.unsubscribe(_onSessionPing);
    _web3App!.onSessionEvent.unsubscribe(_onSessionEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Center(
        child: CircularProgressIndicator(
          color: Web3ModalTheme.colorsOf(context).accent100,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Web3ModalTheme.colorsOf(context).background300,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("lll"),
        backgroundColor: Web3ModalTheme.colorsOf(context).background100,
        foregroundColor: Web3ModalTheme.colorsOf(context).foreground100,
        actions: [
          IconButton(
            icon: Web3ModalTheme.maybeOf(context)?.isDarkMode ?? false
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
            onPressed: widget.swapTheme,
          ),
        ],
      ),
      body: _W3MPage(web3App: _web3App!),
    );
  }

  void _onSessionPing(SessionPing? args) {}

  void _onSessionEvent(SessionEvent? args) {}
}

class _W3MPage extends StatefulWidget {
  const _W3MPage({required this.web3App});
  final IWeb3App web3App;

  @override
  State<_W3MPage> createState() => _W3MPageState();
}

class _W3MPageState extends State<_W3MPage> {
  late IWeb3App _web3App;
  late W3MService _w3mService;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _web3App = widget.web3App;
    _web3App.onSessionConnect.subscribe(_onWeb3AppConnect);
    _web3App.onSessionDelete.subscribe(_onWeb3AppDisconnect);

    _initializeService();
  }

  void _initializeService() async {
    _w3mService = W3MService(
      web3App: _web3App,
      featuredWalletIds: {
        'f2436c67184f158d1beda5df53298ee84abfc367581e4505134b5bcf5f46697d',
        '8a0ee50d1f22f6651afcae7eb4253e52a3310b90af5daef78a8c4929a9bb99d4',
        'f5b4eeb6015d66be3f5940a895cbaa49ef3439e518cd771270e6b553b48f31d2',
      },
    );

    // See https://docs.walletconnect.com/web3modal/flutter/custom-chains
    W3MChainPresets.chains.putIfAbsent('42220', () => myCustomChain);
    W3MChainPresets.chains.putIfAbsent('11155111', () => sepoliaTestnet);
    await _w3mService.init();
    // _w3mService.selectChain(myCustomChain);

    setState(() {
      _isConnected = _web3App.sessions.getAll().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _web3App.onSessionConnect.unsubscribe(_onWeb3AppConnect);
    _web3App.onSessionDelete.unsubscribe(_onWeb3AppDisconnect);
    super.dispose();
  }

  void _onWeb3AppConnect(SessionConnect? args) {
    // If we connect, default to barebones
    setState(() {
      _isConnected = true;
    });
  }

  void _onWeb3AppDisconnect(SessionDelete? args) {
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox.square(dimension: 8.0),
          Visibility(
            visible: !_isConnected,
            child: W3MNetworkSelectButton(service: _w3mService),
          ),
          W3MConnectWalletButton(
            service: _w3mService,
            state: ConnectButtonState.none,
          ),
          const SizedBox.square(dimension: 8.0),
          const Divider(height: 0.0),
          Visibility(
            visible: _isConnected,
            child: _ConnectedView(w3mService: _w3mService),
          ),
        ],
      ),
    );
  }

  W3MChainInfo get myCustomChain => W3MChainInfo(
        chainName: 'Celo',
        namespace: 'eip155:42220',
        chainId: '42220',
        tokenName: 'CELO',
        requiredNamespaces: {
          'eip155': const RequiredNamespace(
            methods: [
              'personal_sign',
              'eth_signTypedData',
              'eth_sendTransaction',
            ],
            chains: ['eip155:42220'],
            events: [
              'chainChanged',
              'accountsChanged',
            ],
          ),
        },
        optionalNamespaces: {
          'eip155': const RequiredNamespace(
            methods: [
              'wallet_switchEthereumChain',
              'wallet_addEthereumChain',
            ],
            chains: ['eip155:42220'],
            events: [],
          ),
        },
        rpcUrl: 'https://1rpc.io/celo',
        blockExplorer: W3MBlockExplorer(
          name: 'Celo Scan',
          url: 'https://celoscan.io',
        ),
      );

  W3MChainInfo sepoliaTestnet = W3MChainInfo(
    chainName: 'Sepolia Test Network',
    namespace: 'eip155:11155111',
    chainId: '11155111',
    tokenName: 'SETH',
    requiredNamespaces: {
      'eip155': const RequiredNamespace(
        methods: EthUtil.ethRequiredMethods,
        chains: ['eip155:11155111'],
        events: EthUtil.ethEvents,
      ),
    },
    optionalNamespaces: {
      'eip155': const RequiredNamespace(
        methods: EthUtil.ethOptionalMethods,
        chains: ['eip155:11155111'],
        events: [],
      ),
    },
    rpcUrl: 'https://rpc.sepolia.org',
    blockExplorer: W3MBlockExplorer(
      name: 'Sepolia Etherscan',
      url: 'https://sepolia.etherscan.io',
    ),
  );
}

class _ConnectedView extends StatelessWidget {
  const _ConnectedView({required this.w3mService});
  final W3MService w3mService;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox.square(dimension: 12.0),
        W3MAccountButton(service: w3mService),
        TextButton(
            onPressed: () {
              w3mService.launchConnectedWallet();
            },
            child: const Text("llll")),
        const SizedBox.square(dimension: 12.0),
      ],
    );
  }
}
