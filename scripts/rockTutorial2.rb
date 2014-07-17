#
# script from http://rock-robotics.org/master/documentation/tutorials/510_joystick.html
#

require 'orocos'
require 'readline'
include Orocos

## Initialize orocos ##
Orocos.initialize

## Execute the tasks 'rock_tutorial' and 'joystick' ##
Orocos.run 'rock_tutorial::RockTutorialControl' => 'rock_tutorial_control',
     'controldev::JoystickTask' => 'joystick' do
  
    ## Get the specific task context ##
    rockControl = TaskContext.get 'rock_tutorial_control'
    joystick = TaskContext.get 'joystick'

    ## Connect the ports ##
    joystick.motion_command.connect_to rockControl.motion_command

    ## Set some properties ##
    joystick.device = "/dev/input/js0" # This might be another port

    ## Configure the tasks ##
    joystick.configure

    ## Start the tasks ##
    joystick.start
    rockControl.start

    Readline::readline("Press Enter to exit\n") do
    end
end
