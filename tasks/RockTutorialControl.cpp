/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "RockTutorialControl.hpp"

using namespace rock_tutorial;

RockTutorialControl::RockTutorialControl(std::string const& name, TaskCore::TaskState initial_state)
    : RockTutorialControlBase(name, initial_state), control(NULL)
{
}

RockTutorialControl::RockTutorialControl(std::string const& name, RTT::ExecutionEngine* engine, TaskCore::TaskState initial_state)
    : RockTutorialControlBase(name, engine, initial_state)
{
}

RockTutorialControl::~RockTutorialControl()
{
}

/// The following lines are template definitions for the various state machine
// hooks defined by Orocos::RTT. See RockTutorialControl.hpp for more detailed
// documentation about them.

// bool RockTutorialControl::configureHook()
// {
//     if (! RockTutorialControlBase::configureHook())
//         return false;
//     return true;
// }

bool RockTutorialControl::startHook()
{
    //delete last instance in case we got restarted
    if(control)
	delete control;

    //create instance of the controller
    control = new RockControl();

    //figure out the period in which the update hook get's called
    taskPeriod = TaskContext::getPeriod();

    return RockTutorialControlBase::startHook();
}

void RockTutorialControl::updateHook()
{    
    // read new motion command if available. If not, default to the (0, 0)
    // motion command
    base::MotionCommand2D motionCommand;
    _motion_command.readNewest(motionCommand);

    // Compute new position based on the input command
    base::Pose currentPose = control->computeNextPose(taskPeriod, motionCommand);
    // This is for backward compatibility only
    _pose.write(currentPose);

    // Now write the actual pose
    base::samples::RigidBodyState rbs;
    rbs.time = base::Time::now();
    rbs.invalidate();
    rbs.position = currentPose.position;
    rbs.cov_position = Eigen::Matrix3d::Zero();
    rbs.orientation = currentPose.orientation;
    rbs.cov_orientation = Eigen::Matrix3d::Zero();
    _pose_samples.write(rbs);
}

// void RockTutorialControl::errorHook()
// {
// 
// }

// void RockTutorialControl::stopHook()
// {
// 
// }

// void RockTutorialControl::cleanupHook()
// {
// 
// }
