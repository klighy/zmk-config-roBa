# Backport the scroll fixes to the v0.3 branch without changing the west checkout.
set(scroll_patch "${CMAKE_CURRENT_LIST_DIR}/zmk-scroll.patch")
set(scroll_build_dir "${CMAKE_CURRENT_BINARY_DIR}/zmk-scroll")
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${scroll_patch}")
foreach(source IN ITEMS src/pointing/input_listener.c src/usb_hid.c)
  set(original "${APPLICATION_SOURCE_DIR}/${source}")
  configure_file("${original}" "${scroll_build_dir}/${source}" COPYONLY)
  set_source_files_properties("${original}" DIRECTORY "${APPLICATION_SOURCE_DIR}"
                              PROPERTIES HEADER_FILE_ONLY TRUE)
endforeach()

find_package(Git REQUIRED)
execute_process(
  COMMAND "${CMAKE_COMMAND}" -E env "GIT_CEILING_DIRECTORIES=${CMAKE_CURRENT_BINARY_DIR}"
          "${GIT_EXECUTABLE}" apply "${scroll_patch}"
  WORKING_DIRECTORY "${scroll_build_dir}"
  COMMAND_ERROR_IS_FATAL ANY
)

target_sources(app PRIVATE "${scroll_build_dir}/src/pointing/input_listener.c")
target_sources_ifdef(CONFIG_ZMK_USB app PRIVATE "${scroll_build_dir}/src/usb_hid.c")
