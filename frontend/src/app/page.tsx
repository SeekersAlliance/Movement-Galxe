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
      if (network?.chainId != "27") {
        window.alert("Please connect to Movement testnet.");
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
    let nightly = wallets?.filter((w) => w.name == "Nightly")[0];
    console.log(nightly);
    
    
    if(connected && network.name == "testnet") {
      console.log("connected");
      router.push("/faction");
    }
    if (nightly.readyState == "NotDetected") {
      window.alert("Nightly wallet not found.");
      window.open("https://chromewebstore.google.com/detail/nightly/fiikommddbeccaoicoejoniammnalkfa", "_blank");
      return
    }
    let res = await connect(nightly?.name);
  }
  console.log("connected", connected);
  console.log("network", network);
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
