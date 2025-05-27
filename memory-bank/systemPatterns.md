# System Patterns

## Core Architecture

### Game State Management
- State machine pattern for game states (menu, playing, gameover, shop)
- Central game state object containing:
  - Current state
  - Score
  - Wave number
  - Monster counts
  - Shop data

### Entity System
- Player entity with:
  - Position
  - Health
  - Speed
  - Armor
  - Shield
- Projectile system with:
  - Multiple types (default, plasma, rocket)
  - Damage calculations
  - Special effects
- Monster system with:
  - Different types (basic, armored, elite)
  - Health scaling
  - Speed scaling

### Weapon System
- Modular weapon types:
  - Default gun
  - Shotgun (spread)
  - Laser gun (fast)
  - Plasma cannon (high damage)
  - Rocket launcher (splash)
- Upgrade system:
  - Damage multipliers
  - Fire rate
  - Auto-targeting

## Design Patterns

### Component Pattern
- Entities composed of components:
  - Position
  - Health
  - Movement
  - Weapon
  - Visual effects

### Observer Pattern
- Event system for:
  - Score updates
  - Health changes
  - Wave completion
  - Shop purchases

### Factory Pattern
- Projectile creation
- Monster spawning
- Shop item generation

## Critical Paths

### Combat Loop
1. Player input
2. Weapon firing
3. Projectile creation
4. Collision detection
5. Damage application
6. Score/coin updates

### Shop System
1. Wave completion
2. Shop state transition
3. Item display
4. Purchase validation
5. Upgrade application
6. Return to game

### Wave Progression
1. Monster count tracking
2. Wave completion check
3. Difficulty scaling
4. Background updates
5. Shop access

## System Architecture
1. Core Systems:
   - Game state management
   - Wave progression system
   - Shop and upgrade system
   - Visual environment system
   - Input handling

2. Game States:
   - Menu
   - Playing
   - Game Over
   - Shop

3. Component Relationships:
   - Player -> Gun -> Projectiles
   - Wave -> Monsters -> Rewards
   - Shop -> Upgrades -> Player Stats
   - Environment -> Visual Effects

## Key Technical Decisions
1. Game Engine:
   - LÖVE (Love2D) for 2D game development
   - Lua for game logic
   - Built-in physics and graphics

2. State Management:
   - Centralized game state
   - Wave progression tracking
   - Shop system persistence
   - Upgrade management

3. Visual System:
   - 8-bit style graphics
   - Dynamic background system
   - Building damage visualization
   - Wave-based environment changes

## Design Patterns
1. Wave System:
   - Wave state tracking
   - Monster scaling
   - Reward distribution
   - Visual feedback

2. Shop System:
   - Upgrade management
   - Purchase validation
   - Effect application
   - State persistence

3. Visual Design:
   - Consistent 8-bit style
   - Dynamic environment
   - Progressive damage
   - Atmospheric effects

## Critical Implementation Paths
1. Game Loop:
   - State updates
   - Input handling
   - Collision detection
   - Visual rendering

2. Wave Management:
   - Wave progression
   - Monster spawning
   - Difficulty scaling
   - Reward distribution

3. Shop System:
   - Purchase handling
   - Upgrade application
   - State persistence
   - Visual feedback

## Component Relationships
1. Player System:
   - Movement controls
   - Shooting mechanics
   - Health management
   - Upgrade effects

2. Monster System:
   - Spawning patterns
   - Movement AI
   - Health tracking
   - Wave scaling

3. Environment System:
   - Background management
   - Building states
   - Visual effects
   - Wave changes

## Technical Considerations
1. Performance:
   - Object pooling
   - State management
   - Visual optimization
   - Update efficiency

2. Maintainability:
   - Clear state management
   - Modular systems
   - Consistent patterns
   - Clear feedback

3. Extensibility:
   - Wave system flexibility
   - Shop item addition
   - Visual effect expansion
   - Feature integration

## Particle System Architecture
- Hit particles (blood effects)
- Death particles (explosions)
- Special effect particles
- Gravity-affected movement
- Alpha-based transparency
- Dynamic rotation system

## Key Technical Decisions
1. Particle Management
   - Separate arrays for different particle types
   - Efficient cleanup system
   - Gravity-based movement
   - Directional spawning
   - Performance optimization

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

## Design Patterns
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

2. Wave System
   ```lua
   -- Wave progression
   function updateWave()
       if monstersKilled >= monstersPerWave then
           -- Wave completion logic
           -- Environment updates
           -- Difficulty scaling
       end
   end
   ```

3. Shop System
   ```lua
   -- Shop item purchase
   function purchaseItem(item)
       if canAfford(item) then
           -- Purchase logic
           -- Effect application
           -- Feedback display
       end
   end
   ```

## Component Relationships
1. Particle System
   - Hit particles → Monster entities
   - Death particles → Monster entities
   - Special particles → Ability system
   - Environment particles → Background system

2. Game Systems
   - Wave system → Monster spawning
   - Shop system → Player upgrades
   - Weapon system → Projectile creation
   - Ability system → Special effects

3. Visual Systems
   - Particle effects → Game feedback
   - Environment → Wave progression
   - UI elements → Game state
   - Effects → Player actions

## Critical Implementation Paths
1. Particle System
   - Particle creation
   - Movement calculation
   - Gravity application
   - Rotation handling
   - Cleanup management

2. Wave Progression
   - Wave completion check
   - Environment updates
   - Difficulty scaling
   - Reward distribution
   - State transitions

3. Shop System
   - Item availability
   - Purchase validation
   - Effect application
   - UI updates
   - Feedback display

## Performance Considerations
1. Particle Optimization
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

## Future Considerations
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

Note: This document will be updated as the technical architecture evolves and new patterns are implemented. 