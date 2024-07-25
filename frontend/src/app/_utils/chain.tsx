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


export const connectWallet = async () => {
    console.log(wallets);
    console.log(wallet);
}
