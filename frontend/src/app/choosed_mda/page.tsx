// @ts-nocheck
'use client';
import Link from 'next/link'
import React from 'react'
import { useRouter } from "next/navigation";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Account, Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
import { nftContractAddress } from '../_utils/helper';


const Home = () => {
  const [popup, setPopup] = React.useState(false)
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

  const handleChooseNFT = async (idx: number) => {
    if(popup) return

    const transaction:InputTransactionData = {
      data: {
      // All transactions on Aptos are implemented via smart contracts.
      function: `${nftContractAddress}::nft::mint`,
      functionArguments: ["Movement-Galxe", idx],
      },
    };
    console.log(transaction);
    const response = await signAndSubmitTransaction(transaction).catch (error => {
      console.log("error",error);
      window.alert("Please try again. Maybe you are already mint the NFT.");
      router.push("/");
    });
    console.log(response);
    await aptos.waitForTransaction({transactionHash:response.hash}).catch (error => {
      console.log("error",error);
    });




    setPopup(true)
  }
  return (
    <>
    <div className="choose container-block bgsize">
      <img className="logo" src="./img/logo.png" />
      <div className="page-title">
        <img src="./img/title3.png" />
      </div>
      <div className="choose-content">
        <div className="choose-box">
          <img onClick={()=>handleChooseNFT(4)} src="./img/mda_m.png" />
          <img onClick={()=>handleChooseNFT(5)} src="./img/mda_f.png" />
        </div>
        <div className="popup" style={{display:popup?"grid":"none"}}>
          <div></div>
          <div>
            <a href="https://twitter.com/SeekersAlliance" target="_self"><img src="./img/x_button.png" /></a>
            <a href="https://discord.gg/PRPC9xJxPW" target="_self"><img src="./img/dc_button.png" /></a>
          </div>
        </div>
      </div>
    </div>
    </>
  )
}

export default Home