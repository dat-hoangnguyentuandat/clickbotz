StepKinds := ['Click trái', 'Click phải', 'Nhấn phím', 'Chờ', 'Chờ màu', 'Chờ màu rồi click']
ParseNumber(value, low, high, label) {
    if !IsNumber(value) || value < low || value > high
        throw ValueError(label ' phải từ ' low ' đến ' high '.')
    return Number(value)
}
KeySequence(value) {
    value := Trim(value)
    if !RegExMatch(value, '^([\^!+#]*)([A-Za-z0-9_]+)$', &parts)
        throw ValueError('Nhập Enter, Space, F1, a hoặc ^a (Ctrl+A).')
    name := parts[2]
    if !GetKeyVK(name) && !GetKeySC(name)
        throw ValueError('Tên phím không hợp lệ: ' name)
    if RegExMatch(name, 'i)^(F9|F10|LButton|RButton|MButton|Wheel.*)$')
        throw ValueError('F9/F10 dành cho điều khiển; nút chuột dùng bước Click.')
    return parts[1] '{' name '}'
}
ValidateStep(step) {
    if step.kind < 1 || step.kind > StepKinds.Length
        throw ValueError('Loại bước không hợp lệ.')
    step.x := Integer(ParseNumber(step.x, -100000, 100000, 'X'))
    step.y := Integer(ParseNumber(step.y, -100000, 100000, 'Y'))
    step.delay := Integer(ParseNumber(step.delay, 0, 3600000, 'Thời gian chờ'))
    step.tolerance := Integer(ParseNumber(step.tolerance, 0, 255, 'Sai số màu'))
    step.timeout := Integer(ParseNumber(step.timeout, 100, 3600000, 'Timeout'))
    if !RegExMatch(step.color, 'i)^(?:0x)?[0-9a-f]{6}$')
        throw ValueError('Màu phải gồm 6 ký tự hex, ví dụ FFCC00.')
    step.color := Format('{:06X}', Integer('0x' RegExReplace(step.color, 'i)^0x')))
    if step.kind = 3
        KeySequence(step.key)
    return step
}
ColorMatches(actual, expected, tolerance) {
    for shift in [0, 8, 16]
        if Abs(((actual >> shift) & 255) - ((expected >> shift) & 255)) > tolerance
            return false
    return true
}
