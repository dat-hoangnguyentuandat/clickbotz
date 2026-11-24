# ClickBotz custom macro test report

PASS: 32 assertions. Tested production modules with real GUI RGB capture, editor add/edit/move/delete, persistence and invalid-load preservation, real sequential clicks, key delivery, wait delay, color match/mismatch timeout, duration expiry, countdown, F9 stop and stale-generation guard. Pointer restored after left/right/color clicks while actual owned target receives each click; stopped/expired clicks neither move pointer nor send input. Test storage: tests/results/test-macro.ini. Owned GUI windows cleaned; no original executable or user macro.ini used.
