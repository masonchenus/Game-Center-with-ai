# 🗺️ Code Structure Module Map

**Purpose:** Since our core logic resides in monolithic files (`GameCenter.js` and `Workshop.js`), this map is mandatory for developer navigation and code maintenance. **DO NOT** add code outside of these established sections.

---

## 1. `src/core/GameCenter.js` (Approx. 12,943 Lines)

| Section Header (Comment) | Line Range (Approx.) | Feature/Purpose |
| :--- | :--- | :--- |
| `// --- SECTION: Core Initialization ---` | 1 - 500 | Global constants, external imports, and the `initializeGameCenter` function. |
| `// --- SECTION: UI Rendering ---` | 501 - 3000 | All functions for dynamic UI generation (e.g., menu(), renderProfile()). |
| `// --- SECTION: Networking/API Client ---` | 3001 - 7000 | All functions making backend API calls (e.g., `fetchGameList()`, `postUserData()`). |
| `// --- SECTION: User Profile Management ---` | 7001 - 9500 | Logic for stats calculation, inventory storage, and achievement tracking. |
| `// --- SECTION: Utility Functions (Internal) ---` | 9501 - 12943 | Helper functions used only internally (e.g., data validation, internal sorting). |

---

## 2. `src/core/Workshop.js` (Approx. 2,000 Lines)

| Section Header (Comment) | Line Range (Approx.) | Feature/Purpose |
| :--- | :--- | :--- |
| `// --- SECTION: Editor Setup & State ---` | 1 - 100 | Initializing the canvas, global variables, and module state. |
| `// --- SECTION: Asset Importer Logic ---` | 101 - 500 | Handling file uploads and validating models/textures. |
| `// --- SECTION: Level Editor Core ---` | 501 - 1500 | Mouse/keyboard input handling and object manipulation logic. |