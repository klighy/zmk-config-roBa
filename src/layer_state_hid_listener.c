/*
 * Copyright (c) 2024 The ZMK Contributors
 * SPDX-License-Identifier: MIT
 *
 * Layer state report protocol adapted from pfilipp/zmk (f9ae3c15).
 */
#include <zmk/event_manager.h>
#include <zmk/events/layer_state_changed.h>
#include <zmk/events/endpoint_changed.h>
#include <zmk/hid.h>
#include <zmk/endpoints.h>
#include <zmk/keymap.h>
#if IS_ENABLED(CONFIG_ZMK_BLE)
#include <zmk/hog.h>
#endif
#if IS_ENABLED(CONFIG_ZMK_USB)
#include <zmk/usb_hid.h>
#endif

static int layer_state_hid_listener(const zmk_event_t *eh) {
    zmk_keymap_layer_index_t index = zmk_keymap_highest_layer_active();
    zmk_hid_layer_state_set(index, zmk_keymap_layer_locked(
        zmk_keymap_layer_index_to_id(index)) ? 1 : 0);

    switch (zmk_endpoints_selected().transport) {
#if IS_ENABLED(CONFIG_ZMK_USB)
    case ZMK_TRANSPORT_USB:
        zmk_usb_hid_send_layer_state_report();
        break;
#endif
#if IS_ENABLED(CONFIG_ZMK_BLE)
    case ZMK_TRANSPORT_BLE:
        zmk_hog_send_layer_state_report(&zmk_hid_get_layer_state_report()->body);
        break;
#endif
    default:
        break;
    }
    return ZMK_EV_EVENT_BUBBLE;
}

ZMK_LISTENER(layer_state_hid_listener, layer_state_hid_listener);
ZMK_SUBSCRIPTION(layer_state_hid_listener, zmk_layer_state_changed);
ZMK_SUBSCRIPTION(layer_state_hid_listener, zmk_endpoint_changed);
