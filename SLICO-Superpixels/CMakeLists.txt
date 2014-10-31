cmake_minimum_required(VERSION 3.0)

project(SLICO)

find_package(OpenCV COMPONENTS core highgui)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${SLICO_SOURCE_DIR}/bin/Debug)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${SLICO_SOURCE_DIR}/bin/Release)

set(SLIC_SOURCE_FILES
  src/SLIC.h
  src/SLIC.cpp
)

set(MAIN_SOURCE_FILES
  src/main.cpp
)

add_executable(SLICO
  ${SLIC_SOURCE_FILES}
  ${MAIN_SOURCE_FILES}
)

source_group(SLIC FILES ${SLIC_SOURCE_FILES})
source_group(main FILES ${MAIN_SOURCE_FILES})

target_include_directories(SLICO PUBLIC
  ${CMAKE_CURRENT_LIST_DIR}/src
  ${OpenCV_INCLUDE_DIRS}
)

target_link_libraries(SLICO PUBLIC ${OpenCV_LIBS})
