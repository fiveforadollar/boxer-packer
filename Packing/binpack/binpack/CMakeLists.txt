cmake_minimum_required (VERSION 3.8)

# Add source to this project's executable.
file(GLOB SOURCES
    ./*.h
    ./*.cpp
)

add_executable(binpack ${SOURCES})
