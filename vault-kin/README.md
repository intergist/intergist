Vault Kin
see app spec under doc

Imporant: Before the first Android build, you must run:

cd vault-kin/app
npx cap add android

This generates the android/ directory and requires the Android SDK. It was intentionally not run here (no SDK in this environment). The generated android/ directory should be committed after running.
What was NOT modified

    No changes to server-side code (server/, shared/schema.ts)
    No changes to existing client components or pages
    No changes to existing routing, state management, or API calls

Test plan

    Verify npm run build:web succeeds in vault-kin/app/
    Verify service worker is generated in dist/public/
    Verify manifest.webmanifest is generated with correct Vault Kin values
    Verify self-hosted fonts load correctly (no CDN requests in DevTools Network tab)
    Run npx cap add android locally with Android SDK
    Run npx cap sync android to copy web assets
    Build debug APK with npm run cap:build:debug
    Test APK on Android device/emulator — verify offline operation
    Verify CI/CD workflow triggers on vault-kin/app/ changes
