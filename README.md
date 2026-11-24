# ClickBotz 2 — Custom Macro

Bản sửa trả chuột: `ClickBotz-2.0.1.exe`. Lưu macro và thoát bản đang mở qua menu khay trước khi mở bản này. Dùng chung `macro.ini` cạnh EXE.

Ứng dụng Windows bằng AutoHotkey v2 để tạo chuỗi click, phím, chờ và điều kiện màu; lặp trong số giây đã đặt. Mở `ClickBotz.exe`, không cần cài AutoHotkey.

## Cách dùng

1. Chọn **Loại bước**, bấm **Setup: lấy vị trí + màu**. Tool ẩn cửa sổ.
2. Trỏ chuột vào điểm cần lấy, nhấn **F8** để điền X/Y và màu HEX; **Esc** hủy.
3. Đặt thời gian chờ rồi bấm **Thêm bước**. Setup lại cho từng điểm khác.
4. Chọn bước trong danh sách để sửa, bấm **Cập nhật bước**. Dùng **Lên/Xuống/Xóa bước** để sắp xếp.
5. Đặt **Lặp trong (giây)** và **Nghỉ giữa vòng (ms)**. Bấm **Lưu macro** để ghi `macro.ini`.
6. **F10** chạy/dừng. Có 3 giây chuyển sang cửa sổ đích trước khi bắt đầu tính thời lượng. **F9** dừng ngay.

Ví dụ: Setup nút A → Click trái, chờ sau 300 ms → Thêm bước. Setup nút B → Click trái, chờ sau 500 ms → Thêm bước. Đặt lặp 30 giây: click A, đợi 300 ms, click B, đợi 500 ms, nghỉ giữa vòng rồi lặp. Hết thời lượng sẽ dừng kể cả chưa xong vòng.

## Các loại bước

| Loại | Hoạt động |
| --- | --- |
| Click trái / phải | Click tại X/Y rồi đợi Chờ sau (ms). |
| Nhấn phím | Gửi `Enter`, `Space`, `a`, hoặc `^a` (Ctrl+A), rồi đợi. F9/F10 dành cho điều khiển. |
| Chờ | Đợi số ms đã đặt. |
| Chờ màu | Đợi pixel tại X/Y khớp HEX rồi đợi Chờ sau. |
| Chờ màu rồi click | Đợi màu khớp, click trái tại đó rồi đợi. |

Sai số màu áp dụng riêng từng kênh RGB: 0 khớp chính xác, 255 cho phép mọi màu. Timeout màu tính bằng ms; hết hạn sẽ dừng cả macro. Setup chỉ lấy điểm để soạn từng bước, không tự ghi lại luồng click.

## Lưu và giới hạn

`macro.ini` nạp tự động khi mở app; **Nạp lại** đọc bản đã lưu. Thay đổi chỉ được lưu khi bấm **Lưu macro**. Đóng cửa sổ sẽ dừng macro và thu xuống khay; menu khay cho mở lại hoặc thoát.

Tọa độ màn hình tuyệt đối, không tự gắn với cửa sổ game. Di chuyển cửa sổ hoặc đổi bố cục/tỷ lệ màn hình có thể cần Setup lại. Phím gửi tới cửa sổ đang active. HDR và hiệu ứng có thể làm màu thay đổi. App không tự nâng quyền quản trị; input có thể không tới ứng dụng chạy quyền cao hơn.

Sau mỗi click trái/phải hoặc chờ màu rồi click, con trỏ được trả ngay về vị trí trước click, giống cách script gốc xử lý. Click vẫn dùng chuột hệ thống trong khoảnh khắc đó; đây không phải click nền độc lập với chuột của anh.

Bản cũ giữ tại `ClickBotz-v1-backup.exe`. [Phân tích EXE gốc](docs/original-analysis.md) là lịch sử v1; profile pixel cũ không điều khiển v2. Chưa kiểm chứng trên phiên Genshin thật.

## Mã nguồn và build

```powershell
cd E:\Project\EarnMoney\mmo\clickbotz
.\build.ps1
.\tools\autohotkey\AutoHotkey64.exe /ErrorStdOut .\clickbotz.ahk
```

Toolchain portable: AutoHotkey 2.0.19 và Ahk2Exe 1.1.37.02a2, dùng runtime v2 qua /base. Nguồn: [AutoHotkey](https://github.com/AutoHotkey/AutoHotkey/releases), [Ahk2Exe](https://github.com/AutoHotkey/Ahk2Exe/releases/tag/Ahk2Exe1.1.37.02a2). Giấy phép runtime tại `tools/autohotkey/license.txt`.

Xem [kiến trúc](docs/system-architecture.md) và [phạm vi kiểm chứng](docs/code-review.md). Bộ kiểm tra v1 không xác nhận macro v2.
