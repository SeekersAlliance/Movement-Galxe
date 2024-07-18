// @ts-nocheck
'use client';
import { PetraWallet } from "petra-plugin-wallet-adapter";
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import { AptosConfig, Aptos, Network } from "@aptos-labs/ts-sdk";

 
// Import the CSS for the connectors.
export function Provider({ children }: { children: React.ReactNode }) {
  const wallets = [new PetraWallet()];
  const aptosConfig = new AptosConfig({ network: Network.MAINNET });
  const aptos = new Aptos(aptosConfig);
  return (
    <AptosWalletAdapterProvider plugins={wallets} autoConnect={false}>
      {children}
    </AptosWalletAdapterProvider>
  );
}