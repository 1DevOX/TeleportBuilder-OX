ESX = nil
local teleportpoint = {}
local name = nil
local name_suppr = nil
local first_place = nil
local second_place = nil
local builder = {
    teleport_name = nil,
    first_coord = nil,
    second_coord = nil
}
local nb1 = 0
local nb2 = 0

ESX = exports["es_extended"]:getSharedObject()

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, "", inputText, "", "", "", maxLength)
	blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
		blockinput = false
        return result
    else
        Citizen.Wait(500)
		blockinput = false
        return nil
    end
end

local function teleport()
    while true do
        local interval = 500
        local pos = GetEntityCoords(PlayerPedId())
        for i, teleportpoints in pairs(teleportpoint) do
            local a = teleportpoints.first_coord
            local b = teleportpoints.second_coord
            
            --POINT A--
            local dist = #(pos - a)
                if (dist <= 15) then
                    interval = 0
                    DrawMarker(25, a.x, a.y, (a.z - 0.98), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, false, true, 2, false, false, false, false)
                    if (dist <= 1) then
                        AddTextEntry("try", (k.textopen))
                        DisplayHelpTextThisFrame("try", false)
                        if (IsControlJustPressed(0, 51)) then
                            SetEntityCoords(PlayerPedId(), b)
                        end
                    end
                end
    
            --POINT B--
            dist = #(pos - b)
                if (dist <= 15) then
                    interval = 0
                    DrawMarker(25, b.x, b.y, (b.z - 0.98), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 255, 255, false, true, 2, false, false, false, false)
                    if (dist <= 1) then
                        AddTextEntry("tryb", (k.textexit))
                        DisplayHelpTextThisFrame("tryb", false)
                        if (IsControlJustPressed(0, 51)) then
                            SetEntityCoords(PlayerPedId(), a)
                        end
                    end
                end
        end
        Wait(interval)
    end
end

--open the menu in RageUI--

local function openMenu()
    lib.registerContext({
        id = 'teleport_menu',
        title = 'Teleport Builder',
        options = {
            {
                title = 'Nom',
                description = 'Définis le nom du téléporteur.',
                icon = 'clipboard',
                onSelect = function()
                    local input = lib.inputDialog('Builder', {{ type = 'input', label = 'Nom', description = 'Entre le nom du point de téléportation.', required = true}})
                    name = input[1]
                    if name and name ~= "" then
                        builder.teleport_name = tostring(name)
                        builder.teleport_name = string.lower(string.gsub(builder.teleport_name, "%s+", "_"))
                        print(builder.teleport_name)
                        lib.showContext('teleport_menu')
                    end
                end,
              },
              {
                title = 'Point 1',
                icon = 'location-dot',
                description = 'Coordonnées du premier point.',
                onSelect = function()
                    local Ped = PlayerPedId()
                    local pedCoords = GetEntityCoords(Ped)
                    builder.first_coord = pedCoords
                    print(builder.first_coord)
                    nb1 = 1
                    lib.notify({  
                        title = 'Teleport Builder',
                        icon = 'location-dot',
                        description = 'Position : '..pedCoords,
                        position = 'top',
                        duration = 5000,
                        style = {
                          backgroundColor = '#141517',
                          color = '#FFFFFF',
                          ['.description'] = {
                            color = '#909296'
                          },
                        },
                    })
                end,
              },
              {
                title = 'Point 2',
                icon = 'location-dot',
                description = 'Coordonnées du second point.',
                onSelect = function()
                    local Ped = PlayerPedId()
                    local pedCoords = GetEntityCoords(Ped)
                    builder.second_coord = pedCoords
                    print(builder.second_coord)
                    nb2 = 2
                    lib.notify({  
                        title = 'Teleport Builder',
                        icon = 'location-dot',
                        description = 'Position : '..pedCoords,
                        position = 'top',
                        duration = 5000,
                        style = {
                          backgroundColor = '#141517',
                          color = '#FFFFFF',
                          ['.description'] = {
                            color = '#909296'
                          },
                        },
                    })
                    lib.showContext('teleport_menu')
                end,
              },
              {
                title = 'Ajouter',
                description = 'Ajoute le téléporteur.',
                icon = 'plus',
                onSelect = function()
                    if nb1 == 1 and nb2 == 2 then
                        TriggerServerEvent('popo_teleport:register_tp_point', builder)
                        lib.notify({  
                            title = 'Teleport Builder',
                            icon = 'location-dot',
                            description = name..' a bien été crée !',
                            position = 'top',
                            duration = 5000,
                            style = {
                              backgroundColor = '#141517',
                              color = '#FFFFFF',
                              ['.description'] = {
                                color = '#909296'
                              },
                            },
                            type = 'success',
                        })
                        name = nil
                        builder.teleport_name = nil
                        builder.first_coord = nil
                        builder.second_coord = nil
                        nb1 = 0
                        nb2 = 0      
                    else
                        lib.notify({  
                            title = 'Teleport Builder',
                            icon = 'location-dot',
                            description = 'Tu n\'as pas mis les deux points !',
                            position = 'top',
                            duration = 5000,
                            style = {
                              backgroundColor = '#141517',
                              color = '#FFFFFF',
                              ['.description'] = {
                                color = '#909296'
                              },
                            },
                            type = 'error',
                          })
                    end
                end,
              },
              {
                title = ' ',
                progress = '100',
              },
              {
                title = 'Gestion',
                description = 'Gestion des téléporteurs.',
                icon = 'gear',
                menu = 'gestion_sub',
              },
        }
    })     
    lib.showContext('teleport_menu')
end

lib.registerContext({
    id = 'gestion_sub',
    title = 'Gestion',
    menu = 'teleport_menu',
    options = {
      {
        title = 'Nom',
        icon = 'signature',
        description = 'Insert le nom du téléporteur que tu souhaite supprimer.',
        onSelect = function()
            local input = lib.inputDialog('Gestion', {{ type = 'input', label = 'Nom', description = 'Entre le nom du point de téléportation que tu souhaite supprimer.', required = true}})
            name_suppr = input[1]
            name_suppr = tostring(name_suppr)
            name_suppr = string.lower(string.gsub(name_suppr, "%s+", "_"))
            lib.showContext('gestion_sub')
        end,
      },
      {
        title = 'Supprimer',
        icon = 'trash',
        description = 'Nécéssite un reboot.',
        onSelect = function()
            if name_suppr and name_suppr ~= "" then
                for i, points in pairs(teleportpoint) do
                    if points.teleport_name and name_suppr == points.teleport_name then
                        lib.notify({  
                            title = 'Teleport Builder',
                            icon = 'location-dot',
                            description = points.teleport_name..' attend un reboot avant d\'être supprimé !',
                            position = 'top',
                            duration = 5000,
                            style = {
                              backgroundColor = '#141517',
                              color = '#FFFFFF',
                              ['.description'] = {
                                color = '#909296'
                              },
                            },
                            type = 'success',
                        })
                        TriggerServerEvent('popo_teleport:remove_tp_point', points)
                    end
                end
            else
                lib.notify({  
                    title = 'Teleport Builder',
                    icon = 'location-dot',
                    description = 'Tu n\'as pas entré un nom de téléporteur !',
                    position = 'top',
                    duration = 5000,
                    style = {
                      backgroundColor = '#141517',
                      color = '#FFFFFF',
                      ['.description'] = {
                        color = '#909296'
                      },
                    },
                    type = 'error',
                })
            end
        end,
      },
    }
})

RegisterNetEvent("popo_teleport:newtppoint", function(zone)
    table.insert(teleportpoint, zone)
end)

RegisterNetEvent("popo_teleport:nbpoint", function(zones)
    teleportpoint = zones
    teleport()
end)

RegisterCommand("teleportbuilder", function()
    openMenu()
end, false)

SetTimeout(1500, function()
    xPlayer = ESX.GetPlayerData()
    TriggerServerEvent("popo_teleport:requestZones")
end)