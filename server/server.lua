ESX = nil

ESX = exports["es_extended"]:getSharedObject()

local teleportpoint = {}

RegisterNetEvent('popo_teleport:register_tp_point')
AddEventHandler('popo_teleport:register_tp_point', function(coord)
    local _src = source
    TriggerClientEvent("popo_teleport:newtppoint", -1, coord)
    MySQL.Async.execute('INSERT INTO teleport (name, coord) VALUES (@name, @coord)', {
        ['@name'] = coord.teleport_name,
        ['@coord'] = json.encode(coord)
    })
    table.insert(teleportpoint, coord)
end)

RegisterNetEvent('popo_teleport:remove_tp_point')
AddEventHandler('popo_teleport:remove_tp_point', function(data)
    local _src = source
    MySQL.Async.execute('DELETE FROM teleport WHERE name = @name', {
        ['@name'] = data.teleport_name,
    })
end)


RegisterNetEvent("popo_teleport:requestZones", function()
    local _src = source
    TriggerClientEvent("popo_teleport:nbpoint", _src, teleportpoint)
end)

CreateThread(function()
    MySQL.Async.fetchAll("SELECT * FROM teleport", {}, function(result)
        for i, row in pairs(result) do
            local data = json.decode(row.coord)
            data.teleport_name = row.name
            data.first_coord = vector3(data.first_coord.x, data.first_coord.y, data.first_coord.z)
            data.second_coord = vector3(data.second_coord.x, data.second_coord.y, data.second_coord.z)
            table.insert(teleportpoint, data)
        end
    end)
end)