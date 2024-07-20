// @ts-nocheck
'use client';
import Image from "next/image";
import Link from 'next/link'
import { useRouter } from "next/navigation";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Account, Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
import React from "react";
import { disconnect } from "process";



export default function Home() {
  const router = useRouter();
  const {
    connect,
    disconnect,
    account,
    network,
    connected,
    wallet,
    wallets,
  } = useWallet();

  React.useEffect(() => {
    const checkTestnet = async () => {
      if(network == null) return;
      if (network?.name != "testnet") {
        window.alert("Please connect to testnet.");
        await disconnect();
        router.push("/");
      }else{
        router.push("/createprofile");
      }
    };
    checkTestnet();
    
  }
  , [network]);


  const handleConnectWallet = async () => {
    let petra = wallets?.filter((w) => w.name == "Petra")[0];
    console.log(petra);
    console.log(network);
    
    if(connected && network.name == "testnet") {
      console.log("connected");
      router.push("/faction");
    }
    if (petra.readyState == "NotDetected") {
      window.alert("Petra wallet not found.");
      window.open("https://chromewebstore.google.com/detail/petra-aptos-wallet/ejjladinnckdgjemekebdpeokbikhfci", "_blank");
      return
    }
    let res = await connect(petra?.name);
  }
  return (
    <div id="index" className="container-block bgsize">
      <div id="index-content">
        <div></div>
        <div></div>
        <div id="cnt_bt">
          <a onClick={handleConnectWallet}><img src="./img/connect_button.png" /></a>
        </div>
        <div></div>
      </div>
    </div>
  );
}
