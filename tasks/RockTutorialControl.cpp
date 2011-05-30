/* Generated from orogen/lib/orogen/templates/tasks/Task.cpp */

#include "RockTutorialControl.hpp"

using namespace rock_tutorial;

RockTutorialControl::RockTutorialControl(std::string const& name, TaskCore::TaskState initial_state)
    : RockTutorialControlBase(name, initial_state)
{
}

RockTutorialControl::RockTutorialControl(std::string const& name, RTT::ExecutionEngine* engine, TaskCore::TaskState initial_state)
    : RockTutorialControlBase(name, engine, initial_state)
{
}

RockTutorialControl::~RockTutorialControl()
{
}

/**
 * Makes sure that angles are between PI and -PI.
 */
void RockTutorialControl::constrainAngle(double& angle)
{
    if (angle < -M_PI)
        angle = angle + 2 * M_PI;
    else if (angle > M_PI)
        angle = angle - 2 * M_PI;
}

/**
 * This method constrains the relativ rotation and translation 
 * of a 2d motion command.
 * Rotation should be between PI an -PI.
 * Translation should be between 10 and -10.
 */
void RockTutorialControl::constrainValues(base::MotionCommand2D& motionCommand)
{
    if (motionCommand.rotation > M_PI)
        motionCommand.rotation = M_PI;
    else if (motionCommand.rotation < -M_PI)
        motionCommand.rotation = -M_PI;
    
    if (motionCommand.translation > 10)
        motionCommand.translation = 10;
    else if (motionCommand.translation < -10)
        motionCommand.translation = -10;
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
    // check if input ports are connected
    if (!_motion_command.connected())
    {
        std::cerr << TaskContext::getName() << ": " 
                    << "Input port 'motion_command' is not connected." << std::endl;
        return false;
    }
    
    // set variables to zero
    actualCommand.rotation = 0;
    actualCommand.translation = 0;
    taskPeriod = 0;
    currentHeading = 0;
    currentRoll = 0;
    currentPose.orientation = base::Quaterniond::Identity();
    currentPose.position = base::Vector3d::Zero();
    return true;
}

void RockTutorialControl::updateHook()
{
    // get triggering interval of this task context
    if (taskPeriod <= 0) 
    {
        taskPeriod = TaskContext::getPeriod();
        if (taskPeriod <= 0)
        {
            std::cerr << TaskContext::getName() << ": " 
                        << "This task needs to be a periodic triggering task." << std::endl;
            error();
            return;
        }
    }
    
    //read new motion command if available
    base::MotionCommand2D motionCommand;
    if (_motion_command.readNewest(motionCommand) == RTT::NewData)
    {
        actualCommand = motionCommand;
        constrainValues(actualCommand);
    }
    
    //translation and rotation relativ to the task period
    double delta_translation  = actualCommand.translation * taskPeriod;
    double delta_rotation  = actualCommand.rotation * taskPeriod;
    
    // set current yaw and roll
    currentHeading += delta_rotation;
    currentRoll += delta_translation * -2;
    constrainAngle(currentHeading);
    constrainAngle(currentRoll);
    
    // calculate new absolut values for position and orientation
    currentPose.position += Eigen::AngleAxis<double>(currentHeading, Eigen::Vector3d::UnitZ()) * Eigen::Vector3d(0, delta_translation, 0);
    currentPose.orientation = Eigen::AngleAxis<double>(currentHeading, Eigen::Vector3d::UnitZ()) * Eigen::AngleAxis<double>(currentRoll, Eigen::Vector3d::UnitX());
    currentPose.orientation.normalize();
    
    //write pose on output port
    if(_pose.connected())
        _pose.write(currentPose);
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