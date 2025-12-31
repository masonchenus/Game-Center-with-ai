/**
 * AI Backend Utilities
 * Common utility functions for the AI backend module
 * This file can be used from both root ai_backend/ and src/ai_backend/
 */

// ============================================================================
// PATH UTILITIES
// ============================================================================

/**
 * Get the base path for ai_backend
 * Works regardless of whether ai_backend is at root or inside src/
 */
function getAiBackendPath() {
    if (typeof window !== 'undefined') {
        // Browser environment
        const path = window.location.pathname;
        if (path.includes('/src/ai_backend')) {
            return '/src/ai_backend';
        }
        return '/ai_backend';
    }
    // Node.js environment
    try {
        const path = require('path');
        const cwd = process.cwd();
        if (path.join(cwd, 'src', 'ai_backend') === __dirname ||
            __dirname.includes('/src/ai_backend')) {
            return path.join(cwd, 'src', 'ai_backend');
        }
        return path.join(cwd, 'ai_backend');
    } catch (e) {
        return 'ai_backend';
    }
}

/**
 * Resolve path relative to ai_backend location
 */
function resolveAiBackendPath(relativePath) {
    const basePath = getAiBackendPath();
    if (typeof window !== 'undefined') {
        return `${basePath}/${relativePath}`;
    }
    try {
        return require('path').join(basePath, relativePath);
    } catch (e) {
        return `${basePath}/${relativePath}`;
    }
}

// ============================================================================
// CONFIGURATION UTILITIES
// ============================================================================

/**
 * Load configuration from JSON file
 */
async function loadConfig(configPath) {
    try {
        const response = await fetch(configPath);
        if (!response.ok) {
            throw new Error(`Failed to load config: ${response.statusText}`);
        }
        return await response.json();
    } catch (error) {
        console.error('Error loading config:', error);
        return null;
    }
}

/**
 * Get environment variable with fallback
 */
function getEnvVar(name, defaultValue = '') {
    return process.env[name] || defaultValue;
}

/**
 * Check if running in development mode
 */
function isDevelopment() {
    return process.env.NODE_ENV !== 'production';
}

// ============================================================================
// ASYNC UTILITIES
// ============================================================================

/**
 * Sleep for specified milliseconds
 */
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Retry a function with exponential backoff
 */
async function retryWithBackoff(fn, maxRetries = 3, initialDelay = 1000) {
    for (let i = 0; i < maxRetries; i++) {
        try {
            return await fn();
        } catch (error) {
            if (i === maxRetries - 1) {
                throw error;
            }
            const delay = initialDelay * Math.pow(2, i);
            await sleep(delay);
        }
    }
}

/**
 * Run multiple promises with timeout
 */
async function promiseWithTimeout(promise, timeoutMs = 5000) {
    let timeoutId;
    const timeoutPromise = new Promise((_, reject) => {
        timeoutId = setTimeout(() => reject(new Error('Operation timed out')), timeoutMs);
    });

    try {
        const result = await Promise.race([promise, timeoutPromise]);
        clearTimeout(timeoutId);
        return result;
    } catch (error) {
        clearTimeout(timeoutId);
        throw error;
    }
}

// ============================================================================
// STRING UTILITIES
// ============================================================================

/**
 * Truncate string to max length
 */
function truncate(str, maxLength = 100, suffix = '...') {
    if (str.length <= maxLength) return str;
    return str.substring(0, maxLength - suffix.length) + suffix;
}

/**
 * Capitalize first letter
 */
function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

/**
 * Generate random string
 */
function generateRandomString(length = 8) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}

/**
 * Slugify string
 */
function slugify(str) {
    return str
        .toLowerCase()
        .trim()
        .replace(/[^\w\s-]/g, '')
        .replace(/[\s_-]+/g, '-')
        .replace(/^-+|-+$/g, '');
}

// ============================================================================
// OBJECT UTILITIES
// ============================================================================

/**
 * Deep clone an object
 */
function deepClone(obj) {
    if (obj === null || typeof obj !== 'object') return obj;
    if (obj instanceof Date) return new Date(obj.getTime());
    if (obj instanceof Array) return obj.map(item => deepClone(item));
    if (typeof obj === 'object') {
        const clonedObj = {};
        for (const key in obj) {
            if (Object.prototype.hasOwnProperty.call(obj, key)) {
                clonedObj[key] = deepClone(obj[key]);
            }
        }
        return clonedObj;
    }
}

/**
 * Merge objects deeply
 */
function deepMerge(target, source) {
    const output = { ...target };
    if (isObject(target) && isObject(source)) {
        Object.keys(source).forEach(key => {
            if (isObject(source[key])) {
                if (!(key in target)) {
                    output[key] = source[key];
                } else {
                    output[key] = deepMerge(target[key], source[key]);
                }
            } else {
                output[key] = source[key];
            }
        });
    }
    return output;
}

function isObject(item) {
    return item && typeof item === 'object' && !Array.isArray(item);
}

/**
 * Remove undefined values from object
 */
function removeUndefined(obj) {
    const result = {};
    for (const key in obj) {
        if (obj[key] !== undefined) {
            result[key] = obj[key];
        }
    }
    return result;
}

// ============================================================================
// VALIDATION UTILITIES
// ============================================================================

/**
 * Validate email format
 */
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

/**
 * Check if value is empty (null, undefined, empty string, empty array, empty object)
 */
function isEmpty(value) {
    if (value === null || value === undefined) return true;
    if (typeof value === 'string') return value.trim() === '';
    if (Array.isArray(value)) return value.length === 0;
    if (typeof value === 'object') return Object.keys(value).length === 0;
    return false;
}

// ============================================================================
// MATH UTILITIES
// ============================================================================

/**
 * Clamp value between min and max
 */
function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
}

/**
 * Linear interpolation
 */
function lerp(start, end, t) {
    return start + (end - start) * t;
}

/**
 * Map value from one range to another
 */
function mapRange(value, inMin, inMax, outMin, outMax) {
    return ((value - inMin) * (outMax - outMin)) / (inMax - inMin) + outMin;
}

/**
 * Generate random integer between min and max (inclusive)
 */
function randomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

/**
 * Generate random float between min and max
 */
function randomFloat(min, max) {
    return Math.random() * (max - min) + min;
}

// ============================================================================
// ARRAY UTILITIES
// ============================================================================

/**
 * Shuffle array using Fisher-Yates algorithm
 */
function shuffleArray(array) {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
}

/**
 * Get unique values from array
 */
function unique(array) {
    return [...new Set(array)];
}

/**
 * Chunk array into smaller arrays
 */
function chunk(array, size) {
    const chunks = [];
    for (let i = 0; i < array.length; i += size) {
        chunks.push(array.slice(i, i + size));
    }
    return chunks;
}

/**
 * Group array by key
 */
function groupBy(array, keyFn) {
    return array.reduce((groups, item) => {
        const key = keyFn(item);
        if (!groups[key]) {
            groups[key] = [];
        }
        groups[key].push(item);
        return groups;
    }, {});
}

// ============================================================================
// EXPORTS
// ============================================================================

const AIBackendUtils = {
    // Path utilities
    getAiBackendPath,
    resolveAiBackendPath,

    // Configuration
    loadConfig,
    getEnvVar,
    isDevelopment,

    // Async utilities
    sleep,
    retryWithBackoff,
    promiseWithTimeout,

    // String utilities
    truncate,
    capitalize,
    generateRandomString,
    slugify,

    // Object utilities
    deepClone,
    deepMerge,
    removeUndefined,

    // Validation utilities
    isValidEmail,
    isEmpty,

    // Math utilities
    clamp,
    lerp,
    mapRange,
    randomInt,
    randomFloat,

    // Array utilities
    shuffleArray,
    unique,
    chunk,
    groupBy
};

// Export for different module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AIBackendUtils;
}
if (typeof window !== 'undefined') {
    window.AIBackendUtils = AIBackendUtils;
}

