# Game Engine Documentation

This document describes the game engine utilities shared between the Game Center frontend and AI Backend.

## Overview

The game engine module (`src/shared/game-engine.s`) provides essential utilities for game development, including:

- **Core Math Utilities**: Collision detection, vector math, interpolation
- **Particle System**: Visual effects for games
- **High Score Management**: Persistent score tracking
- **Game State Management**: State machine for game flow control

## File Structure

```
src/shared/
├── game-engine.s          # Main game engine utilities
├── ai-utils.s             # AI-specific utilities
├── templates/
│   ├── game-templates.t   # Game UI templates
│   └── ai-response-templates.t  # AI response templates
```

## Usage

### Basic Math Functions

```javascript
import { GameEngine } from './game-engine.s';

// Collision detection
const isColliding = GameEngine.circleCollision(x1, y1, r1, x2, y2, r2);
const isOverlapping = GameEngine.rectCollision(x1, y1, w1, h1, x2, y2, w2, h2);

// Random utilities
const random = GameEngine.randomInt(1, 100);
const shuffled = GameEngine.shuffleArray([1, 2, 3, 4, 5]);

// Formatting
const formatted = GameEngine.formatNumber(1234567); // "1,234,567"
const timeStr = GameEngine.formatTime(125); // "02:05"
```

### Particle System

```javascript
const particles = new GameEngine.ParticleSystem();

// Emit particles at position
particles.emit(x, y, 20, {
    color: '#ff0000',
    size: 5,
    lifetime: 1000,
    gravity: 0.1,
    speed: 3
});

// In game loop
function update() {
    particles.update(deltaTime);
    particles.draw(ctx);
}
```

### High Score Management

```javascript
const highScores = new GameEngine.HighScoreManager('gameHighScores');

// Save a score
highScores.saveScore('Player1', 10000, 'BulletForager', {
    level: 5,
    timePlayed: 3600
});

// Get top scores
const top10 = highScores.getTopScores(10);
```

### Game State Management

```javascript
const gameState = new GameEngine.GameStateManager();

gameState.onStateEnter(GameEngine.STATES.PLAYING, (data) => {
    console.log('Game started with:', data);
});

gameState.setState(GameEngine.STATES.PLAYING, { level: 1 });

if (gameState.isState(GameEngine.STATES.GAME_OVER)) {
    // Handle game over
}
```

## Constants

### Game States
- `GAME_ENGINE.STATES.MENU` - Main menu
- `GAME_ENGINE.STATES.PLAYING` - Active gameplay
- `GAME_ENGINE.STATES.PAUSED` - Game paused
- `GAME_ENGINE.STATES.GAME_OVER` - Game ended
- `GAME_ENGINE.STATES.LEVEL_COMPLETE` - Level finished
- `GAME_ENGINE.STATES.LOADING` - Loading assets

### Directions
- `GAME_ENGINE.DIRECTIONS.UP`, `DOWN`, `LEFT`, `RIGHT`
- `GAME_ENGINE.DIRECTIONS.UP_LEFT`, `UP_RIGHT`, `DOWN_LEFT`, `DOWN_RIGHT`

## Configuration

```javascript
GameEngine.CONFIG.FPS = 60;           // Target framerate
GameEngine.CONFIG.COLLISION_THRESHOLD = 0.1;
GameEngine.CONFIG.PARTICLE_LIFETIME = 1000; // milliseconds
```

## AI Backend Integration

The game engine utilities are also available in the AI backend for:

1. **Game Analysis**: Analyzing player performance using collision and scoring utilities
2. **Strategy Generation**: Generating game tips based on math utilities
3. **Statistics**: Calculating performance metrics

```python
# In Python (via Pyodide or similar)
from game_engine_s import GameEngine

score_stats = GameEngine.calculate_statistics(scores)
```

## Performance Considerations

- Use `debounce()` for infrequent operations
- Use `throttle()` for frequent updates like input handling
- Reuse objects instead of creating new ones
- Use `requestAnimationFrame` for game loops

## Browser Support

- Chrome 60+
- Firefox 55+
- Safari 11+
- Edge 79+

## API Reference

### Functions

| Function                   | Description              | Time Complexity |
| -------------------------- | ------------------------ | --------------- |
| `clamp(value, min, max)`   | Constrain value to range | O(1)            |
| `lerp(start, end, t)`      | Linear interpolation     | O(1)            |
| `distance(x1, y1, x2, y2)` | Euclidean distance       | O(1)            |
| `circleCollision(...)`     | Circle collision check   | O(1)            |
| `rectCollision(...)`       | Rectangle collision      | O(1)            |
| `randomInt(min, max)`      | Random integer           | O(1)            |
| `shuffleArray(array)`      | Fisher-Yates shuffle     | O(n)            |

### Classes

| Class              | Description                     |
| ------------------ | ------------------------------- |
| `Particle`         | Individual particle for effects |
| `ParticleSystem`   | Manager for multiple particles  |
| `HighScoreManager` | Persistent score storage        |
| `GameStateManager` | State machine implementation    |

## Contributing

When adding new utilities to the game engine:

1. Add appropriate JSDoc comments
2. Include time complexity in documentation
3. Add unit tests
4. Update this documentation

## License

Part of the Game Center project under MIT license.

