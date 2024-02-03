cmake_minimum_required(VERSION 3.10)
project(je-sappel-greet VERSION 1.0)

find_library(SYSTEMD_LIBRARY NAMES systemd)
find_path(SYSTEMD_INCLUDE_DIR systemd/sd-bus.h)

add_executable(je-sappel-greet src/main.c)
target_include_directories(je-sappel-greet PRIVATE ${SYSTEMD_INCLUDE_DIR})

target_link_libraries(je-sappel-greet ${SYSTEMD_LIBRARY})
