# Technical Context

## Technologies Used
1. Core Framework
   - LÖVE (Love2D) 11.4
   - Lua 5.4
   - LÖVE Physics Module

2. Development Tools
   - Visual Studio Code
   - Git for version control
   - LÖVE Debug Tools
   - Particle System Debugger

3. Asset Management
   - Custom sprite generation
   - Particle effect system
   - Sound effect management
   - Font rendering

## Development Setup
1. Environment Configuration
   ```bash
   # Required dependencies
   love2d=11.4
   lua=5.4
   git=latest
   ```

2. Project Structure
   ```
   8bitShooty/
   ├── main.lua
   ├── conf.lua
   ├── memory-bank/
   │   ├── projectbrief.md
   │   ├── productContext.md
   │   ├── systemPatterns.md
   │   ├── techContext.md
   │   ├── activeContext.md
   │   └── progress.md
   └── assets/
       ├── fonts/
       ├── sounds/
       └── particles/
   ```

3. Build Process
   ```bash
   # Development
   love .
   
   # Distribution
   zip -9 -r 8bitShooty.love .
   ```

## Technical Constraints
1. Performance Requirements
   - 60 FPS target
   - < 16ms frame time
   - < 100MB memory usage
   - Particle count limits
   - Entity pooling

2. Platform Support
   - Windows 10+
   - macOS 10.13+
   - Linux (Ubuntu 20.04+)
   - Web (planned)

3. Hardware Requirements
   - 2GB RAM minimum
   - OpenGL 2.1+
   - 128MB VRAM
   - 1GHz CPU

## Dependencies
1. Core Dependencies
   ```lua
   -- main.lua
   local love = require("love")
   local physics = require("love.physics")
   ```

2. External Libraries
   - None (pure LÖVE implementation)
   - Custom particle system
   - Custom UI framework
   - Custom animation system

3. Asset Dependencies
   - Custom fonts
   - Generated sprites
   - Particle effects
   - Sound effects

## Tool Usage Patterns
1. Particle System
   ```lua
   -- Particle creation
   function createParticles(x, y, type, properties)
       local particles = {}
       -- Particle generation logic
       return particles
   end

   -- Particle update
   function updateParticles(particles, dt)
       for i = #particles, 1, -1 do
           local p = particles[i]
           -- Update logic
           if p.life <= 0 then
               table.remove(particles, i)
           end
       end
   end

   -- Particle rendering
   function drawParticles(particles)
       for _, p in ipairs(particles) do
           -- Drawing logic
       end
   end
   ```

2. Debug Tools
   ```lua
   -- Debug rendering
   function drawDebug()
       -- Particle system debug
       -- Performance metrics
       -- Entity counts
       -- Memory usage
   end
   ```

3. Performance Monitoring
   ```lua
   -- Performance tracking
   function updatePerformance()
       -- Frame time
       -- Memory usage
       -- Particle count
       -- Entity count
   end
   ```

## Implementation Details
1. Particle System
   - Hit particles (blood effects)
   - Death particles (explosions)
   - Special effect particles
   - Gravity-affected movement
   - Alpha-based transparency
   - Dynamic rotation system

2. Visual Effects
   - 8-bit style graphics
   - Dynamic particle systems
   - Flash effects
   - Impact feedback
   - Environmental effects

3. Game Systems
   - Wave-based progression
   - Shop economy
   - Weapon upgrades
   - Special abilities
   - Auto-targeting

## Performance Optimization
1. Particle System
   - Limit particle count
   - Efficient cleanup
   - Batch rendering
   - Memory management
   - Update frequency control

2. Game Systems
   - Entity pooling
   - Update batching
   - State caching
   - Memory optimization
   - Render optimization

3. Visual Effects
   - Effect culling
   - Particle limits
   - Render batching
   - Memory management
   - Update frequency

## Future Technical Considerations
1. System Expansion
   - More particle types
   - Enhanced effects
   - Additional abilities
   - New weapons
   - Environment features

2. Performance Improvements
   - Particle optimization
   - Memory management
   - Render efficiency
   - Update batching
   - State caching

3. Feature Additions
   - Weather effects
   - More special abilities
   - Additional weapons
   - Enhanced UI
   - Save system

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