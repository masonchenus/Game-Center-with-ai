/**
 * src/shared/utils.js
 * Contains universally useful, stateless helper functions.
 */

// Function 1: Logging Utility
export function log(message, level = 'INFO') {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] [${level.toUpperCase()}]: ${message}`);
}

// Function 2: Simple Math Utility (e.g., clamping a value)
/**
 * Clamps a number within the inclusive range specified by the boundary values.
 * @param {number} num - The number to clamp.
 * @param {number} min - The lower boundary.
 * @param {number} max - The upper boundary.
 * @returns {number} The clamped number.
 */
export function clamp(num, min, max) {
    return Math.max(min, Math.min(num, max));
}

// Function 3: Deep Copy for Data Objects
/**
 * Creates a deep clone of a simple object or array.
 * Note: Avoids complex objects like functions, dates, or classes.
 */
export function deepCopy(obj) {
    if (typeof obj !== 'object' || obj === null) {
        return obj;
    }
    return JSON.parse(JSON.stringify(obj));
}
