# System Patterns

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

Note: This document will be updated as the technical architecture evolves and new patterns are implemented. 