# roBa encoder event diagnostics

This branch adds two *separate* USB logging firmware artifacts. The regular `roBa_R`, `roBa_L`, and `settings_reset` builds are unchanged.

## Stage 1: right-half BLE event reception

1. Flash the `roBa_R_encoder_debug` UF2 to the **right half only**.
2. Connect the right half by USB; power the left half and let its normal BLE split connection establish.
3. Open the right USB CDC ACM serial port (Windows: COM port via Device Manager and a serial terminal; macOS: `tio /dev/cu.usbmodem...`).
4. Rotate the left encoder slowly, observing:
   - `[SENSOR NOTIFICATION] data ... length ...`: central received a BLE sensor notification.
   - `val1: ... val2: ... remainder: ... triggers: ...`: central sensor behavior processed its data.

If neither appears but other log lines appear, the right USB logging works, but **this alone cannot locate the failure**.

## Stage 2: log EC11 GPIO states locally on the left half

This standalone diagnostic build is intended precisely for the case where the right-half logs show no sensor notifications.

1. Download and extract the `roBa_L_encoder_gpio_debug` UF2.
2. **Flash it to the left half only.** Disconnect the left half from any USB serial terminal before flashing.
3. Connect the left half itself to the PC by USB. Open the new USB CDC ACM serial port.
4. Rotate the encoder **slowly in both directions**, and look for:
   - `EC11: prev: N, new: M`: A/B GPIO state sampled by the driver (values 0–3)
   - `EC11: Delta: 1` or `EC11: Delta: -1`: valid quadrature transition.
5. If logs are present but no EC11 lines appear when rotating, further testing is needed to separate GPIO input, missing interrupts and driver initialization.

**Warning:** For USB logging to work on the usual left peripheral, this special diagnostic build temporarily sets `CONFIG_ZMK_SPLIT_ROLE_CENTRAL=y` and `CONFIG_SENSOR_LOG_LEVEL_DBG=y`. It acts as a temporary **central**, not the usual split peripheral. During this test normal left-right operation may not work; do not use this as everyday firmware. The right half needs no change for the local USB check.

**Recovery:** Reflash the ordinary `roBa_L` UF2 to the left half after the test. If necessary, power-cycle both halves to restore normal split operation. Flash the ordinary `roBa_R` UF2 to restore right-half ZMK Studio USB.

## What the results mean

| Observation | Implication |
| --- | --- |
| Right has SENSOR NOTIFICATION | Left has produced a sensor event and BLE transport delivered it |
| Right has no notification, left shows EC11 prev/new and Delta | Left GPIO and driver decoding work; investigate sensor-event generation/forwarding, and the change of role during this standalone test |
| Left shows EC11 prev/new but Delta always zero | Samples arrive, but quadrature transitions are not being decoded as expected |
| Left has logs for other modules but no EC11 activity | No EC11 processing observed; test driver initialization, interrupt setup and GPIO before concluding MCU failure |

No `steps`, `triggers-per-rotation`, or key bindings were changed. The test is meant to preserve the original sensor behavior while exposing its internal state.
