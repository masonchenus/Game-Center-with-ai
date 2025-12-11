// Import the AppSettings.json file with correct case-sensitive path
import React, { useState } from 'react';
import APP_SETTINGS from './Config/AppSettings.json';

// Import utility functions
import { log } from './Shared/utils.js';

/**
 * Dynamically loads and displays HTML content for the specified mode.
 * @param {string} mode - The mode to load ('gamecenter' or 'workshop').
 * @param {object} settings - Application settings.
 * @param {function} logFunction - Logging function.
 */
export async function loadModeHTML(mode, settings, logFunction) {
    let htmlPath;
    if (mode === 'gamecenter') {
        htmlPath = './Core/gamecenter.html';
    } else {
        htmlPath = `./Core/${mode}.html`;
    }
    try {
        const response = await fetch(htmlPath);
        if (!response.ok) {
            throw new Error(`Failed to load ${htmlPath}: ${response.statusText}`);
        }
        const htmlContent = await response.text();
        document.body.innerHTML = htmlContent;
        logFunction(`${mode.charAt(0).toUpperCase() + mode.slice(1)} loaded successfully.`, "LAUNCH");
    } catch (error) {
        logFunction(`Error loading ${mode}: ${error.message}`, "ERROR");
        // Fallback: display error message
        document.body.innerHTML = `<h1>Error</h1><p>Failed to load ${mode}. Please check the console for details.</p>`;
    }
}

/*************  ✨ Windsurf Command 🌟  *************/

/**
 * Main application logic.
 */
export const StartApplication = () => {
    const [mode, setMode] = React.useState('gamecenter');
    const [initialized, setInitialized] = React.useState(false);

    React.useEffect(() => {
        const debugMode = APP_SETTINGS.app.debugMode;
        const apiUrl = APP_SETTINGS.networking.apiBaseUrl;
        log(`Debug Mode: ${debugMode}. API: ${apiUrl}`, 'CONFIG');

        const urlParams = new URLSearchParams(window.location.search);
        const urlMode = urlParams.get('mode');
        if (urlMode === 'workshop') {
            setMode('workshop');
        }

        loadModeHTML(mode, APP_SETTINGS, log).then(() => {
            setInitialized(true);
        });
    }, []);

    return (
        initialized ? (
            <div>
                <h1>Initialization Complete</h1>
            </div>
        ) : (
            <div>
                <h1>Initializing...</h1>
            </div>
        )
    );
};

export async function startApplication() {
    log("Application starting up...", 'STARTUP');

    const debugMode = APP_SETTINGS.app.debugMode;
    const apiUrl = APP_SETTINGS.networking.apiBaseUrl;
    log(`Debug Mode: ${debugMode}. API: ${apiUrl}`, 'CONFIG');

    await StartApplication();

    log("Initialization complete.", "STARTUP");
}

// Execute the main function when the script runs
startApplication();