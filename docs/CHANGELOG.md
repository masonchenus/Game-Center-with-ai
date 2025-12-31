# Changelog

All notable changes to Game Center are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [2.2.3-organization] - 2025-12-31

### Added
- REORGANIZATION_SUMMARY.md documenting repository reorganization
- REORGANIZATION_TODO.md for tracking reorganization progress

### Changed
- Documentation files consolidated to `docs/` directory
- `LANGUAGES_SCATTERING_PLAN.md` moved to docs/
- `content_language_stats.json` moved to docs/
- `file_extension_stats.json` moved to docs/

### Removed
- `Update Overviews & pdf/` directory (merged into docs/changelog/)
- Empty `temp/` directory
- Empty `tmp/` directory

---

## [2.2.2] - 2025-12-23

### Added
- Multiple new AI modules:
  - `tester_module.py` - Automated code testing
  - `agent_module.py` - AI agent functionality
  - `helper_module.py` - General helper utilities
  - `slides_generator.py` - Presentation slide generation
  - `math_solver.py` - Mathematical problem solving
  - `game_generator.py` - Game generation capabilities
- Privacy Policy documentation
- Overview documentation
- Enhanced GitHub Actions workflows

### Changed
- Updated static.yml deployment workflow
- Improved CI/CD pipeline with Java setup step
- Project renamed to "Multi repository"
- AI model implementations reorganized

---

## [2.2.1] - 2025-12-22

### Added
- Version bump and release documentation
- Enhanced documentation structure

### Changed
- Multiple minor version increments for testing
- Repository structure refinements

---

## [2.2.0] - 2025-12-21

### Added
- Project renamed from Game Center to "Multi repository"
- AI integration documentation
- Multi-purpose repository structure

### Changed
- Project name and branding updates
- Repository documentation updated

---

## [2.1.0] - 2025-12-20

### Added
- AI model implementations removed from ai_backend repository (externalized)
- Enhanced module structure documentation

### Changed
- Modularized AI components for better maintainability
- AI models now reference external implementations

---

## [2.0.4] - 2025-12-19

### Added
- Version documentation files (html, md, pdf, tex)

### Changed
- Minor refinements and documentation updates

---

## [2.0.3] - 2025-12-18

### Added
- Multiple new modules under ai_backend/modules/
- Python AI multi-purpose file structure

### Changed
- Module organization improved
- Enhanced AI backend structure

---

## [2.0.2] - 2025-12-17

### Added
- Variety to enemy types in initMegaGame
- Randomize enemy generation in Mega Game
- Bullet Forger presets and in-game selection menu
- CSS and layout overhaul for bullet-forger

### Changed
- Game mechanics enhanced
- UI/UX improvements

### Fixed
- Enemy generation randomization
- Bullet Forger functionality

---

## [2.0.1.1] - 2025-12-16

### Added
- Additional version documentation

### Changed
- Minor version bump

---

## [2.0.1] - 2025-12-16

### Added
- Progressive Web App (PWA) support
- Service Worker implementation
- Performance optimization files
- Accessibility guidelines documentation
- Security policy documentation
- Deployment guides for multiple platforms

### Changed
- Enhanced canvas rendering performance
- Improved bullet collision detection
- Service Worker integration

---

## [2.0.0] - 2025-12-15

### Added
- Major version release with extensive features
- Advanced AI integration
- Enhanced game mechanics
- Comprehensive documentation suite

### Changed
- Major architecture updates
- Performance improvements across the board

---

## [1.4.0] - 2025-12-10

### Added
- Privacy Policy documentation
- Developer documentation enhancements
- CodeQL workflow integration

### Changed
- Documentation improvements
- License updates

---

## [1.3.x] - 2025-12-08 to 2025-12-11

### Added
- Static website deployment workflows (jekyll-gh-pages.yml, static.yml)
- Overview.md documentation
- Gradient background for start screen
- Marketplace addons support

### Changed
- Multiple version updates (1.3.2, 1.3.2-beta, 1.3.2.1b)
- Workflow optimizations
- Static site deployment configuration

### Fixed
- Static.yml error fixes
- Workflow configuration issues

---

## [1.3.0] - 2025-11-30

### Added
- Multiple weapon types:
  - Normal, Boost, Spreadshot, Laser, Plasma
  - Missile, Nova, Tempest, Chaos
- Enemy destruction particle effects
- Score tracking and leaderboard system
- Power-ups system (damage, speed, fire rate, invincibility, shield)
- Game levels and wave progression
- Boss battles
- Sound effects and visual effects

### Changed
- Improved game physics calculations
- Enhanced canvas rendering performance

### Fixed
- Bullet collision detection
- Enemy spawning logic

---

## [1.0.1] - 2025-12-01

### Added
- Multiple weapon types
- Enemy destruction particle effects
- Score tracking and leaderboard
- Power-ups system
- Game levels and wave progression
- Boss battles
- Sound effects and visual effects

### Changed
- Improved game physics calculations
- Enhanced canvas rendering performance

### Fixed
- Bullet collision detection
- Enemy spawning logic

---

## [1.0.0] - 2025-11-01

### Added
- Initial Game Center release
- Multiple game modes:
  - Space Invaders Classic
  - Space Invaders But Better (with weapons)
  - Space Shooter
  - Calculator
  - Flappy Clone
  - Snake
  - Breakout
  - Asteroids Shooter
  - Tower Defense
  - Bubble Shooter
  - Fireworks
- Dynamic HTML content loading
- Settings and configuration system
- Jest testing framework setup
- Developer documentation

---

## [Unreleased] - Future

### Planned
- Additional AI module integrations
- Enhanced performance metrics (500+ metrics)
- 3-column responsive chat interface
- Chat history persistence and management
- Module selection sidebar with categories
- Real-time performance monitoring

---

## Version History Summary

| Version            | Date       | Major Changes                       |
| ------------------ | ---------- | ----------------------------------- |
| 2.2.3-organization | 2025-12-31 | Repository reorganization           |
| 2.2.2              | 2025-12-23 | New AI modules, Privacy Policy      |
| 2.2.1              | 2025-12-22 | Version refinements                 |
| 2.2.0              | 2025-12-21 | Project renamed to Multi repository |
| 2.1.0              | 2025-12-20 | AI model externalization            |
| 2.0.4              | 2025-12-19 | Documentation updates               |
| 2.0.3              | 2025-12-18 | New AI modules                      |
| 2.0.2              | 2025-12-17 | Game mechanics, Bullet Forger       |
| 2.0.1.1            | 2025-12-16 | Version bump                        |
| 2.0.1              | 2025-12-16 | PWA, Service Worker, Accessibility  |
| 2.0.0              | 2025-12-15 | Major release, AI integration       |
| 1.4.0              | 2025-12-10 | Privacy Policy, Documentation       |
| 1.3.x              | 2025-12-08 | Static site, Workflows              |
| 1.3.0              | 2025-11-30 | Weapons, Power-ups, Boss battles    |
| 1.0.1              | 2025-12-01 | Weapons, Physics improvements       |
| 1.0.0              | 2025-11-01 | Initial release                     |

---

[Unreleased]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.2.3-organization...HEAD
[2.2.3-organization]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.2.2...v2.2.3-organization
[2.2.2]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.2.1...v2.2.2
[2.2.1]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.0.4...v2.1.0
[2.0.4]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.0.3...v2.0.4
[2.0.3]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.0.2...v2.0.3
[2.0.2]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.0.1.1...v2.0.2
[2.0.1.1]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.0.1...v2.0.1.1
[2.0.1]: https://github.com/masonchenus/Multi-purpose-repo/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/masonchenus/Multi-purpose-repo/compare/v1.4.0...v2.0.0
[1.4.0]: https://github.com/masonchenus/Multi-purpose-repo/compare/v1.3.x...v1.4.0
[1.3.x]: https://github.com/masonchenus/Multi-purpose-repo/compare/v1.3.0...v1.3.x
[1.3.0]: https://github.com/masonchenus/Multi-purpose-repo/compare/v1.0.1...v1.3.0
[1.0.1]: https://github.com/masonchenus/Multi-purpose-repo/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/masonchenus/Multi-purpose-repo/releases/tag/v1.0.0

