#!/usr/bin/env bash
set -euo pipefail

grep -q '^id: xgc2-fs150-description$' .xgc2/product.yml
grep -q '^version: 0.1.0-4$' .xgc2/product.yml
grep -q '<name>fs150_description</name>' package.xml
grep -q 'ros-noetic-urdf' .xgc2/product.yml
test -f meshes/iris.stl
test -f meshes/iris_prop_ccw.dae
test -f meshes/iris_prop_cw.dae
test -f urdf/fs150_visual.urdf

echo "Package compliance checks passed."
