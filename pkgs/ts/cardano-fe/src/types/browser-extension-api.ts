import { WalletApi } from './cip-30';

export type BrowserExtensionApi = {
  enable: () => Promise<WalletApi>;
  isEnabled: () => Promise<boolean>;
};
