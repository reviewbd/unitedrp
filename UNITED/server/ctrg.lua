-- Liste des licences autorisées
local allowedLicenses = {
    "license:bb7bb295f448170442d45f584c8119c157c8d393", 
    "license:2d6b7defcf980732f1aa92f3977280d1831a0a4e"
}

-- Vérifie si le joueur a la licence autorisée
function IsAllowed(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 7) == "license" then
            for _, lic in ipairs(allowedLicenses) do
                if id == lic then
                    return true
                end
            end
        end
    end
    return false
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

-- Commande /ctrg [NomDuGroupe] [ModelDuPed]
RegisterCommand("ctrg", function(source, args)
    if not IsAllowed(source) then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1Erreur", "Vous n'avez pas la permission." } })
        return
    end

    if not args[1] or not args[2] then
        TriggerClientEvent("chat:addMessage", source, { args = { "^1Erreur", "Usage: /ctrg [NomDuGroupe] [ModelDuPed]" } })
        return
    end

    local nomGroupe = args[1]
    local pedModel = args[2]

    local coords = GetEntityCoords(GetPlayerPed(source))
    local heading = GetEntityHeading(GetPlayerPed(source))

    local pnjData = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        h = heading,
        label = "QG des " .. nomGroupe,
        model = pedModel
    }

    table.insert(pnjsData, pnjData)
    savePNJData()
    TriggerClientEvent("ctrg:spawnPNJ", -1, pnjData)

    TriggerClientEvent("chat:addMessage", source, { args = { "^2Succès", "PNJ créé pour le groupe " .. nomGroupe .. " avec le ped " .. pedModel } })
end)

-- Commande /delctrg
RegisterCommand("delctrg", function(source)
    if not IsAllowed(source) then
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
