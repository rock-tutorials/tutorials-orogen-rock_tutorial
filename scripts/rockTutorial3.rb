require 'vizkit'
include Orocos

## Initialize orocos ##
Orocos.initialize

## load and add the 3d plugin for the rock
vizkit_rock = Vizkit.default_loader.RockVisualization

## create a widget that emulates a joystick
joystickGui = Vizkit.default_loader.VirtualJoystick

#show it
joystickGui.show()

#Vizkit::ReaderWriterProxy.default_policy = {:port_proxy => nil, :init => true}

## Execute the deployments 'rock_tutorial' ##
Orocos.run 'rock_tutorial::RockTutorialControl' => 'rock_tutorial_control' do
    ## Get the specific task context ##
    rockControl = TaskContext.get 'rock_tutorial_control'
  
    ## Connect port to vizkit plugin
    rockControl.pose_samples.to_async.on_data :period => 0.1 do |sample| 
	##pass every pose sample to our visualizer plugin
        vizkit_rock.updateRigidBodyState(sample)
    end 

    ## Create a sample writer for a port ##
    sampleWriter = rockControl.motion_command.writer
    sample = sampleWriter.new_sample

    ## glue the widget to the task writer
    joystickGui.connect(SIGNAL('axisChanged(double, double)')) do |x, y|
        sample.translation = x
        sample.rotation = if x != 0 || y != 0
                              - y.abs() * Math::atan2(y, x.abs())
                          else
                              0
                          end
        sampleWriter.write(sample)
    end	
    
    ## Start the tasks ##
    rockControl.start
    Vizkit.exec
end
