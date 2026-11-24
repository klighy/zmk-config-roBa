# Apply the local v0.3 backports to build-directory copies, never to the west checkout.
set(backport_dir "${CMAKE_CURRENT_BINARY_DIR}/zmk-backports")
set(backport_files "")
set(backport_patches "")
if(CONFIG_ZMK_POINTING_SMOOTH_SCROLLING)
  list(APPEND backport_files src/pointing/input_listener.c src/usb_hid.c)
  list(APPEND backport_patches "${CMAKE_CURRENT_LIST_DIR}/zmk-scroll.patch")
endif()
if(CONFIG_ZMK_HID_LAYER_STATE_REPORT)
  list(APPEND backport_files
    include/zmk/hid.h
    include/zmk/keymap.h
    include/zmk/hog.h
    include/zmk/usb_hid.h
    src/hid.c
    src/keymap.c
    src/behaviors/behavior_toggle_layer.c
    src/hog.c
    src/usb_hid.c)
  list(APPEND backport_patches "${CMAKE_CURRENT_LIST_DIR}/zmk-layer-state.patch")
endif()
list(REMOVE_DUPLICATES backport_files)
foreach(source IN LISTS backport_files)
  set(original "${APPLICATION_SOURCE_DIR}/${source}")
  configure_file("${original}" "${backport_dir}/${source}" COPYONLY)
  if(source MATCHES "^src/")
    set_source_files_properties("${original}" DIRECTORY "${APPLICATION_SOURCE_DIR}"
                                PROPERTIES HEADER_FILE_ONLY TRUE)
  endif()
endforeach()

find_package(Git REQUIRED)
foreach(patch IN LISTS backport_patches)
  set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${patch}")
  execute_process(
    COMMAND "${CMAKE_COMMAND}" -E env "GIT_CEILING_DIRECTORIES=${CMAKE_CURRENT_BINARY_DIR}"
            "${GIT_EXECUTABLE}" apply "${patch}"
    WORKING_DIRECTORY "${backport_dir}"
    COMMAND_ERROR_IS_FATAL ANY
  )
endforeach()

if(CONFIG_ZMK_POINTING_SMOOTH_SCROLLING)
  target_sources(app PRIVATE "${backport_dir}/src/pointing/input_listener.c")
endif()
target_sources_ifdef(CONFIG_ZMK_USB app PRIVATE "${backport_dir}/src/usb_hid.c")
if(CONFIG_ZMK_HID_LAYER_STATE_REPORT)
  target_include_directories(app BEFORE PRIVATE "${backport_dir}/include")
  target_sources(app PRIVATE
    "${backport_dir}/src/hid.c"
    "${backport_dir}/src/keymap.c"
    "${backport_dir}/src/behaviors/behavior_toggle_layer.c"
    "${CMAKE_CURRENT_LIST_DIR}/../src/layer_state_hid_listener.c")
  target_sources_ifdef(CONFIG_ZMK_BLE app PRIVATE "${backport_dir}/src/hog.c")
endif()
