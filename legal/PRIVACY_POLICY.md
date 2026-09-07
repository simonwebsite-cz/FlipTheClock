# Privacy Policy — FlipTheClock

**Effective date:** 7 September 2026
**Applies to:** the FlipTheClock application, in all its distributed forms (Windows screensaver, Android application, macOS application), and this repository's source code.

## 1. Summary

FlipTheClock does not collect, store, transmit, sell, or share any personal data, under any legal definition of that term (including Article 4(1) GDPR and equivalent definitions in other jurisdictions). It has no network permission, no analytics, no crash reporting, no advertising, and no third-party SDKs. Everything below exists to make that statement legally precise, not to walk it back.

## 2. Scope

This policy covers the official builds of FlipTheClock distributed via this project's GitHub Releases. It does not cover forks, modified builds, or redistributions by third parties, which may behave differently — always obtain FlipTheClock from the official repository if you rely on this policy.

## 3. What the application does on your device

FlipTheClock reads your device's system clock and your locally configured settings (12/24-hour format, seconds display, date display, color theme, font) to render a flip-clock display. Your settings choices are written to local, application-scoped storage (e.g. Windows registry values under the app's own key, Android `SharedPreferences`, or macOS `UserDefaults`, depending on platform) purely so the app remembers your preferences between launches.

This local storage never leaves your device. It is not synced, backed up to any server, or made available to us or to any third party. Because no data is transmitted or processed by us, it falls outside the scope of "processing" that would otherwise trigger GDPR obligations — there is no controller-processor relationship, no cross-border transfer, and no data subject request we could technically fulfil beyond "uninstall the app and its local storage goes with it."

## 4. What we do not do

- We do not request network or internet permissions on any platform.
- We do not use analytics, telemetry, or usage tracking of any kind.
- We do not use crash-reporting services.
- We do not display advertising.
- We do not integrate any third-party SDK, library, or service that collects data.
- We do not use cookies (the application is not a website; this policy's web-adjacent language is included only because some distribution platforms require it).
- We do not knowingly collect data from anyone, including children — there is no mechanism by which we could, since nothing is collected from anyone.

## 5. Legal basis for processing

Not applicable. Under Article 6 GDPR, a legal basis is required only where personal data is processed. FlipTheClock performs no such processing, so no legal basis analysis arises. If a future version of this application were to introduce any data processing (for example, optional crash reporting), this policy will be updated first, the change will be clearly disclosed in the release notes, and — where required by law — your consent will be obtained before that processing begins.

## 6. Your rights

Because we hold no personal data about you, the GDPR rights of access, rectification, erasure, restriction, portability, and objection (Articles 15–21) have no data for us to act on. Any settings data on your device is already fully within your control: it can be inspected, changed, or deleted at any time through the application's own settings screen, or by uninstalling the application.

If you believe this is inaccurate, or if you have any other privacy question, contact us using the details in Section 8.

## 7. Changes to this policy

If this policy changes — most likely because a future feature introduces optional data processing — the "Effective date" above will be updated and the change will be noted in that release's release notes on GitHub. We recommend checking this file for the version matching your installed release if you have concerns.

## 8. Contact

For privacy questions regarding FlipTheClock, contact: **info@tichysimon.cz**

## 9. Not affiliated with Fliqlo

FlipTheClock is an independent open-source project. It is not affiliated with, endorsed by, or connected to Fliqlo, Yuji Adachi, or 9031.com. See [TRADEMARK_NOTICE.md](./TRADEMARK_NOTICE.md) for details.
