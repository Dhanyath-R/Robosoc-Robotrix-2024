-- Lua script for controlling a robot in a simulated environment using CoppeliaSim (formerly V-REP)
-- The script utilizes proximity sensors and vision sensors for navigation and obstacle avoidance

-- Initialize function called once when the simulation starts
function sysCall_init()
    -- Import the CoppeliaSim API
    sim = require('sim')
    
    -- Get handles for robot components
    pr = sim.getObject('/Medbot')       -- Probot object handle
    leftjoint = sim.getObject('/l_joint')  -- Left joint handle
    rightjoint = sim.getObject('/r_joint')  -- Right joint handle
    PSL= sim.getObject('/PSL')          -- Left proximity sensor handle
    PSR= sim.getObject('/PSR')          -- Right proximity sensor handle
    PSM = sim.getObject('/PSM')         -- Middle proximity sensor handle
    OV = sim.getObject('/OV')           -- Vision sensor handle
    
    -- Initialize a counter variable
    i=0
end

-- Actuation function called at each simulation step
function sysCall_actuation()
    -- Set joint velocities to make the robot move forward
    sim.setJointTargetVelocity(leftjoint, -2)
    sim.setJointTargetVelocity(rightjoint, 2)
    
    -- Check if vision sensor data is available
    if (data_OV ~= nil) then
        intensity_OV = data_OV[11]  -- Extract intensity data from vision sensor
        --print(intensity_OV)
        
        -- Check if a specific intensity threshold is reached
        if(intensity_OV == 0.2078431372549)then
            print('Reached locator',i)  -- Print message indicating locator reached
            i=i+1
        end
    end
    
    -- React based on proximity sensor readings
    -- If middle sensor detects an obstacle, turn right
    if(rm==1)then
        print('Mid')
        sim.setJointTargetVelocity(rightjoint,4)
    end   
    
    -- If left sensor detects an obstacle, turn left
    if(rl==1)then
        print('left')
        sim.setJointTargetVelocity(leftjoint,-4)
    else
        sim.setJointTargetVelocity(rightjoint,4)  -- Continue moving forward
    end
    
    -- If right sensor detects an obstacle, turn right
    if(rr==1)then
        print('right')
        sim.setJointTargetVelocity(rightjoint,4)
    end
end

-- Sensing function called at each simulation step
function sysCall_sensing()
    -- Read proximity sensor data
    -- Store sensor readings and other relevant information
    rr, distance, detectedPoint, detectedObjectHandle, detectedSurfaceNormalVector = sim.readProximitySensor(PSR)
    rl, distance, detectedPoint, detectedObjectHandle, detectedSurfaceNormalVector = sim.readProximitySensor(PSL)
    rm, distance, detectedPoint, detectedObjectHandle, detectedSurfaceNormalVector = sim.readProximitySensor(PSM)
    
    -- Read vision sensor data
    -- Store the result and data from the vision sensor
    result, data_OV = sim.readVisionSensor(OV)
end

-- Cleanup function called once when the simulation ends
function sysCall_cleanup()
    -- Perform any necessary clean-up operations here
end
