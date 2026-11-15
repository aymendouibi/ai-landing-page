# AI Website Builder

A full-stack mobile-first AI website builder composed of three core services:
1. **Backend** — Laravel 11 REST API handling authentication, document schema storage, database migrations, OpenRouter/Gemini AI endpoints, and media asset uploads.
2. **Renderer** — Vite + React 19 interactive website canvas engine embedded in the mobile WebView.
3. **Mobile** — Flutter application with visual editor, GetX state management, AI prompt sheet, and design inspectors.

---

## Prerequisites

- **PHP** >= 8.2 & **Composer**
- **Node.js** >= 18.x & **npm**
- **Flutter SDK** >= 3.24.x
- **Xcode** & iOS Simulator (or Android Studio & Emulator)

---

## First-Time Setup

### 1. Backend Setup
```bash
cd backend
composer install
cp .env.example .env # if .env does not exist yet
php artisan key:generate
php artisan migrate
php artisan storage:link
```
> **AI Configuration:** In `backend/.env`, set your OpenRouter API key:
> ```env
> OPENROUTER_API_KEY=your-openrouter-key-here
> OPENROUTER_MODEL=google/gemini-2.5-flash
> ```

### 2. Web Renderer Setup
```bash
cd renderer
npm install
```

### 3. Mobile App Setup
```bash
cd mobile
flutter pub get
```

---

## Running the Application

To run the full stack locally, open **three terminal tabs or windows**:

### Terminal 1: Backend API (Port 8000)
```bash
cd backend
php artisan serve --port=8000
```
- **API URL:** `http://127.0.0.1:8000`
- **Health Check / API Docs:** `http://127.0.0.1:8000/api/v1/templates`

---

### Terminal 2: Website Renderer Canvas (Port 3000)
```bash
cd renderer
npm run dev -- --host 0.0.0.0 --port 3000
```
- **Renderer URL:** `http://localhost:3000/?editor=true`
- Note: The `--host 0.0.0.0` flag ensures the dev server is reachable from both the iOS Simulator (`127.0.0.1`) and Android Emulator (`10.0.2.2`).

---

### Terminal 3: Mobile App (Flutter)
```bash
cd mobile
flutter run
```

To target a specific simulator (e.g., iPhone 17 Pro):
```bash
cd mobile
flutter run -d "iPhone 17 Pro"
```

---

## Running Automated Tests

Run tests across all three projects to verify functionality:

| Component | Command | Details |
|---|---|---|
| **Mobile** | `cd mobile && flutter test` | Unit, widget, and orientation/editor workflow tests |
| **Renderer** | `cd renderer && npm test` | Vitest engine & component mapping tests |
| **Backend** | `cd backend && php artisan test` | Feature, API authentication, and AI edit tests |

Run all tests together:
```bash
(cd backend && php artisan test) && (cd renderer && npm test) && (cd mobile && flutter test)
```

---

## Architecture & Port Mapping

```
+-----------------------------------------------------------+
|                        Mobile App                         |
|                   (Flutter - Port 8000/3000)              |
+-----------------------------+-----------------------------+
                              |
              +---------------+---------------+
              |                               |
              v                               v
+---------------------------+   +---------------------------+
|       Laravel API         |   |      Vite Renderer        |
|    http://127.0.0.1:8000  |   |   http://127.0.0.1:3000   |
+---------------------------+   +---------------------------+
| - Database & Storage      |   | - React 19 Canvas Engine  |
| - Gemini / OpenRouter AI  |   | - Dynamic Section Theme   |
| - MediaAsset management   |   | - Bi-directional postMsg  |
+---------------------------+   +---------------------------+
```

# ai-landing-page
