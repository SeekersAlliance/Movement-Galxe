// @ts-nocheck
'use client';
import { PetraWallet } from "petra-plugin-wallet-adapter";
import { NightlyWallet } from "@nightlylabs/aptos-wallet-adapter-plugin";
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import { AptosConfig, Aptos, Network } from "@aptos-labs/ts-sdk";

 
// Import the CSS for the connectors.
export function Provider({ children }: { children: React.ReactNode }) {
  const wallets = [new PetraWallet(), new NightlyWallet()];
  return (
    <AptosWalletAdapterProvider plugins={wallets} autoConnect={false}>
      {children}
    </AptosWalletAdapterProvider>
  );
}