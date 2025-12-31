/**
 * AI Frontend Application
 * Main application logic for the AI frontend interface
 */

// ============================================================================
// APP STATE
// ============================================================================

const appState = {
    currentSection: 'chat',
    messages: [],
    settings: {
        model: 'gpt-4',
        temperature: 0.7,
        maxTokens: 2000
    },
    modules: [
        { id: 'code', name: 'Code Generation', description: 'Generate code in various languages' },
        { id: 'analysis', name: 'Data Analysis', description: 'Analyze and visualize data' },
        { id: 'translation', name: 'Translation', description: 'Translate text between languages' },
        { id: 'writing', name: 'Creative Writing', description: 'Generate creative content' },
        { id: 'math', name: 'Math Solver', description: 'Solve mathematical problems' },
        { id: 'explanation', name: 'Explain', description: 'Explain complex topics' },
        { id: 'game', name: 'Game Strategy', description: 'Get gaming tips and strategies' },
        { id: 'slides', name: 'Slides Generator', description: 'Create presentation slides' }
    ]
};

// ============================================================================
// DOM ELEMENTS
// ============================================================================

const elements = {
    app: document.getElementById('app'),
    chatSection: document.getElementById('chatSection'),
    modulesSection: document.getElementById('modulesSection'),
    settingsSection: document.getElementById('settingsSection'),
    chatBtn: document.getElementById('chatBtn'),
    modulesBtn: document.getElementById('modulesBtn'),
    settingsBtn: document.getElementById('settingsBtn'),
    chatMessages: document.getElementById('chatMessages'),
    userInput: document.getElementById('userInput'),
    sendBtn: document.getElementById('sendBtn'),
    modulesGrid: document.getElementById('modulesGrid'),
    modelSelect: document.getElementById('modelSelect'),
    temperatureSlider: document.getElementById('temperatureSlider'),
    temperatureValue: document.getElementById('temperatureValue'),
    maxTokensInput: document.getElementById('maxTokensInput'),
    recentChats: document.getElementById('recentChats')
};

// ============================================================================
// INITIALIZATION
// ============================================================================

function init() {
    setupEventListeners();
    renderModules();
    loadSettings();
    addWelcomeMessage();
}

function setupEventListeners() {
    // Navigation
    elements.chatBtn.addEventListener('click', () => switchSection('chat'));
    elements.modulesBtn.addEventListener('click', () => switchSection('modules'));
    elements.settingsBtn.addEventListener('click', () => switchSection('settings'));

    // Chat
    elements.sendBtn.addEventListener('click', sendMessage);
    elements.userInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // Settings
    elements.modelSelect.addEventListener('change', updateSettings);
    elements.temperatureSlider.addEventListener('input', updateSettings);
    elements.maxTokensInput.addEventListener('change', updateSettings);

    // Quick actions
    document.querySelectorAll('.action-btn[data-action]').forEach(btn => {
        btn.addEventListener('click', () => {
            const action = btn.dataset.action;
            handleQuickAction(action);
        });
    });
}

// ============================================================================
// NAVIGATION
// ============================================================================

function switchSection(section) {
    appState.currentSection = section;

    // Update nav buttons
    [elements.chatBtn, elements.modulesBtn, elements.settingsBtn].forEach(btn => {
        btn.classList.remove('active');
    });

    switch (section) {
        case 'chat':
            elements.chatBtn.classList.add('active');
            elements.chatSection.classList.add('active');
            elements.modulesSection.classList.remove('active');
            elements.settingsSection.classList.remove('active');
            break;
        case 'modules':
            elements.modulesBtn.classList.add('active');
            elements.chatSection.classList.remove('active');
            elements.modulesSection.classList.add('active');
            elements.settingsSection.classList.remove('active');
            break;
        case 'settings':
            elements.settingsBtn.classList.add('active');
            elements.chatSection.classList.remove('active');
            elements.modulesSection.classList.remove('active');
            elements.settingsSection.classList.add('active');
            break;
    }
}

// ============================================================================
// CHAT FUNCTIONS
// ============================================================================

function addWelcomeMessage() {
    addMessage('assistant', 'Hello! I\'m your AI assistant. How can I help you today?');
}

function addMessage(role, content) {
    const message = { role, content, timestamp: Date.now() };
    appState.messages.push(message);

    const messageEl = document.createElement('div');
    messageEl.className = `message ${role}`;
    messageEl.innerHTML = `
        <div class="role">${role === 'user' ? 'You' : 'AI Assistant'}</div>
        <div class="content">${escapeHtml(content)}</div>
    `;

    elements.chatMessages.appendChild(messageEl);
    scrollToBottom();
}

async function sendMessage() {
    const content = elements.userInput.value.trim();
    if (!content) return;

    elements.userInput.value = '';
    addMessage('user', content);

    // Show loading indicator
    const loadingEl = document.createElement('div');
    loadingEl.className = 'message assistant loading';
    loadingEl.innerHTML = `
        <div class="role">AI Assistant</div>
        <div class="content">Thinking...</div>
    `;
    elements.chatMessages.appendChild(loadingEl);
    scrollToBottom();

    try {
        // Simulate AI response (replace with actual API call)
        await sleep(1000 + Math.random() * 1000);

        loadingEl.remove();
        const response = await getAIResponse(content);
        addMessage('assistant', response);
    } catch (error) {
        loadingEl.remove();
        addMessage('assistant', 'Sorry, I encountered an error. Please try again.');
        console.error('AI Response Error:', error);
    }
}

async function getAIResponse(userMessage) {
    // This would typically call an API endpoint
    // For demo purposes, we'll generate a simple response

    const lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.includes('code') || lowerMessage.includes('program')) {
        return generateCodeResponse(userMessage);
    } else if (lowerMessage.includes('hello') || lowerMessage.includes('hi')) {
        return 'Hello! How can I assist you today?';
    } else if (lowerMessage.includes('time') || lowerMessage.includes('date')) {
        return `The current time is ${new Date().toLocaleTimeString()}.`;
    } else if (lowerMessage.includes('help')) {
        return 'I can help you with:\n- Code generation\n- Data analysis\n- Translation\n- Creative writing\n- Math problems\n- General questions\n\nJust ask!';
    }

    // Generic response
    return `I understand you said: "${userMessage}".\n\nI'm a demo AI assistant. In a production environment, I would process your request using the configured AI model (${appState.settings.model}) with temperature ${appState.settings.temperature}.`;
}

function generateCodeResponse(message) {
    const languageMatch = message.match(/(javascript|python|html|css|typescript|rust|go)/i);
    const language = languageMatch ? languageMatch[1] : 'JavaScript';

    return `Here's a simple ${language} example:\n\n\`\`\`${language.toLowerCase()}\n// ${language} Example\nfunction greet(name) {\n    return \`Hello, \${name}!\`;\n}\n\nconsole.log(greet('World'));\n\`\`\`\n\nWould you like me to generate more specific code?`;
}

function scrollToBottom() {
    elements.chatMessages.scrollTop = elements.chatMessages.scrollHeight;
}

// ============================================================================
// MODULES
// ============================================================================

function renderModules() {
    elements.modulesGrid.innerHTML = '';

    appState.modules.forEach(module => {
        const card = document.createElement('div');
        card.className = 'module-card';
        card.innerHTML = `
            <h3>${module.name}</h3>
            <p>${module.description}</p>
        `;
        card.addEventListener('click', () => {
            elements.userInput.value = `[Use ${module.name}] `;
            switchSection('chat');
            elements.userInput.focus();
        });
        elements.modulesGrid.appendChild(card);
    });
}

// ============================================================================
// SETTINGS
// ============================================================================

function loadSettings() {
    const saved = localStorage.getItem('aiFrontendSettings');
    if (saved) {
        try {
            const parsed = JSON.parse(saved);
            appState.settings = { ...appState.settings, ...parsed };
        } catch (e) {
            console.error('Failed to load settings:', e);
        }
    }

    // Update UI
    elements.modelSelect.value = appState.settings.model;
    elements.temperatureSlider.value = appState.settings.temperature;
    elements.temperatureValue.textContent = appState.settings.temperature;
    elements.maxTokensInput.value = appState.settings.maxTokens;
}

function updateSettings() {
    appState.settings.model = elements.modelSelect.value;
    appState.settings.temperature = parseFloat(elements.temperatureSlider.value);
    appState.settings.maxTokens = parseInt(elements.maxTokensInput.value);

    elements.temperatureValue.textContent = appState.settings.temperature;

    // Save to localStorage
    localStorage.setItem('aiFrontendSettings', JSON.stringify(appState.settings));
}

// ============================================================================
// QUICK ACTIONS
// ============================================================================

function handleQuickAction(action) {
    const prompts = {
        'generate-code': 'Generate a simple REST API example in Python with Flask.',
        'analyze-text': 'Analyze the following text for sentiment and key points: ',
        'translate': 'Translate the following text to Spanish: ',
        'summarize': 'Summarize the following article in 3 bullet points: '
    };

    if (prompts[action]) {
        elements.userInput.value = prompts[action];
        switchSection('chat');
        elements.userInput.focus();
    }
}

// ============================================================================
// UTILITIES
// ============================================================================

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML.replace(/\n/g, '<br>');
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// ============================================================================
// EXPORTS (for module systems)
// ============================================================================

if (typeof module !== 'undefined' && module.exports) {
    module.exports = { appState, init };
}

