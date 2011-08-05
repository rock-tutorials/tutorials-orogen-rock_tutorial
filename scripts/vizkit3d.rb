require 'vizkit'
Orocos.initialize

## create a widget for 3d display
view3d = Vizkit.default_loader.create_widget('vizkit::Vizkit3DWidget')

#show it
view3d.show()

## load and add the 3d plugin for the rock
rbs_plugin = view3d.createPlugin('RigidBodyStateVisualization')
rbs = Types::Base::Samples::RigidBodyState.new

cnt = 0
timer = Qt::Timer.new()
timer.connect(SIGNAL("timeout()")) do
    if(cnt > 50)
	cnt = 0
    end
    cnt = cnt + 1
    rbs.position = Eigen::Vector3.new(0, 5.0 / 50.0 * cnt, 0)
    rbs.orientation = Eigen::Quaternion.new(0, 0, 0, 1)

#    rbs_plugin.updateData(rbs)
end

timer.start(100)

Vizkit.exec()
