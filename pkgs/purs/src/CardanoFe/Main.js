export const isWalletEnabledImpl = walletName =>
  window.cardano[walletName].isEnabled;


export const getBrowserWalletsImpl = () =>
  Object.keys(window.cardano);

