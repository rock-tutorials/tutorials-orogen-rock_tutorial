require 'orocos'
require 'readline'
include Orocos

Orocos.initialize

Orocos.run 'rock_tutorial', 'joystick_local' do

rockControl = TaskContext.get 'rock_tutorial_control'
rockVisualization = TaskContext.get 'rock_tutorial_visualization'
joystickLocal = TaskContext.get 'joystick_local'

joystickLocal.motion_command.connect_to rockControl.motion_command
rockControl.pose.connect_to rockVisualization.pose

joystickLocal.configure
joystickLocal.start

rockControl.start
rockVisualization.start

Readline::readline('Press enter to exit')

end
