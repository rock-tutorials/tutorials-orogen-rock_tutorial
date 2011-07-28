require 'orocos'
require 'readline'
include Orocos

## Initialize orocos ##
Orocos.initialize

## Execute the deployments 'rock_tutorial' and 'joystick_local' ##
Orocos.run 'rock_tutorial', 'joystick_local' do

## Get the specific task context ##
rockControl = TaskContext.get 'rock_tutorial_control'
rockVisualization = TaskContext.get 'rock_tutorial_visualization'
joystickLocal = TaskContext.get 'joystick_local'

## Connect the ports ##
joystickLocal.motion_command.connect_to rockControl.motion_command
rockControl.pose.connect_to rockVisualization.pose

## Set some properties ##
joystickLocal.joystick_device = "/dev/input/js0"

## Configure the tasks ##
joystickLocal.configure

## Start the tasks ##
joystickLocal.start
rockControl.start
rockVisualization.start

Readline::readline('Press enter to exit')
end
