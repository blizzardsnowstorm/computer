local sky, cloud, window, pressEnter, phone1, phone2
local emptyboard, bolts, chip, wires
local cloudX = 0
local cloudSpeed = 60
local timer = 0
local isVisible = true
local textAlive = true

local phoneY = 600
local phoneActive = false
local phoneSpeed = 400
local currentPhoneImg
local phoneState = "sliding" -- "sliding", "shaking", "waiting", "done", "sliding_away"
local phoneTimer = 0
local shakeOffset = 0

local boardAlpha = 0
local showBoard = false

function love.load()
    love.window.setMode(600, 600)
    
    -- Background & UI
    sky = love.graphics.newImage("sky.png")
    cloud = love.graphics.newImage("cloud.png")
    window = love.graphics.newImage("transwindow.png")
    pressEnter = love.graphics.newImage("pressenter.png")
    phone1 = love.graphics.newImage("phone1.png")
    phone2 = love.graphics.newImage("phone2.png")
    
    -- Electronics Assets
    emptyboard = love.graphics.newImage("emptyboard.png")
    bolts = love.graphics.newImage("bolts.png")
    chip = love.graphics.newImage("chip.png")
    wires = love.graphics.newImage("wires.png")
    
    currentPhoneImg = phone1
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
    
    if key == "escape" then
        love.event.quit()
    end
end

function love.update(dt)
    -- Cloud movement
    cloudX = cloudX - cloudSpeed * dt
    if cloudX <= -cloud:getWidth() then cloudX = 0 end

    -- Blinking "Press Enter"
    if textAlive then
        timer = timer + dt
        if isVisible then
            if timer >= 2.5 then isVisible = false; timer = 0 end
        else
            if timer >= 0.7 then isVisible = true; timer = 0 end
        end
    end

    -- Phone Animation
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
            phoneTimer = phoneTimer + dt
            if phoneTimer >= 0.5 then
                currentPhoneImg = phone2
                phoneState = "done"
            end
        elseif phoneState == "sliding_away" then
            if phoneY < 600 then
                phoneY = phoneY + phoneSpeed * dt
            else
                phoneY = 600
                phoneActive = false 
                showBoard = true 
            end
        end
    end

    -- Fade-in logic for all components
    if showBoard and boardAlpha < 1 then
        boardAlpha = boardAlpha + (1.5 * dt)
        if boardAlpha > 1 then boardAlpha = 1 end
    end
end

function love.draw()
    local s = 0.75
    
    love.graphics.setColor(1, 1, 1, 1)
    
    -- World
    love.graphics.draw(sky, 0, 0, 0, s, s)
    love.graphics.draw(cloud, cloudX * s, 150 * s, 0, s, s)
    love.graphics.draw(cloud, (cloudX + cloud:getWidth()) * s, 150 * s, 0, s, s)
    love.graphics.draw(window, 0, 0, 0, s, s)

    -- Everything here fades in together
    if showBoard then
        love.graphics.setColor(1, 1, 1, boardAlpha)
        love.graphics.draw(emptyboard, 0, 60 * s, 0, s, s)
        love.graphics.draw(bolts, 0, 0, 0, s, s)
        love.graphics.draw(chip, 0, 0, 0, s, s)
        love.graphics.draw(wires, 0, 0, 0, s, s)
    end

    -- UI Reset
    love.graphics.setColor(1, 1, 1, 1)

    if textAlive and isVisible then
        love.graphics.draw(pressEnter, 0, 0, 0, s, s)
    end

    if phoneActive then
        love.graphics.draw(currentPhoneImg, (0 + shakeOffset) * s, (phoneY + shakeOffset) * s, 0, s, s)
    end
end
