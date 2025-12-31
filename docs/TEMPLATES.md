# Template System Documentation

This document describes the Handlebars template system used by both Game Center frontend and AI Backend for dynamic content generation.

## Overview

Templates (`.t` files) use Handlebars syntax to generate dynamic HTML content for:
- Game UI components
- Email notifications
- AI-generated responses

## File Structure

```
src/shared/templates/
├── game-templates.t           # Game UI templates
└── ai-response-templates.t    # AI response templates

ai_backend/templates/
└── email-templates.t          # Email templates
```

## Template Types

### 1. Game Templates (`game-templates.t`)

Used for rendering game-related UI components:

| Template                 | Description                                | Variables                                             |
| ------------------------ | ------------------------------------------ | ----------------------------------------------------- |
| Game Container           | Main game wrapper with canvas and controls | `gameId`, `gameTitle`, `canvasWidth`, `controls`      |
| Player Card              | Player profile display                     | `playerId`, `playerName`, `avatarUrl`, `achievements` |
| Leaderboard Row          | Individual leaderboard entry               | `rank`, `playerName`, `gameName`, `score`             |
| Mode Selector            | Game mode selection buttons                | `modes[]` with `modeId`, `icon`, `modeName`           |
| Achievement Notification | Achievement unlock popup                   | `achievementId`, `achievementName`, `icon`            |
| AI Game Suggestion       | AI-powered game recommendations            | `suggestionText`, `suggestedActions`                  |

#### Example Usage

```javascript
import Handlebars from 'handlebars';
import gameTemplates from './game-templates.t';

// Compile template
const gameContainerTemplate = Handlebars.compile(`
<div class="game-container" id="game-{{gameId}}">
    <h2>{{gameTitle}}</h2>
    <canvas id="gameCanvas" width="{{canvasWidth}}" height="{{canvasHeight}}"></canvas>
</div>
`);

// Render with data
const html = gameContainerTemplate({
    gameId: 'bullet-forager',
    gameTitle: 'Bullet Forager',
    canvasWidth: 800,
    canvasHeight: 600
});
```

### 2. Email Templates (`email-templates.t`)

Used for sending email notifications:

| Template           | Description              | Variables                                                 |
| ------------------ | ------------------------ | --------------------------------------------------------- |
| Welcome Email      | New user registration    | `userName`, `email`, `registrationDate`, `dashboardUrl`   |
| Achievement Unlock | Achievement notification | `userName`, `achievementIcon`, `achievementName`, `stats` |
| AI Recommendation  | Game recommendations     | `userName`, `recommendations[]`, `matchPercentage`        |
| Weekly Summary     | Leaderboard summary      | `userName`, `currentRank`, `weeklyPoints`, `topPlayers`   |

#### Example Usage

```javascript
import emailTemplates from 'ai_backend/templates/email-templates.t';

const welcomeEmail = Handlebars.compile(emailTemplates.templates.welcome);

const html = welcomeEmail({
    userName: 'Player1',
    email: 'player@example.com',
    registrationDate: new Date().toISOString(),
    dashboardUrl: 'https://gamecenter.app/dashboard'
});
```

### 3. AI Response Templates (`ai-response-templates.t`)

Used for formatting AI-generated content:

| Template         | Description              | Variables                                                    |
| ---------------- | ------------------------ | ------------------------------------------------------------ |
| Game Strategy    | Strategy recommendations | `gameName`, `immediateImprovements[]`, `statsComparison[]`   |
| Game Explanation | How-to guides            | `gameName`, `gameSummary`, `sections[]`                      |
| Coding Solution  | Code snippets            | `language`, `problemDescription`, `code`, `explanation`      |
| Math Solution    | Step-by-step math        | `problemStatement`, `steps[]`, `finalAnswer`                 |
| Translation      | Language translation     | `sourceLang`, `targetLang`, `originalText`, `translatedText` |

#### Example Usage

```javascript
import aiResponseTemplates from './ai-response-templates.t';

const strategyTemplate = Handlebars.compile(aiResponseTemplates.templates.gameStrategy);

const html = strategyTemplate({
    gameName: 'Bullet Forager',
    immediateImprovements: [
        { priority: 'High', suggestion: 'Focus on dodging enemies' },
        { priority: 'Medium', suggestion: 'Collect power-ups strategically' }
    ],
    statsComparison: [
        { metricName: 'Accuracy', yourValue: '65%', topValue: '90%', gap: '-25%' }
    ]
});
```

## Handlebars Helpers

### Built-in Helpers

```handlebars
{{!-- Conditionals --}}
{{#if condition}}
    Content when true
{{else}}
    Content when false
{{/if}}

{{!-- Loops --}}
{{#each items}}
    Index: {{@index}}, Value: {{this}}
{{/each}}

{{!-- Unless --}}
{{#unless isAdmin}}
    Content for non-admins
{{/unless}}

{{!-- With --}}
{{#with user}}
    Name: {{name}}, Email: {{email}}
{{/with}}
```

### Custom Helpers

```javascript
// Register custom helpers
Handlebars.registerHelper('formatDate', function(date) {
    return new Date(date).toLocaleDateString();
});

Handlebars.registerHelper('uppercase', function(str) {
    return str.toUpperCase();
});

Handlebars.registerHelper('math', function(left, operator, right) {
    switch(operator) {
        case '+': return left + right;
        case '-': return left - right;
        case '*': return left * right;
        case '/': return left / right;
    }
});

// Usage in templates
{{formatDate timestamp}}
{{uppercase name}}
{{math score '*' multiplier}}
```

## Template Best Practices

### 1. Use Partials for Reusable Components

```handlebars
{{!-- partials/button.tpl --}}
<button class="btn {{type}}" {{#if disabled}}disabled{{/if}}>
    {{text}}
</button>

{{!-- Register partial --}}
Handlebars.registerPartial('button', buttonTemplate);

{{!-- Use partial --}}
{{> button type="primary" text="Submit"}}
```

### 2. Escape HTML by Default

```handlebars
{{userInput}}     {{!-- Escaped --}}
{{{userInput}}}   {{!-- Raw (unescaped) - use carefully --}}
```

### 3. Optimize for Performance

```javascript
// Pre-compile templates in build process
import Handlebars from 'handlebars';
import fs from 'fs';

// Compile once, use many times
const template = Handlebars.compile(source);
```

### 4. Use Comments for Documentation

```handlebars
{{!-- 
    Game container template
    Used to wrap game canvas and controls
    @param {string} gameId - Unique game identifier
    @param {number} canvasWidth - Canvas width in pixels
--}}
```

## Integration with Backend

### Python (Flask/Jinja2 Adaptation

```python
from jinja2 import Template, Environment

# Convert Handlebars to Jinja2
def convert_hb_to_jinja2(hb_template):
    # Handlebars -> Jinja2 conversions
    conversions = {
        '{{': '{{ ',
        '}}': ' }}',
        '{{#if': '{% if',
        '{{/if': '{% endif %}',
        '{{#each': '{% for',
        '{{/each': '{% endfor %}',
        '{{this}}': '{{ item }}',
        '{{@index}}': '{{ loop.index0 }}'
    }
    # Apply conversions...
```

### JavaScript (Node.js)

```javascript
const Handlebars = require('handlebars');
const fs = require('fs');

// Load all templates
const templates = {};
fs.readdirSync('./templates').forEach(file => {
    const source = fs.readFileSync(`./templates/${file}`, 'utf8');
    templates[file.replace('.t', '')] = Handlebars.compile(source);
});

// Export for use
module.exports = templates;
```

## Template Security

### Sanitize User Input

```javascript
Handlebars.registerHelper('escape', function(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '<')
        .replace(/>/g, '>')
        .replace(/"/g, '"')
        .replace(/'/g, '&#x27;');
});
```

### Content Security Policy

```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; style-src 'self' 'unsafe-inline'">
```

## Performance Optimization

### 1. Pre-compile Templates

```bash
# Using handlebars CLI
handlebars src/templates/ -f templates.js
```

### 2. Cache Compiled Templates

```javascript
const templateCache = new Map();

function getTemplate(name) {
    if (!templateCache.has(name)) {
        const source = loadTemplate(name);
        templateCache.set(name, Handlebars.compile(source));
    }
    return templateCache.get(name);
}
```

### 3. Minimize Template Complexity

```handlebars
{{!-- Instead of complex logic in templates --}}
{{!-- Pass pre-computed values from JavaScript --}}

{{!-- Bad: Complex math in template --}}
{{math score '*' (math level '*' 0.1)}}

{{!-- Good: Pre-computed value --}}
{{effectiveScore}}
```

## Testing Templates

### Unit Test Example

```javascript
import { renderGameContainer } from './game-templates.t';

test('Game container renders correctly', () => {
    const html = renderGameContainer({
        gameId: 'test-game',
        gameTitle: 'Test Game',
        canvasWidth: 800,
        canvasHeight: 600
    });
    
    expect(html).toContain('id="game-test-game"');
    expect(html).toContain('Test Game');
    expect(html).toContain('width="800"');
});
```

## Migration Guide

### From Jinja2 to Handlebars

| Jinja2                 | Handlebars           |
| ---------------------- | -------------------- |
| `{% if x %}`           | `{{#if x}}`          |
| `{% endif %}`          | `{{/if}}`            |
| `{% for i in items %}` | `{{#each items}}`    |
| `{% endfor %}`         | `{{/each}}`          |
| `{{ item }}`           | `{{this}}`           |
| `{{ loop.index }}`     | `{{@index}}`         |
| `{{ item.attribute }}` | `{{item.attribute}}` |

## Related Documentation

- [Handlebars.js Documentation](https://handlebarsjs.com/)
- [Game Engine Documentation](../GAME_ENGINE.md)
- [AI Integration Guide](AI_INTEGRATION.md)

## License

Part of the Game Center project under MIT license.

