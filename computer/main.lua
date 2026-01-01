local sky, cloud, window, pressEnter, phone1, phone2, phone3, store, storeDialogueImg
local storePurchase1Img 
local emptyboard, cpuboard, bolts, chip, wires
local screwcpuboard, wirescrewcpuboard 
local emptybox, wirescrewcpuboardbox
local music 

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
local showStore = false 
local showDialogue = false 
local showPurchase1 = false 

-- Interaction Variables
local chipSelected = false
local chipInstalled = false
local boltsSelected = false   
local boltsInstalled = false  
local wiresSelected = false   
local wiresInstalled = false  
local boardSelected = false
local boardBoxed = false      
local finalPhoneTriggered = false 

-- HITBOX SETTINGS
local hitboxes = {
    chip  = {x = 340, y = 515, w = 40, h = 40},  
    board = {x = 410, y = 480, w = 125, h = 100},
    bolts = {x = 30, y = 515, w = 50, h = 50},  
    wires = {x = 180, y = 515, w = 50, h = 50},
    box   = {x = 60, y = 380, w = 155, h = 130},
    employee = {x = 30, y = 250, w = 100, h = 150} 
}

function love.load()
    love.window.setMode(600, 600)
    
    music = love.audio.newSource("dreamlike.mp3", "stream")
    music:setLooping(true) 
    music:play()           
    
    sky = love.graphics.newImage("sky.png")
    cloud = love.graphics.newImage("cloud.png")
    window = love.graphics.newImage("transwindow.png")
    pressEnter = love.graphics.newImage("pressenter.png")
    phone1 = love.graphics.newImage("phone1.png")
    phone2 = love.graphics.newImage("phone2.png")
    phone3 = love.graphics.newImage("phone3message.png") 
    store = love.graphics.newImage("store.png")
    storeDialogueImg = love.graphics.newImage("storedialogue.png")
    storePurchase1Img = love.graphics.newImage("storepurchase1.png")
    
    emptyboard = love.graphics.newImage("emptyboard.png")
    cpuboard = love.graphics.newImage("cpuboard.png")
    bolts = love.graphics.newImage("bolts.png")
    chip = love.graphics.newImage("chip.png")
    wires = love.graphics.newImage("wires.png")
    
    screwcpuboard = love.graphics.newImage("screwcpuboard.png")
    wirescrewcpuboard = love.graphics.newImage("wirescrewcpuboard.png")
    
    emptybox = love.graphics.newImage("emptybox.png")
    wirescrewcpuboardbox = love.graphics.newImage("wirescrewcpuboardbox.png")
    
    currentPhoneImg = phone1
end

function checkHit(mx, my, box)
    return mx > box.x and mx < box.x + box.w and my > box.y and my < box.y + box.h
end

function love.mousepressed(x, y, button)
    if button == 1 and not showStore then
        if showBoard then
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

            -- 4. BOXING LOGIC
            if wiresInstalled and not boardBoxed then
                if not boardSelected then
                    if checkHit(x, y, hitboxes.board) then boardSelected = true end
                else
                    if checkHit(x, y, hitboxes.box) then
                        boardBoxed = true
                        boardSelected = false
                        showStore = true 
                    else
                        boardSelected = false
                    end
                end
            end
        end
    elseif button == 1 and showStore then
        -- Employee interaction (Only works if not already looking at purchase result)
        if not showPurchase1 and checkHit(x, y, hitboxes.employee) then
            showDialogue = true
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

    -- Trigger purchase image when 1 is pressed while dialogue is active
    if key == "1" and showDialogue then
        showPurchase1 = true
    end

    if key == "escape" then love.event.quit() end
end

function love.update(dt)
    cloudX = cloudX - cloudSpeed * dt
    if cloudX <= -cloud:getWidth() then cloudX = 0 end

    if textAlive then
        timer = timer + dt
        if isVisible then
            if timer >= 2.5 then isVisible = false; timer = 0 end
        else
            if timer >= 0.7 then isVisible = true; timer = 0 end
        end
    end

    if wiresInstalled and not finalPhoneTriggered then
        finalPhoneTriggered = true
        currentPhoneImg = phone3
        phoneY = 600
        phoneActive = true
        phoneState = "sliding"
        phoneTimer = 0
    end

    if phoneActive then
        if phoneState == "sliding" then
            if phoneY > 0 then phoneY = phoneY - phoneSpeed * dt else phoneY = 0; phoneState = "shaking"; phoneTimer = 0 end
        elseif phoneState == "shaking" then
            phoneTimer = phoneTimer + dt
            shakeOffset = math.random(-5, 5)
            if phoneTimer >= 0.2 then phoneState = "waiting"; phoneTimer = 0; shakeOffset = 0 end
        elseif phoneState == "waiting" then
            phoneTimer = phoneTimer + dt
            if phoneTimer >= 0.5 then 
                if currentPhoneImg == phone1 then currentPhoneImg = phone2 end
                phoneState = "done" 
            end
        elseif phoneState == "sliding_away" then
            if phoneY < 600 then 
                phoneY = phoneY + phoneSpeed * dt 
            else 
                phoneY = 600; 
                phoneActive = false; 
                if not showBoard then showBoard = true end 
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
            if boardBoxed then
                love.graphics.draw(wirescrewcpuboardbox, 0, 0, 0, s, s)
            else
                love.graphics.draw(emptybox, 0, 0, 0, s, s)
            end
        end

        if not boardBoxed then
            if boardSelected then love.graphics.setColor(1, 1, 0, boardAlpha) end
            if wiresInstalled then
                love.graphics.draw(wirescrewcpuboard, 0, 60 * s, 0, s, s)
            elseif boltsInstalled then
                love.graphics.draw(screwcpuboard, 0, 60 * s, 0, s, s)
            elseif chipInstalled then
                love.graphics.draw(cpuboard, 0, 60 * s, 0, s, s)
            else
                love.graphics.draw(emptyboard, 0, 60 * s, 0, s, s)
            end
            love.graphics.setColor(1, 1, 1, boardAlpha)
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

    if showStore then
        love.graphics.setColor(1, 1, 1, 1)
        
        if showPurchase1 then
            love.graphics.draw(storePurchase1Img, 0, 0, 0, s, s)
        elseif showDialogue then
            love.graphics.draw(storeDialogueImg, 0, 0, 0, s, s)
        else
            love.graphics.draw(store, 0, 0, 0, s, s)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
    if textAlive and isVisible then love.graphics.draw(pressEnter, 0, 0, 0, s, s) end
    if phoneActive then love.graphics.draw(currentPhoneImg, (0 + shakeOffset) * s, (phoneY + shakeOffset) * s, 0, s, s) end
end
