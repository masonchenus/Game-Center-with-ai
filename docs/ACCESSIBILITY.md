# Accessibility Guidelines

This document outlines accessibility standards for Game Center.

## WCAG 2.1 Compliance

Game Center aims for WCAG 2.1 AA compliance where applicable.

## Vision

### Color Contrast

- **Minimum contrast ratio**: 4.5:1 for normal text
- **Minimum contrast ratio**: 3:1 for large text (18pt+)
- **Minimum contrast ratio**: 3:1 for UI components

### Text Sizing

- Minimum readable font size: 14px
- Support browser zoom up to 200%
- Use relative units (em, rem) for scalability

### Visual Indicators

- Don't rely on color alone to convey information
- Use icons, patterns, and text labels
- Provide visual focus indicators

## Hearing

### Audio Alternatives

- Provide captions for all video content
- Use text descriptions for sound effects
- Offer visual indicators instead of audio alerts

### Volume Control

- Implement audio controls for all sound effects
- Provide volume adjustment in settings
- Respect system volume settings

## Motor

### Keyboard Navigation

- All functionality accessible via keyboard
- Logical tab order through interactive elements
- Clear focus indicators (outline, highlight)
- Skip navigation links for faster keyboard navigation

### Input Methods

- Support mouse, keyboard, and touch
- Minimum touch target size: 44x44 pixels
- Provide multiple input methods where possible
- No time-based interactions that can't be paused

### Gesture Alternatives

- Provide keyboard alternatives for gestures
- Don't require multi-finger gestures
- Allow time for input detection

## Cognitive

### Clear Language

- Use simple, clear language
- Avoid jargon when possible
- Provide definitions for technical terms
- Use short sentences and paragraphs

### Consistent Navigation

- Keep controls in consistent locations
- Use predictable naming conventions
- Provide clear labels for all controls

### Error Prevention

- Prevent errors where possible
- Clearly explain errors that occur
- Provide suggestions for correction
- Allow users to undo actions

## Implementation

### HTML Structure

```html
<!-- Use semantic HTML -->
<header>...</header>
<nav>...</nav>
<main>...</main>
<footer>...</footer>

<!-- Use proper heading hierarchy -->
<h1>Page Title</h1>
<h2>Section</h2>

<!-- Use labels for form controls -->
<label for="username">Username:</label>
<input id="username" type="text">
```

### ARIA (Accessible Rich Internet Applications)

```html
<!-- Use ARIA for dynamic content -->
<div role="alert" aria-live="polite">
  Game paused
</div>

<!-- Use ARIA labels -->
<button aria-label="Close menu">×</button>

<!-- Provide accessible names -->
<img alt="Game controller icon" src="controller.png">
```

### Focus Management

```javascript
// Move focus programmatically
element.focus();

// Store and restore focus
const previousFocus = document.activeElement;
// ... show modal ...
// ... close modal ...
previousFocus.focus();
```

### Screen Reader Support

- Provide alt text for all images
- Use ARIA landmarks for page structure
- Announce dynamic content changes
- Use semantic HTML elements

## Testing

### Automated Testing

```bash
# Axe accessibility testing
npm install --save-dev @axe-core/playwright

# WebAIM tools
# https://webaim.org/resources/
```

### Manual Testing

1. **Keyboard Navigation**
   - Tab through all interactive elements
   - Verify logical tab order
   - Test with screen readers

2. **Screen Reader Testing**
   - Use NVDA (Windows) or JAWS
   - Use VoiceOver (macOS/iOS)
   - Use TalkBack (Android)

3. **Color Contrast**
   - Use WebAIM Color Contrast Checker
   - Test with color blindness simulator

4. **Responsive Testing**
   - Test at 200% zoom
   - Test with browser font size increased
   - Test with mobile devices

## Guidelines by Feature

### Buttons

```html
<!-- Good -->
<button aria-label="Pause game">⏸️</button>

<!-- Also good -->
<button>Pause <span class="sr-only">game</span></button>
```

### Links

```html
<!-- Good - descriptive text -->
<a href="/rules">Game rules</a>

<!-- Avoid - vague text -->
<a href="/rules">Click here</a>
```

### Form Controls

```html
<!-- Always use labels -->
<label for="difficulty">Difficulty:</label>
<select id="difficulty">
  <option value="easy">Easy</option>
  <option value="hard">Hard</option>
</select>

<!-- Provide clear error messages -->
<input type="email" required aria-invalid="true" aria-describedby="email-error">
<div id="email-error" role="alert">Please enter a valid email</div>
```

### Canvas Games

Canvas games present unique accessibility challenges:

1. **Keyboard Controls**
   ```javascript
   // Make all game actions keyboard accessible
   document.addEventListener('keydown', (e) => {
     if (e.key === 'ArrowUp') moveUp();
     if (e.key === ' ') fire();
   });
   ```

2. **Audio Description**
   ```html
   <video aria-label="Game gameplay with audio description">
     <source src="game-description.mp3" type="audio/mpeg">
   </video>
   ```

3. **Pause Functionality**
   ```javascript
   // Allow users to pause games
   const canPause = true;
   ```

## Accessibility Checklist

- [ ] All text has sufficient contrast (4.5:1 minimum)
- [ ] All interactive elements are keyboard accessible
- [ ] Focus indicators are visible
- [ ] All images have alt text
- [ ] Form labels are properly associated
- [ ] Color is not the only method to convey information
- [ ] Page structure uses semantic HTML
- [ ] ARIA is used correctly (not overused)
- [ ] Page can be zoomed to 200%
- [ ] Text is resizable
- [ ] Pause/stop functionality is available
- [ ] No content flashes more than 3 times per second
- [ ] Error messages are clear and helpful
- [ ] Controls are 44x44px minimum touch targets
- [ ] Page works without JavaScript (progressive enhancement)

## Resources

- [WebAIM](https://webaim.org/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)
- [Accessibility Insights](https://accessibilityinsights.io/)
- [Axe DevTools](https://www.deque.com/axe/devtools/)

## Continuous Improvement

- Regularly test with real assistive technology users
- Gather feedback from disabled users
- Stay updated with WCAG guidelines
- Implement accessibility from the start of development
