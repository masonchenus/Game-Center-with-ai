/**
 * Game Engine Shared Utilities
 * Common functions used by both game center frontend and ai_backend
 * File extension: .s (shared script)
 */

// ============================================================================
// CONSTANTS AND CONFIGURATIONS
// ============================================================================

const GAME_ENGINE_CONFIG = {
    FPS: 60,
    CANVAS_SMOOTHING: true,
    COLLISION_THRESHOLD: 0.1,
    PARTICLE_LIFETIME: 1000,
    SCORE_MULTIPLIER_BASE: 1.0,
    MAX_HIGH_SCORES: 100
};

const GAME_STATES = {
    MENU: 'menu',
    PLAYING: 'playing',
    PAUSED: 'paused',
    GAME_OVER: 'game_over',
    LEVEL_COMPLETE: 'level_complete',
    LOADING: 'loading'
};

const DIRECTIONS = {
    UP: { x: 0, y: -1 },
    DOWN: { x: 0, y: 1 },
    LEFT: { x: -1, y: 0 },
    RIGHT: { x: 1, y: 0 },
    UP_LEFT: { x: -1, y: -1 },
    UP_RIGHT: { x: 1, y: 1 },
    DOWN_LEFT: { x: -1, y: 1 },
    DOWN_RIGHT: { x: 1, y: 1 }
};

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Clamp a value between min and max
 */
function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
}

/**
 * Linear interpolation between two values
 */
function lerp(start, end, t) {
    return start + (end - start) * t;
}

/**
 * Map a value from one range to another
 */
function mapRange(value, inMin, inMax, outMin, outMax) {
    return ((value - inMin) * (outMax - outMin)) / (inMax - inMin) + outMin;
}

/**
 * Check collision between two circles
 */
function circleCollision(x1, y1, r1, x2, y2, r2) {
    const dx = x2 - x1;
    const dy = y2 - y1;
    const distance = Math.sqrt(dx * dx + dy * dy);
    return distance < r1 + r2;
}

/**
 * Check collision between two rectangles
 */
function rectCollision(x1, y1, w1, h1, x2, y2, w2, h2) {
    return x1 < x2 + w2 &&
           x1 + w1 > x2 &&
           y1 < y2 + h2 &&
           y1 + h1 > y2;
}

/**
 * Calculate distance between two points
 */
function distance(x1, y1, x2, y2) {
    const dx = x2 - x1;
    const dy = y2 - y1;
    return Math.sqrt(dx * dx + dy * dy);
}

/**
 * Calculate angle between two points in radians
 */
function angle(x1, y1, x2, y2) {
    return Math.atan2(y2 - y1, x2 - x1);
}

/**
 * Convert degrees to radians
 */
function toRadians(degrees) {
    return degrees * Math.PI / 180;
}

/**
 * Convert radians to degrees
 */
function toDegrees(radians) {
    return radians * 180 / Math.PI;
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

/**
 * Pick random element from array
 */
function randomPick(array) {
    return array[Math.floor(Math.random() * array.length)];
}

/**
 * Shuffle array using Fisher-Yates algorithm
 */
function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
}

/**
 * Format number with thousand separators
 */
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

/**
 * Format time in MM:SS format
 */
function formatTime(seconds) {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
}

/**
 * Debounce function execution
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Throttle function execution
 */
function throttle(func, limit) {
    let inThrottle;
    return function executedFunction(...args) {
        if (!inThrottle) {
            func(...args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

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
            if (obj.hasOwnProperty(key)) {
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

// ============================================================================
// PARTICLE SYSTEM
// ============================================================================

class Particle {
    constructor(x, y, options = {}) {
        this.x = x;
        this.y = y;
        this.vx = options.vx || randomFloat(-2, 2);
        this.vy = options.vy || randomFloat(-2, 2);
        this.life = options.lifetime || 1000;
        this.maxLife = this.life;
        this.size = options.size || 5;
        this.color = options.color || '#ffffff';
        this.shape = options.shape || 'circle';
        this.gravity = options.gravity || 0;
        this.friction = options.friction || 0.99;
    }

    update(deltaTime) {
        this.vx *= this.friction;
        this.vy *= this.friction;
        this.vy += this.gravity;
        
        this.x += this.vx * deltaTime;
        this.y += this.vy * deltaTime;
        
        this.life -= deltaTime * 16.67; // Normalize to 60fps
    }

    draw(ctx) {
        const alpha = this.life / this.maxLife;
        ctx.globalAlpha = alpha;
        ctx.fillStyle = this.color;
        
        if (this.shape === 'circle') {
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size * alpha, 0, Math.PI * 2);
            ctx.fill();
        } else if (this.shape === 'square') {
            ctx.fillRect(
                this.x - this.size * alpha / 2,
                this.y - this.size * alpha / 2,
                this.size * alpha,
                this.size * alpha
            );
        }
        
        ctx.globalAlpha = 1;
    }

    isDead() {
        return this.life <= 0;
    }
}

class ParticleSystem {
    constructor() {
        this.particles = [];
    }

    emit(x, y, count = 10, options = {}) {
        for (let i = 0; i < count; i++) {
            const angle = Math.random() * Math.PI * 2;
            const speed = Math.random() * options.speed || 3;
            const spread = options.spread || 1;
            
            this.particles.push(new Particle(x, y, {
                vx: Math.cos(angle) * speed * randomFloat(1 - spread, 1 + spread),
                vy: Math.sin(angle) * speed * randomFloat(1 - spread, 1 + spread),
                ...options
            }));
        }
    }

    update(deltaTime) {
        this.particles = this.particles.filter(particle => {
            particle.update(deltaTime);
            return !particle.isDead();
        });
    }

    draw(ctx) {
        this.particles.forEach(particle => particle.draw(ctx));
    }

    clear() {
        this.particles = [];
    }
}

// ============================================================================
// HIGH SCORE MANAGEMENT
// ============================================================================

class HighScoreManager {
    constructor(storageKey = 'highScores', maxScores = 100) {
        this.storageKey = storageKey;
        this.maxScores = maxScores;
    }

    getScores() {
        try {
            const stored = localStorage.getItem(this.storageKey);
            return stored ? JSON.parse(stored) : [];
        } catch (e) {
            console.error('Failed to load scores:', e);
            return [];
        }
    }

    saveScore(playerName, score, gameName, metadata = {}) {
        const scores = this.getScores();
        
        const newEntry = {
            id: Date.now(),
            playerName,
            score,
            gameName,
            date: new Date().toISOString(),
            ...metadata
        };
        
        scores.push(newEntry);
        scores.sort((a, b) => b.score - a.score);
        scores.splice(this.maxScores);
        
        try {
            localStorage.setItem(this.storageKey, JSON.stringify(scores));
        } catch (e) {
            console.error('Failed to save score:', e);
        }
        
        return newEntry;
    }

    getTopScores(limit = 10, gameName = null) {
        const scores = this.getScores();
        
        if (gameName) {
            const filtered = scores.filter(s => s.gameName === gameName);
            return filtered.slice(0, limit);
        }
        
        return scores.slice(0, limit);
    }

    getPlayerRank(score, gameName = null) {
        const scores = this.getScores();
        let rankedScores = scores;
        
        if (gameName) {
            rankedScores = scores.filter(s => s.gameName === gameName);
        }
        
        const sorted = rankedScores.sort((a, b) => b.score - score);
        return sorted.findIndex(s => s.score <= score) + 1;
    }

    clearAll() {
        localStorage.removeItem(this.storageKey);
    }
}

// ============================================================================
// GAME STATE MANAGEMENT
// ============================================================================

class GameStateManager {
    constructor() {
        this.currentState = GAME_STATES.LOADING;
        this.previousState = null;
        this.stateData = {};
        this.stateCallbacks = {};
    }

    setState(newState, data = {}) {
        this.previousState = this.currentState;
        this.currentState = newState;
        this.stateData = data;
        
        // Trigger state change callbacks
        if (this.stateCallbacks[newState]) {
            this.stateCallbacks[newState](data);
        }
    }

    getState() {
        return this.currentState;
    }

    isState(state) {
        return this.currentState === state;
    }

    pushState(state, data = {}) {
        if (this.stateCallbacks['push']) {
            this.stateCallbacks['push']({ from: this.currentState, to: state, data });
        }
        this.setState(state, data);
    }

    popState() {
        if (this.previousState) {
            const previous = this.previousState;
            this.previousState = null;
            return previous;
        }
        return this.currentState;
    }

    onStateEnter(state, callback) {
        this.stateCallbacks[state] = callback;
    }

    clearCallbacks() {
        this.stateCallbacks = {};
    }
}

// ============================================================================
// EXPORTS
// ============================================================================

// Export all functions and classes
const GameEngine = {
    // Constants
    CONFIG: GAME_ENGINE_CONFIG,
    STATES: GAME_STATES,
    DIRECTIONS: DIRECTIONS,
    
    // Utilities
    clamp,
    lerp,
    mapRange,
    circleCollision,
    rectCollision,
    distance,
    angle,
    toRadians,
    toDegrees,
    randomInt,
    randomFloat,
    randomPick,
    shuffleArray,
    formatNumber,
    formatTime,
    debounce,
    throttle,
    deepClone,
    deepMerge,
    
    // Classes
    Particle,
    ParticleSystem,
    HighScoreManager,
    GameStateManager
};

// Export for different module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = GameEngine;
}
if (typeof window !== 'undefined') {
    window.GameEngine = GameEngine;
}

