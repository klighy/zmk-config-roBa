# roBa encoder event diagnostics

This branch adds an **extra right-half diagnostic build** named `roBa_R_encoder_debug`.
The usual `roBa_R`, `roBa_L`, and `settings_reset` builds remain available.

## Flash and inspect

1. In GitHub Actions, open the build artifact named `roBa_R_encoder_debug`. Extract and flash the right-hand UF2 **only**. Keep the regular left-hand firmware.
2. Connect the **right (central)** half to a PC with USB and leave the left half powered on and connected via BLE.
3. Open the new USB CDC ACM serial port with a serial terminal (e.g. `tio /dev/cu.usbmodem*` on macOS, or PuTTY on Windows).
4. Rotate the encoder slowly in both directions and look for messages such as:
   - `[SENSOR NOTIFICATION] data ... length ...` from the central BLE handler
   - `val1: ... val2: ... remainder: ... triggers: ...` from the rotation behavior

If the first line appears but `triggers` is zero, the event arrived at the central but did not generate a key action. If neither appears, it does **not** prove the MCU GPIO is defective; the cause could be GPIO interrupts, the local EC11 driver, the sensor event path, BLE transport, or logging.

**Limitation:** The EC11 driver's `prev/new` and `Delta` logs are local to the **left peripheral**. They are not forwarded to the right half. Capturing those requires left-side RTT logging with a suitable SWD debug probe, or a separate temporary on-device GPIO diagnostic.

## Return to normal

Flash the ordinary `roBa_R` artifact to restore the regular ZMK Studio USB connection. Do not flash the diagnostic artifact to the left half.

No encoder resolution or keymap settings were changed, to preserve the original failure symptoms.
