-- TIRE & VEHICLE DAMAGE SYSTEM

local function GetVehicleSpeedKmh(vehicle)
    local speed = GetEntitySpeed(vehicle)
    return speed * 3.6
end

-- Check tire damage from speed and terrain
RegisterNetEvent('realdrive:checkTireDamage', function(vehicle)
    if not Config.TireDamage.enabled or not vehicle or vehicle == 0 then return end
    
    local speed = GetVehicleSpeedKmh(vehicle)
    local tireType = exports['realdrive']:GetTireType(vehicle)
    local surface = exports['realdrive']:GetSurfaceType(vehicle)
    
    -- Determine threshold
    local threshold = Config.TireDamage.speedThresholds.normal
    if tireType == 'offroad' then
        threshold = Config.TireDamage.speedThresholds.offroad
    elseif tireType == 'sport' or tireType == 'tuner' then
        threshold = Config.TireDamage.speedThresholds.agile
    end
    
    -- Calculate damage
    if speed > threshold then
        local excessSpeed = speed - threshold
        local damage = excessSpeed * Config.TireDamage.damageMultiplier
        
        -- Apply terrain damage multiplier
        if surface == 'gravel' or surface == 'sand' then
            damage = damage * 1.5
        elseif surface == 'mud' then
            damage = damage * 2.0
        end
        
        -- Apply damage to random wheel
        local wheels = {0, 1, 2, 3}
        local randomWheel = wheels[math.random(#wheels)]
        
        local currentWear = GetVehicleTyreHealth(vehicle, randomWheel)
        SetVehicleTyreHealth(vehicle, randomWheel, math.max(0, currentWear - damage))
        
        -- Chance to burst tire
        if math.random() < Config.TireDamage.burstChance and currentWear - damage < 50 then
            SmashVehicleWindow(vehicle, randomWheel)
        end
    end
end)

-- Check off-road damage
RegisterNetEvent('realdrive:checkOffRoadDamage', function(vehicle)
    if not Config.OffRoadDamage.enabled or not vehicle or vehicle == 0 then return end
    
    local tireType = exports['realdrive']:GetTireType(vehicle)
    local surface = exports['realdrive']:GetSurfaceType(vehicle)
    
    -- Off-road tires on road or road tires off-road
    local isOnRoad = surface == 'asphalt'
    local hasOffRoadTires = tireType == 'offroad' or tireType == 'suv'
    
    if not isOnRoad and not hasOffRoadTires then
        -- Taking damage driving unsuitable vehicle off-road
        local bodyHealth = GetVehicleBodyHealth(vehicle)
        local newHealth = bodyHealth - Config.OffRoadDamage.damagePerSecond
        
        SetVehicleBodyHealth(vehicle, math.max(0, newHealth))
        
        if newHealth < 200 then
            SmashVehicleWindow(vehicle, 0)
        end
    end
    
    -- Weather impact
    local weatherType = GetPrevWeatherTypeHashName()
    if weatherType == 'RAIN' or weatherType == 'THUNDER' then
        if not isOnRoad then
            local health = GetVehicleBodyHealth(vehicle)
            SetVehicleBodyHealth(vehicle, health - (Config.OffRoadDamage.damagePerSecond * Config.OffRoadDamage.rainDamageMultiplier))
        end
    elseif weatherType == 'SNOW' or weatherType == 'BLIZZARD' then
        if not isOnRoad then
            local health = GetVehicleBodyHealth(vehicle)
            SetVehicleBodyHealth(vehicle, health - (Config.OffRoadDamage.damagePerSecond * Config.OffRoadDamage.snowDamageMultiplier))
        end
    end
end)

-- Mountain jump detection
CreateThread(function()
    while true do
        Wait(500)
        
        if not Config.TireDamage.enabled then goto continue end
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle and vehicle ~= 0 then
            local velocity = GetEntityVelocity(vehicle)
            local jumpForce = velocity.z
            
            if jumpForce > 2.0 then
                -- Significant air time detected
                local prevZ = GetEntityCoords(vehicle).z
                
                Wait(500)
                
                local currentZ = GetEntityCoords(vehicle).z
                local heightDifference = currentZ - prevZ
                
                if heightDifference > Config.TireDamage.mountainHeight then
                    -- High fall detected
                    if math.random() < Config.TireDamage.wheelLossChance then
                        local wheels = {0, 1, 2, 3}
                        local lostWheel = wheels[math.random(#wheels)]
                        SmashVehicleWindow(vehicle, lostWheel)
                    end
                end
            end
        end
        
        ::continue::
    end
end)

-- HUD Display
CreateThread(function()
    while true do
        Wait(100)
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle and vehicle ~= 0 then
            local speed = GetVehicleSpeedKmh(vehicle)
            local health = GetVehicleBodyHealth(vehicle)
            local tireHealth = (GetVehicleTyreHealth(vehicle, 0) + GetVehicleTyreHealth(vehicle, 1) + GetVehicleTyreHealth(vehicle, 2) + GetVehicleTyreHealth(vehicle, 3)) / 4
            local engineHealth = GetVehicleEngineHealth(vehicle)
            
            -- Draw HUD (only in debug mode)
            if Config.Settings.debugMode then
                DrawAdvancedText(0.01, 0.05, 0.005, 0.0028, "Speed: " .. math.floor(speed) .. " km/h", 255, 255, 255, 255)
                DrawAdvancedText(0.01, 0.08, 0.005, 0.0028, "Body: " .. math.floor(health) .. "/1000", 255, math.floor((health/1000)*255), 0, 255)
                DrawAdvancedText(0.01, 0.11, 0.005, 0.0028, "Tires: " .. math.floor(tireHealth) .. "/1000", 255, math.floor((tireHealth/1000)*255), 0, 255)
                DrawAdvancedText(0.01, 0.14, 0.005, 0.0028, "Engine: " .. math.floor(engineHealth) .. "/1000", 255, math.floor((engineHealth/1000)*255), 0, 255)
            end
        end
    end
end)

-- Draw text helper
function DrawAdvancedText(x, y, width, height, text, r, g, b, a)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(height, width)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
