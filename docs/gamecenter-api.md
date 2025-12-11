# 🕹️ GameCenter Public API Reference

This document defines the public functions and methods exported by the Game Center Core Module (`src/core/GameCenter.js`). **All external modules must use these functions to interact with the Game Center.**

---

## 1. Initialization and System

### `initializeGameCenter(config)`

Initializes the entire Game Center application state, UI, and networking layer. Must be called once by `main.js`.

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `config` | Object | The configuration object containing `settings` (from AppSettings.json) and a `logFunction`. |

### `getAppStatus()`

Checks the current state of the Game Center (e.g., 'READY', 'LOADING', 'ERROR').

| Returns | Type | Description |
| :--- | :--- | :--- |
| String | | The current status string. |

---

## 2. Game Library & Launching

### `fetchGameList()`

Asynchronously retrieves the list of games available to the current user.

| Returns | Type | Description |
| :--- | :--- | :--- |
| Array<Object> | Promise | An array of game metadata objects (e.g., `{id: 'G001', name: 'Space Fighter'}`). |

### `launchGame(gameID)`

Initiates the external process to launch the specified game.

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `gameID` | String | The unique identifier of the game to launch. |

---

## 3. Events

The Game Center broadcasts the following global events:

* **`GC_READY`**: Fired when initialization is complete and the main menu is rendered.
* **`GAME_LAUNCHED`**: Fired successfully when a game process starts.