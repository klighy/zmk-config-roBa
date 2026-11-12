if(CONFIG_PMW3610)
  add_subdirectory(drivers/pmw3610)
endif()

if(CONFIG_ZMK_POINTING_SMOOTH_SCROLLING)
  include(cmake/zmk-scroll.cmake)
endif()
