-- 8bitShooty
-- A vertical shooter game made with LÖVE

-- Asset variables
local playerImg, gunImg, zombieImg

-- Game state
local game = {
    state = "menu", -- menu, playing, gameover, shop
    score = 0,
    highScore = 0,
    wave = 1,
    monstersKilled = 0,
    monstersPerWave = 10,
    coins = 0,
    shopFeedback = {
        message = "",
        timer = 0,
        color = {1, 1, 1}
    },
    shopScroll = 0, -- Added shop scroll position
    itemsPerPage = 4 -- Number of items visible at once
}

-- Background properties
local stars = {}
local numStars = 100
local background = {
    color = {0.5, 0.8, 1}, -- Light blue sky
    starColor = {1, 1, 1},    -- Default white stars
    nebula = false,           -- Whether to show nebula effect
    nebulaColor = {0, 0, 0, 0}, -- RGBA for nebula
    buildings = {} -- Background buildings
}

-- Ground properties
local ground = {
    height = 100,
    buildings = {},
    grass = {},
    numBuildings = 5,
    numGrass = 50,
    color = {0.4, 0.6, 0.2}, -- Green
    grassColor = {0.2, 0.8, 0.2} -- Bright green
}

-- Player properties
local player = {
    x = 0,
    y = 0,
    width = 32,
    height = 32,
    speed = 200,
    health = 100,
    maxHealth = 100,
    armor = 0 -- Added armor attribute
}

-- Gun properties
local gun = {
    length = 20,
    width = 4,
    angle = 0,
    offsetX = 0,
    offsetY = 0,
    type = "default", -- Added gun type attribute
    spread = 0, -- Added spread attribute
    projectilesPerShot = 1, -- Added projectilesPerShot attribute
    cooldown = 0.1, -- Reduced base cooldown between shots for faster shooting
    lastShot = 0, -- Time of last shot
    damageMultiplier = 1, -- Base damage multiplier
    autoTarget = false, -- Auto-targeting enabled
    plasmaDamage = 1, -- Base plasma damage
    rocketDamage = 1, -- Base rocket damage
    rocketSplash = 0, -- Base splash radius
    reloadTime = 0.5, -- Added reload time
    ammo = 10, -- Added ammo count
    maxAmmo = 10, -- Added max ammo
    isReloading = false, -- Added reloading state
    reloadStartTime = 0 -- Added reload start time
}

-- Projectile properties
local projectiles = {}
local projectileSpeed = 400
local projectileSize = 4

-- Monster properties
local monsters = {}
local monsterSpawnTimer = 0
local monsterSpawnInterval = 2 -- seconds
local monsterSpeed = 100
local monsterSize = 30
local monsterHealth = 5 -- Increased base health

-- Monster types
local monsterTypes = {
    -- Basic monsters (1-10)
    {name = "Zombie", health = 5, speed = 100, size = 30, color = {0.2, 0.4, 0.2}, score = 100},
    {name = "Fast Zombie", health = 3, speed = 150, size = 25, color = {0.3, 0.5, 0.3}, score = 150},
    {name = "Tank Zombie", health = 10, speed = 70, size = 35, color = {0.4, 0.3, 0.2}, score = 200},
    {name = "Swarm Zombie", health = 2, speed = 120, size = 20, color = {0.2, 0.3, 0.4}, score = 75},
    {name = "Brute Zombie", health = 8, speed = 90, size = 40, color = {0.5, 0.2, 0.2}, score = 175},
    {name = "Crawler", health = 4, speed = 130, size = 25, color = {0.3, 0.2, 0.3}, score = 125},
    {name = "Runner", health = 3, speed = 160, size = 22, color = {0.4, 0.4, 0.2}, score = 150},
    {name = "Stalker", health = 6, speed = 110, size = 28, color = {0.2, 0.2, 0.4}, score = 175},
    {name = "Bruiser", health = 12, speed = 80, size = 38, color = {0.5, 0.3, 0.2}, score = 225},
    {name = "Scout", health = 2, speed = 180, size = 20, color = {0.3, 0.4, 0.3}, score = 100},
    
    -- Special monsters (11-20)
    {name = "Spitter", health = 4, speed = 90, size = 25, color = {0.4, 0.2, 0.4}, score = 200, special = "spit"},
    {name = "Exploder", health = 5, speed = 70, size = 30, color = {0.5, 0.2, 0.2}, score = 250, special = "explode"},
    {name = "Shield Zombie", health = 8, speed = 85, size = 32, color = {0.3, 0.3, 0.5}, score = 225, special = "shield"},
    {name = "Leaper", health = 6, speed = 100, size = 28, color = {0.4, 0.4, 0.3}, score = 200, special = "leap"},
    {name = "Screamer", health = 3, speed = 95, size = 26, color = {0.5, 0.3, 0.3}, score = 175, special = "scream"},
    {name = "Toxic Zombie", health = 7, speed = 80, size = 30, color = {0.2, 0.5, 0.2}, score = 225, special = "toxic"},
    {name = "Armored Zombie", health = 15, speed = 60, size = 35, color = {0.4, 0.4, 0.4}, score = 300, special = "armor"},
    {name = "Hunter", health = 5, speed = 140, size = 27, color = {0.3, 0.2, 0.2}, score = 250, special = "hunt"},
    {name = "Bomber", health = 4, speed = 75, size = 28, color = {0.5, 0.1, 0.1}, score = 275, special = "bomb"},
    {name = "Titan", health = 20, speed = 50, size = 45, color = {0.6, 0.3, 0.2}, score = 400, special = "titan"},
    
    -- Elite monsters (21-25)
    {name = "Necromancer", health = 12, speed = 85, size = 32, color = {0.4, 0.2, 0.5}, score = 500, special = "summon"},
    {name = "Behemoth", health = 25, speed = 60, size = 50, color = {0.5, 0.2, 0.3}, score = 600, special = "charge"},
    {name = "Plague Bearer", health = 15, speed = 75, size = 35, color = {0.2, 0.5, 0.3}, score = 550, special = "plague"},
    {name = "Shadow", health = 8, speed = 160, size = 28, color = {0.2, 0.2, 0.2}, score = 450, special = "teleport"},
    {name = "Abomination", health = 30, speed = 55, size = 55, color = {0.6, 0.2, 0.2}, score = 750, special = "rage"}
}

-- Shop items (moved after player definition)
game.shopItems = {
    {
        name = "Health Upgrade",
        cost = 100,
        maxLevel = 5,
        level = 0,
        effect = function()
            player.maxHealth = player.maxHealth + 20
            player.health = player.maxHealth
        end
    },
    {
        name = "Speed Upgrade",
        cost = 150,
        maxLevel = 3,
        level = 0,
        effect = function()
            player.speed = player.speed + 50
        end
    },
    {
        name = "Damage Upgrade",
        cost = 200,
        maxLevel = 3,
        level = 0,
        effect = function()
            projectileSize = projectileSize + 1
        end
    },
    {
        name = "Shotgun",
        cost = 300,
        maxLevel = 1,
        level = 0,
        effect = function()
            -- Change gun type to shotgun
            gun.type = "shotgun"
            gun.spread = 0.3 -- Spread angle in radians
            gun.projectilesPerShot = 5
        end
    },
    {
        name = "Laser Gun",
        cost = 400,
        maxLevel = 1,
        level = 0,
        effect = function()
            -- Change gun type to laser
            gun.type = "laser"
            projectileSpeed = 800 -- Faster projectiles
            projectileSize = 2 -- Thinner projectiles
        end
    },
    {
        name = "Heavy Armor",
        cost = 250,
        maxLevel = 1,
        level = 0,
        effect = function()
            -- Add armor that reduces damage
            player.armor = 0.5 -- Reduces damage by 50%
        end
    },
    {
        name = "Rapid Fire",
        cost = 350,
        maxLevel = 3,
        level = 0,
        effect = function()
            -- Increase fire rate by reducing cooldown
            if not gun.cooldown then gun.cooldown = 0.5 end
            gun.cooldown = gun.cooldown * 0.7 -- Reduce cooldown by 30% each level
        end
    },
    {
        name = "Double Damage",
        cost = 450,
        maxLevel = 2,
        level = 0,
        effect = function()
            -- Double the damage of projectiles
            if not gun.damageMultiplier then gun.damageMultiplier = 1 end
            gun.damageMultiplier = gun.damageMultiplier * 2
        end
    },
    {
        name = "Plasma Cannon",
        cost = 600,
        maxLevel = 1,
        level = 0,
        effect = function()
            -- Change gun type to plasma
            gun.type = "plasma"
            projectileSpeed = 600
            projectileSize = 6
            gun.projectilesPerShot = 1
            gun.plasmaDamage = 3 -- Each plasma shot does 3 damage
        end
    },
    {
        name = "Rocket Launcher",
        cost = 500,
        maxLevel = 1,
        level = 0,
        effect = function()
            -- Change gun type to rocket
            gun.type = "rocket"
            projectileSpeed = 300
            projectileSize = 8
            gun.projectilesPerShot = 1
            gun.rocketDamage = 5 -- Each rocket does 5 damage
            gun.rocketSplash = 100 -- Splash radius
        end
    },
    {
        name = "Shield Generator",
        cost = 400,
        maxLevel = 1,
        level = 0,
        effect = function()
            -- Add a shield that blocks one hit
            player.shield = true
            player.shieldHealth = 1
        end
    },
    {
        name = "Auto-Targeting",
        cost = 550,
        maxLevel = 1,
        level = 0,
        effect = function()
            -- Enable auto-targeting for projectiles
            gun.autoTarget = true
        end
    }
}

-- Animation states
local ANIMATION_STATES = {
    IDLE = "idle",
    ATTACK = "attack",
    DEATH = "death",
    SPECIAL = "special" -- New special attack state
}

function safeLoadImage(path)
    local ok, img = pcall(love.graphics.newImage, path)
    if ok then return img else return nil end
end

-- Initialize game
function love.load()
    -- Set up the game window
    love.window.setTitle("8bitShooty")
    love.window.setMode(800, 600)
    
    -- Load images (fallback to nil if not found)
    playerImg = safeLoadImage("assets/images/player.png")
    gunImg = safeLoadImage("assets/images/gun.png")
    zombieImg = safeLoadImage("assets/images/zombie.png")
    
    -- Initialize player position (centered at bottom)
    player.x = love.graphics.getWidth() / 2 - player.width / 2
    player.y = love.graphics.getHeight() - player.height - 20
    
    -- Set gun offset (center of player)
    gun.offsetX = player.width / 2
    gun.offsetY = player.height / 2
    
    -- Initialize stars
    for i = 1, numStars do
        stars[i] = {
            x = love.math.random(0, love.graphics.getWidth()),
            y = love.math.random(0, love.graphics.getHeight()),
            size = love.math.random(1, 3),
            speed = love.math.random(50, 150),
            twinkle = love.math.random() > 0.7, -- Some stars twinkle
            twinkleSpeed = love.math.random(1, 3),
            twinklePhase = love.math.random() * math.pi * 2
        }
    end
    
    -- Initialize ground elements
    initializeGround()
    
    -- Initialize background buildings
    initializeBackgroundBuildings()
    
    -- Set initial background
    updateBackground()
end

-- Initialize ground elements
function initializeGround()
    -- Clear existing elements
    ground.buildings = {}
    ground.grass = {}
    
    -- Create buildings
    local buildingSpacing = love.graphics.getWidth() / (ground.numBuildings + 1)
    for i = 1, ground.numBuildings do
        local building = {
            x = buildingSpacing * i,
            width = love.math.random(40, 60),
            height = love.math.random(100, 150),
            windows = {},
            damage = 0
        }
        
        -- Add windows
        local numWindows = love.math.random(3, 5)
        local windowSpacing = building.width / (numWindows + 1)
        for j = 1, numWindows do
            table.insert(building.windows, {
                x = windowSpacing * j,
                y = love.math.random(20, building.height - 20),
                lit = love.math.random() > 0.5
            })
        end
        
        table.insert(ground.buildings, building)
    end
    
    -- Create grass
    for i = 1, ground.numGrass do
        table.insert(ground.grass, {
            x = love.math.random(0, love.graphics.getWidth()),
            height = love.math.random(5, 15),
            width = love.math.random(2, 4)
        })
    end
end

-- Initialize background buildings
function initializeBackgroundBuildings()
    background.buildings = {}
    local numBuildings = 8
    
    for i = 1, numBuildings do
        local building = {
            x = love.math.random(0, love.graphics.getWidth()),
            y = love.graphics.getHeight() - ground.height - love.math.random(150, 250), -- Position buildings to touch grass
            width = love.math.random(60, 100),
            height = love.math.random(150, 250),
            damage = love.math.random(0, 100) / 100,
            windows = {}
        }
        
        -- Add windows
        local numWindows = love.math.random(4, 8)
        local windowSpacing = building.width / (numWindows + 1)
        for j = 1, numWindows do
            table.insert(building.windows, {
                x = windowSpacing * j,
                y = love.math.random(20, building.height - 20),
                lit = love.math.random() > 0.7
            })
        end
        
        table.insert(background.buildings, building)
    end
end

-- Update background based on wave
function updateBackground()
    -- Change sky color based on wave
    local waveType = game.wave % 4
    if waveType == 0 then
        -- Day time
        background.color = {0.5, 0.8, 1} -- Light blue
        background.starColor = {1, 1, 1} -- White stars
        background.nebula = false
    elseif waveType == 1 then
        -- Sunset
        background.color = {0.8, 0.4, 0.2} -- Orange
        background.starColor = {1, 0.8, 0.6} -- Warm stars
        background.nebula = true
        background.nebulaColor = {0.8, 0.4, 0.2, 0.2} -- Orange nebula
    elseif waveType == 2 then
        -- Night
        background.color = {0.1, 0.1, 0.2} -- Dark blue
        background.starColor = {1, 1, 0.8} -- Bright stars
        background.nebula = true
        background.nebulaColor = {0.2, 0.1, 0.3, 0.3} -- Purple nebula
    else
        -- Dawn
        background.color = {0.3, 0.5, 0.8} -- Blue-gray
        background.starColor = {0.8, 0.8, 1} -- Cool stars
        background.nebula = true
        background.nebulaColor = {0.3, 0.5, 0.8, 0.2} -- Blue nebula
    end
    
    -- Reinitialize background buildings for new wave
    initializeBackgroundBuildings()
end

-- Update ground based on wave
function updateGround()
    local waveType = game.wave % 4
    
    -- Change ground color based on wave
    if waveType == 0 then
        -- Normal grass
        ground.color = {0.4, 0.6, 0.2} -- Green
        ground.grassColor = {0.2, 0.8, 0.2} -- Bright green
    elseif waveType == 1 then
        -- Autumn
        ground.color = {0.6, 0.4, 0.2} -- Brown
        ground.grassColor = {0.8, 0.6, 0.2} -- Yellow
    elseif waveType == 2 then
        -- Night
        ground.color = {0.2, 0.3, 0.1} -- Dark green
        ground.grassColor = {0.3, 0.5, 0.2} -- Dark grass
    else
        -- Dawn
        ground.color = {0.3, 0.5, 0.2} -- Blue-green
        ground.grassColor = {0.4, 0.7, 0.3} -- Cool grass
    end
    
    -- Reinitialize ground elements for new wave
    initializeGround()
end

-- Create a new projectile
function createProjectile()
    -- Check if reloading
    if gun.isReloading then
        return
    end
    
    -- Check if out of ammo
    if gun.ammo <= 0 then
        -- Start reloading
        gun.isReloading = true
        gun.reloadStartTime = love.timer.getTime()
        return
    end
    
    -- Check cooldown
    if love.timer.getTime() - gun.lastShot < gun.cooldown then
        return
    end
    
    -- Decrease ammo
    gun.ammo = gun.ammo - 1
    gun.lastShot = love.timer.getTime()

    if gun.type == "shotgun" then
        -- Create multiple projectiles with spread
        for i = 1, gun.projectilesPerShot do
            local spread = (i - (gun.projectilesPerShot + 1) / 2) * gun.spread
            local projectile = {
                x = player.x + gun.offsetX,
                y = player.y + gun.offsetY,
                size = projectileSize,
                speed = projectileSpeed,
                angle = gun.angle + spread,
                damage = 1 * gun.damageMultiplier,
                type = "default"
            }
            table.insert(projectiles, projectile)
        end
    elseif gun.type == "plasma" then
        local projectile = {
            x = player.x + gun.offsetX,
            y = player.y + gun.offsetY,
            size = projectileSize,
            speed = projectileSpeed,
            angle = gun.angle,
            damage = gun.plasmaDamage * gun.damageMultiplier,
            type = "plasma"
        }
        table.insert(projectiles, projectile)
    elseif gun.type == "rocket" then
        local projectile = {
            x = player.x + gun.offsetX,
            y = player.y + gun.offsetY,
            size = projectileSize,
            speed = projectileSpeed,
            angle = gun.angle,
            damage = gun.rocketDamage * gun.damageMultiplier,
            type = "rocket",
            splash = gun.rocketSplash
        }
        table.insert(projectiles, projectile)
    else
        -- Create single projectile
        local projectile = {
            x = player.x + gun.offsetX,
            y = player.y + gun.offsetY,
            size = projectileSize,
            speed = projectileSpeed,
            angle = gun.angle,
            damage = 1 * gun.damageMultiplier,
            type = "default"
        }
        table.insert(projectiles, projectile)
    end
end

-- Create a new monster
function createMonster()
    -- Randomly select monster type
    local monsterType = monsterTypes[love.math.random(1, #monsterTypes)]
    
    -- Scale monster stats based on wave
    local waveMultiplier = 1 + (game.wave - 1) * 0.2 -- 20% increase per wave
    
    local monster = {
        x = love.math.random(monsterType.size, love.graphics.getWidth() - monsterType.size),
        y = -monsterType.size,
        size = monsterType.size,
        speed = monsterType.speed * waveMultiplier,
        health = monsterType.health * waveMultiplier,
        maxHealth = monsterType.health * waveMultiplier,
        angle = 0,
        type = monsterType,
        special = monsterType.special,
        score = monsterType.score,
        -- Animation properties
        state = ANIMATION_STATES.IDLE,
        animationTimer = 0,
        frame = 1,
        attackCooldown = 0,
        deathTimer = 0,
        shakeOffset = {x = 0, y = 0},
        particles = {}, -- For blood and death effects
        hitParticles = {}, -- Separate array for hit effects
        specialAttackTimer = 0,
        specialAttackCooldown = 3,
        specialAttackParticles = {}
    }
    
    -- Add special abilities with enhanced properties
    if monster.special == "spit" then
        monster.spitCooldown = 0
        monster.spitRange = 200
        monster.spitParticles = {}
    elseif monster.special == "explode" then
        monster.explodeRadius = 100
        monster.explodeParticles = {}
    elseif monster.special == "shield" then
        monster.shieldHealth = 5
        monster.shieldParticles = {}
    elseif monster.special == "leap" then
        monster.leapCooldown = 0
        monster.leapRange = 150
        monster.leapParticles = {}
    elseif monster.special == "scream" then
        monster.screamCooldown = 0
        monster.screamRange = 200
        monster.screamParticles = {}
    elseif monster.special == "toxic" then
        monster.toxicRadius = 50
        monster.toxicParticles = {}
    elseif monster.special == "armor" then
        monster.armor = 0.5
        monster.armorParticles = {}
    elseif monster.special == "hunt" then
        monster.huntRange = 300
        monster.huntParticles = {}
    elseif monster.special == "bomb" then
        monster.bombTimer = 5
        monster.bombParticles = {}
    elseif monster.special == "titan" then
        monster.chargeCooldown = 0
        monster.chargeRange = 200
        monster.chargeParticles = {}
    elseif monster.special == "summon" then
        monster.summonCooldown = 0
        monster.summonParticles = {}
    elseif monster.special == "charge" then
        monster.chargeCooldown = 0
        monster.chargeSpeed = 200
        monster.chargeParticles = {}
    elseif monster.special == "plague" then
        monster.plagueRadius = 100
        monster.plagueParticles = {}
    elseif monster.special == "teleport" then
        monster.teleportCooldown = 0
        monster.teleportRange = 200
        monster.teleportParticles = {}
    elseif monster.special == "rage" then
        monster.rageThreshold = monster.health * 0.3
        monster.rageActive = false
        monster.rageParticles = {}
    end
    
    table.insert(monsters, monster)
end

-- Create special attack particles
function createSpecialAttackParticles(monster, particleType)
    local particles = {}
    local numParticles = 8
    
    if particleType == "spit" then
        -- Spit particles
        for i = 1, numParticles do
            table.insert(particles, {
                x = 0,
                y = 0,
                vx = math.cos(monster.angle) * 200,
                vy = math.sin(monster.angle) * 200,
                size = 4,
                color = {0.4, 0.2, 0.4},
                life = 1,
                rotation = 0,
                rotationSpeed = 5
            })
        end
    elseif particleType == "explode" then
        -- Explosion particles
        for i = 1, numParticles do
            local angle = (i / numParticles) * math.pi * 2
            table.insert(particles, {
                x = 0,
                y = 0,
                vx = math.cos(angle) * 150,
                vy = math.sin(angle) * 150,
                size = 6,
                color = {1, 0.5, 0},
                life = 1,
                rotation = 0,
                rotationSpeed = 10
            })
        end
    elseif particleType == "toxic" then
        -- Toxic cloud particles
        for i = 1, numParticles do
            local angle = (i / numParticles) * math.pi * 2
            table.insert(particles, {
                x = 0,
                y = 0,
                vx = math.cos(angle) * 50,
                vy = math.sin(angle) * 50,
                size = 5,
                color = {0.2, 0.5, 0.2},
                life = 2,
                rotation = 0,
                rotationSpeed = 2
            })
        end
    end
    
    return particles
end

-- Create blood particles
function createBloodParticles(x, y, color)
    local particles = {}
    local numParticles = 12 -- Increased number of blood particles
    
    for i = 1, numParticles do
        local angle = (i / numParticles) * math.pi * 2
        local speed = love.math.random(100, 200) -- Increased speed
        table.insert(particles, {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            size = love.math.random(3, 6), -- Increased size
            color = color or {0.8, 0.1, 0.1},
            life = 0.8, -- Increased lifetime
            rotation = love.math.random() * math.pi * 2,
            rotationSpeed = love.math.random(-10, 10),
            gravity = 500, -- Added gravity effect
            alpha = 1 -- Added alpha for fade effect
        })
    end
    
    return particles
end

-- Create death particles
function createDeathParticles(monster)
    local numParticles = 30 -- Increased number of particles
    for i = 1, numParticles do
        local angle = (i / numParticles) * math.pi * 2
        local speed = love.math.random(150, 300) -- Increased speed range
        table.insert(monster.particles, {
            x = 0,
            y = 0,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            size = love.math.random(4, 8), -- Increased size
            color = monster.type.color,
            life = 1.5, -- Increased lifetime
            rotation = love.math.random() * math.pi * 2,
            rotationSpeed = love.math.random(-15, 15),
            gravity = 300 -- Added gravity effect
        })
    end
    
    -- Add blood particles to death effect
    local bloodParticles = createBloodParticles(0, 0, {0.8, 0.1, 0.1})
    for _, p in ipairs(bloodParticles) do
        table.insert(monster.particles, p)
    end
    
    -- Add explosion flash
    for i = 1, 5 do
        table.insert(monster.particles, {
            x = 0,
            y = 0,
            vx = 0,
            vy = 0,
            size = monster.size * (1 + i * 0.5),
            color = {1, 0.8, 0.2},
            life = 0.3,
            rotation = 0,
            rotationSpeed = 0,
            isFlash = true
        })
    end
end

-- Check collision between two circles
function checkCollision(x1, y1, r1, x2, y2, r2)
    local dx = x2 - x1
    local dy = y2 - y1
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < r1 + r2
end

-- Update game state
function love.update(dt)
    if game.state == "playing" then
        -- Check if wave is complete
        if game.monstersKilled >= game.monstersPerWave then
            -- Calculate coin reward based on wave number
            local coinReward = 50 + (game.wave * 25) -- Base 50 coins + 25 per wave
            game.coins = game.coins + coinReward
            
            -- Show coin reward message
            game.waveFeedback = {
                message = "+" .. coinReward .. " coins!",
                timer = 2,
                color = {1, 0.8, 0} -- Gold color
            }
            
            game.wave = game.wave + 1
            game.monstersKilled = 0
            game.monstersPerWave = game.monstersPerWave + 5 -- Increase monsters per wave
            updateBackground() -- Update scenery for new wave
            updateGround() -- Update ground for new wave
        end
        
        -- Update wave feedback timer
        if game.waveFeedback and game.waveFeedback.timer > 0 then
            game.waveFeedback.timer = game.waveFeedback.timer - dt
        end
        
        -- Check reload status
        if gun.isReloading then
            if love.timer.getTime() - gun.reloadStartTime >= gun.reloadTime then
                gun.ammo = gun.maxAmmo
                gun.isReloading = false
            end
        end
        
        -- Update stars
        for _, star in ipairs(stars) do
            star.y = star.y + star.speed * dt
            if star.y > love.graphics.getHeight() then
                star.y = 0
                star.x = love.math.random(0, love.graphics.getWidth())
            end
            
            -- Update twinkling stars
            if star.twinkle then
                star.twinklePhase = star.twinklePhase + dt * star.twinkleSpeed
            end
        end
        
        -- Handle player movement
        if love.keyboard.isDown("left", "a") then
            player.x = math.max(0, player.x - player.speed * dt)
        end
        if love.keyboard.isDown("right", "d") then
            player.x = math.min(love.graphics.getWidth() - player.width, player.x + player.speed * dt)
        end
        
        -- Update gun angle based on mouse position
        local mouseX, mouseY = love.mouse.getPosition()
        local playerCenterX = player.x + gun.offsetX
        local playerCenterY = player.y + gun.offsetY
        
        -- Calculate angle between player and mouse
        gun.angle = math.atan2(mouseY - playerCenterY, mouseX - playerCenterX)
        
        -- Spawn monsters if wave not complete
        if game.monstersKilled < game.monstersPerWave then
            monsterSpawnTimer = monsterSpawnTimer + dt
            if monsterSpawnTimer >= monsterSpawnInterval then
                createMonster()
                monsterSpawnTimer = 0
            end
        end
        
        -- Update projectiles
        for i = #projectiles, 1, -1 do
            local p = projectiles[i]
            
            -- Move projectile
            p.x = p.x + math.cos(p.angle) * p.speed * dt
            p.y = p.y + math.sin(p.angle) * p.speed * dt
            
            -- Check collision with monsters
            for j = #monsters, 1, -1 do
                local m = monsters[j]
                if checkCollision(p.x, p.y, p.size, m.x, m.y, m.size) then
                    -- Calculate impact point relative to monster
                    local impactX = p.x - m.x
                    local impactY = p.y - m.y
                    
                    -- Create blood effect at impact point
                    local bloodParticles = createBloodParticles(impactX, impactY, {0.8, 0.1, 0.1})
                    for _, bp in ipairs(bloodParticles) do
                        -- Adjust particle velocity based on projectile angle
                        local angle = p.angle + love.math.random(-0.5, 0.5)
                        local speed = love.math.random(100, 200)
                        bp.vx = math.cos(angle) * speed
                        bp.vy = math.sin(angle) * speed
                        table.insert(m.hitParticles, bp)
                    end
                    
                    -- Remove projectile
                    table.remove(projectiles, i)
                    
                    -- Apply damage based on projectile type
                    if p.type == "rocket" then
                        -- Apply splash damage to nearby monsters
                        for k = #monsters, 1, -1 do
                            local splashMonster = monsters[k]
                            local dx = splashMonster.x - p.x
                            local dy = splashMonster.y - p.y
                            local dist = math.sqrt(dx * dx + dy * dy)
                            if dist <= p.splash then
                                -- Create blood effect for splash damage
                                local splashBlood = createBloodParticles(dx, dy, {0.8, 0.1, 0.1})
                                for _, sbp in ipairs(splashBlood) do
                                    -- Adjust particle velocity based on distance from explosion
                                    local angle = math.atan2(dy, dx) + love.math.random(-0.5, 0.5)
                                    local speed = love.math.random(100, 200)
                                    sbp.vx = math.cos(angle) * speed
                                    sbp.vy = math.sin(angle) * speed
                                    table.insert(splashMonster.hitParticles, sbp)
                                end
                                
                                splashMonster.health = splashMonster.health - p.damage
                                if splashMonster.health <= 0 then
                                    table.remove(monsters, k)
                                    game.score = game.score + 100
                                    game.monstersKilled = game.monstersKilled + 1
                                end
                            end
                        end
                    else
                        -- Normal damage
                        m.health = m.health - p.damage
                        if m.health <= 0 then
                            table.remove(monsters, j)
                            game.score = game.score + 100
                            game.monstersKilled = game.monstersKilled + 1
                        end
                    end
                    break
                end
            end
            
            -- Remove projectiles that are off screen
            if p.x < 0 or p.x > love.graphics.getWidth() or
               p.y < 0 or p.y > love.graphics.getHeight() then
                table.remove(projectiles, i)
            end
        end
        
        -- Update monsters
        for i = #monsters, 1, -1 do
            local m = monsters[i]
            
            -- Update particles
            for j = #m.particles, 1, -1 do
                local p = m.particles[j]
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
                
                -- Apply gravity to particles
                if p.gravity then
                    p.vy = p.vy + p.gravity * dt
                end
                
                p.life = p.life - dt
                p.rotation = p.rotation + p.rotationSpeed * dt
                
                -- Remove dead particles
                if p.life <= 0 then
                    table.remove(m.particles, j)
                end
            end
            
            -- Update hit particles
            for j = #m.hitParticles, 1, -1 do
                local p = m.hitParticles[j]
                p.x = p.x + p.vx * dt
                p.y = p.y + p.vy * dt
                
                -- Apply gravity to hit particles
                if p.gravity then
                    p.vy = p.vy + p.gravity * dt
                end
                
                p.life = p.life - dt
                p.rotation = p.rotation + p.rotationSpeed * dt
                
                -- Remove dead hit particles
                if p.life <= 0 then
                    table.remove(m.hitParticles, j)
                end
            end
            
            -- Update animation timers
            m.animationTimer = m.animationTimer + dt
            if m.animationTimer >= 0.1 then -- 10 FPS animation
                m.animationTimer = 0
                m.frame = m.frame + 1
                if m.frame > 4 then m.frame = 1 end
            end
            
            -- Update attack cooldown
            if m.attackCooldown > 0 then
                m.attackCooldown = m.attackCooldown - dt
            end
            
            -- Update special attack cooldown
            if m.specialAttackCooldown > 0 then
                m.specialAttackCooldown = m.specialAttackCooldown - dt
            end
            
            -- Update special attack particles
            if m.state == ANIMATION_STATES.SPECIAL then
                m.specialAttackTimer = m.specialAttackTimer + dt
                
                -- Update particles based on monster type
                if m.special == "spit" then
                    for _, p in ipairs(m.spitParticles) do
                        p.x = p.x + p.vx * dt
                        p.y = p.y + p.vy * dt
                        p.life = p.life - dt
                        p.rotation = p.rotation + p.rotationSpeed * dt
                    end
                elseif m.special == "explode" then
                    for _, p in ipairs(m.explodeParticles) do
                        p.x = p.x + p.vx * dt
                        p.y = p.y + p.vy * dt
                        p.life = p.life - dt
                        p.rotation = p.rotation + p.rotationSpeed * dt
                    end
                elseif m.special == "toxic" then
                    for _, p in ipairs(m.toxicParticles) do
                        p.x = p.x + p.vx * dt
                        p.y = p.y + p.vy * dt
                        p.life = p.life - dt
                        p.rotation = p.rotation + p.rotationSpeed * dt
                    end
                end
                
                -- End special attack after duration
                if m.specialAttackTimer >= 1 then
                    m.state = ANIMATION_STATES.IDLE
                    m.specialAttackTimer = 0
                end
            end
            
            -- Update death animation
            if m.state == ANIMATION_STATES.DEATH then
                m.deathTimer = m.deathTimer + dt
                -- Update particles
                for j = #m.particles, 1, -1 do
                    local p = m.particles[j]
                    p.x = p.x + p.vx * dt
                    p.y = p.y + p.vy * dt
                    
                    -- Apply gravity to particles
                    if p.gravity then
                        p.vy = p.vy + p.gravity * dt
                    end
                    
                    p.life = p.life - dt
                    p.rotation = p.rotation + p.rotationSpeed * dt
                    
                    -- Remove dead particles
                    if p.life <= 0 then
                        table.remove(m.particles, j)
                    end
                end
                -- Remove monster after death animation
                if m.deathTimer >= 1 then
                    table.remove(monsters, i)
                    break
                end
            end
            
            -- Update shake effect
            if m.state == ANIMATION_STATES.ATTACK then
                m.shakeOffset.x = love.math.random(-2, 2)
                m.shakeOffset.y = love.math.random(-2, 2)
            else
                m.shakeOffset.x = 0
                m.shakeOffset.y = 0
            end
            
            -- Update special abilities
            if m.special == "spit" then
                m.spitCooldown = math.max(0, m.spitCooldown - dt)
            elseif m.special == "leap" then
                m.leapCooldown = math.max(0, m.leapCooldown - dt)
            elseif m.special == "scream" then
                m.screamCooldown = math.max(0, m.screamCooldown - dt)
            elseif m.special == "bomb" then
                m.bombTimer = m.bombTimer - dt
                if m.bombTimer <= 0 then
                    -- Explode
                    for j = #monsters, 1, -1 do
                        local otherMonster = monsters[j]
                        if j ~= i then
                            local dx = otherMonster.x - m.x
                            local dy = otherMonster.y - m.y
                            local dist = math.sqrt(dx * dx + dy * dy)
                            if dist <= 100 then
                                otherMonster.health = otherMonster.health - 10
                            end
                        end
                    end
                    table.remove(monsters, i)
                    break
                end
            elseif m.special == "titan" then
                m.chargeCooldown = math.max(0, m.chargeCooldown - dt)
            elseif m.special == "summon" then
                m.summonCooldown = math.max(0, m.summonCooldown - dt)
            elseif m.special == "charge" then
                m.chargeCooldown = math.max(0, m.chargeCooldown - dt)
            elseif m.special == "teleport" then
                m.teleportCooldown = math.max(0, m.teleportCooldown - dt)
            end
            
            -- Calculate angle to player
            local playerCenterX = player.x + player.width/2
            local playerCenterY = player.y + player.height/2
            m.angle = math.atan2(playerCenterY - m.y, playerCenterX - m.x)
            
            -- Move monster towards player
            m.x = m.x + math.cos(m.angle) * m.speed * dt
            m.y = m.y + math.sin(m.angle) * m.speed * dt
            
            -- Check collision with player
            if checkCollision(player.x + player.width/2, player.y + player.height/2, player.width/2,
                            m.x, m.y, m.size) then
                if m.attackCooldown <= 0 then
                    -- Start attack animation
                    m.state = ANIMATION_STATES.ATTACK
                    m.attackCooldown = 0.5
                    
                    -- Apply damage reduction if armor is equipped
                    local damage = 20
                    if player.armor then
                        damage = damage * (1 - player.armor)
                    end
                    if m.special == "armor" then
                        damage = damage * 1.5 -- Armored zombies do more damage
                    end
                    player.health = player.health - damage
                    
                    if player.health <= 0 then
                        game.state = "gameover"
                    end
                end
            end
            
            -- Check if monster should die
            if m.health <= 0 and m.state ~= ANIMATION_STATES.DEATH then
                m.state = ANIMATION_STATES.DEATH
                createDeathParticles(m)
                game.score = game.score + m.score
                game.monstersKilled = game.monstersKilled + 1
            end
            
            -- Remove monsters that are off screen
            if m.x < -m.size or m.x > love.graphics.getWidth() + m.size or
               m.y < -m.size or m.y > love.graphics.getHeight() + m.size then
                table.remove(monsters, i)
            end
        end
    elseif game.state == "shop" then
        -- Update shop feedback timer
        if game.shopFeedback.timer > 0 then
            game.shopFeedback.timer = game.shopFeedback.timer - dt
        end
    end
end

-- Draw game
function love.draw()
    if game.state == "menu" then
        -- Draw menu
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("8bitShooty", 0, love.graphics.getHeight()/2 - 50, love.graphics.getWidth(), "center")
        love.graphics.printf("Press SPACE to start", 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
    elseif game.state == "playing" then
        -- Draw background (sky)
        love.graphics.setColor(background.color)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        -- Draw nebula if active
        if background.nebula then
            love.graphics.setColor(background.nebulaColor)
            for i = 1, 5 do
                local x = love.math.random(0, love.graphics.getWidth())
                local y = love.math.random(0, love.graphics.getHeight())
                local size = love.math.random(100, 300)
                love.graphics.circle("fill", x, y, size)
            end
        end
        
        -- Draw stars
        for _, star in ipairs(stars) do
            if star.twinkle then
                local brightness = 0.5 + 0.5 * math.sin(star.twinklePhase)
                love.graphics.setColor(background.starColor[1] * brightness,
                                    background.starColor[2] * brightness,
                                    background.starColor[3] * brightness)
            else
                love.graphics.setColor(background.starColor)
            end
            love.graphics.circle("fill", star.x, star.y, star.size)
        end
        
        -- Draw background buildings
        for _, building in ipairs(background.buildings) do
            -- Draw building shadow
            love.graphics.setColor(0, 0, 0, 0.2)
            love.graphics.rectangle("fill", building.x + 5, building.y + 5,
                                  building.width, building.height)
            
            -- Draw building
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", building.x, building.y,
                                  building.width, building.height)
            
            -- Draw windows
            for _, window in ipairs(building.windows) do
                if window.lit then
                    love.graphics.setColor(1, 0.8, 0.3, 0.3)
                else
                    love.graphics.setColor(0.1, 0.1, 0.1, 0.3)
                end
                love.graphics.rectangle("fill", 
                    building.x + window.x - 3,
                    building.y + building.height - window.y,
                    6, 8)
            end
            
            -- Draw damage
            if building.damage > 0 then
                love.graphics.setColor(0.5, 0.2, 0.2, building.damage * 0.3)
                love.graphics.rectangle("fill", building.x, building.y,
                                      building.width, building.height)
            end
        end
        
        -- Draw buildings
        for _, building in ipairs(ground.buildings) do
            -- Draw building shadow
            love.graphics.setColor(0, 0, 0, 0.3)
            love.graphics.rectangle("fill", building.x - building.width/2 + 5, 
                                  love.graphics.getHeight() - ground.height + building.height + 5,
                                  building.width, 10)
            
            -- Draw building
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", building.x - building.width/2,
                                  love.graphics.getHeight() - ground.height + building.height,
                                  building.width, -building.height)
            
            -- Draw windows
            for _, window in ipairs(building.windows) do
                if window.lit then
                    love.graphics.setColor(1, 0.8, 0.3)
                else
                    love.graphics.setColor(0.1, 0.1, 0.1)
                end
                love.graphics.rectangle("fill", 
                    building.x - building.width/2 + window.x - 3,
                    love.graphics.getHeight() - ground.height + building.height - window.y,
                    6, 8)
            end
            
            -- Draw damage
            if building.damage > 0 then
                love.graphics.setColor(0.5, 0.2, 0.2, building.damage)
                love.graphics.rectangle("fill", building.x - building.width/2,
                                      love.graphics.getHeight() - ground.height + building.height,
                                      building.width, -building.height)
            end
        end
        
        -- Draw grass
        love.graphics.setColor(ground.grassColor or {0.2, 0.8, 0.2}) -- Use grass color or default
        for _, blade in ipairs(ground.grass) do
            love.graphics.rectangle("fill", blade.x, 
                                  love.graphics.getHeight() - ground.height,
                                  blade.width, -blade.height)
        end
        
        -- Draw ground
        love.graphics.setColor(ground.color or {0.4, 0.6, 0.2}) -- Use ground color or default
        love.graphics.rectangle("fill", 0, love.graphics.getHeight() - ground.height,
                              love.graphics.getWidth(), ground.height)
        
        -- Draw monsters
        for _, m in ipairs(monsters) do
            -- Draw particles first (so they appear behind the monster)
            for _, p in ipairs(m.particles) do
                love.graphics.push()
                love.graphics.translate(m.x + p.x, m.y + p.y)
                love.graphics.rotate(p.rotation)
                
                if p.isFlash then
                    -- Draw explosion flash
                    love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
                    love.graphics.circle("fill", 0, 0, p.size)
                else
                    -- Draw blood/death particle
                    love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
                    love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
                    -- Add highlight
                    love.graphics.setColor(1, 1, 1, p.life * 0.3)
                    love.graphics.rectangle("fill", -p.size/4, -p.size/4, p.size/2, p.size/2)
                end
                
                love.graphics.pop()
            end
            
            -- Draw hit particles
            for _, p in ipairs(m.hitParticles) do
                love.graphics.push()
                love.graphics.translate(m.x + p.x, m.y + p.y)
                love.graphics.rotate(p.rotation)
                
                -- Draw blood particle
                love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
                love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
                -- Add highlight
                love.graphics.setColor(1, 1, 1, p.life * 0.3)
                love.graphics.rectangle("fill", -p.size/4, -p.size/4, p.size/2, p.size/2)
                
                love.graphics.pop()
            end
            
            if zombieImg then
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(zombieImg, m.x, m.y, 0, m.size/zombieImg:getWidth()*2, m.size/zombieImg:getHeight()*2, zombieImg:getWidth()/2, zombieImg:getHeight()/2)
            else
                -- 8-bit style monster
                love.graphics.push()
                love.graphics.translate(m.x + m.shakeOffset.x, m.y + m.shakeOffset.y)
                
                if m.state == ANIMATION_STATES.DEATH then
                    -- Draw death particles
                    for _, p in ipairs(m.particles) do
                        love.graphics.push()
                        love.graphics.translate(p.x, p.y)
                        love.graphics.rotate(p.rotation)
                        
                        -- Draw pixelated death particle
                        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
                        love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
                        love.graphics.setColor(1, 1, 1, p.life * 0.5)
                        love.graphics.rectangle("fill", -p.size/4, -p.size/4, p.size/2, p.size/2)
                        
                        love.graphics.pop()
                    end
                elseif m.state == ANIMATION_STATES.SPECIAL then
                    -- Draw special attack particles
                    if m.special == "spit" then
                        for _, p in ipairs(m.spitParticles) do
                            love.graphics.push()
                            love.graphics.translate(p.x, p.y)
                            love.graphics.rotate(p.rotation)
                            
                            -- Draw spit projectile
                            love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
                            love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
                            love.graphics.setColor(1, 1, 1, p.life * 0.3)
                            love.graphics.rectangle("fill", -p.size/4, -p.size/4, p.size/2, p.size/2)
                            
                            love.graphics.pop()
                        end
                    elseif m.special == "explode" then
                        for _, p in ipairs(m.explodeParticles) do
                            love.graphics.push()
                            love.graphics.translate(p.x, p.y)
                            love.graphics.rotate(p.rotation)
                            
                            -- Draw explosion particle
                            love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
                            love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
                            love.graphics.setColor(1, 0.8, 0, p.life * 0.5)
                            love.graphics.rectangle("fill", -p.size/4, -p.size/4, p.size/2, p.size/2)
                            
                            love.graphics.pop()
                        end
                    elseif m.special == "toxic" then
                        for _, p in ipairs(m.toxicParticles) do
                            love.graphics.push()
                            love.graphics.translate(p.x, p.y)
                            love.graphics.rotate(p.rotation)
                            
                            -- Draw toxic cloud particle
                            love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life * 0.5)
                            love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
                            love.graphics.setColor(0.3, 0.8, 0.3, p.life * 0.3)
                            love.graphics.rectangle("fill", -p.size/4, -p.size/4, p.size/2, p.size/2)
                            
                            love.graphics.pop()
                        end
                    end
                else
                    -- Draw monster sprite based on type
                    if m.type.name == "Zombie" then
                        -- Basic zombie with enhanced 8-bit style
                        -- Body
                        love.graphics.setColor(0.2, 0.4, 0.2)
                        love.graphics.rectangle("fill", -6, -8, 12, 16)
                        -- Shirt details
                        love.graphics.setColor(0.1, 0.3, 0.1)
                        love.graphics.rectangle("fill", -4, -4, 8, 8)
                        -- Head
                        love.graphics.setColor(0.3, 0.6, 0.3)
                        love.graphics.rectangle("fill", -4, -12, 8, 6)
                        -- Face details
                        love.graphics.setColor(0.2, 0.5, 0.2)
                        love.graphics.rectangle("fill", -3, -10, 6, 3)
                        -- Eyes
                        love.graphics.setColor(0.8, 0.2, 0.2)
                        love.graphics.rectangle("fill", -3, -10, 2, 2)
                        love.graphics.rectangle("fill", 1, -10, 2, 2)
                        -- Mouth
                        love.graphics.setColor(0.2, 0.3, 0.2)
                        love.graphics.rectangle("fill", -2, -8, 4, 1)
                        -- Arms
                        love.graphics.setColor(0.2, 0.3, 0.2)
                        love.graphics.rectangle("fill", -8, -4, 3, 6)
                        love.graphics.rectangle("fill", 5, -4, 3, 6)
                        -- Legs
                        love.graphics.setColor(0.15, 0.25, 0.15)
                        love.graphics.rectangle("fill", -4, 8, 3, 6)
                        love.graphics.rectangle("fill", 1, 8, 3, 6)
                        
                    elseif m.type.name == "Fast Zombie" then
                        -- Fast zombie with enhanced 8-bit style
                        -- Body
                        love.graphics.setColor(0.3, 0.5, 0.3)
                        love.graphics.rectangle("fill", -6, -8, 12, 16)
                        -- Shirt details
                        love.graphics.setColor(0.2, 0.4, 0.2)
                        love.graphics.rectangle("fill", -4, -4, 8, 8)
                        -- Head
                        love.graphics.setColor(0.4, 0.6, 0.4)
                        love.graphics.rectangle("fill", -4, -12, 8, 6)
                        -- Face details
                        love.graphics.setColor(0.3, 0.5, 0.3)
                        love.graphics.rectangle("fill", -3, -10, 6, 3)
                        -- Eyes
                        love.graphics.setColor(0.8, 0.2, 0.2)
                        love.graphics.rectangle("fill", -3, -10, 2, 2)
                        love.graphics.rectangle("fill", 1, -10, 2, 2)
                        -- Mouth
                        love.graphics.setColor(0.2, 0.3, 0.2)
                        love.graphics.rectangle("fill", -2, -8, 4, 1)
                        -- Running legs
                        love.graphics.setColor(0.2, 0.3, 0.2)
                        local legOffset = math.sin(m.animationTimer * 15) * 3
                        love.graphics.rectangle("fill", -4, 8, 3, 6 + legOffset)
                        love.graphics.rectangle("fill", 1, 8, 3, 6 - legOffset)
                        -- Arms
                        love.graphics.setColor(0.25, 0.35, 0.25)
                        love.graphics.rectangle("fill", -8, -4, 3, 6)
                        love.graphics.rectangle("fill", 5, -4, 3, 6)
                        
                    elseif m.type.name == "Tank Zombie" then
                        -- Tank zombie with enhanced 8-bit style
                        -- Body
                        love.graphics.setColor(0.4, 0.3, 0.2)
                        love.graphics.rectangle("fill", -8, -10, 16, 20)
                        -- Armor plates
                        love.graphics.setColor(0.6, 0.6, 0.6)
                        love.graphics.rectangle("fill", -6, -8, 12, 4)
                        love.graphics.rectangle("fill", -6, 0, 12, 4)
                        -- Head
                        love.graphics.setColor(0.5, 0.4, 0.3)
                        love.graphics.rectangle("fill", -6, -14, 12, 8)
                        -- Face details
                        love.graphics.setColor(0.4, 0.3, 0.2)
                        love.graphics.rectangle("fill", -4, -12, 8, 4)
                        -- Eyes
                        love.graphics.setColor(0.8, 0.2, 0.2)
                        love.graphics.rectangle("fill", -4, -12, 3, 3)
                        love.graphics.rectangle("fill", 1, -12, 3, 3)
                        -- Mouth
                        love.graphics.setColor(0.3, 0.2, 0.1)
                        love.graphics.rectangle("fill", -3, -9, 6, 2)
                        -- Arms
                        love.graphics.setColor(0.5, 0.4, 0.3)
                        love.graphics.rectangle("fill", -10, -4, 4, 12)
                        love.graphics.rectangle("fill", 6, -4, 4, 12)
                        -- Legs
                        love.graphics.setColor(0.4, 0.3, 0.2)
                        love.graphics.rectangle("fill", -5, 10, 4, 8)
                        love.graphics.rectangle("fill", 1, 10, 4, 8)
                        
                    elseif m.type.name == "Swarm Zombie" then
                        -- Swarm zombie with enhanced 8-bit style
                        -- Body
                        love.graphics.setColor(0.2, 0.3, 0.4)
                        love.graphics.rectangle("fill", -5, -6, 10, 12)
                        -- Shirt details
                        love.graphics.setColor(0.1, 0.2, 0.3)
                        love.graphics.rectangle("fill", -3, -3, 6, 6)
                        -- Head
                        love.graphics.setColor(0.3, 0.4, 0.5)
                        love.graphics.rectangle("fill", -3, -10, 6, 4)
                        -- Face details
                        love.graphics.setColor(0.2, 0.3, 0.4)
                        love.graphics.rectangle("fill", -2, -8, 4, 2)
                        -- Eyes
                        love.graphics.setColor(0.8, 0.2, 0.2)
                        love.graphics.rectangle("fill", -2, -8, 1, 1)
                        love.graphics.rectangle("fill", 1, -8, 1, 1)
                        -- Mouth
                        love.graphics.setColor(0.1, 0.2, 0.3)
                        love.graphics.rectangle("fill", -1, -7, 2, 1)
                        -- Arms
                        love.graphics.setColor(0.2, 0.3, 0.4)
                        love.graphics.rectangle("fill", -6, -3, 2, 4)
                        love.graphics.rectangle("fill", 4, -3, 2, 4)
                        -- Legs
                        love.graphics.setColor(0.15, 0.25, 0.35)
                        love.graphics.rectangle("fill", -3, 6, 2, 4)
                        love.graphics.rectangle("fill", 1, 6, 2, 4)
                        
                    elseif m.type.name == "Brute Zombie" then
                        -- Brute zombie with enhanced 8-bit style
                        -- Body
                        love.graphics.setColor(0.5, 0.2, 0.2)
                        love.graphics.rectangle("fill", -8, -10, 16, 20)
                        -- Muscle details
                        love.graphics.setColor(0.4, 0.1, 0.1)
                        love.graphics.rectangle("fill", -6, -8, 12, 16)
                        -- Head
                        love.graphics.setColor(0.6, 0.3, 0.3)
                        love.graphics.rectangle("fill", -6, -14, 12, 8)
                        -- Face details
                        love.graphics.setColor(0.5, 0.2, 0.2)
                        love.graphics.rectangle("fill", -4, -12, 8, 4)
                        -- Eyes
                        love.graphics.setColor(0.8, 0.2, 0.2)
                        love.graphics.rectangle("fill", -4, -12, 3, 3)
                        love.graphics.rectangle("fill", 1, -12, 3, 3)
                        -- Mouth
                        love.graphics.setColor(0.3, 0.1, 0.1)
                        love.graphics.rectangle("fill", -3, -9, 6, 2)
                        -- Arms
                        love.graphics.setColor(0.5, 0.2, 0.2)
                        love.graphics.rectangle("fill", -10, -4, 4, 12)
                        love.graphics.rectangle("fill", 6, -4, 4, 12)
                        -- Legs
                        love.graphics.setColor(0.4, 0.1, 0.1)
                        love.graphics.rectangle("fill", -5, 10, 4, 8)
                        love.graphics.rectangle("fill", 1, 10, 4, 8)
                        
                    elseif m.type.name == "Crawler" then
                        -- Crawler zombie with enhanced 8-bit style
                        -- Body
                        love.graphics.setColor(0.3, 0.2, 0.3)
                        love.graphics.rectangle("fill", -6, -4, 12, 8)
                        -- Body details
                        love.graphics.setColor(0.2, 0.1, 0.2)
                        love.graphics.rectangle("fill", -4, -3, 8, 6)
                        -- Head
                        love.graphics.setColor(0.4, 0.3, 0.4)
                        love.graphics.rectangle("fill", -4, -8, 8, 4)
                        -- Face details
                        love.graphics.setColor(0.3, 0.2, 0.3)
                        love.graphics.rectangle("fill", -3, -7, 6, 2)
                        -- Eyes
                        love.graphics.setColor(0.8, 0.2, 0.2)
                        love.graphics.rectangle("fill", -3, -7, 2, 2)
                        love.graphics.rectangle("fill", 1, -7, 2, 2)
                        -- Mouth
                        love.graphics.setColor(0.2, 0.1, 0.2)
                        love.graphics.rectangle("fill", -2, -6, 4, 1)
                        -- Arms
                        love.graphics.setColor(0.3, 0.2, 0.3)
                        love.graphics.rectangle("fill", -8, -2, 3, 6)
                        love.graphics.rectangle("fill", 5, -2, 3, 6)
                        -- Legs
                        love.graphics.setColor(0.25, 0.15, 0.25)
                        love.graphics.rectangle("fill", -4, 4, 3, 4)
                        love.graphics.rectangle("fill", 1, 4, 3, 4)
                        
                    else
                        -- Default monster appearance with enhanced 8-bit style
                        -- Body
                        love.graphics.setColor(m.type.color)
                        love.graphics.rectangle("fill", -6, -8, 12, 16)
                        -- Shirt details
                        local darkerColor = {
                            m.type.color[1] * 0.7,
                            m.type.color[2] * 0.7,
                            m.type.color[3] * 0.7
                        }
                        love.graphics.setColor(darkerColor)
                        love.graphics.rectangle("fill", -4, -4, 8, 8)
                        -- Head
                        local lighterColor = {
                            m.type.color[1] * 1.2,
                            m.type.color[2] * 1.2,
                            m.type.color[3] * 1.2
                        }
                        love.graphics.setColor(lighterColor)
                        love.graphics.rectangle("fill", -4, -12, 8, 6)
                        -- Face details
                        love.graphics.setColor(darkerColor)
                        love.graphics.rectangle("fill", -3, -10, 6, 3)
                        -- Eyes
                        love.graphics.setColor(0.8, 0.2, 0.2)
                        love.graphics.rectangle("fill", -3, -10, 2, 2)
                        love.graphics.rectangle("fill", 1, -10, 2, 2)
                        -- Mouth
                        love.graphics.setColor(0.1, 0.1, 0.1)
                        love.graphics.rectangle("fill", -2, -8, 4, 1)
                        -- Arms
                        love.graphics.setColor(m.type.color)
                        love.graphics.rectangle("fill", -8, -4, 3, 6)
                        love.graphics.rectangle("fill", 5, -4, 3, 6)
                        -- Legs
                        love.graphics.setColor(darkerColor)
                        love.graphics.rectangle("fill", -4, 8, 3, 6)
                        love.graphics.rectangle("fill", 1, 8, 3, 6)
                    end
                end
                
                love.graphics.pop()
            end
            
            -- Draw health bar
            if m.state ~= ANIMATION_STATES.DEATH then
                local barWidth = m.size * 2
                local barHeight = 5
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", m.x - barWidth/2, m.y - m.size - 10, barWidth, barHeight)
                love.graphics.setColor(0, 1, 0)
                love.graphics.rectangle("fill", m.x - barWidth/2, m.y - m.size - 10, 
                                      barWidth * (m.health / m.maxHealth), barHeight)
                
                -- Draw monster name
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(m.type.name, m.x - m.size/2, m.y - m.size - 25)
            end
        end
        
        -- Draw projectiles
        for _, p in ipairs(projectiles) do
            if p.type == "plasma" then
                -- Draw plasma projectile
                love.graphics.setColor(0, 1, 1, 0.8) -- Cyan color
                love.graphics.circle("fill", p.x, p.y, p.size)
                -- Add glow effect
                love.graphics.setColor(0, 1, 1, 0.3)
                love.graphics.circle("fill", p.x, p.y, p.size * 2)
            elseif p.type == "rocket" then
                -- Draw rocket projectile
                love.graphics.setColor(1, 0.5, 0) -- Orange color
                love.graphics.circle("fill", p.x, p.y, p.size)
                -- Add trail effect
                love.graphics.setColor(1, 0.3, 0, 0.3)
                love.graphics.circle("fill", p.x - math.cos(p.angle) * 10, 
                                   p.y - math.sin(p.angle) * 10, p.size * 0.7)
            else
                -- Draw default projectile
                love.graphics.setColor(1, 1, 0)
                love.graphics.circle("fill", p.x, p.y, p.size)
            end
        end
        
        -- Draw player
        if playerImg then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(playerImg, player.x, player.y, 0, player.width/playerImg:getWidth(), player.height/playerImg:getHeight())
        else
            -- 8-bit style player
            love.graphics.push()
            love.graphics.translate(player.x + player.width/2, player.y + player.height/2)
            
            -- Draw armor if equipped
            if player.armor then
                love.graphics.setColor(0.6, 0.6, 0.6) -- Gray armor
                love.graphics.rectangle("fill", -12, -12, 24, 24) -- Armor plate
                love.graphics.setColor(0.4, 0.4, 0.4) -- Darker gray
                love.graphics.rectangle("fill", -10, -10, 20, 20) -- Inner armor
            end
            
            -- Body (blue)
            love.graphics.setColor(0.2, 0.4, 0.8)
            love.graphics.rectangle("fill", -8, -8, 16, 16)
            -- Head (skin tone)
            love.graphics.setColor(0.9, 0.7, 0.6)
            love.graphics.rectangle("fill", -6, -12, 12, 8)
            -- Eyes (white)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", -4, -10, 3, 3)
            love.graphics.rectangle("fill", 1, -10, 3, 3)
            -- Pupils (black)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", -3, -9, 2, 2)
            love.graphics.rectangle("fill", 1, -9, 2, 2)
            -- Helmet (dark blue)
            love.graphics.setColor(0.1, 0.2, 0.4)
            love.graphics.rectangle("fill", -8, -14, 16, 4)
            -- Arms (lighter blue)
            love.graphics.setColor(0.3, 0.5, 0.9)
            love.graphics.rectangle("fill", -12, -4, 4, 8)
            love.graphics.rectangle("fill", 8, -4, 4, 8)
            love.graphics.pop()
        end
        
        -- Draw gun
        love.graphics.push()
        love.graphics.translate(player.x + gun.offsetX, player.y + gun.offsetY)
        love.graphics.rotate(gun.angle)
        if gunImg then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(gunImg, 0, -gunImg:getHeight()/2, 0, 1, 1)
        else
            -- 8-bit style gun: draw pixel blocks
            if gun.type == "shotgun" then
                -- Shotgun design
                love.graphics.setColor(0.3, 0.3, 0.3) -- Dark gray
                love.graphics.rectangle("fill", 0, -4, 20, 8) -- Wider body
                love.graphics.setColor(0.7, 0.7, 0.7) -- Light gray
                love.graphics.rectangle("fill", 20, -3, 12, 6) -- Wider barrel
                love.graphics.setColor(0.4, 0.2, 0) -- Brown
                love.graphics.rectangle("fill", 4, 4, 6, 6) -- Wider grip
            elseif gun.type == "laser" then
                -- Laser gun design
                love.graphics.setColor(0.2, 0.2, 0.2) -- Dark gray
                love.graphics.rectangle("fill", 0, -3, 16, 6) -- Body
                love.graphics.setColor(0.8, 0.2, 0.2) -- Red
                love.graphics.rectangle("fill", 16, -2, 12, 4) -- Laser barrel
                love.graphics.setColor(0.4, 0.2, 0) -- Brown
                love.graphics.rectangle("fill", 2, 3, 4, 5) -- Grip
                -- Laser sight
                love.graphics.setColor(0, 1, 0) -- Green
                love.graphics.rectangle("fill", 12, -1, 2, 2)
            else
                -- Default gun design
                love.graphics.setColor(0.2, 0.2, 0.2) -- Dark gray
                love.graphics.rectangle("fill", 0, -3, 16, 6) -- Body
                love.graphics.setColor(0.7, 0.7, 0.7) -- Light gray
                love.graphics.rectangle("fill", 16, -2, 8, 4) -- Barrel
                love.graphics.setColor(0.4, 0.2, 0) -- Brown
                love.graphics.rectangle("fill", 2, 3, 4, 5) -- Grip
            end
        end
        love.graphics.pop()
        
        -- Draw health bar
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", 10, 10, 200, 20)
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", 10, 10, 200 * (player.health / player.maxHealth), 20)
        
        -- Draw score and wave
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Score: " .. game.score, 10, 40)
        love.graphics.print("Wave: " .. game.wave, 10, 60)
        love.graphics.print("Monsters Left: " .. (game.monstersPerWave - game.monstersKilled), 10, 80)
        
        -- Draw wave feedback message
        if game.waveFeedback and game.waveFeedback.timer > 0 then
            love.graphics.setColor(game.waveFeedback.color)
            love.graphics.printf(game.waveFeedback.message, 
                0, love.graphics.getHeight()/2 - 50, 
                love.graphics.getWidth(), "center")
        end
        
        -- Draw coins
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.circle("fill", 30, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("x " .. game.coins, 45, 95)
        
        -- Draw ammo count
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Ammo: " .. gun.ammo .. "/" .. gun.maxAmmo, 10, 120)
        
        -- Draw reload indicator if reloading
        if gun.isReloading then
            local reloadProgress = (love.timer.getTime() - gun.reloadStartTime) / gun.reloadTime
            love.graphics.setColor(1, 0.5, 0)
            love.graphics.rectangle("fill", 10, 140, 100 * reloadProgress, 10)
        end
    elseif game.state == "gameover" then
        -- Draw game over screen
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game Over", 0, love.graphics.getHeight()/2 - 100, love.graphics.getWidth(), "center")
        love.graphics.printf("Score: " .. game.score, 0, love.graphics.getHeight()/2 - 50, love.graphics.getWidth(), "center")
        love.graphics.printf("Wave Reached: " .. game.wave, 0, love.graphics.getHeight()/2, love.graphics.getWidth(), "center")
        love.graphics.printf("Coins: " .. game.coins, 0, love.graphics.getHeight()/2 + 50, love.graphics.getWidth(), "center")
        love.graphics.printf("Press SPACE to continue", 0, love.graphics.getHeight()/2 + 100, love.graphics.getWidth(), "center")
    elseif game.state == "shop" then
        -- Draw shop background
        love.graphics.setColor(0.1, 0.1, 0.2)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        
        -- Draw shop title
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Shop", 0, 50, love.graphics.getWidth(), "center")
        
        -- Draw coins
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.circle("fill", 30, 30, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("x " .. game.coins, 45, 25)
        
        -- Draw shop items using the new function
        drawShopItems()
        
        -- Draw continue button
        love.graphics.setColor(0.2, 0.2, 0.6)
        love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 100, love.graphics.getHeight() - 100, 200, 50)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Continue", love.graphics.getWidth()/2 - 100, love.graphics.getHeight() - 85, 200, "center")
        
        -- Draw feedback message
        if game.shopFeedback.timer > 0 then
            love.graphics.setColor(game.shopFeedback.color)
            love.graphics.printf(game.shopFeedback.message, 0, love.graphics.getHeight() - 40, love.graphics.getWidth(), "center")
        end
    end
end

-- Handle key presses
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        if game.state == "menu" then
            game.state = "playing"
            updateBackground()
            initializeGround()
        elseif game.state == "gameover" then
            game.state = "shop"
        elseif game.state == "shop" then
            game.state = "playing"
            game.score = 0
            game.wave = 1
            game.monstersKilled = 0
            player.health = player.maxHealth
            player.x = love.graphics.getWidth() / 2 - player.width / 2
            projectiles = {}
            monsters = {}
            monsterSpawnTimer = 0
            updateBackground()
            initializeGround()
        end
    elseif game.state == "shop" then
        if key == "up" then
            game.shopScroll = math.max(0, game.shopScroll - 1)
        elseif key == "down" then
            game.shopScroll = math.min(#game.shopItems - game.itemsPerPage, game.shopScroll + 1)
        end
    end
end

-- Handle mouse wheel
function love.wheelmoved(x, y)
    if game.state == "shop" then
        -- Scroll up/down in shop
        game.shopScroll = math.max(0, math.min(#game.shopItems - game.itemsPerPage, game.shopScroll - y))
    end
end

-- Handle mouse clicks
function love.mousepressed(x, y, button)
    if button == 1 then
        if game.state == "playing" then
            createProjectile()
        elseif game.state == "shop" then
            -- Check shop item purchases
            local itemY = 150
            local startIndex = game.shopScroll + 1
            local endIndex = math.min(startIndex + game.itemsPerPage - 1, #game.shopItems)
            
            -- Check scroll bar click
            if #game.shopItems > game.itemsPerPage then
                local scrollBarX = 720
                local scrollBarY = 150
                local scrollBarHeight = 200
                local scrollBarWidth = 20
                
                if x >= scrollBarX and x <= scrollBarX + scrollBarWidth and
                   y >= scrollBarY and y <= scrollBarY + scrollBarHeight then
                    -- Calculate new scroll position based on click
                    local clickRatio = (y - scrollBarY) / scrollBarHeight
                    game.shopScroll = math.floor(clickRatio * (#game.shopItems - game.itemsPerPage))
                    return
                end
            end
            
            -- Check buy buttons for visible items
            for i = startIndex, endIndex do
                local item = game.shopItems[i]
                if item.level < item.maxLevel then
                    -- Check buy button
                    if x >= 500 and x <= 600 and
                       y >= itemY + 20 and y <= itemY + 60 then
                        purchaseShopItem(item)
                    end
                end
                itemY = itemY + 100
            end
            
            -- Check continue button
            if x >= love.graphics.getWidth()/2 - 100 and x <= love.graphics.getWidth()/2 + 100 and
               y >= love.graphics.getHeight() - 100 and y <= love.graphics.getHeight() - 50 then
                game.state = "playing"
                game.score = 0
                game.wave = 1
                game.monstersKilled = 0
                player.health = player.maxHealth
                player.x = love.graphics.getWidth() / 2 - player.width / 2
                projectiles = {}
                monsters = {}
                monsterSpawnTimer = 0
                updateBackground()
                initializeGround()
            end
        end
    end
end

-- Purchase shop item
function purchaseShopItem(item)
    if game.coins >= item.cost and item.level < item.maxLevel then
        game.coins = game.coins - item.cost
        item.level = item.level + 1
        item.effect()
        game.shopFeedback.message = "Purchased " .. item.name .. "!"
        game.shopFeedback.timer = 2
        game.shopFeedback.color = {0, 1, 0} -- Green for success
        return true
    else
        if game.coins < item.cost then
            game.shopFeedback.message = "Not enough coins!"
        else
            game.shopFeedback.message = "Max level reached!"
        end
        game.shopFeedback.timer = 2
        game.shopFeedback.color = {1, 0, 0} -- Red for error
        return false
    end
end

-- Draw shop items
function drawShopItems()
    local y = 150
    local startIndex = game.shopScroll + 1
    local endIndex = math.min(startIndex + game.itemsPerPage - 1, #game.shopItems)
    
    -- Draw scroll indicator
    if #game.shopItems > game.itemsPerPage then
        local scrollBarHeight = 200
        local scrollBarY = 150
        local scrollBarX = 720
        local scrollBarWidth = 20
        
        -- Draw scroll bar background
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", scrollBarX, scrollBarY, scrollBarWidth, scrollBarHeight)
        
        -- Calculate scroll thumb position and size
        local thumbHeight = math.max(30, (game.itemsPerPage / #game.shopItems) * scrollBarHeight)
        local thumbY = scrollBarY + (game.shopScroll / (#game.shopItems - game.itemsPerPage)) * (scrollBarHeight - thumbHeight)
        
        -- Draw scroll thumb
        love.graphics.setColor(0.4, 0.4, 0.5)
        love.graphics.rectangle("fill", scrollBarX, thumbY, scrollBarWidth, thumbHeight)
    end
    
    -- Draw visible items
    for i = startIndex, endIndex do
        local item = game.shopItems[i]
        -- Draw item box
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", 100, y, 600, 80)
        
        -- Draw item name and level
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(item.name .. " (Level " .. item.level .. "/" .. item.maxLevel .. ")", 120, y + 20)
        
        -- Draw cost
        if item.level < item.maxLevel then
            love.graphics.setColor(1, 0.8, 0)
            love.graphics.circle("fill", 120, y + 50, 8)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("x " .. item.cost, 135, y + 45)
            
            -- Draw buy button
            if game.coins >= item.cost then
                love.graphics.setColor(0.2, 0.6, 0.2)
            else
                love.graphics.setColor(0.4, 0.4, 0.4)
            end
            love.graphics.rectangle("fill", 500, y + 20, 100, 40)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Buy", 500, y + 30, 100, "center")
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.printf("MAX LEVEL", 500, y + 30, 100, "center")
        end
        
        y = y + 100
    end
end 