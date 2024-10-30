// @ts-nocheck
'use client';
import Image from "next/image";
import Link from 'next/link'
import { useRouter } from "next/navigation";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { Account, Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
import React from "react";
import { disconnect } from "process";
import { partyContractAddress } from '../_utils/helper';



export default function Home() {
  const [codename, setCodename] = React.useState("");
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
  const config = new AptosConfig({ network: Network.CUSTOM });
  const aptos = new Aptos(config);

  React.useEffect(() => {
    if(connected == false) {
      router.push("/");
    }
  }, [connected])


  const handleCreateCodename = async () => {
    if (codename == "") {
      window.alert("Please enter a codename.");
      return;
    }
    if (codename.length > 20) {
      window.alert("Codename must be less than 20 characters.");
      return;
    }
    if (!codename.match(/^[a-zA-Z0-9_]+$/)) {
      window.alert("Codename must be alphanumeric.");
      return;
    }
    console.log("handleCreateCodename");
    const transaction:InputTransactionData = {
        data: {
        // All transactions on Aptos are implemented via smart contracts.
        function: `${partyContractAddress}::party::update_player_name`,
        functionArguments: [codename],
        },
      };
      console.log(transaction);
      const response = await signAndSubmitTransaction(transaction).catch (error => {
        console.log("error",error);
        window.alert("Oops, something went wrong.\nPlease make sure you have $MOVE for gas and try again.");
      });
      if(response == undefined) {
        return;
      }
      await aptos.waitForTransaction({transactionHash:response.hash}).catch (error => {
        console.log("error",error);
      });
      router.push("/faction");
  }
  return (
    <div id="createprofile" className="index container-block bgsize">
      <div className="index-content">
        <div></div>
        <div></div>
        <div id="code-box">
          <img src="./img/entercode_text.png"/>
          <input type="text"
            style={{color: "black", fontFamily:"Chakra Petch", fontSize:"24px", paddingLeft:"10px", marginLeft:"10px"}}
            onChange={(e) => setCodename(e.target.value)}
            value={codename}
           />
        </div>
        <div></div>
        <div id="next_bt">
          <a onClick={handleCreateCodename}><img src="./img/next_button.png"/></a>
        </div>
        <div></div>
      </div>
    </div>
  );
}
