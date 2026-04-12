# MemoCare — Pre-Publish Checklist

**Repo:** [https://github.com/moyeenhaider3/memo-care](https://github.com/moyeenhaider3/memo-care)  
**GitHub Pages site:** `https://moyeenhaider3.github.io/memo-care/` (landing + shared styles in `docs/`)

| Page | URL |
|------|-----|
| Home | `https://moyeenhaider3.github.io/memo-care/` |
| Privacy | `https://moyeenhaider3.github.io/memo-care/privacy.html` |
| Terms | `https://moyeenhaider3.github.io/memo-care/terms.html` |

This app **does not** use verified App Links or Digital Asset Links for shared HTTPS URLs. **No `.well-known/assetlinks.json` (or iOS AASA) setup is required** for launch unless you later add shareable web links.

---

## 1. Android signing & package ID

- [x] `applicationId` / `namespace` set to `io.github.moyeenhaider3.memocare` in `android/app/build.gradle.kts`
- [x] Release signing wired to read `android/key.properties` when present (falls back to debug if missing for local dev)
- [ ] **Generate keystore** (one-time; keep backup offline):

  ```bash
  cd android
  keytool -genkey -v -keystore memocare.jks -alias memocare -keyalg RSA -keysize 2048 -validity 10000
  ```

- [ ] Copy `android/key.properties.example` → `android/key.properties` and fill passwords and paths
- [ ] **Never** commit `memocare.jks` or `key.properties` (already in `.gitignore`)

---

## 2. GitHub Pages — marketing site + privacy & terms (no `.well-known`)

Static site files live under **`docs/`**: `index.html` (landing), `site.css`, `privacy.html`, `terms.html`. Header + bottom bar on every page link **Home**, **Privacy**, **Terms**, and **GitHub**.

- [ ] Push to **`moyeenhaider3/memo-care`**
- [ ] Repo **Settings → Pages**: Source **Deploy from a branch**, branch **`main`**, folder **`/docs`**, Save
- [ ] After build (~1 min), confirm:

  - `https://moyeenhaider3.github.io/memo-care/`
  - `https://moyeenhaider3.github.io/memo-care/privacy.html`
  - `https://moyeenhaider3.github.io/memo-care/terms.html`

- [ ] If the app shows legal links in Settings, point them to the same URLs (add constants in Dart when you wire UI)

---

## 3. Store listing prep (Play Store)

- [ ] Fill fields from `docs/PLAY_STORE_LISTING.md`
- [ ] 512×512 icon, feature graphic 1024×500, 2+ phone screenshots
- [ ] Data safety form completed accurately (mostly on-device data)
- [ ] Support email that you monitor

---

## 4. Quality & device checks

- [ ] **Real Android devices** (multiple OEMs): exact alarm, notification, full-screen intent, battery optimization prompt
- [ ] Cold start after reboot: alarms reschedule (`BootCompletedReceiver`)
- [ ] `flutter analyze` — clean or only acceptable infos
- [ ] `flutter test` — all pass
- [ ] Release build: `flutter build appbundle --release`

---

## 5. Optional / later

- [ ] Crash reporting (e.g. Firebase Crashlytics) for production
- [ ] iOS build & App Store checklist (separate from this doc)
- [ ] ProGuard / R8 shrinking — only if you add rules and test thoroughly

---

## Quick reference — files

| File | Purpose |
| ---- | ------- |
| `android/memocare.jks` | Release keystore (local only) |
| `android/key.properties` | Passwords + alias (local only) |
| `android/key.properties.example` | Template for teammates |
| `android/app/build.gradle.kts` | `applicationId`, signing |
| `docs/PLAY_STORE_LISTING.md` | Copy for Play Console |
