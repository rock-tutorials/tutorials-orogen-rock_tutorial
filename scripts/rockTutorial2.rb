require 'orocos'
require 'readline'
include Orocos

## Initialize orocos ##
Orocos.initialize

## Execute the deployment 'rock_tutorial' ##
Orocos.run 'rock_tutorial' do

## Get a specific task context ##
rockControl = TaskContext.get 'rock_tutorial_control'
rockVisualization = TaskContext.get 'rock_tutorial_visualization'

## Connect the ports ##
rockControl.pose.connect_to rockVisualization.pose

## Create a sample writer for a port ##
sampleWriter = rockControl.motion_command.writer

## Start the tasks ##
rockControl.start
rockVisualization.start

## Write motion command sample ##
sample = sampleWriter.new_sample
sample.translation = 1
sample.rotation = 0.5
sampleWriter.write(sample)

Readline::readline('Press enter to exit')
end
