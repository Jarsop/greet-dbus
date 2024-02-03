cmake_minimum_required(VERSION 3.10)
project(je-sappel-greet VERSION 1.0)

find_library(SDBUS_CPP_LIBRARY NAMES sdbus-c++)
find_path(SDBUS_CPP_INCLUDE_DIR sdbus-c++/sdbus-c++.h)

add_executable(je-sappel-greet src/main.cpp)
target_include_directories(je-sappel-greet PRIVATE ${SDBUS_CPP_INCLUDE_DIR})

target_link_libraries(je-sappel-greet ${SDBUS_CPP_LIBRARY})
