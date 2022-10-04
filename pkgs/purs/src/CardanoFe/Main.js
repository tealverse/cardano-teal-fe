export const isWalletEnabledImpl = walletName =>
  window.cardano[walletName].isEnabled();

export const getBrowserWalletsImpl = () =>
  window.cardano ? Object.keys(window.cardano) : [];

export const getWalletApiImpl = walletName =>
  window.cardano[walletName].enable();
