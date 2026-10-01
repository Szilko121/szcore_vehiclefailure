local C=SzCoreVehicleFailureConfig
local tracked=0
local last={engine=1000.0,body=1000.0,tank=1000.0}
local tyreClock=0
local active=false
local function notify(text,kind) exports.szcore_ui:Notify({description=text,type=kind or 'inform'}) end
local function driverVehicle()
    local ped=PlayerPedId();local veh=GetVehiclePedIsIn(ped,false)
    if veh==0 or GetPedInVehicleSeat(veh,-1)~=ped then return 0 end
    local class=GetVehicleClass(veh);if class==13 or class==15 or class==16 or class==21 then return 0 end
    return veh
end
local function resetVehicle(veh)
    tracked=veh;last.engine=GetVehicleEngineHealth(veh);last.body=GetVehicleBodyHealth(veh);last.tank=GetVehiclePetrolTankHealth(veh);tyreClock=0
end
local function burstRandomTyre(veh)
    if not GetVehicleTyresCanBurst(veh) then return false end
    local wheels=GetVehicleNumberOfWheels(veh);local pool
    if wheels==2 then pool={0,4} elseif wheels==4 then pool={0,1,4,5} elseif wheels==6 then pool={0,1,2,3,4,5} else pool={0} end
    local tyre=pool[math.random(1,#pool)];SetVehicleTyreBurst(veh,tyre,false,1000.0);return true
end
local function nearestVehicle(radius)
    local ped=PlayerPedId();if IsPedInAnyVehicle(ped,false) then return 0 end
    local p=GetEntityCoords(ped);local best=0;local dist=radius+0.01
    for _,veh in ipairs(GetGamePool('CVehicle')) do local d=#(GetEntityCoords(veh)-p);if d<dist then best=veh;dist=d end end
    return best
end
local function fixedTyres(veh) for i=0,7 do SetVehicleTyreFixed(veh,i) end end
RegisterNetEvent('szcore_vehiclefailure:repair',function(kind,slot)
    local veh=nearestVehicle(C.repair.repairDistance);if veh==0 then return notify('Nincs jármű elég közel.','error') end
    local duration=C.repair.basicDuration;local label='Jármű javítása...'
    if kind=='advancedrepairkit' then duration=C.repair.advancedDuration;label='Teljes javítás...'
    elseif kind=='tirekit' then duration=C.repair.tyreDuration;label='Kerék javítása...'
    elseif kind=='cleaningkit' then duration=C.repair.cleanDuration;label='Jármű tisztítása...' end
    TaskStartScenarioInPlace(PlayerPedId(),'WORLD_HUMAN_VEHICLE_MECHANIC',0,true)
    local ok=exports.szcore_ui:Progress({label=label,duration=duration})
    ClearPedTasks(PlayerPedId());if not ok then return end
    if kind=='advancedrepairkit' then SetVehicleFixed(veh);SetVehicleDeformationFixed(veh);fixedTyres(veh);SetVehicleEngineHealth(veh,1000.0);SetVehicleBodyHealth(veh,1000.0);SetVehiclePetrolTankHealth(veh,1000.0)
    elseif kind=='repairkit' then fixedTyres(veh);SetVehicleEngineHealth(veh,math.max(GetVehicleEngineHealth(veh),C.repair.basicEngineHealth));SetVehicleUndriveable(veh,false)
    elseif kind=='tirekit' then fixedTyres(veh)
    elseif kind=='cleaningkit' then SetVehicleDirtLevel(veh,0.0);WashDecalsFromVehicle(veh,1.0) end
    TriggerServerEvent('szcore_vehiclefailure:consume',kind,slot,NetworkGetNetworkIdFromEntity(veh))
end)
RegisterNetEvent('szcore_vehiclefailure:adminFix',function()
    local veh=driverVehicle();if veh==0 then veh=nearestVehicle(5.0) end;if veh==0 then return end
    SetVehicleFixed(veh);SetVehicleDeformationFixed(veh);fixedTyres(veh);SetVehicleEngineHealth(veh,1000.0);SetVehicleBodyHealth(veh,1000.0);SetVehiclePetrolTankHealth(veh,1000.0);SetVehicleUndriveable(veh,false)
end)
RegisterNetEvent('szcore_vehiclefailure:syncClean',function(netId)local veh=NetToVeh(netId);if veh~=0 then SetVehicleDirtLevel(veh,0.0);WashDecalsFromVehicle(veh,1.0) end end)
CreateThread(function()
    while true do
        local veh=driverVehicle()
        if veh==0 then tracked=0;active=false;Wait(650)
        else
            active=true;if tracked~=veh then resetVehicle(veh) end
            local class=GetVehicleClass(veh);local m=C.classMultiplier[class] or 1.0
            local e=GetVehicleEngineHealth(veh);local b=GetVehicleBodyHealth(veh);local t=GetVehiclePetrolTankHealth(veh)
            local de=math.max(0,last.engine-e);local db=math.max(0,last.body-b);local dt=math.max(0,last.tank-t)
            if de>0 then e=e-de*C.damage.engine*m end;if db>0 then b=b-db*C.damage.body*m end;if dt>0 then t=t-dt*C.damage.tank*m end
            local seconds=C.sampleMs/1000.0
            if e<C.damage.cascadingThreshold then e=e-C.damage.cascadePerSecond*seconds elseif e<C.damage.degradeThreshold then e=e-C.damage.degradePerSecond*seconds end
            if e<C.damage.safeGuard then e=C.damage.safeGuard end
            SetVehicleEngineHealth(veh,e);if b<last.body then SetVehicleBodyHealth(veh,math.max(0,b)) end;if t<last.tank then SetVehiclePetrolTankHealth(veh,math.max(100,t)) end
            if e<=C.damage.safeGuard+1 and not C.torque.limpMode then SetVehicleUndriveable(veh,true) else SetVehicleUndriveable(veh,false) end
            last.engine=e;last.body=GetVehicleBodyHealth(veh);last.tank=GetVehiclePetrolTankHealth(veh)
            if C.randomTyreBurst.enabled and (C.randomTyreBurst.averageMinutes or 0)>0 then
                local kph=GetEntitySpeed(veh)*3.6
                if kph>=C.randomTyreBurst.minimumSpeedKph then
                    tyreClock=tyreClock+C.sampleMs
                    if tyreClock>=1000 then tyreClock=tyreClock-1000;local chance=1.0/(C.randomTyreBurst.averageMinutes*60.0);if math.random()<chance then burstRandomTyre(veh) end end
                else tyreClock=0 end
            end
            Wait(C.sampleMs)
        end
    end
end)
CreateThread(function()
    while true do
        if not active or tracked==0 or not DoesEntityExist(tracked) then Wait(500)
        else
            local e=GetVehicleEngineHealth(tracked)
            if C.torque.enabled and e<C.torque.startAt then
                local span=math.max(1,C.torque.startAt-C.damage.safeGuard);local factor=C.torque.min+((e-C.damage.safeGuard)/span)*(1.0-C.torque.min)
                if C.torque.limpMode and e<=C.damage.safeGuard+5 then factor=C.torque.limpMultiplier end
                SetVehicleEngineTorqueMultiplier(tracked,math.max(C.torque.min,math.min(1.0,factor)))
            end
            if C.preventFlip then local roll=GetEntityRoll(tracked);if (roll>75.0 or roll< -75.0) and GetEntitySpeed(tracked)<2.0 then DisableControlAction(0,59,true);DisableControlAction(0,60,true) end end
            if C.preventAirControl and IsEntityInAir(tracked) then DisableControlAction(0,59,true);DisableControlAction(0,60,true);DisableControlAction(0,61,true);DisableControlAction(0,62,true) end
            Wait(0)
        end
    end
end)
exports('BurstRandomTyre',burstRandomTyre)
