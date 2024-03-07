-- Initialize the script
function sysCall_init()
    -- Load necessary modules and get object handles
    sim = require('sim')
    pr = sim.getObject('/Probot')  -- Probot object handle
    leftjoint = sim.getObject('/l_joint')  -- Left joint handle
    rightjoint = sim.getObject('/r_joint')  -- Right joint handle
    LV = sim.getObject('/LV')  -- Left sensor handle
    RV = sim.getObject('/RV')  -- Right sensor handle
    MV = sim.getObject('/MV')  -- Middle sensor handle
    proximity = sim.getObject('/Proximity_sensor')  -- Proximity sensor handle
    lc = 0  -- Initialize a variable to count locator hits
    ip = sim.getObjectPosition(pr, sim.handle_world)  -- Get initial position of the robot
    print('Initial Position', ip)  -- Print initial position
end

-- Main actuation function
function sysCall_actuation()
    -- Set initial velocities for both joints
    sim.setJointTargetVelocity(leftjoint, -2)
    sim.setJointTargetVelocity(rightjoint, 2)
    
    -- Check sensor readings and adjust velocities accordingly
    if (data_left ~= nil) then
        intensity_left = data_left[11]
        intensity_right = data_right[11]
        intensity_mid = data_mid[11]
        
        -- Turn right if left sensor detects an line and right sensor doesn't
        if (intensity_right < 0.5 and intensity_left > 0.5) then
            sim.setJointTargetVelocity(rightjoint, -2)
        end
        
        -- Turn left if right sensor detects an line and left sensor doesn't
        if (intensity_left < 0.5 and intensity_right > 0.5) then
            sim.setJointTargetVelocity(leftjoint, 2)
        end
        
        -- Handle line detection in the middle sensor
        if (intensity_mid > 0.4) then
            if (intensity_left < 0.5 and intensity_right > 0.5) then
                sim.setJointTargetVelocity(leftjoint, 2)
            end
            if (intensity_right < 0.5 and intensity_left > 0.5) then
                sim.setJointTargetVelocity(rightjoint, -2)
            end
            if (intensity_right > 0.5 and intensity_left > 0.5) then
                if (lc <= 1) then
                    sim.setJointTargetVelocity(rightjoint, -2)
                end
                if (lc > 1) then
                    sim.setJointTargetVelocity(leftjoint, 2)
                end 
            end
        end
        
        -- After hitting all locators, then take an uturn
        if (lc == 4) then
            sim.setJointTargetVelocity(leftjoint, 2)
        end
    end
end

-- Sensing function
function sysCall_sensing()
    -- Read sensor data
    result, data_left = sim.readVisionSensor(LV)
    result, data_right = sim.readVisionSensor(RV)
    result, data_mid = sim.readVisionSensor(MV)
    
    -- Read proximity sensor data
    result, distance, detectedPoint, detectedObjectHandle, detectedSurfaceNormalVector = sim.readProximitySensor(proximity)
    
    -- Check if proximity sensor detects an obstacle and update locator count
    if (result == 1 and i == 0) then
        i = 1
        lc = lc + 1 
        if (lc <= 4) then
            print('Reached Locator')
        end
        if (lc == 4) then
            print('Reached all the destinations returning to initial position')
        end
    end
    
    -- Reset i if no obstacle is detected
    if (result == 0) then
        i = 0
    end  
    
    -- Stop simulation if the robot returns to initial position
    if (result == 0 and lc >= 4) then
        lp = sim.getObjectPosition(pr, sim.handle_world)
        if (lp[1] <= -2.5) then
            sim.stopSimulation(0)
        end 
    end
end

-- Clean-up function
function sysCall_cleanup()
    -- Clean-up code goes here
end
