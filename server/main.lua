local function inventoryId(src)local p=exports.szcore:GetPlayer(src);return p and ('player:'..p.PlayerData.citizenid) or nil end
local allowed={repairkit=true,advancedrepairkit=true,tirekit=true,cleaningkit=true}
for item in pairs(allowed) do
    exports.szcore_inventory:RegisterUsableItem(item,function(src,entry,slot)
        TriggerClientEvent('szcore_vehiclefailure:repair',src,item,slot);return true
    end)
end
RegisterNetEvent('szcore_vehiclefailure:consume',function(item,slot,netId)
    local src=source;if not allowed[item] then return end
    local ped=GetPlayerPed(src);if ped==0 then return end
    local veh=NetworkGetEntityFromNetworkId(tonumber(netId) or 0);if veh==0 or not DoesEntityExist(veh) then return end
    if #(GetEntityCoords(ped)-GetEntityCoords(veh))>6.0 then return end
    local inv=exports.szcore_inventory:GetPlayerInventory(src);local entry=inv and inv.items and inv.items[tonumber(slot)]
    if not entry or entry.name~=item then return end
    local id=inventoryId(src);if not id or not exports.szcore_inventory:RemoveItemBySlot(id,tonumber(slot),1) then return end
    if item=='cleaningkit' then TriggerClientEvent('szcore_vehiclefailure:syncClean',-1,tonumber(netId)) end
end)
RegisterCommand('fixveh',function(src)if src==0 or IsPlayerAceAllowed(src,'szcore.admin') then TriggerClientEvent('szcore_vehiclefailure:adminFix',src) end end,false)
