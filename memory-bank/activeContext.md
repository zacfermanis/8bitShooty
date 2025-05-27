# Active Context

## Current Focus
- Implementing and balancing new weapon systems
- Shop system improvements
- Visual feedback enhancements
- Enhanced visual effects for zombie interactions
- Improved particle system for blood and explosions
- Dynamic environment changes with wave progression

## Recent Changes
1. Added new weapon types:
   - Plasma Cannon
   - Rocket Launcher
   - Auto-targeting system
2. Implemented weapon upgrades:
   - Damage multipliers
   - Fire rate improvements
   - Special effects
3. Enhanced shop system:
   - More upgrade options
   - Better visual feedback
   - Improved navigation
4. Enhanced Blood Effects System
   - Added directional blood spray from impact points
   - Implemented gravity-affected blood particles
   - Created separate hit particles system
   - Added alpha-based fade effects
5. Improved Death Explosions
   - Added explosion flash effects
   - Enhanced particle count and distribution
   - Implemented gravity-affected explosion particles
   - Added dynamic rotation and movement
6. Wave-Based Environment Changes
   - Dynamic background color changes
   - Ground and grass color variations
   - Building regeneration between waves
   - Nebula effects for different times of day

## Active Decisions
1. Weapon Balance
   - Plasma Cannon: High damage, medium speed
   - Rocket Launcher: Splash damage, slower speed
   - Auto-targeting: Limited to default projectiles
   - Damage multipliers: Stack with weapon upgrades

2. Shop System
   - Scrollable item list
   - Clear upgrade paths
   - Balanced costs
   - Visual feedback for purchases

3. Visual Effects
   - Distinct weapon visuals
   - Clear damage indicators
   - Improved feedback
   - Performance optimization

4. Particle System Architecture
   - Separate arrays for different particle types (hit, death, special)
   - Gravity-based movement for realistic effects
   - Alpha-based fade-out for smooth transitions
   - Directional spawning based on impact angles

5. Visual Feedback
   - Blood particles spray in projectile direction
   - Explosion particles expand outward
   - Flash effects for dramatic moments
   - Dynamic particle rotation and movement

6. Performance Considerations
   - Particle count optimization
   - Efficient particle cleanup
   - Separate update loops for different particle types
   - Gravity calculations for realistic movement

## Next Steps
1. Balance new weapons
2. Test upgrade combinations
3. Optimize performance
4. Add more visual feedback
5. Improve shop navigation
6. Add sound effects
7. Implement save system
8. Further enhance particle effects
   - Add more variety to blood splatter patterns
   - Implement particle trails
   - Add more special effects for different zombie types
   - Optimize particle performance
9. Improve visual feedback
   - Add screen shake for impacts
   - Implement more dramatic death animations
   - Add particle effects for special abilities
   - Enhance explosion visuals
10. Environment improvements
   - Add more variety to background effects
   - Implement weather effects
   - Add more building variations
   - Enhance ground detail

## Current Patterns
1. Weapon System
   - Modular design
   - Upgrade stacking
   - Visual feedback
   - Performance optimization

2. Shop System
   - Scrollable interface
   - Clear feedback
   - Balanced progression
   - Multiple upgrade paths

3. Visual System
   - Distinct effects
   - Clear feedback
   - Performance focus
   - Consistent style

4. Particle Management
   - Create particles at impact points
   - Update positions with gravity
   - Apply rotation and scaling
   - Clean up expired particles

5. Wave Progression
   - Environment color changes
   - Building regeneration
   - Difficulty scaling
   - Visual theme variations

## Project Insights
1. Weapon balance is crucial for engaging gameplay
2. Clear visual feedback improves user experience
3. Multiple upgrade paths increase replayability
4. Performance optimization is ongoing
5. Shop system needs regular balancing
6. Visual effects enhance gameplay feel
7. Auto-targeting adds strategic depth
8. Visual Feedback
   - Blood effects provide immediate feedback for hits
   - Explosions create satisfying death animations
   - Particle systems enhance game feel
   - Dynamic effects improve engagement
9. Performance
   - Particle count affects performance
   - Separate particle types help organization
   - Efficient cleanup is crucial
   - Gravity calculations add realism
10. User Experience
   - Visual feedback enhances satisfaction
   - Dynamic effects improve immersion
   - Wave progression creates variety
   - Special effects add excitement

## Active Decisions and Considerations
- LÖVE physics vs custom collision system
- Enemy spawning patterns
- Health system mechanics
- Performance optimization strategies
- Asset management approach

## Important Patterns and Preferences
- Component-based architecture
- Event-driven systems
- Clean code practices
- Regular documentation updates
- LÖVE best practices

## Learnings and Project Insights
- LÖVE engine selected for development
- Vertical shooter mechanics defined
- Health system requirements established
- Ready for initial implementation

Note: This document will be updated frequently as the project progresses and new decisions are made. 