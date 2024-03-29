import 'package:dapp2/models/chain_metadata.dart';

class WalletConstants {
  static const mainChainMetaData = ChainMetadata(
    type: "eip155",
    chainId: 'eip155:1',
    name: 'Ethereum',
    // method: "personal_sign",
    // method: "wallet_switchEthereumChain",
    method: "personal_sign",

    events: ["chainChanged", "accountsChanged"],
    relayUrl: "wss://relay.walletconnect.com",
    projectId: "68ccdce69aec001e3cd0b33aec530b81",
    redirectUrl: "metamask://com.example.metamask_login_blog",
    walletConnectUrl: "https://walletconnect.com",
  );
  static const deepLinkMetamask = "metamask://wc?uri=";

  static const sepoliaTestnetMetaData = ChainMetadata(
    type: "eip155",
    chainId: 'eip155:11155111',
    name: 'Sepolia Testnet',
    method: "eth_sendTransaction",
    events: ["chainChanged", "accountsChanged"],
    relayUrl: "wss://relay.walletconnect.com",
    projectId: "68ccdce69aec001e3cd0b33aec530b81",
    redirectUrl: "metamask://com.example.metamask_login_blog",
    walletConnectUrl: "https://walletconnect.com",
  );
}
