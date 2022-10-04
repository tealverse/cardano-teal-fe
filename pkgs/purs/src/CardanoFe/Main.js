export const isWalletEnabledImpl = walletName =>
  window.cardano && window.cardano[walletName]
    ? Promise.reject()
    : window.cardano[walletName].isEnabled();

export const getBrowserWalletsImpl = () =>
  window.cardano ? Object.keys(window.cardano) : [];

// TODO: check if checks are necessary
export const getWalletApiImpl = walletName =>
  window.cardano && window.cardano[walletName]
    ? Promise.reject()
    : window.cardano[walletName].enable();
