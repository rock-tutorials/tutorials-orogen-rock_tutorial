require 'orocos'
require 'vizkit'
include Orocos

## Initialize orocos ##
Orocos.initialize

## create a widget for 3d display
view3d = Vizkit.default_loader.create_widget('vizkit::Vizkit3DWidget')

#show it
view3d.show()

## load and add the 3d plugin for the rock
vizkit_rock = view3d.createPlugin('rock_tutorial', 'RockVisualization')

## create a widget that emulates a joystick
joystickGui = Vizkit.default_loader.create_widget('VirtualJoystick')

#show it
joystickGui.show()

## Execute the deployments 'rock_tutorial' ##
Orocos.run 'rock_tutorial' do
  
    ## Connect port to vizkit plugin
    con = Vizkit.connect_port_to 'rock_tutorial_control', 'pose', :update_frequency => 33 do |sample, name|
	##pass every pose sample to our visualizer plugin
        vizkit_rock.updatePose(sample)
        sample
    end 

    ## Get the specific task context ##
    rockControl = TaskContext.get 'rock_tutorial_control'

    ## Create a sample writer for a port ##
    sampleWriter = rockControl.motion_command.writer

    sample = sampleWriter.new_sample

    ## glue the widget to the task writer
    joystickGui.connect(SIGNAL('axisChanged(double, double)')) do |x, y|
	sample.translation = x
	sample.rotation = - y.abs() * Math::atan2(y, x.abs())
	sampleWriter.write(sample)
    end	
    
    ## Start the tasks ##
    rockControl.start
    
    ## Write motion command sample ##

    Vizkit.exec
end
