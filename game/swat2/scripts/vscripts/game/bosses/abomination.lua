-- Stores information relating to abominations and generic boss spawning information

Abomination = {}


function Abomination:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

-- Generic boss function that will be called to see if we should spawn this boss
-- Should return a boolean of True to spawn it
function Abomination:rollToSpawn()
    -- Aboms always succeed
    return true
end

-- Generic boss function for actually spawning the boss
-- Returns the created boss unit
function Abomination:spawnBoss()
    print("Abomination | Spawning abomination")
    g_EnemySpawner.abomsCurrentlyAlive = g_EnemySpawner.abomsCurrentlyAlive + 1

    local warehouse = GetRandomWarehouse()
    local boss = CreateUnitByName( "npc_dota_creature_basic_abomination", GetCenterInRegion(warehouse), true, nil, nil, DOTA_TEAM_BADGUYS )

    -- TODO: Add more abilities and abomination types
    boss:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(boss, 0))

    -- Spawn a group of enemies to go with the boss
    self:spawnAbomMinionGroup(warehouse)

    -- Tell the boss where to go
    -- Issueing an order to a unit immediately after it spawns seems to not consistently work
    -- so we'll wait a second before telling the group where to go
    Timers:CreateTimer(1.0, function()
        g_EnemyCommander:doMobAction(boss, nil)
    end)

    -- TODO - Fix boss display message
    Notifications:TopToAll({text="Satellite recon just spotted a freakishly large creature!", duration=8, style={color="yellow"}})

    return boss
end

-- Abomination spawns with a few units of his own
function Abomination:spawnAbomMinionGroup(warehouse)
    local numberOfMinions = RandomInt(1, math.max(Round(g_EnemyUpgrades.minionUber / 10.0), 1))
    local warehouseCenter = warehouse:GetAbsOrigin()
    local spawnedUnits = {}
    for i = 1, numberOfMinions do
        local j = RandomInt(0, 9)
        local position = warehouseCenter + RandomVector(270)
        if j < 1 then
            table.insert(spawnedUnits, g_EnemySpawner:spawnEnemy(EnemySpawner.ENEMY_CODE_BEAST, position, 0, true))
        elseif j < 2 then
            table.insert(spawnedUnits, g_EnemySpawner:spawnEnemy(EnemySpawner.ENEMY_CODE_GROTESQUE, position, 0, true))
        elseif j < 4 then
            table.insert(spawnedUnits, g_EnemySpawner:spawnEnemy(EnemySpawner.ENEMY_CODE_DOG, position, 0, true))
        else
            table.insert(spawnedUnits, g_EnemySpawner:spawnEnemy(EnemySpawner.ENEMY_CODE_ZOMBIE, position, 0, true))
        end
    end

    -- Tell the group where to go
    -- Issueing an order to a unit immediately after it spawns seems to not consistently work
    -- so we'll wait a second before telling the group where to go
    Timers:CreateTimer(1.0, function()
        for _,unit in pairs(spawnedUnits) do
            g_EnemyCommander:doMobAction(unit, nil)
        end
    end)

end
