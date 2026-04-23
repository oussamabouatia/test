# 🚀 GéoCollège → Android APK — Complete Guide

---

## ✅ CONFIRMATION: YES, THIS IS 100% POSSIBLE FOR YOUR CASE

After analyzing your full project, here's the verdict:

| Question | Answer |
|----------|--------|
| Can I convert my web app to APK? | **YES** ✅ |
| Can it work fully offline? | **YES** ✅ |
| Can it include my PWA? | **YES** ✅ |
| Without hosting/public URL? | **YES** ✅ |
| Demo ready for CRMEF? | **YES** ✅ |

**Why it works perfectly for your case:** Your app is **mostly frontend** (HTML/CSS/JS). The PHP backend just serves JSON data from MySQL. We can **snapshot that data into static JSON files** and embed them directly in the APK. The exercises verification logic (currently in `verifier.php`) can be **moved to JavaScript** since it's just a tolerance-based comparison.

---

## PART 1 — Feasibility Analysis

### What Your Project Actually Is

After reviewing every file:

| Component | Technology | Can Go Offline? |
|-----------|-----------|----------------|
| `index.html` | HTML/CSS/JS + fetch to `api/formes.php` | ✅ YES — embed JSON |
| `formes.html` | HTML/CSS/JS + fetch to `api/formes.php` | ✅ YES — embed JSON |
| `theoremes.html` | HTML/CSS/JS + fetch to `api/theoremes.php` | ✅ YES — embed JSON |
| `exercices.html` | HTML/CSS/JS + fetch to `api/exercices.php` + `api/verifier.php` | ✅ YES — embed JSON + JS verification |
| `service-worker.js` | PWA caching | ✅ Already there |
| `manifest.json` | PWA manifest | ✅ Already there |
| PHP Backend | MySQL queries → JSON output | ❌ REPLACE with static JSON |

### Key Insight

Your PHP/MySQL backend does **exactly 4 things**:
1. `formes.php` → Returns JSON array of geometric shapes
2. `theoremes.php` → Returns JSON array of theorems
3. `exercices.php` → Returns JSON array of exercises (without answers)
4. `verifier.php` → Compares student answer to database answer (simple `abs(answer - correct) <= tolerance`)

**All of these can work 100% offline** by:
- Exporting database data to static JSON files
- Moving the verification logic to client-side JavaScript

### Limitations

| Limitation | Impact on Your Project |
|-----------|----------------------|
| No server-side code in APK | ✅ Not a problem — we replace PHP with embedded JSON |
| No MySQL database | ✅ Not a problem — data is static educational content |
| No dynamic content updates | ⚠️ Minor — you'd need to rebuild APK to update exercises |
| APK size larger (~5-15 MB) | ✅ Fine for a demo project |
| No Play Store (unsigned) | ✅ Fine — install via direct APK download |

---

## PART 2 — Method Comparison

### Head-to-Head Comparison

| Criteria | TWA | WebView (Android Studio) | PWABuilder | **Capacitor** | Cordova |
|----------|-----|------------------------|------------|---------------|---------|
| **Difficulty** | 🟡 Medium | 🔴 Hard | 🟢 Easy | 🟢 **Easy** | 🟡 Medium |
| **Coding Required?** | Minimal | Java/Kotlin | None | Minimal | Minimal |
| **Offline Support** | ⚠️ Needs hosting first | ✅ Full | ⚠️ Needs public URL | ✅ **Full** | ✅ Full |
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **No Public URL Needed?** | ❌ NO | ✅ Yes | ❌ NO | ✅ **Yes** | ✅ Yes |
| **Includes Web Assets?** | ❌ Loads from URL | ✅ Bundled | ❌ Loads from URL | ✅ **Bundled** | ✅ Bundled |
| **Modern / Maintained?** | Yes | Yes | Yes | ✅ **Yes** | ❌ Deprecated |
| **Recommended?** | ❌ No (needs hosting) | ❌ Overkill | ❌ No (needs URL) | ✅ **BEST** | ❌ Outdated |

### Why Each Method Fails or Works

| Method | Verdict | Why |
|--------|---------|-----|
| **TWA** | ❌ Rejected | Requires a **public HTTPS URL** — defeats your requirement of "no hosting needed" |
| **WebView** | ❌ Rejected | Requires Android Studio, Java/Kotlin knowledge, manual WebView setup — **overkill** |
| **PWABuilder** | ❌ Rejected | Requires a **live public URL** — same problem as TWA |
| **Capacitor** | ✅ **WINNER** | Bundles all web files INTO the APK, works 100% offline, easy setup, modern |
| **Cordova** | ❌ Rejected | Deprecated, slow, outdated — Capacitor is its modern replacement |

### 🏆 BEST METHOD: **Capacitor (by Ionic)**

**Why Capacitor wins for your case:**
- ✅ Copies your HTML/CSS/JS directly into the APK
- ✅ Works **100% offline** without any server
- ✅ No public URL needed
- ✅ Simple CLI commands (no Java/Kotlin coding)
- ✅ Professional output (real native APK)
- ✅ Your existing PWA manifest + service worker still work

---

## PART 3 — What Your Project Needs

### Current Architecture

```
Browser → fetch('api/formes.php') → PHP → MySQL → JSON → Browser renders
Browser → fetch('api/exercices.php') → PHP → MySQL → JSON → Browser renders  
Browser → POST('api/verifier.php') → PHP → MySQL → comparison → JSON result
```

### Target Architecture (for APK)

```
APK WebView → fetch('data/formes.json') → LOCAL JSON file → Browser renders
APK WebView → fetch('data/exercices.json') → LOCAL JSON file → Browser renders
APK WebView → verifierLocal(answer, correctAnswer) → JS comparison → result
```

### What Needs to Change

| Current | Change To | Effort |
|---------|-----------|--------|
| `fetch('api/formes.php')` | `fetch('data/formes.json')` | 1 line |
| `fetch('api/theoremes.php')` | `fetch('data/theoremes.json')` | 1 line |
| `fetch('api/exercices.php')` | `fetch('data/exercices.json')` | 1 line |
| `POST api/verifier.php` | Local JS function | ~20 lines |
| MySQL database | Static JSON files | Export once |
| PHP backend | Not needed | Remove |

> [!IMPORTANT]
> The **only real work** is exporting your database to JSON and adding a small JS verification function. Everything else is configuration.

---

## PART 4 — Step-by-Step (Full Implementation)

### Prerequisites

You need these tools installed:

| Tool | Command to Check | Install If Missing |
|------|------------------|--------------------|
| Node.js (v18+) | `node -v` | [nodejs.org](https://nodejs.org) |
| npm | `npm -v` | Comes with Node.js |
| Java JDK 17 | `java -version` | [adoptium.net](https://adoptium.net) |
| Android Studio | — | [developer.android.com](https://developer.android.com/studio) |
| Android SDK | Via Android Studio | SDK Manager → API 33+ |

### Step 1: Export Database to JSON

First, start XAMPP and run these URLs in your browser to save the JSON responses:

```
http://localhost/geocollege - Copie/api/formes.php
http://localhost/geocollege - Copie/api/theoremes.php  
http://localhost/geocollege - Copie/api/exercices.php
```

> [!TIP]
> I will automate this with a PHP export script — see the implementation section below.

### Step 2: Create a Clean Build Copy

We'll work in a new folder to keep your original safe:

```powershell
# Create the Capacitor project folder
mkdir "c:\geocollege-apk"
mkdir "c:\geocollege-apk\www"

# Copy all web files (NOT the PHP/config/admin)
Copy-Item "c:\xampp\htdocs\geocollege - Copie\index.html" "c:\geocollege-apk\www\"
Copy-Item "c:\xampp\htdocs\geocollege - Copie\formes.html" "c:\geocollege-apk\www\"
Copy-Item "c:\xampp\htdocs\geocollege - Copie\theoremes.html" "c:\geocollege-apk\www\"
Copy-Item "c:\xampp\htdocs\geocollege - Copie\exercices.html" "c:\geocollege-apk\www\"
Copy-Item "c:\xampp\htdocs\geocollege - Copie\geocollege_figures_animees.html" "c:\geocollege-apk\www\"
Copy-Item "c:\xampp\htdocs\geocollege - Copie\geo-animations.css" "c:\geocollege-apk\www\"
Copy-Item "c:\xampp\htdocs\geocollege - Copie\geo-animations.js" "c:\geocollege-apk\www\"
Copy-Item "c:\xampp\htdocs\geocollege - Copie\pwa.js" "c:\geocollege-apk\www\"
Copy-Item "c:\xampp\htdocs\geocollege - Copie\service-worker.js" "c:\geocollege-apk\www\"
Copy-Item "c:\xampp\htdocs\geocollege - Copie\manifest.json" "c:\geocollege-apk\www\"
Copy-Item "c:\xampp\htdocs\geocollege - Copie\icons" "c:\geocollege-apk\www\icons" -Recurse

# Create data folder for JSON
mkdir "c:\geocollege-apk\www\data"
```

### Step 3: Initialize Capacitor Project

```powershell
cd "c:\geocollege-apk"

# Initialize npm project
npm init -y

# Install Capacitor
npm install @capacitor/core @capacitor/cli

# Initialize Capacitor
npx cap init "GéoCollège" "com.crmef.geocollege" --web-dir www
```

### Step 4: Add Android Platform

```powershell
cd "c:\geocollege-apk"

# Install Android platform
npm install @capacitor/android

# Add Android platform
npx cap add android
```

### Step 5: Configure capacitor.config.ts

Create/replace the config file:

```json
{
  "appId": "com.crmef.geocollege",
  "appName": "GéoCollège",
  "webDir": "www",
  "server": {
    "androidScheme": "https"
  },
  "android": {
    "backgroundColor": "#14532d",
    "allowMixedContent": false
  }
}
```

### Step 6: Set Up App Icons

Android requires multiple icon sizes. Place your icons in the Android project:

```
android/app/src/main/res/mipmap-hdpi/ic_launcher.png      (72x72)
android/app/src/main/res/mipmap-mdpi/ic_launcher.png      (48x48)
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png     (96x96)
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png    (144x144)
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png   (192x192)
```

> [!TIP]
> Use [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html) to generate all sizes from your `icon-512.png`.

### Step 7: Configure Android App Name and Theme

Edit `android/app/src/main/res/values/strings.xml`:

```xml
<?xml version='1.0' encoding='utf-8'?>
<resources>
    <string name="app_name">GéoCollège</string>
    <string name="title_activity_main">GéoCollège</string>
    <string name="package_name">com.crmef.geocollege</string>
    <string name="custom_url_scheme">com.crmef.geocollege</string>
</resources>
```

Edit `android/app/src/main/res/values/styles.xml` to set the green theme:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="AppTheme" parent="Theme.AppCompat.Light.DarkActionBar">
        <item name="colorPrimary">#16a34a</item>
        <item name="colorPrimaryDark">#14532d</item>
        <item name="colorAccent">#4ade80</item>
    </style>
    <style name="AppTheme.NoActionBar" parent="Theme.AppCompat.DayNight.NoActionBar">
        <item name="windowActionBar">false</item>
        <item name="windowNoTitle">true</item>
        <item name="android:background">@null</item>
        <item name="colorPrimary">#16a34a</item>
        <item name="colorPrimaryDark">#14532d</item>
        <item name="colorAccent">#4ade80</item>
    </style>
    <style name="AppTheme.NoActionBar.SplashScreen" parent="AppTheme.NoActionBar">
        <item name="android:background">#14532d</item>
    </style>
</resources>
```

### Step 8: Sync and Build

```powershell
cd "c:\geocollege-apk"

# Copy web files to Android project
npx cap sync android

# Open in Android Studio (to build APK)
npx cap open android
```

Then in Android Studio:
1. **Build → Build Bundle(s) / APK(s) → Build APK(s)**
2. The APK will be at: `android/app/build/outputs/apk/debug/app-debug.apk`
3. Rename to `GeoCollege.apk`

**Or build from command line:**

```powershell
cd "c:\geocollege-apk\android"
.\gradlew.bat assembleDebug
```

APK output: `app/build/outputs/apk/debug/app-debug.apk`

---

## PART 5 — Offline Mode Implementation

This is the **most critical part**. Here's exactly what to change in your HTML files.

### 5.1 — Export Database to JSON

Create this script to run ONCE on your XAMPP:

**File: `export-data.php`** (run at `http://localhost/geocollege - Copie/export-data.php`)

```php
<?php
require_once __DIR__ . '/config/db.php';
$pdo = getDB();

// ── Export formes ──
$formes = $pdo->query("SELECT * FROM vue_formes WHERE actif = 1")->fetchAll();
// (apply same formatting as api/formes.php)
file_put_contents(__DIR__ . '/data/formes.json', json_encode($formes, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));

// ── Export exercices WITH answers (for offline verification) ──
$exercices = $pdo->query("
    SELECT e.id, e.titre, e.enonce, e.valeurs, e.type_calcul,
           e.reponse, e.tolerance, e.unite, e.explication,
           e.etapes, e.niveau, e.difficulte,
           e.forme_slug, e.forme_nom, e.svg_viewbox,
           e.svg_elements, e.categorie
    FROM vue_exercices e WHERE e.actif = 1
")->fetchAll();

foreach ($exercices as &$ex) {
    $ex['valeurs'] = json_decode($ex['valeurs'] ?? '{}', true) ?? [];
    $ex['etapes'] = json_decode($ex['etapes'] ?? '[]', true) ?? [];
    $ex['reponse'] = (float)$ex['reponse'];
    $ex['tolerance'] = (float)$ex['tolerance'];
    $ex['svg'] = ['viewBox' => $ex['svg_viewbox'], 'elements' => $ex['svg_elements'] ?? ''];
    unset($ex['svg_viewbox'], $ex['svg_elements']);
}
file_put_contents(__DIR__ . '/data/exercices.json', json_encode($exercices, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));

// ── Export theoremes ──
$theoremes = $pdo->query("SELECT * FROM theoremes WHERE actif = 1")->fetchAll();
foreach ($theoremes as &$t) {
    $t['formes_liees'] = json_decode($t['formes_liees'] ?? '[]', true) ?? [];
}
file_put_contents(__DIR__ . '/data/theoremes.json', json_encode($theoremes, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));

echo "✅ Exported: formes.json, exercices.json, theoremes.json";
```

### 5.2 — Modify index.html for Offline

Replace the `init()` function fetch URL:

```javascript
// BEFORE (requires PHP server):
const r = await fetch('api/formes.php');

// AFTER (works offline):
const r = await fetch('data/formes.json');
```

### 5.3 — Modify exercices.html for Offline

**Change 1:** Replace the fetch URL:

```javascript
// BEFORE:
const r = await fetch('api/exercices.php');

// AFTER:
const r = await fetch('data/exercices.json');
```

**Change 2:** Add client-side verification (replaces `api/verifier.php`):

Replace the `verifier()` function with this fully offline version:

```javascript
async function verifier(exId) {
  const input = document.getElementById(`input-${exId}`);
  const btn   = document.getElementById(`btn-${exId}`);
  const resEl = document.getElementById(`result-${exId}`);
  const card  = document.getElementById(`ex-card-${exId}`);

  const valeur = parseFloat(input.value);
  if (isNaN(valeur) || input.value.trim() === '') {
    input.style.borderColor = 'var(--amber)';
    input.focus();
    return;
  }

  btn.disabled = true;
  btn.textContent = '…';

  // ── OFFLINE VERIFICATION (no server needed) ──
  const ex = EXERCICES.find(e => e.id === exId || e.id === String(exId));
  if (!ex || ex.reponse === undefined) {
    btn.disabled = false;
    btn.textContent = 'Vérifier';
    resEl.className = 'ex-result show';
    resEl.innerHTML = `<div class="result-wrong"><div class="result-message">⚠️ Exercice non trouvé.</div></div>`;
    return;
  }

  const bonne_reponse = parseFloat(ex.reponse);
  const tolerance = parseFloat(ex.tolerance) || 0.01;
  const difference = Math.abs(valeur - bonne_reponse);
  const correct = difference <= tolerance;

  // Build hint
  let indice = '';
  if (!correct) {
    indice = valeur > bonne_reponse ? 'Ta réponse est trop grande.' : 'Ta réponse est trop petite.';
    if (Math.abs(valeur - bonne_reponse * 2) < tolerance * 2) {
      indice += ' As-tu bien divisé par 2 ?';
    }
  }

  const data = {
    correct,
    message: correct ? '✅ Bravo ! Ta réponse est correcte !' : '❌ Pas tout à fait. Regarde la correction ci-dessous.',
    explication: correct ? null : ex.explication,
    etapes: ex.etapes || [],
    indice,
    unite: ex.unite
  };

  // ── Display result (same UI as before) ──
  if (data.correct) {
    input.classList.add('correct');
    card.classList.add('resolved-correct');
    SESSION[exId] = 'correct';
    btn.textContent = '✓ Correct !';
    resEl.className = 'ex-result show';
    resEl.innerHTML = `
      <div class="result-correct">
        <div class="result-message">✅ Bravo ! Bonne réponse !</div>
        ${data.etapes?.length ? `
          <div class="result-etapes-title">Correction pas à pas :</div>
          ${data.etapes.map((e,i,a) => `
            <div class="result-etape ${i===a.length-1?'finale':''}">
              <div class="etape-n">${i+1}</div>
              <div class="etape-txt">${e}</div>
            </div>`).join('')}
        ` : ''}
      </div>`;
  } else {
    input.classList.add('wrong');
    card.classList.add('resolved-wrong');
    SESSION[exId] = 'wrong';
    btn.textContent = '✗ Voir correction';
    resEl.className = 'ex-result show';
    resEl.innerHTML = `
      <div class="result-wrong">
        <div class="result-message">❌ ${data.message}</div>
        ${data.indice ? `<div class="result-indice">💡 ${data.indice}</div>` : ''}
        <div class="result-explication">${data.explication || ''}</div>
        ${data.etapes?.length ? `
          <div class="result-etapes-title">Correction pas à pas :</div>
          ${data.etapes.map((e,i,a) => `
            <div class="result-etape ${i===a.length-1?'finale':''}">
              <div class="etape-n">${i+1}</div>
              <div class="etape-txt">${e}</div>
            </div>`).join('')}
        ` : ''}
        <button class="btn-retry" onclick="retry(${exId})">🔄 Réessayer</button>
      </div>`;
  }

  input.disabled = true;
  updateStats();
  updateProgress();
}
```

> [!IMPORTANT]
> In the offline version, the `exercices.json` file **includes** `reponse` and `tolerance` fields (unlike the server API which hides them). This is fine for a student demo project. For production, you could obfuscate the data.

### 5.4 — Update service-worker.js for Offline Data

Add the JSON files to the precache list:

```javascript
const STATIC_ASSETS = [
  './index.html',
  './formes.html',
  './theoremes.html',
  './exercices.html',
  './geo-animations.css',
  './geo-animations.js',
  './pwa.js',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './manifest.json',
  // ── Offline data files ──
  './data/formes.json',
  './data/exercices.json',
  './data/theoremes.json'
];
```

Remove the API_URLS section since there are no more API calls.

---

## PART 6 — Final Result

### What You Get

| Feature | Status |
|---------|--------|
| APK file (`GeoCollege.apk`) | ✅ Ready to install |
| Works 100% offline | ✅ No server needed |
| All exercises work | ✅ With step-by-step correction |
| Verification works offline | ✅ Client-side JS |
| Professional green theme | ✅ Same as web version |
| App icon | ✅ Custom icon |
| Splash screen | ✅ Green branded |
| Installable on any Android | ✅ Direct APK install |
| Demo ready for CRMEF | ✅ Professional |

### How to Install on Phone

1. Transfer `GeoCollege.apk` to phone (USB, WhatsApp, Google Drive)
2. Open the APK file on the phone
3. Allow "Install from unknown sources" if prompted
4. Install → Open
5. **Done!** 🎉

### Summary of Commands

```powershell
# Full build sequence (after setup)
cd "c:\geocollege-apk"
npx cap sync android
cd android
.\gradlew.bat assembleDebug

# APK is at:
# android/app/build/outputs/apk/debug/app-debug.apk
```

---

## Quick Reference: File Changes Needed

| File | Change | Lines |
|------|--------|-------|
| `index.html` | `fetch('api/formes.php')` → `fetch('data/formes.json')` | 1 line |
| `formes.html` | Same change for formes fetch | 1 line |
| `theoremes.html` | `fetch('api/theoremes.php')` → `fetch('data/theoremes.json')` | 1 line |
| `exercices.html` | Change fetch URL + replace `verifier()` function | ~60 lines |
| `service-worker.js` | Add JSON files to precache, remove API_URLS | 5 lines |
| **New files** | `data/formes.json`, `data/exercices.json`, `data/theoremes.json` | Export from DB |

> [!NOTE]
> **Total actual code changes: ~70 lines.** The rest is tooling and configuration. This is a **1-2 hour project** for someone who already has Android Studio installed.
