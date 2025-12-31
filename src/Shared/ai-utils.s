/**
 * AI Utilities Shared Script
 * Common AI functions used by both game center frontend and ai_backend
 * File extension: .s (shared script)
 */

// ============================================================================
// AI MODEL CONFIGURATIONS
// ============================================================================

const AI_CONFIG = {
    defaultModel: 'gpt-4',
    maxTokens: 2000,
    temperature: 0.7,
    topP: 1.0,
    frequencyPenalty: 0.0,
    presencePenalty: 0.0,
    timeout: 30000,
    retryAttempts: 3,
    retryDelay: 1000
};

const AI_MODELS = {
    'gpt-4': { name: 'GPT-4', provider: 'OpenAI', maxTokens: 8192 },
    'gpt-4-turbo': { name: 'GPT-4 Turbo', provider: 'OpenAI', maxTokens: 128000 },
    'gpt-3.5-turbo': { name: 'GPT-3.5 Turbo', provider: 'OpenAI', maxTokens: 16384 },
    'claude-3-opus': { name: 'Claude 3 Opus', provider: 'Anthropic', maxTokens: 200000 },
    'claude-3-sonnet': { name: 'Claude 3 Sonnet', provider: 'Anthropic', maxTokens: 200000 },
    'claude-3-haiku': { name: 'Claude 3 Haiku', provider: 'Anthropic', maxTokens: 200000 },
    'gemini-pro': { name: 'Gemini Pro', provider: 'Google', maxTokens: 2097152 },
    'groq-llama2-70b': { name: 'Llama 2 70B', provider: 'Groq', maxTokens: 4096 },
    'groq-mixtral': { name: 'Mixtral', provider: 'Groq', maxTokens: 32768 }
};

const AI_TASK_TYPES = {
    GAME_STRATEGY: 'game_strategy',
    CODE_GENERATION: 'code_generation',
    MATH_SOLVE: 'math_solve',
    TRANSLATION: 'translation',
    TEXT_SUMMARIZATION: 'text_summarization',
    CREATIVE_WRITING: 'creative_writing',
    DATA_ANALYSIS: 'data_analysis',
    QUESTION_ANSWER: 'question_answer',
    GAME_TIPS: 'game_tips',
    EXPLANATION: 'explanation'
};

// ============================================================================
// PROMPT TEMPLATES
// ============================================================================

const AI_PROMPTS = {
    [AI_TASK_TYPES.GAME_STRATEGY]: `
You are an expert game strategist analyzing player performance.
Game: {{gameName}}
Player Level: {{playerLevel}}
Recent Scores: {{recentScores}}

Analyze the player's performance and provide specific, actionable strategies to improve.
Focus on: patterns in mistakes, optimal play patterns, timing recommendations, and practice priorities.
`,

    [AI_TASK_TYPES.CODE_GENERATION]: `
You are an expert coding assistant.
Language: {{language}}
Task: {{taskDescription}}
Constraints: {{constraints}}
Examples: {{examples}}

Provide clean, well-commented code with explanations.
`,

    [AI_TASK_TYPES.MATH_SOLVE]: `
You are a math tutor helping solve problems.
Problem Level: {{difficulty}}
Problem: {{problem}}

Provide a step-by-step solution with clear explanations for each step.
Include the final answer clearly marked.
`,

    [AI_TASK_TYPES.TRANSLATION]: `
You are a professional translator.
Translate from {{sourceLang}} to {{targetLang}}.
Context: {{translationContext}}

Original text: {{originalText}}
`,

    [AI_TASK_TYPES.GAME_TIPS]: `
You are a game expert providing tips for {{gameName}}.
Player's Current Situation: {{playerContext}}
Recent Achievements: {{recentAchievements}}

Provide helpful tips that are relevant to the player's current situation and skill level.
`
};

// ============================================================================
// TEXT PROCESSING UTILITIES
// ============================================================================

/**
 * Clean and normalize text input
 */
function cleanText(text) {
    return text
        .trim()
        .replace(/\s+/g, ' ')
        .replace(/[\x00-\x1F\x7F]/g, '');
}

/**
 * Truncate text to maximum length
 */
function truncateText(text, maxLength, suffix = '...') {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
}

/**
 * Extract keywords from text
 */
function extractKeywords(text, maxKeywords = 10) {
    const stopWords = new Set([
        'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
        'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'been',
        'be', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
        'could', 'should', 'may', 'might', 'must', 'shall', 'can', 'need',
        'it', 'its', 'this', 'that', 'these', 'those', 'i', 'you', 'he',
        'she', 'we', 'they', 'what', 'which', 'who', 'when', 'where', 'why',
        'how', 'all', 'each', 'every', 'both', 'few', 'more', 'most', 'other',
        'some', 'such', 'no', 'nor', 'not', 'only', 'own', 'same', 'so',
        'than', 'too', 'very', 'just', 'also'
    ]);

    const words = text.toLowerCase()
        .replace(/[^\w\s]/g, '')
        .split(/\s+/)
        .filter(word => word.length > 2 && !stopWords.has(word));

    const frequency = {};
    words.forEach(word => {
        frequency[word] = (frequency[word] || 0) + 1;
    });

    return Object.entries(frequency)
        .sort((a, b) => b[1] - a[1])
        .slice(0, maxKeywords)
        .map(([word]) => word);
}

/**
 * Calculate text similarity (simple implementation)
 */
function textSimilarity(text1, text2) {
    const words1 = new Set(text1.toLowerCase().split(/\s+/));
    const words2 = new Set(text2.toLowerCase().split(/\s+/));
    
    const intersection = new Set([...words1].filter(x => words2.has(x)));
    const union = new Set([...words1, ...words2]);
    
    return intersection.size / union.size;
}

/**
 * Sentiment analysis (simple keyword-based)
 */
function analyzeSentiment(text) {
    const positiveWords = [
        'good', 'great', 'excellent', 'amazing', 'wonderful', 'fantastic',
        'awesome', 'love', 'happy', 'joy', 'success', 'win', 'best', 'perfect',
        'brilliant', 'outstanding', 'superb', 'nice', 'beautiful', 'delight'
    ];
    
    const negativeWords = [
        'bad', 'terrible', 'awful', 'horrible', 'worst', 'hate', 'sad',
        'angry', 'fail', 'lose', 'wrong', 'poor', 'disappointing', 'boring',
        'dull', 'difficult', 'hard', 'impossible', 'annoying', 'frustrat'
    ];

    const words = text.toLowerCase().split(/\s+/);
    let positive = 0;
    let negative = 0;

    words.forEach(word => {
        if (positiveWords.some(pw => word.includes(pw))) positive++;
        if (negativeWords.some(nw => word.includes(nw))) negative++;
    });

    if (positive > negative) return { sentiment: 'positive', score: positive / (positive + negative) || 0 };
    if (negative > positive) return { sentiment: 'negative', score: negative / (positive + negative) || 0 };
    return { sentiment: 'neutral', score: 0.5 };
}

/**
 * Count tokens (approximate)
 */
function countTokens(text) {
    return text.split(/\s+/).filter(word => word.length > 0).length;
}

/**
 * Summarize text using extractive summarization
 */
function summarizeText(text, maxLength = 100) {
    const sentences = text.split(/[.!?]+/).filter(s => s.trim().length > 0);
    
    if (sentences.length <= 2) return text;
    
    // Score sentences by word frequency
    const wordFrequency = {};
    const words = text.toLowerCase().split(/\s+/);
    
    words.forEach(word => {
        if (word.length > 3) {
            wordFrequency[word] = (wordFrequency[word] || 0) + 1;
        }
    });
    
    const scoredSentences = sentences.map((sentence, index) => {
        const sentenceWords = sentence.toLowerCase().split(/\s+/);
        let score = 0;
        
        sentenceWords.forEach(word => {
            if (wordFrequency[word]) {
                score += wordFrequency[word];
            }
        });
        
        // Bonus for first and last sentences
        if (index === 0) score *= 1.5;
        if (index === sentences.length - 1) score *= 1.3;
        
        return { sentence: sentence.trim(), score, index };
    });
    
    scoredSentences.sort((a, b) => b.score - a.score);
    
    const selected = scoredSentences.slice(0, 2).sort((a, b) => a.index - b.index);
    
    return truncateText(selected.map(s => s.sentence).join('. '), maxLength);
}

// ============================================================================
// GAME-SPECIFIC AI UTILITIES
// ============================================================================

/**
 * Analyze game performance metrics
 */
function analyzeGamePerformance(scores, timeSpent, achievements) {
    const analysis = {
        averageScore: 0,
        scoreTrend: 'stable',
        bestScore: 0,
        totalGames: 0,
        achievementProgress: 0,
        recommendations: []
    };

    if (scores.length === 0) return analysis;

    // Calculate statistics
    analysis.totalGames = scores.length;
    analysis.averageScore = scores.reduce((a, b) => a + b, 0) / scores.length;
    analysis.bestScore = Math.max(...scores);

    // Determine trend
    if (scores.length >= 3) {
        const recentAvg = scores.slice(-3).reduce((a, b) => a + b, 0) / 3;
        const olderAvg = scores.slice(0, -3).reduce((a, b) => a + b, 0) / (scores.length - 3);
        
        if (recentAvg > olderAvg * 1.1) {
            analysis.scoreTrend = 'improving';
        } else if (recentAvg < olderAvg * 0.9) {
            analysis.scoreTrend = 'declining';
        }
    }

    // Achievement progress
    if (achievements && achievements.total > 0) {
        analysis.achievementProgress = Math.round((achievements.unlocked / achievements.total) * 100);
    }

    // Generate recommendations
    if (analysis.scoreTrend === 'declining') {
        analysis.recommendations.push('Consider taking a break to avoid fatigue');
        analysis.recommendations.push('Review your recent games to identify patterns');
    }

    if (analysis.achievementProgress < 50 && achievements) {
        analysis.recommendations.push(`Focus on unlocking more achievements (${achievements.total - achievements.unlocked} remaining)`);
    }

    return analysis;
}

/**
 * Generate personalized game recommendations
 */
function generateGameRecommendations(playerProfile, allGames) {
    const { preferences, playHistory, skillLevel } = playerProfile;
    
    const scoredGames = allGames.map(game => {
        let score = 0;
        
        // Match genres
        if (preferences.genres.includes(game.genre)) {
            score += 30;
        }
        
        // Match difficulty to skill level
        if (game.difficulty === skillLevel) {
            score += 20;
        } else if (game.difficulty === 'adaptive') {
            score += 15;
        }
        
        // Boost games not yet played
        if (!playHistory.includes(game.id)) {
            score += 25;
        }
        
        // Consider popularity
        score += Math.min(game.popularity || 0, 15);
        
        return { ...game, recommendationScore: score };
    });
    
    return scoredGames
        .sort((a, b) => b.recommendationScore - a.recommendationScore)
        .slice(0, 10);
}

/**
 * Calculate skill level based on performance
 */
function calculateSkillLevel(scores, wins, totalGames) {
    if (totalGames < 5) return 'beginner';
    
    const winRate = wins / totalGames;
    const avgScore = scores.reduce((a, b) => a + b, 0) / scores.length;
    
    if (winRate > 0.7 && avgScore > 10000) return 'expert';
    if (winRate > 0.5 && avgScore > 5000) return 'advanced';
    if (winRate > 0.3 && avgScore > 1000) return 'intermediate';
    return 'beginner';
}

// ============================================================================
// AI RESPONSE FORMATTING
// ============================================================================

/**
 * Format AI response with markdown-like styling
 */
function formatAIResponse(response, options = {}) {
    const { includeTimestamp = true, maxLength = null } = options;
    
    let formatted = response;
    
    // Apply basic formatting
    formatted = formatted
        .replace(/```(\w+)?\n([\s\S]*?)```/g, '<pre><code class="language-$1">$2</code></pre>')
        .replace(/`([^`]+)`/g, '<code>$1</code>')
        .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
        .replace(/\*([^*]+)\*/g, '<em>$1</em>')
        .replace(/^- (.+)$/gm, '<li>$1</li>')
        .replace(/(<li>.*<\/li>\n?)+/g, '<ul>$&</ul>')
        .replace(/\n\n/g, '</p><p>');
    
    // Wrap in container
    let html = `<div class="ai-response">`;
    if (includeTimestamp) {
        html += `<div class="response-meta">Generated: ${new Date().toLocaleString()}</div>`;
    }
    html += `<div class="response-content"><p>${formatted}</p></div></div>`;
    
    if (maxLength && html.length > maxLength) {
        html = truncateText(html, maxLength);
    }
    
    return html;
}

/**
 * Create structured AI response object
 */
function createStructuredResponse(data) {
    return {
        id: generateUniqueId(),
        timestamp: new Date().toISOString(),
        type: data.type || 'general',
        content: data.content,
        confidence: data.confidence || 1.0,
        metadata: {
            model: data.model || AI_CONFIG.defaultModel,
            tokens: countTokens(data.content),
            processingTime: data.processingTime || 0
        },
        suggestions: data.suggestions || [],
        relatedTopics: data.relatedTopics || []
    };
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

function generateUniqueId() {
    return 'ai_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function retryWithBackoff(fn, maxRetries = AI_CONFIG.retryAttempts) {
    for (let attempt = 0; attempt < maxRetries; attempt++) {
        try {
            return await fn();
        } catch (error) {
            if (attempt === maxRetries - 1) throw error;
            await delay(AI_CONFIG.retryDelay * Math.pow(2, attempt));
        }
    }
}

// ============================================================================
// EXPORTS
// ============================================================================

const AIUtils = {
    // Configuration
    CONFIG: AI_CONFIG,
    MODELS: AI_MODELS,
    TASK_TYPES: AI_TASK_TYPES,
    PROMPTS: AI_PROMPTS,
    
    // Text processing
    cleanText,
    truncateText,
    extractKeywords,
    textSimilarity,
    analyzeSentiment,
    countTokens,
    summarizeText,
    
    // Game AI
    analyzeGamePerformance,
    generateGameRecommendations,
    calculateSkillLevel,
    
    // Response formatting
    formatAIResponse,
    createStructuredResponse,
    
    // Helpers
    generateUniqueId,
    delay,
    retryWithBackoff
};

// Export for different module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AIUtils;
}
if (typeof window !== 'undefined') {
    window.AIUtils = AIUtils;
}

