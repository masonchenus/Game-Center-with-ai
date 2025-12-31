
// AI Response Templates - Handlebars template system
// Used by both game center and ai_backend for AI-generated responses

{{!-- Game Strategy Suggestion Template --}}
<div class="ai-response game-strategy">
    <div class="ai-header">
        <span class="ai-avatar">🤖</span>
        <span class="ai-label">AI Strategy Advisor</span>
        <span class="response-time">Generated in {{responseTime}}ms</span>
    </div>
    <div class="ai-content">
        <p class="intro">Based on your gameplay analysis, here are my recommendations for improving your performance in <strong>{{gameName}}</strong>:</p>
        
        <div class="strategy-section">
            <h4>🎯 Immediate Improvements</h4>
            <ul class="improvement-list">
                {{#each immediateImprovements}}
                <li class="improvement-item priority-{{priority}}">
                    <span class="priority-badge">{{priority}}</span>
                    <span class="improvement-text">{{suggestion}}</span>
                </li>
                {{/each}}
            </ul>
        </div>
        
        <div class="strategy-section">
            <h4>📈 Long-term Goals</h4>
            <ul class="goal-list">
                {{#each longTermGoals}}
                <li class="goal-item">
                    <span class="goal-icon">{{icon}}</span>
                    <span class="goal-text">{{description}}</span>
                    <span class="goal-difficulty difficulty-{{difficulty}}">{{difficulty}}</span>
                </li>
                {{/each}}
            </ul>
        </div>
        
        <div class="strategy-section stats-preview">
            <h4>📊 Your Stats Comparison</h4>
            <table class="stats-table">
                <thead>
                    <tr>
                        <th>Metric</th>
                        <th>Your Avg</th>
                        <th>Top Player</th>
                        <th>Gap</th>
                    </tr>
                </thead>
                <tbody>
                    {{#each statsComparison}}
                    <tr class="stat-row">
                        <td>{{metricName}}</td>
                        <td class="your-value">{{yourValue}}</td>
                        <td class="top-value">{{topValue}}</td>
                        <td class="gap-value {{gapClass}}">{{gap}}</td>
                    </tr>
                    {{/each}}
                </tbody>
            </table>
        </div>
    </div>
</div>

{{!-- AI Game Explanation Template --}}
<div class="ai-response game-explanation">
    <div class="ai-header">
        <span class="ai-avatar">🎮</span>
        <span class="ai-label">AI Game Guide</span>
    </div>
    <div class="ai-content">
        <h2 class="game-title">{{gameName}}</h2>
        <p class="game-summary">{{gameSummary}}</p>
        
        <div class="explanation-sections">
            {{#each sections}}
            <div class="explanation-section">
                <h3>{{title}}</h3>
                <div class="section-content">{{{content}}}</div>
                {{#if tips}}
                <div class="tips-box">
                    <h4>💡 Pro Tips</h4>
                    <ul>
                        {{#each tips}}
                        <li>{{.}}</li>
                        {{/each}}
                    </ul>
                </div>
                {{/if}}
            </div>
            {{/each}}
        </div>
    </div>
</div>

{{!-- AI Coding Solution Template --}}
<div class="ai-response coding-solution">
    <div class="ai-header">
        <span class="ai-avatar">💻</span>
        <span class="ai-label">AI Code Assistant</span>
        <span class="language-badge">{{language}}</span>
    </div>
    <div class="ai-content">
        <p class="problem-description">{{problemDescription}}</p>
        
        <div class="solution-tabs">
            {{#each solutionVariants}}
            <button class="tab-btn {{#if selected}}active{{/if}}" data-variant="{{index}}">
                {{variantName}}
            </button>
            {{/each}}
        </div>
        
        <div class="code-block">
            <pre><code class="language-{{language}}">{{code}}</code></pre>
        </div>
        
        <div class="explanation-box">
            <h4>Explanation</h4>
            <p>{{explanation}}</p>
        </div>
        
        {{#if complexity}}
        <div class="complexity-info">
            <span class="time-complexity">Time: {{complexity.time}}</span>
            <span class="space-complexity">Space: {{complexity.space}}</span>
        </div>
        {{/if}}
    </div>
</div>

{{!-- AI Math Problem Solution Template --}}
<div class="ai-response math-solution">
    <div class="ai-header">
        <span class="ai-avatar">🔢</span>
        <span class="ai-label">AI Math Tutor</span>
        <span class="difficulty-badge {{difficulty}}">{{difficulty}}</span>
    </div>
    <div class="ai-content">
        <div class="problem-statement">
            <h3>Problem</h3>
            <p>{{problemStatement}}</p>
        </div>
        
        <div class="solution-steps">
            <h3>Solution</h3>
            {{#each steps}}
            <div class="step">
                <span class="step-number">{{@index}}</span>
                <div class="step-content">
                    <p class="step-explanation">{{explanation}}</p>
                    {{#if formula}}
                    <div class="formula">{{formula}}</div>
                    {{/if}}
                    {{#if intermediateResult}}
                    <p class="intermediate-result">= {{intermediateResult}}</p>
                    {{/if}}
                </div>
            </div>
            {{/each}}
        </div>
        
        <div class="final-answer">
            <h4>Final Answer</h4>
            <p class="answer">{{finalAnswer}}</p>
        </div>
        
        {{#if relatedConcepts}}
        <div class="related-concepts">
            <h4>Related Concepts</h4>
            <ul>
                {{#each relatedConcepts}}
                <li>{{.}}</li>
                {{/each}}
            </ul>
        </div>
        {{/if}}
    </div>
</div>

{{!-- AI Translation Response Template --}}
<div class="ai-response translation">
    <div class="ai-header">
        <span class="ai-avatar">🌐</span>
        <span class="ai-label">AI Translator</span>
        <span class="language-pair">{{sourceLang}} → {{targetLang}}</span>
    </div>
    <div class="ai-content">
        <div class="translation-box">
            <div class="original-text">
                <span class="label">Original ({{sourceLang}}):</span>
                <p>{{originalText}}</p>
            </div>
            <div class="translated-text">
                <span class="label">Translation ({{targetLang}}):</span>
                <p>{{translatedText}}</p>
            </div>
        </div>
        
        {{#if alternatives}}
        <div class="alternatives">
            <h4>Alternative Translations</h4>
            {{#each alternatives}}
            <div class="alternative">
                <p>{{text}}</p>
                <span class="alternative-note">{{note}}</span>
            </div>
            {{/each}}
        </div>
        {{/if}}
        
        <div class="transliteration">
            <span class="label">Transliteration:</span>
            <p>{{transliteration}}</p>
        </div>
    </div>
</div>

