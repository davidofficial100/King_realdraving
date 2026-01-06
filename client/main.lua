-- REAL DRIVING SYSTEM - MAIN CLIENT

local playerData = {
    currentVehicle = nil,
    isEngineRunning = false,
    tireWearStates = {},
    engineTemp = 20,
    autopilotActive = false,
    waypointSet = false
}

-- Notify function
local function Notify(title, message, type)
    if Config.Settings.notificationType == 'chat' then
        print('^2[' .. title .. ']^7 ' .. message)
    end
end

-- Get current vehicle
local function GetPlayerVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end
    return nil
end

-- Get tire type from vehicle
local function GetTireType(vehicle)
    local wheelType = GetVehicleWheelType(vehicle)
    
    if wheelType == 0 then return 'sport'
    elseif wheelType == 1 then return 'muscle'
    elseif wheelType == 2 then return 'lowrider'
    elseif wheelType == 3 then return 'suv'
    elseif wheelType == 4 then return 'offroad'
    elseif wheelType == 5 then return 'tuner'
    elseif wheelType == 6 then return 'motorcycle'
    elseif wheelType == 7 then return 'highend'
    end
    
    return 'sport'
end

-- Get surface type under vehicle
local function GetSurfaceType(vehicle)
    local coords = GetEntityCoords(vehicle)
    local surfaceHash = GetGroundZoneAtCoords(coords.x, coords.y, coords.z)
    
    for surfaceName, surfaceData in pairs(Config.Terrain.surfaces) do
        if surfaceData.hash == surfaceHash then
            return surfaceName
        end
    end
    
    return 'asphalt'
end

-- Apply terrain traction modifiers
local function ApplyTerrainModifiers(vehicle)
    local tireType = GetTireType(vehicle)
    local surface = GetSurfaceType(vehicle)
    
    if not Config.Terrain.tireTypes[tireType] then
        tireType = 'sport'
    end
    
    local modifiers = Config.Terrain.tireTypes[tireType][surface] or Config.Terrain.tireTypes[tireType].asphalt
    
    -- Apply handling modifiers
    if modifiers.speed then
        SetVehicleEnginePowerMultiplier(vehicle, modifiers.speed)
    end
    if modifiers.steering then
        -- Adjust steering sensitivity
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSteeringLock", GetVehicleHandlingFloat(vehicle, "CHandlingData", "fSteeringLock") * modifiers.steering)
    end
    if modifiers.braking then
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", GetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce") * modifiers.braking)
    end
end

-- Main loop
CreateThread(function()
    while true do
        Wait(Config.Settings.updateInterval)
        
        if not Config.Settings.allSystemsEnabled then goto continue end
        
        local vehicle = GetPlayerVehicle()
        
        if vehicle and vehicle ~= 0 then
            playerData.currentVehicle = vehicle
            
            -- Apply terrain modifiers
            ApplyTerrainModifiers(vehicle)
            
            -- Check tire damage
            if Config.TireDamage.enabled then
                TriggerEvent('realdrive:checkTireDamage', vehicle)
            end
            
            -- Check off-road damage
            if Config.OffRoadDamage.enabled then
                TriggerEvent('realdrive:checkOffRoadDamage', vehicle)
            end
            
        else
            playerData.currentVehicle = nil
        end
        
        ::continue::
    end
end)

-- Print debug info
if Config.Settings.debugMode then
    CreateThread(function()
        while true do
            Wait(1000)
            local vehicle = GetPlayerVehicle()
            if vehicle and vehicle ~= 0 then
                local tireType = GetTireType(vehicle)
                local surface = GetSurfaceType(vehicle)
                print('^3[DEBUG]^7 Tire: ' .. tireType .. ' | Surface: ' .. surface)
            end
        end
    end)
end

-- Export functions
exports('GetPlayerVehicle', GetPlayerVehicle)
exports('GetTireType', GetTireType)
exports('GetSurfaceType', GetSurfaceType)
