cmake_minimum_required (VERSION 3.8)

# Add source to this project's executable.
file(GLOB SOURCES
    ./*.h
    ./*.cpp
)

# Mock JSON data
file(GLOB JSON_DATA RELATIVE ./sample_data/
	*.json
)

find_package(cpprestsdk REQUIRED)
find_package(sqlite3 CONFIG REQUIRED)


add_executable(binpack ${JSON_DATA} ${SOURCES})	
target_link_libraries(binpack PRIVATE cpprestsdk::cpprest)
target_link_libraries(binpack PRIVATE sqlite3)