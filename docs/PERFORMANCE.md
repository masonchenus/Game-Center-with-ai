# Performance Optimization Guide

This document outlines performance optimizations implemented in Game Center.

## Service Worker & Caching Strategy

### Cache Levels

1. **Network First** - Requests go to network first, fallback to cache
   - API calls
   - Game data
   - Dynamic content

2. **Cache First** - Use cache, fallback to network
   - Images
   - CSS/JS files
   - Static assets

3. **Stale While Revalidate** - Use cache immediately, update in background
   - HTML files
   - JSON configuration

### Cache Versioning

The Service Worker uses versioning (`v1`) to manage cache invalidation:

```javascript
const CACHE_NAME = 'game-center-v1';
```

Increment the version number when deploying breaking changes.

## Compression

### Gzip Compression

All text-based responses are compressed using gzip:

- HTML files: ~40% smaller
- CSS files: ~45% smaller
- JavaScript: ~50% smaller
- JSON: ~60% smaller

### Brotli Compression (Optional)

For modern browsers, consider Brotli compression for 15-20% better compression.

## Asset Optimization

### Image Optimization

```
Logo: 192x192 PNG / 512x512 PNG
- Use WebP format where supported
- Lazy load images below the fold
- Use srcset for responsive images
```

### Code Splitting

Consider splitting large game code into separate files:

```javascript
// Feature-based splitting
- calculator.js
- spaceinvaders.js
- spaceshooter.js
- chaos-weapons.js
```

### Minification

All JavaScript and CSS should be minified in production:

```bash
# Manual minification example
uglifyjs src/main.js -o src/main.min.js
cleancss src/style.css -o src/style.min.css
```

## Rendering Performance

### Requestsimationframe

Use `requestAnimationFrame` for smooth animations:

```javascript
function animate() {
  // Update game state
  // Render to canvas
  requestAnimationFrame(animate);
}
```

### Canvas Optimization

1. **Clear only affected regions**
   ```javascript
   ctx.clearRect(0, 0, width, height); // Full clear
   ```

2. **Use appropriate precision**
   ```javascript
   // Instead of Math.random() * 999999
   // Use Math.random() * 1000
   ```

3. **Cache transformed values**
   ```javascript
   const rad = angle * Math.PI / 180; // Cache once
   ```

## Memory Management

### Garbage Collection

1. **Avoid creating objects in loops**
   ```javascript
   // Bad
   for (let i = 0; i < 1000; i++) {
     const obj = new Bullet();
   }
   
   // Good
   const bullets = [];
   for (let i = 0; i < 1000; i++) {
     bullets[i] = new Bullet();
   }
   ```

2. **Reuse objects**
   ```javascript
   // Use object pools for frequent allocations
   const bulletPool = [];
   ```

3. **Remove event listeners**
   ```javascript
   element.removeEventListener('click', handler);
   ```

## Network Performance

### HTTP/2 Push

Enable HTTP/2 Server Push for critical assets:

```
X-Push: /style.css, /main.js
```

### Preload Critical Resources

```html
<link rel="preload" href="font.woff2" as="font" type="font/woff2">
<link rel="preload" href="critical.css" as="style">
```

### DNS Prefetch

```html
<link rel="dns-prefetch" href="https://api.example.com">
```

## Deployment Optimization

### minify HTML

Minify all HTML files before deployment.

### Bundle Size

Keep bundle size under 500KB:

- Check with: `du -sh src/`
- Analyze with: `webpack-bundle-analyzer`

### Content Delivery Network (CDN)

Use a CDN for:
- Static assets
- Images
- CSS/JavaScript files

## Performance Metrics

### Core Web Vitals

Target values:

- **LCP** (Largest Contentful Paint): < 2.5 seconds
- **FID** (First Input Delay): < 100 milliseconds
- **CLS** (Cumulative Layout Shift): < 0.1

### Monitoring

Use tools to monitor performance:

- Google PageSpeed Insights
- WebPageTest
- Lighthouse
- Chrome DevTools Performance tab

## Browser DevTools

### Performance Recording

1. Open DevTools → Performance tab
2. Click record
3. Play game for 30 seconds
4. Stop and analyze

### Memory Profiling

1. Open DevTools → Memory tab
2. Take heap snapshot
3. Play game for 1 minute
4. Take another snapshot
5. Compare for memory leaks

## Configuration Files

### .htaccess

Configured for:
- Gzip compression
- Cache control headers
- Browser caching
- Security headers

### netlify.toml

Configured for:
- Build optimization
- Redirect rules
- Cache headers
- Deployment strategies

### vercel.json

Configured for:
- Rewrite rules
- Response headers
- Build settings

## Future Optimizations

1. **WebAssembly (WASM)**
   - Physics calculations
   - Collision detection
   - Particle effects

2. **Web Workers**
   - Offload heavy computations
   - Keep main thread responsive

3. **IndexedDB**
   - Store game progress locally
   - Cache downloaded assets

4. **Progressive Enhancement**
   - Load features progressively
   - Graceful degradation

## Testing Performance

```bash
# Generate performance report
npm run perf

# Analyze bundle size
npm run analyze
```

## References

- [Web.dev Performance](https://web.dev/performance/)
- [MDN Performance Guide](https://developer.mozilla.org/en-US/docs/Web/Performance)
- [Chrome DevTools](https://developer.chrome.com/docs/devtools/)
