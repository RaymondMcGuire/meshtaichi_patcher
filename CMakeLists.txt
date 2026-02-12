cmake_minimum_required(VERSION 3.4...3.18)
project(meshtaichi_patcher_core)

add_subdirectory(pybind11)
pybind11_add_module(meshtaichi_patcher_core src/main.cpp src/api.cpp src/mesh.cpp src/patcher_old.cpp src/csr.cpp src/cluster.cpp src/patcher.cpp)

# Provide a sane default when building directly with CMake (outside setup.py).
if(NOT DEFINED EXAMPLE_VERSION_INFO OR EXAMPLE_VERSION_INFO STREQUAL "")
  set(EXAMPLE_VERSION_INFO "dev")
endif()

# EXAMPLE_VERSION_INFO is defined by setup.py and passed into the C++ code as a
# define (VERSION_INFO) here.
target_compile_definitions(meshtaichi_patcher_core
                           PRIVATE VERSION_INFO=\"${EXAMPLE_VERSION_INFO}\")
