'use client';
import Image from "next/image";
import Link from 'next/link'
import { useRouter } from "next/navigation";

export default function Home() {
  const router = useRouter();

  const handleConnectWallet = async () => {
    router.push("/faction");
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
