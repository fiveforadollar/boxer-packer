cmake_minimum_required (VERSION 3.8)

# Add source to this project's executable.
file(GLOB SOURCES
    ./*.h
    ./*.cpp
)

find_package(cpprestsdk REQUIRED)

add_executable(binpack ${SOURCES})	
target_link_libraries(binpack PRIVATE cpprestsdk::cpprest)