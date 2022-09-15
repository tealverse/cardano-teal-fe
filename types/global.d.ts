import { BrowserExtensionApi } from '../src/types/browser-extension-api';
import { SupportedWallets } from '../src/types/supported-wallets';

declare global {
  interface Window {
    cardano: {
      [key in SupportedWallets]: BrowserExtensionApi;
    };
  }
}
