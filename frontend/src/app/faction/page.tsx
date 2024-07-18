import Link from 'next/link'
import React from 'react'

const Home = () => {
  return (
    <>
    <div id="faction" className="container-block bgsize">
      <img className="logo" src="./img/logo.png" />
      <div className="page-title">
        <img src="./img/title2.png" />
      </div>
      <div className="faction-card-box">
        <Link href="./choosed_vdl" target="_self"><img src="./img/vdl.png" /></Link>
        <Link href="./choosed_glh" target="_self"><img src="./img/glh.png" /></Link>
        <Link href="./choosed_mda" target="_self"><img src="./img/mda.png" /></Link>
      </div>
    </div>
    </>
  )
}

export default Home