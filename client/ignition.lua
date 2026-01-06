-- MANUAL IGNITION SYSTEM

local engineRunning = {}

local function GetVehicleClass(vehicle)
    local class = GetVehicleClass(vehicle)
    
    if class == 0 then return 'compact'
    elseif class == 1 then return 'sedan'
    elseif class == 2 then return 'suv'
    elseif class == 3 then return 'coupe'
    elseif class == 8 then return 'motorcycle'
    elseif class == 14 then return 'truck'
    elseif class == 20 then return 'offroad'
    elseif class == 15 then return 'helicopter'
    end
    
    return 'sedan'
end

-- Engine start sequence
local function StartEngine(vehicle)
    if not Config.Ignition.enabled then
        SetVehicleEngineHealth(vehicle, 1000)
        StartVehicleEngine(vehicle)
        return
    end
    
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if engineRunning[netId] then return end
    
    local class = GetVehicleClass(vehicle)
    local startTime = Config.Ignition.startTimes[class] or 1200
    
    -- Adjust by engine temperature
    local engineHealth = GetVehicleEngineHealth(vehicle)
    if engineHealth < 500 then
        startTime = startTime * Config.Ignition.tempMultiplier
    end
    
    -- Start animation
    TriggerEvent('realdrive:notifyIgnition', 'Starting engine...')
    
    -- Wait for engine to start
    Wait(startTime)
    
    -- Actually start engine
    StartVehicleEngine(vehicle)
    engineRunning[netId] = true
    
    TriggerEvent('realdrive:notifyIgnition', 'Engine started!')
end

-- Engine stop sequence
local function StopEngine(vehicle)
    if not Config.Ignition.enabled then
        SmashVehicleWindow(vehicle, 0)
        StopVehicleEngine(vehicle)
        return
    end
    
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    engineRunning[netId] = false
    
    StopVehicleEngine(vehicle)
    TriggerEvent('realdrive:notifyIgnition', 'Engine stopped!')
end

-- Key binding for ignition
CreateThread(function()
    while true do
        Wait(0)
        
        if not Config.Ignition.enabled then break end
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle and vehicle ~= 0 then
            if IsControlJustPressed(0, Config.Ignition.key) then
                if GetIsVehicleEngineRunning(vehicle) then
                    StopEngine(vehicle)
                else
                    StartEngine(vehicle)
                end
            end
        end
    end
end)

-- Helicopter rotor spin-up
CreateThread(function()
    while true do
        Wait(100)
        
        if not Config.Ignition.enabled then goto continue end
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle and vehicle ~= 0 then
            local model = GetEntityModel(vehicle)
            
            -- Check if helicopter
            if IsThisModelAHeli(model) then
                if GetIsVehicleEngineRunning(vehicle) then
                    -- Spin up rotor
                    SmashVehicleWindow(vehicle, 0)
                end
            end
        end
        
        ::continue::
    end
end)

-- Notifications
RegisterNetEvent('realdrive:notifyIgnition', function(message)
    if Config.Settings.notificationType == 'chat' then
        print('^3[Ignition]^7 ' .. message)
    end
end)

-- Exports
exports('StartEngine', StartEngine)
exports('StopEngine', StopEngine)
