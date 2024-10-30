// import { NightlyConnectAptosAdapter } from "@nightlylabs/wallet-selector-aptos";
// import { Aptos, AptosConfig } from '@aptos-labs/ts-sdk'

// let _adapter: NightlyConnectAptosAdapter | undefined;
// export const getAdapter = async (persisted = true) => {
//   if (_adapter) return _adapter;
//   _adapter = await NightlyConnectAptosAdapter.build(
//     {
//       appMetadata: {
//         name: "Movement Template",
//         description: "Movement Template",
//         icon: "https://docs.nightly.app/img/logo.png",
//       },
//     },
//     { initOnConnect: false, disableModal: false, disableEagerConnect: true },
//     undefined,
//     {
//       networkDataOverride: {
//         name: "Movement",
//         icon: "https://registry.nightly.app/networks/movement.svg",
//       },
//     }
//   );
//   return _adapter;
// };



// let _provider: Aptos | undefined
// const endpoint = 'https://aptos.testnet.porto.movementlabs.xyz/v1'
// export const getMovement = () => {
//   if (_provider) return _provider
//   const conf = new AptosConfig({
//     fullnode: endpoint,
//   })
//   _provider = new Aptos(conf)
//   return _provider
// }