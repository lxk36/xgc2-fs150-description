#!/usr/bin/env bash
set -euo pipefail

grep -q '^id: xgc2-ros-jazzy-fs150-description$' .xgc2/product.yml
grep -q '^version: 0.1.0-1$' .xgc2/product.yml
grep -q '^kind: ros2-apt$' .xgc2/product.yml
grep -q '^  distro: jazzy$' .xgc2/product.yml
grep -q '<name>fs150_description</name>' package.xml
grep -q '<license>Proprietary</license>' package.xml
grep -q '<build_type>ament_cmake</build_type>' package.xml
grep -q '^  - fs150_description$' .xgc2/product.yml
grep -q '^  - ros-jazzy-xgc2-fs150-description$' .xgc2/product.yml
grep -q 'ros-jazzy-urdf' .xgc2/product.yml
test -f meshes/iris.stl
test -f meshes/iris_prop_ccw.dae
test -f meshes/iris_prop_cw.dae
test -f urdf/fs150_visual.urdf
test -f MODEL_ASSET_NOTICE.md
grep -q 'does not grant, expand' MODEL_ASSET_NOTICE.md

expected_hashes="$(mktemp)"
actual_hashes="$(mktemp)"
trap 'rm -f "${expected_hashes}" "${actual_hashes}"' EXIT
printf '%s  %s\n' \
  d9ef95f5fe0959a7af426cd03a2da8a12b5617fc78c45723068e6295d486523b MODEL_ASSET_NOTICE.md \
  11a9a1453723182f812e4ca0def829b18272a0dfc1145d2c3e28f8c6210cea7b meshes/iris.stl \
  5f8b01668ee24a5b663ca8c4dd56e294fd6480db7eec1e5a7c11e45ba9004e99 meshes/iris_prop_ccw.dae \
  626c1922e0de751dc08c038d6d4b90a3dfb63d98f681d07a11b832ba9c78a22f meshes/iris_prop_ccw.stl \
  6cbc686772dccd46253fb65ece000e7ffa6a74b9c097bda349884bd1e78cd879 meshes/iris_prop_cw.dae \
  ce68c5e931f5f08f2adbea215ea3f218315b17d3aabeb9914ab2d92c28a37259 meshes/iris_prop_cw.stl \
  23cfa6b5c1b4a273030106cbfe37036c2229ce2eca957550d5189fb38fa92374 urdf/fs150_visual.urdf >"${expected_hashes}"
sha256sum MODEL_ASSET_NOTICE.md meshes/* urdf/fs150_visual.urdf | sort >"${actual_hashes}"
sort -o "${expected_hashes}" "${expected_hashes}"
diff -u "${expected_hashes}" "${actual_hashes}"

python3 test/test_visual_assets.py

echo "Package compliance checks passed."
