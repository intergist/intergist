import type { CapacitorConfig } from '@capacitor/cli';

/**
 * Capacitor configuration for Vault Kin Android app.
 *
 * webDir points to the Vite build output directory (dist/public/).
 * After building with `npm run build:web`, run `npx cap sync android`
 * to copy web assets into the Android shell.
 *
 * IMPORTANT: Before first use, you must run `npx cap add android`
 * to generate the android/ directory. This requires the Android SDK.
 */
const config: CapacitorConfig = {
  appId: 'com.intergist.vaultkin',
  appName: 'Vault Kin',
  webDir: 'dist/public',
  android: {
    buildOptions: {
      keystorePath: process.env.ANDROID_KEYSTORE_PATH,
      keystoreAlias: process.env.ANDROID_KEY_ALIAS,
    },
  },
  plugins: {
    CapacitorSQLite: {
      androidIsEncryption: false,
      androidBiometric: {
        biometricAuth: false,
      },
    },
  },
};

export default config;
