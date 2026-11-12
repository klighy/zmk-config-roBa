# PMW3610 driver

This copy is based on [kumamuk-git/zmk-pmw3610-driver at 5e04553](https://github.com/kumamuk-git/zmk-pmw3610-driver/commit/5e04553ab803d24405bd45621a41310ea3050e59).
The roBa Zephyr module builds it from this checkout.

In scroll mode, `CONFIG_PMW3610_SCROLL_DEADZONE` filters small deltas on each
axis after software polling has combined the raw samples. The driver checks the
vertical axis first and uses the full delta of the selected axis. It emits at
most one wheel event per motion sample and uses 64 sensor counts per nominal
detent. Signed remainders of up to three counts are kept separately for both
axes until the next entry into scroll mode.
