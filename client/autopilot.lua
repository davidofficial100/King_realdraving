-- AUTOPILOT SYSTEM

local autopilotActive = false
local waypointCoords = nil
local drivingState = {
    speed = 0,
    heading = 0
}

-- Notify player
local function NotifyAutopilot(message)
    if Config.Autopilot.soundNotifications then
        PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
    end
    
    if Config.Settings.notificationType == 'chat' then
        print('^2[Autopilot]^7 ' .. message)
    end
end

-- Toggle autopilot
local function ToggleAutopilot()
    if not Config.Autopilot.enabled then
        NotifyAutopilot('Autopilot is disabled in config')
        return
    end
    
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if not vehicle or vehicle == 0 then
        NotifyAutopilot('You must be in a vehicle')
        return
    end
    
    -- Check if waypoint is set
    if not GetIsWaypointActive() then
        NotifyAutopilot('Please set a waypoint on GPS first')
        return
    end
    
    autopilotActive = not autopilotActive
    
    if autopilotActive then
        local waypointBlip = GetFirstBlipInfoId(8)
        waypointCoords = GetBlipCoords(waypointBlip)
        NotifyAutopilot('Autopilot enabled - Heading to waypoint')
        TriggerEvent('realdrive:autopilotLoop', vehicle)
    else
        waypointCoords = nil
        NotifyAutopilot('Autopilot disabled')
        TaskLeaveAnyVehicle(ped, vehicle, 0)
    end
end

-- Main autopilot driving loop
RegisterNetEvent('realdrive:autopilotLoop', function(vehicle)
    while autopilotActive and vehicle and DoesEntityExist(vehicle) do
        Wait(100)
        
        local ped = PlayerPedId()
        local vehicleCoords = GetEntityCoords(vehicle)
        
        if not waypointCoords then
            autopilotActive = false
            break
        end
        
        -- Distance to waypoint
        local distance = #(vehicleCoords - waypointCoords)
        
        -- Stop at waypoint
        if distance < Config.Autopilot.stopDistance then
            autopilotActive = false
            NotifyAutopilot('Destination reached')
            
            -- Stop vehicle
            TaskVehicleTempAction(ped, vehicle, 26, 3000)
            break
        end
        
        -- Calculate direction to waypoint
        local direction = waypointCoords - vehicleCoords
        direction = #direction > 0 and direction / #direction or vector3(0, 0, 0)
        
        -- Get current vehicle heading
        local currentHeading = GetEntityHeading(vehicle)
        local targetHeading = math.atan2(direction.y, direction.x) * 180 / math.pi
        targetHeading = (targetHeading + 90) % 360
        
        -- Calculate heading difference
        local headingDiff = targetHeading - currentHeading
        if headingDiff > 180 then
            headingDiff = headingDiff - 360
        elseif headingDiff < -180 then
            headingDiff = headingDiff + 360
        end
        
        -- Steer towards waypoint
        local steering = math.min(1.0, math.max(-1.0, headingDiff / 90.0))
        
        -- Control vehicle
        TaskVehicleDriveToCoord(ped, vehicle, waypointCoords.x, waypointCoords.y, waypointCoords.z, Config.Autopilot.maxSpeed / 3.6, 0, GetEntityModel(vehicle), 16, 0.0, true)
        
        -- Stop if traffic ahead (optional)
        if Config.Autopilot.followTrafficRules then
            local ahead = vehicleCoords + direction * 10.0
            local traffic = GetClosestVehicle(ahead.x, ahead.y, ahead.z, 5.0, 0, 70) -- 70 is all vehicles
            
            if traffic and traffic ~= 0 and traffic ~= vehicle then
                TaskVehicleTempAction(ped, vehicle, 26, 500)
            end
        end
    end
end)

-- Keybind for autopilot toggle
CreateThread(function()
    while true do
        Wait(0)
        
        if not Config.Autopilot.enabled then break end
        
        if IsControlJustPressed(0, Config.Autopilot.toggleKey) then
            ToggleAutopilot()
        end
    end
end)

-- Autopilot speed limiter
CreateThread(function()
    while true do
        Wait(100)
        
        if not autopilotActive then goto continue end
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle and vehicle ~= 0 then
            local speed = #GetEntityVelocity(vehicle) * 3.6
            
            if speed > Config.Autopilot.maxSpeed then
                ApplyForceToEntity(vehicle, 1, 0, 0, -2, 0, 0, 0, 0, true, true, true, false)
            end
        end
        
        ::continue::
    end
end)

-- Autopilot safety (dead man's switch)
CreateThread(function()
    while true do
        Wait(200)
        
        if not autopilotActive then goto continue end
        
        local ped = PlayerPedId()
        
        -- Check if player is still in vehicle
        if not GetVehiclePedIsIn(ped, false) then
            autopilotActive = false
            NotifyAutopilot('Autopilot disengaged - you left the vehicle')
        end
        
        -- Check if player is pressing any driving controls (override)
        if IsControlPressed(0, 71) or IsControlPressed(0, 72) or IsControlPressed(0, 76) or IsControlPressed(0, 77) then
            autopilotActive = false
            NotifyAutopilot('Autopilot disabled - manual control detected')
        end
        
        ::continue::
    end
end)

-- Export function
exports('ToggleAutopilot', ToggleAutopilot)
exports('IsAutopilotActive', function() return autopilotActive end)
