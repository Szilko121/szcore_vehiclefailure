SzCoreVehicleFailureConfig = {
    enabled = true,
    sampleMs = 200,
    damage = {engine = 3.0, body = 3.0, tank = 24.0,degradeThreshold = 350.0,cascadingThreshold = 220.0,safeGuard = 80.0,degradePerSecond = 1.8,cascadePerSecond = 8.0,weaponMultiplier = 1.0},
    torque = { enabled = true, startAt = 850.0, min = 0.18, limpMode = true, limpMultiplier = 0.16 },
    preventFlip = true,
    preventAirControl = true,
    randomTyreBurst = { enabled = true, averageMinutes = 45, minimumSpeedKph = 35.0 },
    classMultiplier = {[0]=0.55,[1]=0.55,[2]=0.60,[3]=0.60,[4]=0.65,[5]=0.62,[6]=0.62,[7]=0.65,[8]=0.30,[9]=0.48,[10]=0.35,[11]=0.40,[12]=0.55,[13]=0.0,[14]=0.25,[15]=0.25,[16]=0.25,[17]=0.50,[18]=0.55,[19]=0.35,[20]=0.40,[21]=0.0},
    repair = {basicEngineHealth = 650.0,repairDistance = 4.0,basicDuration = 9000,advancedDuration = 16000,tyreDuration = 6500,cleanDuration = 6500}
}
