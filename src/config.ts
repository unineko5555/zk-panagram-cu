import { http, createConfig } from "wagmi";
import { sepolia } from "wagmi/chains";
import { metaMask, safe, walletConnect } from "wagmi/connectors";

const rpcUrl = import.meta.env.VITE_SEPOLIA_RPC_URL!;
export const config = createConfig({
  chains: [sepolia],
  connectors: [
    walletConnect({ projectId: import.meta.env.VITE_PUBLIC_WC_PROJECT_ID! }),
    metaMask(),
    safe(),
  ],
  transports: {
    [sepolia.id]: http(rpcUrl),
  },
});
