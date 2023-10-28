
import 'package:flutter/material.dart';

  import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyAddressWidget(),
    );
  }
}

class MyAddressWidget extends StatefulWidget {
  @override
  _MyAddressWidgetState createState() => _MyAddressWidgetState();
}

class _MyAddressWidgetState extends State<MyAddressWidget> {
  TextEditingController textController = TextEditingController(text: "c7f086dbd0af7ff720fbc0e94e010863816a930b0dd28b3d145d14793cad5acd");
 Web3Client? ethClient;

  String _submittedText = '';
@override

void initState() {ethClient=Web3Client("https://sepolia.infura.io/v3/8d21c6343f4a4797b4896a3e2aa677e6",http. Client());
    super.initState();
  }
  void _handleSubmit() {
  startElection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TextField with Submit Button'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Enter text',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _handleSubmit,
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
            Text(
              'Submitted Text: $_submittedText',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }


Future<DeployedContract> loadContract() async {
  dynamic str = await rootBundle.loadString('backend/build/contracts/Lottery.json');
  dynamic jsonString=jsonDecode(str);



  String contractAddress = "0x9d15e5B5dc086b6F0548fAb5222025439801Ee34";
  final contract = DeployedContract(ContractAbi.fromJson(jsonEncode(jsonString["abi"]), 'Lottery'),
      EthereumAddress.fromHex(contractAddress));
  return contract;
}

Future<String> callFunction(String funcname, List<dynamic> args,
   ) async {
  EthPrivateKey credentials = EthPrivateKey.fromHex(textController.text);
  DeployedContract contract = await loadContract();
  final ethFunction = contract.function(funcname);
  final result = await ethClient!.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
      ),
      chainId: null,
      fetchChainIdFromNetworkId: true);
  return result;
}




Future<String> startElection() async {
  var response =
      await callFunction('enter', []);
print("kkkkkkkkkkkkkkkkkkkkkkkkk");
print(response);

return response;
}

// Future<String> addCandidate(String name, Web3Client ethClient) async {
//   var response =
//       await callFunction('addCandidate', [name], ethClient, owner_private_key);
//   print('Candidate added successfully');
//   return response;
// }

// Future<String> authorizeVoter(String address, Web3Client ethClient) async {
//   var response = await callFunction('authorizeVoter',
//       [EthereumAddress.fromHex(address)], ethClient, owner_private_key);
//   print('Voter Authorized successfully');
//   return response;
// }

// Future<List> getCandidatesNum(Web3Client ethClient) async {
//   List<dynamic> result = await ask('getNumCandidates', [], ethClient);
//   return result;
// }

// Future<List> getTotalVotes(Web3Client ethClient) async {
//   List<dynamic> result = await ask('getTotalVotes', [], ethClient);
//   return result;
// }

// Future<List> candidateInfo(int index, Web3Client ethClient) async {
//   List<dynamic> result =
//       await ask('candidateInfo', [BigInt.from(index)], ethClient);
//   return result;
// }

// Future<List<dynamic>> ask(
//     String funcName, List<dynamic> args, Web3Client ethClient) async {
//   final contract = await loadContract();
//   final ethFunction = contract.function(funcName);
//   final result =
//       ethClient.call(contract: contract, function: ethFunction, params: args);
//   return result;
// }

// Future<String> vote(int candidateIndex, Web3Client ethClient) async {
//   var response = await callFunction(
//       "vote", [BigInt.from(candidateIndex)], ethClient, voter_private_key);
//   print("Vote counted successfully");
//   return response;
// }


}
