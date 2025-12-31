// AI Backend Email Templates - Handlebars template system
// Used by game center and ai_backend for notification emails

{{!-- Welcome Email Template --}}
<!DOCTYPE html>
<html>
<head>
    <style>
        .container { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background: #f9f9f9; }
        .button { display: inline-block; padding: 12px 24px; background: #667eea; color: white; text-decoration: none; border-radius: 4px; }
        .footer { padding: 20px; text-align: center; font-size: 12px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎮 Welcome to Game Center!</h1>
        </div>
        <div class="content">
            <p>Hi {{userName}},</p>
            <p>Welcome to the Game Center! We're thrilled to have you join our community.</p>
            <p>Your account has been created successfully with the following details:</p>
            <ul>
                <li><strong>Username:</strong> {{userName}}</li>
                <li><strong>Email:</strong> {{email}}</li>
                <li><strong>Member since:</strong> {{registrationDate}}</li>
            </ul>
            <p>Get started by exploring our games and competing on leaderboards!</p>
            <p style="text-align: center;">
                <a href="{{dashboardUrl}}" class="button">Go to Dashboard</a>
            </p>
        </div>
        <div class="footer">
            <p>© {{currentYear}} Game Center. All rights reserved.</p>
            <p>To unsubscribe, visit <a href="{{unsubscribeUrl}}">unsubscribe</a></p>
        </div>
    </div>
</body>
</html>

{{!-- Achievement Unlock Email Template --}}
<!DOCTYPE html>
<html>
<head>
    <style>
        .container { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; }
        .header { background: linear-gradient(135deg, #f6d365 0%, #fda085 100%); color: white; padding: 20px; text-align: center; }
        .achievement-badge { font-size: 64px; text-align: center; margin: 20px 0; }
        .content { padding: 20px; background: #f9f9f9; }
        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin: 20px 0; }
        .stat-box { background: white; padding: 15px; text-align: center; border-radius: 8px; }
        .stat-value { font-size: 24px; font-weight: bold; color: #667eea; }
        .stat-label { font-size: 12px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏆 Achievement Unlocked!</h1>
        </div>
        <div class="achievement-badge">{{achievementIcon}}</div>
        <div class="content">
            <p>Congratulations, {{userName}}!</p>
            <p>You've unlocked a new achievement:</p>
            <h2 style="text-align: center; color: #667eea;">{{achievementName}}</h2>
            <p>{{achievementDescription}}</p>
            <div class="stats-grid">
                <div class="stat-box">
                    <div class="stat-value">{{totalAchievements}}</div>
                    <div class="stat-label">Total Achievements</div>
                </div>
                <div class="stat-box">
                    <div class="stat-value">{{completionPercentage}}%</div>
                    <div class="stat-label">Completion</div>
                </div>
                <div class="stat-box">
                    <div class="stat-value">{{currentStreak}}</div>
                    <div class="stat-label">Day Streak</div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>

{{!-- AI Game Recommendation Email Template --}}
<!DOCTYPE html>
<html>
<head>
    <style>
        .container { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }
        .ai-badge { background: #667eea; color: white; padding: 5px 15px; border-radius: 20px; font-size: 12px; display: inline-block; margin-bottom: 10px; }
        .content { padding: 20px; background: #f9f9f9; }
        .game-card { background: white; border-radius: 8px; padding: 15px; margin: 10px 0; display: flex; align-items: center; }
        .game-icon { width: 60px; height: 60px; background: #667eea; border-radius: 8px; margin-right: 15px; display: flex; align-items: center; justify-content: center; font-size: 24px; }
        .game-info { flex: 1; }
        .match-score { background: #28a745; color: white; padding: 5px 10px; border-radius: 4px; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <span class="ai-badge">🤖 AI Recommended</span>
            <h1>Games For You</h1>
        </div>
        <div class="content">
            <p>Hi {{userName}},</p>
            <p>Based on your playing history and preferences, our AI thinks you'll love these games:</p>
            
            {{#each recommendations}}
            <div class="game-card">
                <div class="game-icon">{{gameIcon}}</div>
                <div class="game-info">
                    <h3>{{gameName}}</h3>
                    <p>{{gameDescription}}</p>
                    <p>Tags: {{gameTags}}</p>
                </div>
                <span class="match-score">{{matchPercentage}}% Match</span>
            </div>
            {{/each}}
            
            <p style="text-align: center; margin-top: 20px;">
                <a href="{{recommendationsUrl}}" class="button">View All Recommendations</a>
            </p>
        </div>
    </div>
</body>
</html>

{{!-- Weekly Leaderboard Summary Email Template --}}
<!DOCTYPE html>
<html>
<head>
    <style>
        .container { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; }
        .header { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background: #f9f9f9; }
        .rank-change { display: inline-block; padding: 2px 8px; border-radius: 4px; font-size: 12px; }
        .rank-up { background: #28a745; color: white; }
        .rank-down { background: #dc3545; color: white; }
        .rank-same { background: #6c757d; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Weekly Leaderboard Summary</h1>
        </div>
        <div class="content">
            <p>Hi {{userName}},</p>
            <p>Here's how you performed this week:</p>
            
            <div class="stats-summary">
                <h3>Your Rank: #{{currentRank}}</h3>
                <p>
                    Rank Change: 
                    <span class="rank-change {{rankChangeClass}}">
                        {{#if rankImproved}}↑{{else}}↓{{/if}} {{rankChange}}
                    </span>
                </p>
                <p>Points Earned This Week: {{weeklyPoints}}</p>
                <p>Total Points: {{totalPoints}}</p>
            </div>
            
            <h3>Top 5 Players This Week</h3>
            <ol>
                {{#each topPlayers}}
                <li>{{playerName}} - {{points}} points</li>
                {{/each}}
            </ol>
        </div>
    </div>
</body>
</html>

