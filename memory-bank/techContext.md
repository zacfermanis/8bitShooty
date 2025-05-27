# Technical Context

## Technology Stack
- LÖVE (Love2D) framework
- Lua programming language
- Built-in LÖVE modules:
  - graphics
  - audio
  - input
  - math
  - timer

## Development Setup
- LÖVE 11.4 or higher
- Lua 5.1
- Git for version control
- Text editor with Lua support

## Core Systems

### Rendering System
- LÖVE graphics module
- Custom drawing functions for:
  - Player
  - Enemies
  - Projectiles
  - UI elements
- Particle effects
- Visual feedback

### Input System
- Keyboard controls:
  - A/D or Left/Right for movement
  - Space for shooting
  - Escape for menu
- Mouse controls:
  - Aiming
  - Shop interaction
  - Menu navigation

### Physics System
- Custom collision detection
- Circle-based hitboxes
- Splash damage calculations
- Movement vectors

### Weapon System
- Projectile types:
  - Default (yellow, single shot)
  - Plasma (cyan, high damage)
  - Rocket (orange, splash damage)
- Damage calculations
- Auto-targeting
- Cooldown system

## Dependencies
- No external libraries required
- Uses LÖVE's built-in modules
- Asset requirements:
  - Player sprite (optional)
  - Enemy sprites (optional)
  - Weapon sprites (optional)

## Performance Considerations
- Object pooling for projectiles
- Efficient collision detection
- Particle effect optimization
- Memory management for entities
- Frame rate targeting (60 FPS)

## Development Guidelines
1. Maintain consistent code style
2. Document complex systems
3. Optimize critical paths
4. Test on multiple platforms
5. Regular performance profiling
6. Version control best practices
7. Regular backups

## Development Workflow
1. Code Organization:
   - Modular structure
   - Clear separation
   - Consistent patterns
   - Documentation

2. Testing:
   - Manual testing
   - Performance monitoring
   - Bug tracking
   - Feature validation

3. Version Control:
   - Git workflow
   - Feature branches
   - Commit messages
   - Code review

## Technical Documentation
1. Code Documentation:
   - Function documentation
   - System architecture
   - Implementation details
   - Usage patterns

2. System Documentation:
   - Wave system
   - Shop system
   - Upgrade system
   - Visual system

3. Development Guidelines:
   - Coding standards
   - Documentation requirements
   - Testing procedures
   - Review process

Note: This document will be updated as specific technology choices are made and development tools are selected. 