if(CONFIG_PMW3610)
  add_subdirectory(drivers/pmw3610)
endif()

if(CONFIG_ZMK_POINTING_SMOOTH_SCROLLING OR CONFIG_ZMK_HID_LAYER_STATE_REPORT)
  include(cmake/zmk-backports.cmake)
endif()
