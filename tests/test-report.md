# ClickBotz test report

PASS: 70 assertions. Real GUI pixels use production BuildProfiles, MatchPixels/PixelSearch and ChooseAction. Covered none, primary click, play/stop Space, option, manual option suppression, secondary fallback at each desktop-supported size. Source app starts; F10 toggles; absent game waits and sends zero actions.

- Skipped: 2560x1080 real pixels (desktop is 1920x1080); geometry checked.

Original executable was not executed. Only owned test windows/processes were created and cleaned up. No live game integration test performed.
