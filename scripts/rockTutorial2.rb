require 'orocos'
require 'vizkit'
include Orocos

## Initialize orocos ##
Orocos.initialize

## create a widget for 3d display
view3d = Vizkit.default_loader.create_widget('vizkit::QVizkitWidget')

#show it
view3d.show()

## load and add the 3d plugin for the rock
vizkit_rock = view3d.createPlugin('rock_tutorial', 'RockVisualization')

## Execute the deployments 'rock_tutorial' and 'joystick_local' ##
Orocos.run 'rock_tutorial', 'joystick' do
  
    ## Connect port to vizkit plugin
    con = Vizkit.connect_port_to 'rock_tutorial_control', 'pose', :update_frequency => 33 do |sample, name|
	##pass every pose sample to our visualizer plugin
        vizkit_rock.updatePose(sample)
        sample
    end 

    ## Get the specific task context ##
    rockControl = TaskContext.get 'rock_tutorial_control'
    joystick = TaskContext.get 'joystick'

    ## Connect the ports ##
    joystick.motion_command.connect_to rockControl.motion_command

    ## Set some properties ##
    joystick.device = "/dev/input/js0"

    ## Configure the tasks ##
    joystick.configure

    ## Start the tasks ##
    joystick.start
    rockControl.start

    Vizkit.exec
end
