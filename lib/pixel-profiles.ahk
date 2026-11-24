; Coordinates follow the observed 1280x720 reference geometry.
BuildProfiles(w, h) {
    s := Min(w / 1280, h / 720)
    wide := w >= 2 * h
    sx := (x) => (x + 0.5) * s - 0.5
    right := (x) => w - 1 - sx(1279 - x)
    bottom := (y) => h - 1 - sx(719 - y)
    marker := (y) => [
        [w / 2, bottom(y), 0xFFBF01, 0, s * 5, 8],
        [w / 2 - s * 2, bottom(y), 0xFFBF01, 0, s * 5, 8],
        [w / 2 + s * 2, bottom(y), 0xFFBF01, 0, s * 5, 8]]
    d := wide ? 96 : 0
    play := [[sx(47+d), sx(30), 0x3B4354, 0, 0, 8],
        [sx(50+d), sx(32), 0x3B4354, 0, 0, 8],
        [sx(47+d), sx(35), 0x3B4354, 0, 0, 8]]
    stop := [[sx(44+d), sx(32), 0x3B4354, 0, 0, 8],
        [sx(47+d), sx(32), 0xECE5D8, 0, 0, 2],
        [sx(51+d), sx(32), 0x3B4354, 0, 0, 8]]
    y := h - sx(720 - (wide ? 525 : 535))
    d := wide ? 92 : 0
    option := [[right(860-d), y, 0x5F676F, s, s, 32],
        [right(863-d), y, 0xFFFFFF, s, s, 2],
        [right(866-d), y, 0x606870, s, s, 32],
        [right(869-d), y, 0xFFFFFF, s, s, 2],
        [right(872-d), y, 0x606971, s, s, 32]]
    return {primary: marker(wide ? 688 : 698),
        secondary: marker(wide ? 688 : 685), play: play, stop: stop, option: option}
}

MatchPixels(profile, &outX, &outY) {
    outX := 0, outY := 0
    for p in profile {
        x := Round(p[1]), y := Round(p[2])
        dx := Ceil(p[4]), dy := Ceil(p[5])
        if !PixelSearch(&outX, &outY, x-dx, y-dy, x+dx, y+dy, p[3], p[6])
            return false
    }
    return true
}

ChooseAction(profiles, manual, matcher := MatchPixels) {
    if matcher(profiles.primary, &x, &y) {
        px := x, py := y
        if matcher(profiles.play, &x, &y) || matcher(profiles.stop, &x, &y)
            return {kind: 'space', x: 0, y: 0}
        return {kind: 'click', x: px, y: py}
    }
    if !manual && matcher(profiles.option, &x, &y)
        return {kind: 'option', x: x, y: y}
    if matcher(profiles.secondary, &x, &y)
        return {kind: 'click', x: x, y: y}
    return {kind: 'none', x: 0, y: 0}
}
