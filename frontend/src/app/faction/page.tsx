// @ts-nocheck
'use client';
import Link from 'next/link'
import React from 'react'
import { useRouter } from "next/navigation";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Account, Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
const partyContractAddress = "0x9cd5227ba33c15e6b2b0cb091ba3e79d3643d4189e83affae1ddedeb00c42d56"

const Home = () => {
  const router = useRouter();
  const {
    connect,
    account,
    network,
    connected,
    wallet,
    wallets,
    signAndSubmitTransaction,
  } = useWallet();
  const config = new AptosConfig({ network: Network.TESTNET });
  const aptos = new Aptos(config);

  React.useEffect(() => {
    if(connected == false) {
      router.push("/");
    }
  }, [connected])

  const handleChooseFaction = async (faction_idx: number) => {

    const transaction:InputTransactionData = {
      data: {
      // All transactions on Aptos are implemented via smart contracts.
      function: `${partyContractAddress}::party::participate`,
      functionArguments: [faction_idx],
      },
    };
    console.log(transaction);
    const response = await signAndSubmitTransaction(transaction).catch (error => {
      console.log("error",error);
      window.alert("Please try again. Maybe you are already participated in a faction.");
      router.push("/");
    });
    console.log(response);
    await aptos.waitForTransaction({transactionHash:response.hash}).catch (error => {
      console.log("error",error);
    });

    if(faction_idx == 1) {
      router.push("/choosed_vdl");
    }else if(faction_idx == 2) {
      router.push("/choosed_glh");
    }else if(faction_idx == 3) {
      router.push("/choosed_mda");
    }
  }
  return (
    <>
    <div id="faction" className="container-block bgsize">
      <img className="logo" src="./img/logo.png" />
      <div className="page-title">
        <img src="./img/title2.png" />
      </div>
      <div className="faction-card-box">
        <a onClick={()=>handleChooseFaction(1)}><img src="./img/vdl.png" /></a>
        <a onClick={()=>handleChooseFaction(2)}><img src="./img/glh.png" /></a>
        <a onClick={()=>handleChooseFaction(3)}><img src="./img/mda.png" /></a>
      </div>
    </div>
    </>
  )
}

export default Home