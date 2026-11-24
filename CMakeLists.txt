if(CONFIG_PMW3610)
  add_subdirectory(drivers/pmw3610)
endif()

if(CONFIG_ZMK_POINTING_SMOOTH_SCROLLING)
  include(cmake/zmk-scroll.cmake)
endif()

# KeyBeacon v1.2.0 detects the legacy endpoint API but its directory-scoped
# definition does not reach the Zephyr library. Export it via zephyr_interface.
if(CONFIG_ZMK_KEYBEACON)
  file(READ "${CMAKE_SOURCE_DIR}/include/zmk/endpoints.h" ROBA_ZMK_ENDPOINTS_HEADER)
  if(ROBA_ZMK_ENDPOINTS_HEADER MATCHES "zmk_endpoints_selected[ \t\r\n]*\\(")
    zephyr_compile_definitions(ZMK_KEYBEACON_HAS_LEGACY_ENDPOINT=1)
  endif()
endif()
