# CMakeList.txt : CMake project for binpack, include source and define
# project specific logic here.
#
cmake_minimum_required (VERSION 3.8)

# Add source to this project's executable.
file(GLOB SOURCES
    ./*.h
    ./*.cpp
)

add_executable(binpack ${SOURCES})

# TODO: Add tests and install targets if needed.
