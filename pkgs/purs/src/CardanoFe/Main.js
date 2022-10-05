import * as CSL from '@emurgo/cardano-serialization-lib-asmjs';

export const isWalletEnabledImpl = walletName =>
  window.cardano && window.cardano[walletName]
    ? window.cardano[walletName].isEnabled()
    : Promise.reject();

export const getBrowserWalletsImpl = () =>
  window.cardano ? Object.keys(window.cardano) : [];

// TODO: check if checks are necessary
export const getWalletApiImpl = walletName =>
  window.cardano && window.cardano[walletName]
    ? window.cardano[walletName].enable()
    : Promise.reject();

export const adaRawToLovelace = cbor => {
  const balance = CSL.Value.from_bytes(hexToBytes(cbor));
  const lovelaces = balance.coin().to_str();

  console.log(lovelaces);

  return 1;
};

function hexToBytes(hex) {
  for (var bytes = [], c = 0; c < hex.length; c += 2)
    bytes.push(parseInt(hex.substr(c, 2), 16));
  return bytes;
}
