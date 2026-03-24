import { createContext, useContext, useReducer, type ReactNode } from "react";

interface VaultState {
  currentVaultId: number | null;
  isUnlocked: boolean;
  vaultMode: "owner" | "executor";
  ownerName: string;
}

type VaultAction =
  | { type: "UNLOCK_VAULT"; payload: { vaultId: number; ownerName: string; mode: "owner" | "executor" } }
  | { type: "LOCK_VAULT" }
  | { type: "SET_MODE"; payload: "owner" | "executor" }
  | { type: "SET_OWNER_NAME"; payload: string }
  | { type: "SET_VAULT_ID"; payload: number };

const initialState: VaultState = {
  currentVaultId: null,
  isUnlocked: false,
  vaultMode: "owner",
  ownerName: "",
};

function vaultReducer(state: VaultState, action: VaultAction): VaultState {
  switch (action.type) {
    case "UNLOCK_VAULT":
      return {
        ...state,
        currentVaultId: action.payload.vaultId,
        isUnlocked: true,
        ownerName: action.payload.ownerName,
        vaultMode: action.payload.mode as "owner" | "executor",
      };
    case "LOCK_VAULT":
      return { ...state, isUnlocked: false };
    case "SET_MODE":
      return { ...state, vaultMode: action.payload };
    case "SET_OWNER_NAME":
      return { ...state, ownerName: action.payload };
    case "SET_VAULT_ID":
      return { ...state, currentVaultId: action.payload };
    default:
      return state;
  }
}

interface VaultContextValue {
  state: VaultState;
  dispatch: React.Dispatch<VaultAction>;
  unlockVault: (vaultId: number, ownerName: string, mode: string) => void;
  lockVault: () => void;
}

const VaultContext = createContext<VaultContextValue | null>(null);

export function VaultProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(vaultReducer, initialState);

  const unlockVault = (vaultId: number, ownerName: string, mode: string) => {
    dispatch({
      type: "UNLOCK_VAULT",
      payload: { vaultId, ownerName, mode: mode as "owner" | "executor" },
    });
  };

  const lockVault = () => {
    dispatch({ type: "LOCK_VAULT" });
  };

  return (
    <VaultContext.Provider value={{ state, dispatch, unlockVault, lockVault }}>
      {children}
    </VaultContext.Provider>
  );
}

export function useVault() {
  const context = useContext(VaultContext);
  if (!context) {
    throw new Error("useVault must be used within a VaultProvider");
  }
  return context;
}
