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
