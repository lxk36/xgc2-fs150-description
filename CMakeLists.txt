cmake_minimum_required(VERSION 3.8)
project(fs150_description)

find_package(ament_cmake REQUIRED)

if(BUILD_TESTING)
  find_package(ament_cmake_pytest REQUIRED)
  ament_add_pytest_test(visual_assets test/test_visual_assets.py)
endif()

install(DIRECTORY meshes urdf
  DESTINATION share/${PROJECT_NAME}
)

install(FILES MODEL_ASSET_NOTICE.md
  DESTINATION share/${PROJECT_NAME}
)

ament_package()
