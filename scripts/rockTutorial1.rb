require 'orocos'
require 'readline'
include Orocos

## Initialize orocos ##
Orocos.initialize

## Execute the deployment 'rock_tutorial' ##
Orocos.run 'rock_tutorial' do

## Get a specific task context ##
rockVisualization = TaskContext.get 'rock_tutorial_visualization'

## Start the tasks ##
rockVisualization.start

Readline::readline('Press enter to exit')
end
