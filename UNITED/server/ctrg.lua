function IsAdmin(source)
    return exports["eko"]:isIGM(source)
end


local pnjsFile = "pnjs.json"
local pnjsData = {}


CreateThread(function()
    local file = LoadResourceFile(GetCurrentResourceName(), pnjsFile)
    if file then
        pnjsData = json.decode(file) or {}
    end
end)

local function savePNJData()
    SaveResourceFile(GetCurrentResourceName(), pnjsFile, json.encode(pnjsData, { indent = true }), -1)
end

AddEventHandler("playerJoining", function()
    local src = source
    for _, pnj in ipairs(pnjsData) do
        TriggerClientEvent("ctrg:spawnPNJ", src, pnj)
    end
end)

RegisterCommand("ctrg", function(source, args)
    if not IsAdmin(source) then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1Erreur", "Vous n'avez pas la permission." } })
        return
    end

    if not args[1] then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1Erreur", "Usage: /ctrg [NomDuGroupe]" } })
        return
    end

    local nomGroupe = table.concat(args, " ")
    local coords = GetEntityCoords(GetPlayerPed(source))
    local heading = GetEntityHeading(GetPlayerPed(source))

    local pnjData = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        h = heading,
        label = "QG des " .. nomGroupe
    }

    table.insert(pnjsData, pnjData)
    savePNJData()
    TriggerClientEvent("ctrg:spawnPNJ", -1, pnjData)

    TriggerClientEvent("chat:addMessage", source, { args = { "^2Succès", "PNJ créé pour le groupe " .. nomGroupe } })
end)

RegisterCommand("delctrg", function(source)
    if not IsAdmin(source) then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1Erreur", "Vous n'avez pas la permission." } })
        return
    end

    local pedCoords = GetEntityCoords(GetPlayerPed(source))
    local closestIndex, closestDist

    for i, pnj in ipairs(pnjsData) do
        local dist = #(vector3(pnj.x, pnj.y, pnj.z) - pedCoords)
        if not closestDist or dist < closestDist then
            closestDist = dist
            closestIndex = i
        end
    end

    if closestIndex and closestDist < 5.0 then
        local removedPNJ = pnjsData[closestIndex]
        table.remove(pnjsData, closestIndex)
        savePNJData()
        TriggerClientEvent("ctrg:deletePNJ", -1, removedPNJ)
        TriggerClientEvent("chat:addMessage", source, { args = { "^2Succès", "PNJ supprimé." } })
    else
        TriggerClientEvent("chat:addMessage", source, { args = { "^1Erreur", "Aucun PNJ proche à supprimer." } })
    end
end)
