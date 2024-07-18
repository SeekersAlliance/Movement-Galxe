'use client';
import Link from 'next/link'
import React from 'react'

const Home = () => {
  const [popup, setPopup] = React.useState(false)
  const handleChooseNFT = async (idx: number) => {
    if(popup) return
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
          <img onClick={()=>handleChooseNFT(2)} src="./img/glh_m.png" />
          <img onClick={()=>handleChooseNFT(3)} src="./img/glh_f.png" />
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