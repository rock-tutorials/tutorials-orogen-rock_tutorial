require 'orocos'
require 'readline'
include Orocos

Orocos.initialize

Orocos.run 'rock_tutorial' do

rockControl = TaskContext.get 'rock_tutorial_control'
rockVisualization = TaskContext.get 'rock_tutorial_visualization'

rockControl.pose.connect_to rockVisualization.pose

sampleWriter = rockControl.motion_command.writer

rockControl.start
rockVisualization.start

sample = sampleWriter.new_sample
sample.translation = 1
sample.rotation = 0.5
sampleWriter.write(sample)

Readline::readline('Press enter to exit')

end
