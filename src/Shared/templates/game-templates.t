// Game Templates - Handlebars template system
// Used by both game center and ai_backend for dynamic UI generation

{{!-- Main Game Container Template --}}
<div class="game-container" id="game-{{gameId}}">
    <div class="game-header">
        <h2>{{gameTitle}}</h2>
        <span class="game-version">v{{gameVersion}}</span>
    </div>
    
    <div class="game-canvas-wrapper">
        <canvas id="gameCanvas" width="{{canvasWidth}}" height="{{canvasHeight}}"></canvas>
    </div>
    
    <div class="game-controls">
        {{#each controls}}
        <button class="control-btn" data-action="{{action}}">{{label}}</button>
        {{/each}}
    </div>
    
    <div class="game-stats">
        <span class="stat">Score: <span id="score">{{initialScore}}</span></span>
        <span class="stat">Level: <span id="level">{{initialLevel}}</span></span>
        <span class="stat">Time: <span id="timer">{{initialTime}}</span></span>
    </div>
</div>

{{!-- Player Card Template --}}
<div class="player-card" data-player-id="{{playerId}}">
    <div class="player-avatar">
        <img src="{{avatarUrl}}" alt="{{playerName}}">
    </div>
    <div class="player-info">
        <h3>{{playerName}}</h3>
        <p class="player-rank">Rank: #{{playerRank}}</p>
        <p class="player-score">Score: {{playerScore}}</p>
    </div>
    {{#if achievements}}
    <div class="player-achievements">
        {{#each achievements}}
        <span class="achievement-badge" data-tooltip="{{description}}">{{icon}}</span>
        {{/each}}
    </div>
    {{/if}}
</div>

{{!-- Leaderboard Row Template --}}
<tr class="leaderboard-row" data-rank="{{rank}}">
    <td class="rank">{{rank}}</td>
    <td class="player-name">{{playerName}}</td>
    <td class="game-name">{{gameName}}</td>
    <td class="score">{{score}}</td>
    <td class="date">{{formattedDate}}</td>
</tr>

{{!-- Game Mode Selection Template --}}
<div class="mode-selector">
    {{#each modes}}
    <button class="mode-btn {{#if selected}}selected{{/if}}" data-mode="{{modeId}}">
        <span class="mode-icon">{{icon}}</span>
        <span class="mode-name">{{modeName}}</span>
        <span class="mode-desc">{{description}}</span>
    </button>
    {{/each}}
</div>

{{!-- Achievement Notification Template --}}
<div class="achievement-notification" id="achievement-{{achievementId}}">
    <div class="achievement-icon">{{icon}}</div>
    <div class="achievement-content">
        <h4>Achievement Unlocked!</h4>
        <p class="achievement-name">{{achievementName}}</p>
        <p class="achievement-desc">{{achievementDescription}}</p>
    </div>
</div>

{{!-- AI Game Suggestion Template --}}
<div class="ai-suggestion">
    <div class="ai-avatar">
        <span class="ai-icon">🤖</span>
    </div>
    <div class="suggestion-content">
        <p class="suggestion-text">{{suggestionText}}</p>
        {{#if suggestedActions}}
        <div class="suggested-actions">
            {{#each suggestedActions}}
            <button class="action-btn" data-action="{{action}}">{{label}}</button>
            {{/each}}
        </div>
        {{/if}}
    </div>
</div>

