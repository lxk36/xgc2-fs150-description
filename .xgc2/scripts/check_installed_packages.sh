#!/usr/bin/env bash
set -euo pipefail

ROS_DISTRO="${ROS_DISTRO:-noetic}"
source "/opt/ros/${ROS_DISTRO}/setup.bash"

dpkg -s ros-noetic-xgc2-fs150-description >/dev/null
test "$(rospack find fs150_description)" = "/opt/ros/${ROS_DISTRO}/share/fs150_description"
test -f "/opt/ros/${ROS_DISTRO}/share/fs150_description/meshes/iris.stl"
test -f "/opt/ros/${ROS_DISTRO}/share/fs150_description/urdf/fs150_visual.urdf"
test -f "/opt/ros/${ROS_DISTRO}/share/fs150_description/MODEL_ASSET_NOTICE.md"

echo "Installed package check passed"
