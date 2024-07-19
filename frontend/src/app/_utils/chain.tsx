import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Account, Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
const {
    connect,
    account,
    network,
    connected,
    disconnect,
    wallet,
    wallets,
    signAndSubmitTransaction,
    signTransaction,
    signMessage,
    signMessageAndVerify,
  } = useWallet();
const aptosConfig = new AptosConfig({ network: Network.MAINNET });
const aptos = new Aptos(aptosConfig);

export const connectWallet = async () => {
    console.log(wallets);
    console.log(wallet);
}
