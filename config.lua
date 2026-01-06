Config = {}

-- TERRAIN TRACTION SYSTEM
Config.Terrain = {
    -- Surface type detection (material hashes)
    surfaces = {
        asphalt = {hash = 0x696BAD58, name = 'Asphalt'},
        grass = {hash = 0xA8435FEC, name = 'Grass'},
        sand = {hash = 0xC1F5EBEA, name = 'Sand'},
        mud = {hash = 0x2E10B1C5, name = 'Mud'},
        snow = {hash = 0x1FA85B89, name = 'Snow'},
        gravel = {hash = 0x8F0490DB, name = 'Gravel'},
        rock = {hash = 0x47932A79, name = 'Rock'}
    },
    
    -- Tire type performance modifiers
    tireTypes = {
        sport = {
            asphalt = {speed = 1.0, steering = 1.0, braking = 1.0},
            grass = {speed = 0.5, steering = 0.5, braking = 0.7},
            sand = {speed = 0.6, steering = 0.7, braking = 0.8},
            mud = {speed = 0.3, steering = 0.4, braking = 0.5},
            snow = {speed = 0.4, steering = 0.5, braking = 0.6},
            gravel = {speed = 0.7, steering = 0.8, braking = 0.8}
        },
        offroad = {
            asphalt = {speed = 0.6, steering = 0.9, braking = 0.9},
            grass = {speed = 0.85, steering = 0.8, braking = 0.8},
            sand = {speed = 0.8, steering = 0.8, braking = 0.85},
            mud = {speed = 0.9, steering = 0.85, braking = 0.85},
            snow = {speed = 0.88, steering = 0.8, braking = 0.8},
            gravel = {speed = 0.95, steering = 0.9, braking = 0.9}
        },
        suv = {
            asphalt = {speed = 0.95, steering = 1.0, braking = 1.0},
            grass = {speed = 0.85, steering = 0.8, braking = 0.8},
            sand = {speed = 0.75, steering = 0.75, braking = 0.75},
            mud = {speed = 0.8, steering = 0.75, braking = 0.75},
            snow = {speed = 0.85, steering = 0.85, braking = 0.8},
            gravel = {speed = 0.9, steering = 0.9, braking = 0.9}
        },
        tuner = {
            asphalt = {speed = 1.0, steering = 1.0, braking = 1.0},
            grass = {speed = 0.1, steering = 0.1, braking = 0.6},
            sand = {speed = 0.1, steering = 0.1, braking = 0.7},
            mud = {speed = 0.2, steering = 0.2, braking = 0.5},
            snow = {speed = 0.3, steering = 0.3, braking = 0.5},
            gravel = {speed = 0.4, steering = 0.4, braking = 0.6}
        }
    }
}

-- TIRE DAMAGE SYSTEM
Config.TireDamage = {
    enabled = true,
    -- Damage speed thresholds (km/h)
    speedThresholds = {
        offroad = 120,
        normal = 100,
        agile = 80
    },
    -- Damage multiplier per km/h over threshold
    damageMultiplier = 0.15,
    -- Tire burst chance (0-1)
    burstChance = 0.3,
    -- Mountain climb detection
    mountainHeight = 50,
    wheelLossChance = 0.4
}

-- MANUAL IGNITION SYSTEM
Config.Ignition = {
    enabled = true,
    -- Engine start time by vehicle class (ms)
    startTimes = {
        compact = 800,
        sedan = 1200,
        suv = 1500,
        coupe = 900,
        motorcycle = 500,
        truck = 2000,
        offroad = 1800,
        helicopter = 3000
    },
    -- Engine temperature effects
    tempMultiplier = 1.2,
    -- Keybind for manual ignition (default: E)
    key = 38
}

-- AUTOPILOT SYSTEM
Config.Autopilot = {
    enabled = true,
    -- Keybind to toggle autopilot (default: G)
    toggleKey = 47,
    -- Maximum autopilot speed (km/h)
    maxSpeed = 120,
    -- Distance to waypoint before auto-stopping (meters)
    stopDistance = 10,
    -- Follow traffic rules
    followTrafficRules = true,
    -- Sound notifications
    soundNotifications = true
}

-- OFF-ROAD DAMAGE
Config.OffRoadDamage = {
    enabled = true,
    -- Damage when driving off-road with unsuitable tires
    damagePerSecond = 2.0,
    -- Speed multiplier for off-road areas
    maxOffRoadSpeed = 80,
    -- Weather impacts
    rainDamageMultiplier = 1.5,
    snowDamageMultiplier = 1.8
}

-- GENERAL SETTINGS
Config.Settings = {
    -- Enable all systems
    allSystemsEnabled = true,
    -- Debug mode
    debugMode = false,
    -- Notification type: 'chat', 'tnotify', 'native'
    notificationType = 'chat',
    -- Update frequency (ms)
    updateInterval = 500
}
