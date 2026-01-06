-- TERRAIN SYSTEM - Surface detection and handling

local function GetGroundMaterial(x, y, z)
    local groundHash = GetGroundZoneAtCoords(x, y, z)
    
    -- Map game material hashes to terrain types
    local terrainMap = {
        [0x696BAD58] = 'asphalt',
        [0xA8435FEC] = 'grass',
        [0xC1F5EBEA] = 'sand',
        [0x2E10B1C5] = 'mud',
        [0x1FA85B89] = 'snow',
        [0x8F0490DB] = 'gravel',
        [0x47932A79] = 'rock'
    }
    
    return terrainMap[groundHash] or 'asphalt'
end

-- Check if vehicle is suitable for terrain
local function IsVehicleSuitableForTerrain(vehicle, terrain)
    local tireType = exports['realdrive']:GetTireType(vehicle)
    
    -- Sport/tuner tires perform poorly off-road
    if (terrain == 'grass' or terrain == 'mud' or terrain == 'sand' or terrain == 'snow') then
        if tireType == 'sport' or tireType == 'tuner' then
            return false
        end
    end
    
    -- Road tires on road surfaces
    if terrain == 'asphalt' then
        if tireType == 'offroad' or tireType == 'suv' then
            return true  -- Still good, just less optimal
        end
    end
    
    return true
end

-- Get traction modifier for current terrain
local function GetTerrainTractionModifier(vehicle)
    local coords = GetEntityCoords(vehicle)
    local tireType = exports['realdrive']:GetTireType(vehicle)
    local surface = GetGroundMaterial(coords.x, coords.y, coords.z)
    
    if not Config.Terrain.tireTypes[tireType] then
        tireType = 'sport'
    end
    
    local modifiers = Config.Terrain.tireTypes[tireType][surface] or {
        speed = 1.0,
        steering = 1.0,
        braking = 1.0
    }
    
    return modifiers
end

-- Apply dynamic handling based on terrain
CreateThread(function()
    while true do
        Wait(500)
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        if vehicle and vehicle ~= 0 then
            local speed = #GetEntityVelocity(vehicle) * 3.6
            local modifiers = GetTerrainTractionModifier(vehicle)
            
            -- Lose traction on unsuitable terrain at high speed
            if not IsVehicleSuitableForTerrain(vehicle, exports['realdrive']:GetSurfaceType(vehicle)) then
                if speed > 80 then
                    -- Apply random traction loss
                    if math.random() < 0.1 then
                        local force = vector3(
                            math.random(-100, 100) / 100,
                            math.random(-100, 100) / 100,
                            0
                        )
                        ApplyForceToEntity(vehicle, 1, force.x, force.y, force.z, 0, 0, 0, 0, true, true, true, false)
                    end
                end
            end
            
            -- Mountain climbing detection
            local velocity = GetEntityVelocity(vehicle)
            if velocity.z > 1.5 then
                -- Climbing - reduce speed
                if modifiers.speed < 0.8 then
                    ApplyForceToEntity(vehicle, 1, 0, 0, -1.5, 0, 0, 0, 0, true, true, true, false)
                end
            end
        end
    end
end)

-- Export functions
exports('GetGroundMaterial', GetGroundMaterial)
exports('IsVehicleSuitableForTerrain', IsVehicleSuitableForTerrain)
exports('GetTerrainTractionModifier', GetTerrainTractionModifier)
