/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "RockTutorialVisualization.hpp"

using namespace rock_tutorial;

RockTutorialVisualization::RockTutorialVisualization(std::string const& name, TaskCore::TaskState initial_state)
    : RockTutorialVisualizationBase(name, initial_state)
{
}

RockTutorialVisualization::RockTutorialVisualization(std::string const& name, RTT::ExecutionEngine* engine, TaskCore::TaskState initial_state)
    : RockTutorialVisualizationBase(name, engine, initial_state)
{
}

RockTutorialVisualization::~RockTutorialVisualization()
{
}



/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See RockTutorialVisualization.hpp for more detailed
// documentation about them.

// bool RockTutorialVisualization::configureHook()
// {
//     if (! RockTutorialVisualizationBase::configureHook())
//         return false;
//     return true;
// }
bool RockTutorialVisualization::startHook()
{
    // check if input port is connected
    if (!_pose.connected())
    {
        std::cerr << TaskContext::getName() << ": " 
                    << "Input port 'pose' is not connected." << std::endl;
        return false;
    }
    
    // start thread containing the vizkit widget
    app.start();
    vizkitWidget = app.getWidget();
    // add a new visualization to the vizkit widget
    rockVizPlugin = new vizkit::RockVisualization();
    vizkitWidget->addDataHandler(rockVizPlugin);
    return true;
}
void RockTutorialVisualization::updateHook()
{
    // read new pose if available
    base::Pose pose;
    if(_pose.readNewest(pose) == RTT::NewData)
    {
        // transmit the new pose to the visualization
        rockVizPlugin->updateData(pose);
    }
}
void RockTutorialVisualization::errorHook()
{
    
}
void RockTutorialVisualization::stopHook()
{
    // remove the plugin and stop the thread
    vizkitWidget->removeDataHandler(rockVizPlugin);
    app.stop();
}
void RockTutorialVisualization::cleanupHook()
{
    // delete the visualization plugin
    if (rockVizPlugin)
        delete rockVizPlugin;
}

