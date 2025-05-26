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
    }
}

-- Background properties
local stars = {}
local numStars = 100
local background = {
    color = {0.1, 0.1, 0.2}, -- Default dark blue
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
    numGrass = 50
}

-- Player properties
local player = {
    x = 0,
    y = 0,
    width = 32,
    height = 32,
    speed = 200,
    health = 100,
    maxHealth = 100
}

-- Gun properties
local gun = {
    length = 20,
    width = 4,
    angle = 0,
    offsetX = 0,
    offsetY = 0
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
    }
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
            y = love.math.random(0, love.graphics.getHeight() - ground.height - 200),
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
    local waveType = game.wave % 4 -- Cycle through 4 different backgrounds
    
    if waveType == 0 then
        -- Deep space (dark blue)
        background.color = {0.1, 0.1, 0.2}
        background.starColor = {1, 1, 1}
        background.nebula = false
    elseif waveType == 1 then
        -- Nebula (purple)
        background.color = {0.2, 0.1, 0.3}
        background.starColor = {0.8, 0.6, 1}
        background.nebula = true
        background.nebulaColor = {0.4, 0.2, 0.6, 0.3}
    elseif waveType == 2 then
        -- Red space (danger zone)
        background.color = {0.3, 0.1, 0.1}
        background.starColor = {1, 0.8, 0.8}
        background.nebula = true
        background.nebulaColor = {0.6, 0.2, 0.2, 0.3}
    else
        -- Green space (alien zone)
        background.color = {0.1, 0.3, 0.2}
        background.starColor = {0.8, 1, 0.8}
        background.nebula = true
        background.nebulaColor = {0.2, 0.6, 0.3, 0.3}
    end
end

-- Update ground based on wave
function updateGround()
    local waveType = game.wave % 4
    
    -- Update building damage based on wave
    for _, building in ipairs(ground.buildings) do
        building.damage = math.min(1, (game.wave - 1) * 0.2) -- Increase damage up to 100%
        
        -- Randomly break windows based on damage
        for _, window in ipairs(building.windows) do
            if love.math.random() < building.damage then
                window.lit = false
            end
        end
    end
end

-- Create a new projectile
function createProjectile()
    local projectile = {
        x = player.x + gun.offsetX,
        y = player.y + gun.offsetY,
        size = projectileSize,
        speed = projectileSpeed,
        angle = gun.angle
    }
    table.insert(projectiles, projectile)
end

-- Create a new monster
function createMonster()
    local monster = {
        x = love.math.random(monsterSize, love.graphics.getWidth() - monsterSize),
        y = -monsterSize,
        size = monsterSize,
        speed = monsterSpeed * (1 + (game.wave - 1) * 0.3), -- Increased speed scaling
        health = monsterHealth + (game.wave - 1) * 2, -- Increased health scaling
        maxHealth = monsterHealth + (game.wave - 1) * 2,
        angle = 0,
        type = game.wave % 3 -- 0: basic, 1: armored, 2: elite
    }
    table.insert(monsters, monster)
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
                    -- Remove projectile
                    table.remove(projectiles, i)
                    -- Damage monster
                    m.health = m.health - 1
                    if m.health <= 0 then
                        table.remove(monsters, j)
                        game.score = game.score + 100
                        game.monstersKilled = game.monstersKilled + 1
                        
                        -- Check if wave is complete
                        if game.monstersKilled >= game.monstersPerWave then
                            game.wave = game.wave + 1
                            game.monstersKilled = 0
                            -- Clear remaining monsters
                            monsters = {}
                            -- Update background and ground for new wave
                            updateBackground()
                            updateGround()
                            -- Add coins for completing wave
                            game.coins = game.coins + 50
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
                player.health = player.health - 20
                table.remove(monsters, i)
                if player.health <= 0 then
                    game.state = "gameover"
                end
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
        -- Draw background
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
        love.graphics.setColor(0.2, 0.5, 0.2)
        for _, blade in ipairs(ground.grass) do
            love.graphics.rectangle("fill", blade.x, 
                                  love.graphics.getHeight() - ground.height,
                                  blade.width, -blade.height)
        end
        
        -- Draw ground
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", 0, love.graphics.getHeight() - ground.height,
                              love.graphics.getWidth(), ground.height)
        
        -- Draw monsters
        for _, m in ipairs(monsters) do
            if zombieImg then
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(zombieImg, m.x, m.y, 0, m.size/zombieImg:getWidth()*2, m.size/zombieImg:getHeight()*2, zombieImg:getWidth()/2, zombieImg:getHeight()/2)
            else
                -- 8-bit style monster with different types
                love.graphics.push()
                love.graphics.translate(m.x, m.y)
                
                if m.type == 0 then
                    -- Basic monster (green)
                    -- Body
                    love.graphics.setColor(0.2, 0.4, 0.2)
                    love.graphics.rectangle("fill", -8, -8, 16, 16)
                    -- Head
                    love.graphics.setColor(0.3, 0.6, 0.3)
                    love.graphics.rectangle("fill", -6, -12, 12, 8)
                    -- Eyes
                    love.graphics.setColor(0.8, 0.2, 0.2)
                    love.graphics.rectangle("fill", -4, -10, 3, 3)
                    love.graphics.rectangle("fill", 1, -10, 3, 3)
                    -- Mouth
                    love.graphics.setColor(0.1, 0.1, 0.1)
                    love.graphics.rectangle("fill", -3, -5, 6, 2)
                    -- Arms
                    love.graphics.setColor(0.2, 0.3, 0.2)
                    love.graphics.rectangle("fill", -12, -4, 4, 8)
                    love.graphics.rectangle("fill", 8, -4, 4, 8)
                elseif m.type == 1 then
                    -- Armored monster (purple with armor)
                    -- Body
                    love.graphics.setColor(0.4, 0.2, 0.4)
                    love.graphics.rectangle("fill", -8, -8, 16, 16)
                    -- Head
                    love.graphics.setColor(0.5, 0.3, 0.5)
                    love.graphics.rectangle("fill", -6, -12, 12, 8)
                    -- Eyes
                    love.graphics.setColor(0.8, 0.8, 0.2)
                    love.graphics.rectangle("fill", -4, -10, 3, 3)
                    love.graphics.rectangle("fill", 1, -10, 3, 3)
                    -- Mouth
                    love.graphics.setColor(0.1, 0.1, 0.1)
                    love.graphics.rectangle("fill", -3, -5, 6, 2)
                    -- Arms
                    love.graphics.setColor(0.3, 0.2, 0.3)
                    love.graphics.rectangle("fill", -12, -4, 4, 8)
                    love.graphics.rectangle("fill", 8, -4, 4, 8)
                    -- Armor plates
                    love.graphics.setColor(0.6, 0.6, 0.6)
                    love.graphics.rectangle("fill", -10, -6, 20, 4)
                    love.graphics.rectangle("fill", -8, -10, 16, 2)
                else
                    -- Elite monster (red with spikes)
                    -- Body
                    love.graphics.setColor(0.6, 0.2, 0.2)
                    love.graphics.rectangle("fill", -8, -8, 16, 16)
                    -- Head
                    love.graphics.setColor(0.7, 0.3, 0.3)
                    love.graphics.rectangle("fill", -6, -12, 12, 8)
                    -- Eyes
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.rectangle("fill", -4, -10, 3, 3)
                    love.graphics.rectangle("fill", 1, -10, 3, 3)
                    -- Mouth
                    love.graphics.setColor(0.1, 0.1, 0.1)
                    love.graphics.rectangle("fill", -3, -5, 6, 2)
                    -- Arms
                    love.graphics.setColor(0.5, 0.2, 0.2)
                    love.graphics.rectangle("fill", -12, -4, 4, 8)
                    love.graphics.rectangle("fill", 8, -4, 4, 8)
                    -- Spikes
                    love.graphics.setColor(0.8, 0.8, 0.8)
                    love.graphics.rectangle("fill", -8, -14, 4, 4)
                    love.graphics.rectangle("fill", 4, -14, 4, 4)
                    love.graphics.rectangle("fill", -10, -4, 4, 4)
                    love.graphics.rectangle("fill", 6, -4, 4, 4)
                end
                
                love.graphics.pop()
            end
            
            -- Draw health bar
            local barWidth = m.size * 2
            local barHeight = 5
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", m.x - barWidth/2, m.y - m.size - 10, barWidth, barHeight)
            love.graphics.setColor(0, 1, 0)
            love.graphics.rectangle("fill", m.x - barWidth/2, m.y - m.size - 10, 
                                  barWidth * (m.health / m.maxHealth), barHeight)
        end
        
        -- Draw projectiles
        love.graphics.setColor(1, 1, 0)
        for _, p in ipairs(projectiles) do
            love.graphics.circle("fill", p.x, p.y, p.size)
        end
        
        -- Draw player
        if playerImg then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(playerImg, player.x, player.y, 0, player.width/playerImg:getWidth(), player.height/playerImg:getHeight())
        else
            -- 8-bit style player
            love.graphics.push()
            love.graphics.translate(player.x + player.width/2, player.y + player.height/2)
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
            -- Gun body (dark gray)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", 0, -3, 16, 6) -- main body
            -- Gun barrel (light gray)
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.rectangle("fill", 16, -2, 8, 4) -- barrel
            -- Gun grip (brown)
            love.graphics.setColor(0.4, 0.2, 0)
            love.graphics.rectangle("fill", 2, 3, 4, 5) -- grip
            -- Gun highlight (white)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", 12, -2, 2, 2) -- highlight
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
        
        -- Draw coins
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.circle("fill", 30, 100, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("x " .. game.coins, 45, 95)
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
        
        -- Draw shop items
        local y = 150
        for i, item in ipairs(game.shopItems) do
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
        
        -- Draw continue button
        love.graphics.setColor(0.2, 0.2, 0.6)
        love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 100, y + 50, 200, 50)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Continue", love.graphics.getWidth()/2 - 100, y + 65, 200, "center")
        
        -- Draw feedback message
        if game.shopFeedback.timer > 0 then
            love.graphics.setColor(game.shopFeedback.color)
            love.graphics.printf(game.shopFeedback.message, 0, y + 120, love.graphics.getWidth(), "center")
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
            for i, item in ipairs(game.shopItems) do
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
               y >= itemY + 50 and y <= itemY + 100 then
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