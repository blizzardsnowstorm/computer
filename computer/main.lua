local sky, cloud, window, pressEnter, phone1, phone2, phone3
local emptyboard, cpuboard, bolts, chip, wires
local screwcpuboard, wirescrewcpuboard 
local cloudX = 0
local cloudSpeed = 60
local timer = 0
local isVisible = true
local textAlive = true

local phoneY = 600
local phoneActive = false
local phoneSpeed = 400
local currentPhoneImg
local phoneState = "sliding"
local phoneTimer = 0
local shakeOffset = 0

local boardAlpha = 0
local showBoard = false

-- Interaction Variables
local chipSelected = false
local chipInstalled = false
local boltsSelected = false   
local boltsInstalled = false  
local wiresSelected = false   
local wiresInstalled = false  
local finalPhoneTriggered = false -- Track final message state

-- HITBOX SETTINGS
local hitboxes = {
    chip  = {x = 340, y = 515, w = 40, h = 40},  
    board = {x = 410, y = 480, w = 125, h = 100},
    bolts = {x = 30, y = 515, w = 50, h = 50},  
    wires = {x = 180, y = 515, w = 50, h = 50}  
}

function love.load()
    love.window.setMode(600, 600)
    
    sky = love.graphics.newImage("sky.png")
    cloud = love.graphics.newImage("cloud.png")
    window = love.graphics.newImage("transwindow.png")
    pressEnter = love.graphics.newImage("pressenter.png")
    phone1 = love.graphics.newImage("phone1.png")
    phone2 = love.graphics.newImage("phone2.png")
    phone3 = love.graphics.newImage("phone3message.png") -- New Image
    
    emptyboard = love.graphics.newImage("emptyboard.png")
    cpuboard = love.graphics.newImage("cpuboard.png")
    bolts = love.graphics.newImage("bolts.png")
    chip = love.graphics.newImage("chip.png")
    wires = love.graphics.newImage("wires.png")
    
    screwcpuboard = love.graphics.newImage("screwcpuboard.png")
    wirescrewcpuboard = love.graphics.newImage("wirescrewcpuboard.png")
    
    currentPhoneImg = phone1
end

function checkHit(mx, my, box)
    return mx > box.x and mx < box.x + box.w and my > box.y and my < box.y + box.h
end

function love.mousepressed(x, y, button)
    if button == 1 and showBoard then
        -- 1. CHIP LOGIC
        if not chipSelected and not chipInstalled then
            if checkHit(x, y, hitboxes.chip) then chipSelected = true end
        elseif chipSelected then
            if checkHit(x, y, hitboxes.board) then
                chipInstalled = true
                chipSelected = false
            else chipSelected = false end
        end

        -- 2. BOLTS LOGIC
        if chipInstalled and not boltsSelected and not boltsInstalled then
            if checkHit(x, y, hitboxes.bolts) then boltsSelected = true end
        elseif boltsSelected then
            if checkHit(x, y, hitboxes.board) then
                boltsInstalled = true
                boltsSelected = false
            else boltsSelected = false end
        end

        -- 3. WIRES LOGIC
        if boltsInstalled and not wiresSelected and not wiresInstalled then
            if checkHit(x, y, hitboxes.wires) then wiresSelected = true end
        elseif wiresSelected then
            if checkHit(x, y, hitboxes.board) then
                wiresInstalled = true
                wiresSelected = false
            else wiresSelected = false end
        end
    end
end

function love.keypressed(key)
    if (key == "return" or key == "kpenter") then
        if textAlive then
            textAlive = false
            phoneActive = true
        elseif phoneState == "done" then
            phoneState = "sliding_away"
        end
    end
    if key == "escape" then love.event.quit() end
end

function love.update(dt)
    cloudX = cloudX - cloudSpeed * dt
    if cloudX <= -cloud:getWidth() then cloudX = 0 end

    -- Handle flashing text
    if textAlive then
        timer = timer + dt
        if isVisible then
            if timer >= 2.5 then isVisible = false; timer = 0 end
        else
            if timer >= 0.7 then isVisible = true; timer = 0 end
        end
    end

    -- TRIGGER FINAL PHONE MESSAGE
    if wiresInstalled and not finalPhoneTriggered then
        finalPhoneTriggered = true
        currentPhoneImg = phone3
        phoneY = 600
        phoneActive = true
        phoneState = "sliding"
        phoneTimer = 0
    end

    -- PHONE ANIMATION LOGIC
    if phoneActive then
        if phoneState == "sliding" then
            if phoneY > 0 then 
                phoneY = phoneY - phoneSpeed * dt 
            else 
                phoneY = 0
                phoneState = "shaking"
                phoneTimer = 0 
            end
        elseif phoneState == "shaking" then
            phoneTimer = phoneTimer + dt
            shakeOffset = math.random(-5, 5)
            if phoneTimer >= 0.2 then 
                phoneState = "waiting"
                phoneTimer = 0
                shakeOffset = 0 
            end
        elseif phoneState == "waiting" then
            -- For the first phone, it swaps to phone2. For phone3, it just stays.
            phoneTimer = phoneTimer + dt
            if phoneTimer >= 0.5 then 
                if currentPhoneImg == phone1 then
                    currentPhoneImg = phone2 
                end
                phoneState = "done" 
            end
        elseif phoneState == "sliding_away" then
            if phoneY < 600 then 
                phoneY = phoneY + phoneSpeed * dt 
            else 
                phoneY = 600
                phoneActive = false
                -- If this was the first phone, show the board
                if not finalPhoneTriggered then
                    showBoard = true 
                end
            end
        end
    end

    if showBoard and boardAlpha < 1 then
        boardAlpha = boardAlpha + (1.5 * dt)
        if boardAlpha > 1 then boardAlpha = 1 end
    end
end

function love.draw()
    local s = 0.75
    love.graphics.setColor(1, 1, 1, 1)
    
    love.graphics.draw(sky, 0, 0, 0, s, s)
    love.graphics.draw(cloud, cloudX * s, 150 * s, 0, s, s)
    love.graphics.draw(cloud, (cloudX + cloud:getWidth()) * s, 150 * s, 0, s, s)
    love.graphics.draw(window, 0, 0, 0, s, s)

    if showBoard then
        love.graphics.setColor(1, 1, 1, boardAlpha)
        
        if wiresInstalled then
            love.graphics.draw(wirescrewcpuboard, 0, 60 * s, 0, s, s)
        elseif boltsInstalled then
            love.graphics.draw(screwcpuboard, 0, 60 * s, 0, s, s)
        elseif chipInstalled then
            love.graphics.draw(cpuboard, 0, 60 * s, 0, s, s)
        else
            love.graphics.draw(emptyboard, 0, 60 * s, 0, s, s)
        end
        
        if not boltsInstalled then
            if boltsSelected then love.graphics.setColor(1, 1, 0, boardAlpha) end
            love.graphics.draw(bolts, 0, 0, 0, s, s)
            love.graphics.setColor(1, 1, 1, boardAlpha)
        end

        if not wiresInstalled then
            if wiresSelected then love.graphics.setColor(1, 1, 0, boardAlpha) end
            love.graphics.draw(wires, 0, 0, 0, s, s)
            love.graphics.setColor(1, 1, 1, boardAlpha)
        end

        if not chipInstalled then
            if chipSelected then love.graphics.setColor(1, 1, 0, boardAlpha) end
            love.graphics.draw(chip, 0, 0, 0, s, s)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
    if textAlive and isVisible then love.graphics.draw(pressEnter, 0, 0, 0, s, s) end
    
    -- Draw the active phone
    if phoneActive then 
        love.graphics.draw(currentPhoneImg, (0 + shakeOffset) * s, (phoneY + shakeOffset) * s, 0, s, s) 
    end
end
