/**
 * Security Utilities - Shared Security Functions
 * Common security utilities for both game center frontend and ai_backend
 * File extension: .s (shared security script)
 */

// ============================================================================
// ENCRYPTION UTILITIES
// ============================================================================

/**
 * Simple XOR encryption for basic obfuscation
 * Note: For production, use AES-256 or similar
 */
function xorEncrypt(text, key) {
    let result = '';
    for (let i = 0; i < text.length; i++) {
        result += String.fromCharCode(
            text.charCodeAt(i) ^ key.charCodeAt(i % key.length)
        );
    }
    return result;
}

/**
 * Base64 encode with optional encryption
 */
function base64Encode(text, encrypt = false, key = '') {
    let data = text;
    if (encrypt) {
        data = xorEncrypt(text, key);
    }
    return btoa(unescape(encodeURIComponent(data)));
}

/**
 * Base64 decode with optional decryption
 */
function base64Decode(encoded, decrypt = false, key = '') {
    try {
        let data = decodeURIComponent(escape(atob(encoded)));
        if (decrypt) {
            data = xorEncrypt(data, key);
        }
        return data;
    } catch (e) {
        console.error('Base64 decode failed:', e);
        return null;
    }
}

/**
 * Hash string using simple hash function
 * Note: For production, use SHA-256 or bcrypt
 */
function simpleHash(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
        const char = str.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash;
    }
    return Math.abs(hash).toString(16);
}

/**
 * Generate secure random token
 */
function generateSecureToken(length = 32) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let token = '';
    const array = new Uint8Array(length);
    crypto.getRandomValues(array);

    for (let i = 0; i < length; i++) {
        token += chars[array[i] % chars.length];
    }

    return token;
}

// ============================================================================
// INPUT VALIDATION
// ============================================================================

/**
 * Validate email format
 */
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

/**
 * Validate username (alphanumeric + underscore, 3-20 chars)
 */
function isValidUsername(username) {
    const usernameRegex = /^[a-zA-Z0-9_]{3,20}$/;
    return usernameRegex.test(username);
}

/**
 * Validate password strength
 */
function validatePassword(password) {
    const result = {
        valid: false,
        score: 0,
        feedback: []
    };

    if (password.length < 8) {
        result.feedback.push('Password must be at least 8 characters');
    } else {
        result.score += 1;
    }

    if (/[a-z]/.test(password)) {
        result.score += 1;
    } else {
        result.feedback.push('Add lowercase letters');
    }

    if (/[A-Z]/.test(password)) {
        result.score += 1;
    } else {
        result.feedback.push('Add uppercase letters');
    }

    if (/[0-9]/.test(password)) {
        result.score += 1;
    } else {
        result.feedback.push('Add numbers');
    }

    if (/[^a-zA-Z0-9]/.test(password)) {
        result.score += 1;
    } else {
        result.feedback.push('Add special characters');
    }

    result.valid = result.score >= 4 && password.length >= 8;

    return result;
}

/**
 * Sanitize HTML to prevent XSS
 */
function sanitizeHTML(html) {
    const map = {
        '&': '&amp;',
        '<': '<',
        '>': '>',
        '"': '"',
        "'": '&#x27;',
        '/': '&#x2F;',
        '`': '&#x60;',
        '=': '&#x3D;'
    };

    return html.replace(/[&<>"'`=/]/g, function (m) {
        return map[m];
    });
}

/**
 * Validate and sanitize user input
 */
function sanitizeInput(input, options = {}) {
    const {
        maxLength = 1000,
        allowHTML = false,
        trim = true,
        lowercase = false
    } = options;

    let sanitized = trim ? input.trim() : input;
    sanitized = lowercase ? sanitized.toLowerCase() : sanitized;

    if (sanitized.length > maxLength) {
        sanitized = sanitized.substring(0, maxLength);
    }

    if (!allowHTML) {
        sanitized = sanitized
            .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
            .replace(/javascript:/gi, '')
            .replace(/on\w+=/gi, '');
    }

    return sanitized;
}

/**
 * Check for SQL injection patterns
 */
function containsSQLInjection(input) {
    const sqlPatterns = [
        /(\%27)|(\')|(\-\-)|(\%23)|(#)/i,
        /(\w*)\s*=\s*(\w*)/i,
        /(\s|;)(DROP|DELETE|UPDATE|INSERT|ALTER)/i,
        /UNION\s+SELECT/i,
        /EXEC(\s|\+)+(s|x)p\w+/i
    ];

    return sqlPatterns.some(pattern => pattern.test(input));
}

// ============================================================================
// RATE LIMITING
// ============================================================================

class RateLimiter {
    constructor(maxRequests = 100, windowMs = 60000) {
        this.maxRequests = maxRequests;
        this.windowMs = windowMs;
        this.requests = new Map();
    }

    isAllowed(key) {
        const now = Date.now();
        const windowStart = now - this.windowMs;

        // Clean old entries
        for (const [k, timestamps] of this.requests) {
            this.requests.set(k, timestamps.filter(t => t > windowStart));
        }

        const timestamps = this.requests.get(key) || [];

        if (timestamps.length >= this.maxRequests) {
            return { allowed: false, remaining: 0, resetTime: timestamps[0] + this.windowMs - now };
        }

        timestamps.push(now);
        this.requests.set(key, timestamps);

        return {
            allowed: true,
            remaining: this.maxRequests - timestamps.length,
            resetTime: windowStart + this.windowMs - now
        };
    }

    reset(key) {
        this.requests.delete(key);
    }

    resetAll() {
        this.requests.clear();
    }
}

// ============================================================================
// TOKEN MANAGEMENT
// ============================================================================

class TokenManager {
    constructor() {
        this.tokens = new Map();
        this.tokenExpiry = new Map();
    }

    createToken(userId, additionalClaims = {}) {
        const token = generateSecureToken(64);
        const expiresIn = Date.now() + (24 * 60 * 60 * 1000); // 24 hours

        this.tokens.set(token, {
            userId,
            claims: additionalClaims,
            createdAt: Date.now()
        });

        this.tokenExpiry.set(token, expiresIn);

        // Cleanup expired tokens periodically
        this.cleanup();

        return token;
    }

    validateToken(token) {
        if (!token || !this.tokens.has(token)) {
            return { valid: false, reason: 'Invalid token' };
        }

        const expiresAt = this.tokenExpiry.get(token);
        if (Date.now() > expiresAt) {
            this.tokens.delete(token);
            this.tokenExpiry.delete(token);
            return { valid: false, reason: 'Token expired' };
        }

        return {
            valid: true,
            data: this.tokens.get(token)
        };
    }

    revokeToken(token) {
        this.tokens.delete(token);
        this.tokenExpiry.delete(token);
    }

    revokeAllTokens(userId) {
        for (const [token, data] of this.tokens) {
            if (data.userId === userId) {
                this.tokens.delete(token);
                this.tokenExpiry.delete(token);
            }
        }
    }

    cleanup() {
        const now = Date.now();
        for (const [token, expiresAt] of this.tokenExpiry) {
            if (now > expiresAt) {
                this.tokens.delete(token);
                this.tokenExpiry.delete(token);
            }
        }
    }
}

// ============================================================================
// SECURITY LOGGING
// ============================================================================

class SecurityLogger {
    constructor() {
        this.logs = [];
        this.maxLogs = 1000;
    }

    log(event, details = {}) {
        const logEntry = {
            id: generateSecureToken(16),
            timestamp: new Date().toISOString(),
            event,
            details,
            userAgent: typeof navigator !== 'undefined' ? navigator.userAgent : 'server',
            ip: details.ip || 'unknown'
        };

        this.logs.push(logEntry);

        if (this.logs.length > this.maxLogs) {
            this.logs.shift();
        }

        // In production, send to logging service
        console.log('[Security]', JSON.stringify(logEntry));

        return logEntry;
    }

    getRecentLogs(eventType = null) {
        if (eventType) {
            return this.logs.filter(log => log.event === eventType);
        }
        return this.logs;
    }

    getSuspiciousActivity(threshold = 10) {
        const ipCounts = {};

        this.logs.forEach(log => {
            const ip = log.details.ip || 'unknown';
            ipCounts[ip] = (ipCounts[ip] || 0) + 1;
        });

        return Object.entries(ipCounts)
            .filter(([ip, count]) => count >= threshold)
            .map(([ip, count]) => ({ ip, count }));
    }
}

// ============================================================================
// DATA ENCRYPTION FOR STORAGE
// ============================================================================

/**
 * Encrypt data for local storage
 */
function encryptForStorage(data, key) {
    const jsonString = JSON.stringify(data);
    const encoded = base64Encode(jsonString, true, key);

    // Add integrity check
    const integrityHash = simpleHash(jsonString);

    return {
        data: encoded,
        integrity: integrityHash
    };
}

/**
 * Decrypt data from local storage
 */
function decryptFromStorage(encrypted, key) {
    if (!encrypted || !encrypted.data) {
        return null;
    }

    const jsonString = base64Decode(encrypted.data, true, key);

    if (!jsonString) {
        return null;
    }

    // Verify integrity
    const integrityHash = simpleHash(jsonString);
    if (integrityHash !== encrypted.integrity) {
        console.error('Data integrity check failed');
        return null;
    }

    try {
        return JSON.parse(jsonString);
    } catch (e) {
        console.error('Failed to parse decrypted data:', e);
        return null;
    }
}

// ============================================================================
// PERMISSION CHECKS
// ============================================================================

const PERMISSIONS = {
    USER: ['read_profile', 'update_profile', 'play_games'],
    PREMIUM: ['read_profile', 'update_profile', 'play_games', 'premium_features'],
    MODERATOR: ['read_profile', 'update_profile', 'play_games', 'premium_features', 'view_moderation'],
    ADMIN: ['read_profile', 'update_profile', 'play_games', 'premium_features', 'view_moderation', 'admin_access']
};

/**
 * Check if user has required permission
 */
function hasPermission(userRole, requiredPermission) {
    const rolePermissions = PERMISSIONS[userRole.toUpperCase()] || PERMISSIONS.USER;
    return rolePermissions.includes(requiredPermission);
}

/**
 * Get all permissions for a role
 */
function getPermissions(role) {
    return PERMISSIONS[role.toUpperCase()] || PERMISSIONS.USER;
}

/**
 * Validate role hierarchy
 */
function canAssignRole(assignerRole, targetRole) {
    const hierarchy = ['USER', 'PREMIUM', 'MODERATOR', 'ADMIN'];
    const assignerIndex = hierarchy.indexOf(assignerRole.toUpperCase());
    const targetIndex = hierarchy.indexOf(targetRole.toUpperCase());

    return assignerIndex > targetIndex;
}

// ============================================================================
// EXPORTS
// ============================================================================

const SecurityUtils = {
    // Encryption
    xorEncrypt,
    base64Encode,
    base64Decode,
    simpleHash,
    generateSecureToken,

    // Validation
    isValidEmail,
    isValidUsername,
    validatePassword,
    sanitizeHTML,
    sanitizeInput,
    containsSQLInjection,

    // Rate limiting
    RateLimiter,

    // Token management
    TokenManager,

    // Logging
    SecurityLogger,

    // Storage
    encryptForStorage,
    decryptFromStorage,

    // Permissions
    PERMISSIONS,
    hasPermission,
    getPermissions,
    canAssignRole
};

// Export for different module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SecurityUtils;
}
if (typeof window !== 'undefined') {
    window.SecurityUtils = SecurityUtils;
}

