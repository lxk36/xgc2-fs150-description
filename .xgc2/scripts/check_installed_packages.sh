#!/usr/bin/env bash
set -euo pipefail

ROS_DISTRO="${ROS_DISTRO:-jazzy}"
set +u
source "/opt/ros/${ROS_DISTRO}/setup.bash"
set -u

dpkg -s ros-jazzy-xgc2-fs150-description >/dev/null
test "$(ros2 pkg prefix fs150_description)" = "/opt/ros/${ROS_DISTRO}"
test -f "/opt/ros/${ROS_DISTRO}/share/ament_index/resource_index/packages/fs150_description"
test -f "/opt/ros/${ROS_DISTRO}/share/ament_index/resource_index/package_run_dependencies/fs150_description"
test -f "/opt/ros/${ROS_DISTRO}/share/ament_index/resource_index/parent_prefix_path/fs150_description"
test -f "/opt/ros/${ROS_DISTRO}/share/fs150_description/meshes/iris.stl"
test -f "/opt/ros/${ROS_DISTRO}/share/fs150_description/urdf/fs150_visual.urdf"
test -f "/opt/ros/${ROS_DISTRO}/share/fs150_description/MODEL_ASSET_NOTICE.md"

echo "Installed package check passed"
