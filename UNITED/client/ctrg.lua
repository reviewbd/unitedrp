local pnjs = {}
local model = `csb_vagspeak`

local function spawnPNJ(data)
RequestModel(model)
while not HasModelLoaded(model) do
Wait(10)
end

local ped = CreatePed(4, model, data.x, data.y, data.z - 1.0, data.h, false, true)
SetEntityInvincible(ped, true)
FreezeEntityPosition(ped, true)
SetBlockingOfNonTemporaryEvents(ped, true)
return ped
end

RegisterNetEvent("ctrg:spawnPNJ", function(data)
local ped = spawnPNJ(data)
table.insert(pnjs, { data = data, ped = ped })
end)

RegisterNetEvent("ctrg:deletePNJ", function(data)
for i, p in ipairs(pnjs) do
if math.abs(p.data.x - data.x) < 0.1 and math.abs(p.data.y - data.y) < 0.1 then
if DoesEntityExist(p.ped) then
DeleteEntity(p.ped)
end
table.remove(pnjs, i)
break
end
end
end)

CreateThread(function()
while true do
Wait(2000)
for i, p in ipairs(pnjs) do
if not DoesEntityExist(p.ped) then
p.ped = spawnPNJ(p.data)
end
end
end
end)

CreateThread(function()
    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        for _, p in ipairs(pnjs) do
            if DoesEntityExist(p.ped) then
                local coords = GetEntityCoords(p.ped)
                local dist = #(playerCoords - coords)
                if dist < 10.0 then
                    DrawText3D(coords.x, coords.y, coords.z + 1.0, p.data.label)
                end
            end
        end
    end
end)


function DrawText3D(x, y, z, text)
SetDrawOrigin(x, y, z, 0)
SetTextFont(0)
SetTextProportional(1)
SetTextScale(0.35, 0.35)
SetTextColour(255, 255, 255, 215)
SetTextCentre(1)
BeginTextCommandDisplayText("STRING")
AddTextComponentSubstringPlayerName(text)
EndTextCommandDisplayText(0.0, 0.0)
ClearDrawOrigin()
end
