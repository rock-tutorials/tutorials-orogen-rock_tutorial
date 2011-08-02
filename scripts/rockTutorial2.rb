require 'orocos'
require 'readline'
require 'vizkit'
include Orocos

## Initialize orocos ##
Orocos.initialize

##TODO THIS IS A BUG
Orocos.load_typekit('base')

## create a widget for 3d display
view3d = Vizkit.default_loader.create_widget('vizkit::QVizkitWidget')

#show it
view3d.show()

## load and add the 3d plugin for the rock
vizkit_rock = view3d.createPlugin('rock_tutorial', 'RockVisualization')

## Execute the deployment 'rock_tutorial' ##
Orocos.run 'rock_tutorial' do

    ## Get a specific task context ##
    rockControl = TaskContext.get 'rock_tutorial_control'
    
    ## Connect port to vizkit plugin
    con = Vizkit.connect_port_to 'rock_tutorial_control', 'pose', :auto_reconnect => true, :pull => false, :update_frequency => 33 do |sample, name|
	##pass every pose sample to our visualizer plugin
        vizkit_rock.updatePose(sample)
        sample
    end 

    ## Create a sample writer for a port ##
    sampleWriter = rockControl.motion_command.writer
    
    ## Start the tasks ##
    rockControl.start
    
    ## Write motion command sample ##
    sample = sampleWriter.new_sample
    sample.translation = 1
    sample.rotation = 0.5
    sampleWriter.write(sample)

    Vizkit.exec
end
