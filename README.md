# Harmonix Music App - Phiên bản PRO

Một ứng dụng Music App (nghe nhạc trực tuyến và ngoại tuyến) được viết bằng Flutter, áp dụng kiến trúc sạch Clean Architecture (Feature-first) cùng bộ quản lý trạng thái hiện đại Riverpod. Phiên bản PRO này đã được hoàn thiện đầy đủ mọi tính năng nghiệp vụ, tối ưu hiệu suất và đạt tiêu chuẩn phân tích tĩnh tuyệt đối.

---

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod (AsyncNotifierProvider)
- **Network**: Dio, Retrofit, Firebase Firestore
- **Audio Service**: Just Audio, Just Audio Background
- **Code Generation**: Freezed, Build Runner
- **Database**: Firebase (Auth & Firestore)

---

## Cấu trúc thư mục (Clean Architecture)

- `lib/core/`: Chứa các module dùng chung (network, theme, constants, utils).
- `lib/features/`: Chia theo từng tính năng (auth, player, playlist, explore, favorites, feedback, admin...).
  - **data/**: datasources (API/DB), models (DTOs), repositories (implementations).
  - **domain/**: entities, repositories (interfaces).
  - **presentation/**: controllers (Riverpod Notifiers), pages (UI), widgets.

---

## Tính năng phiên bản PRO

### Trình phát nhạc cao cấp (Music Player Page)
- **Thông tin chi tiết**: Hiển thị ảnh bìa dạng đĩa nhạc xoay (Vinyl Style), tiêu đề, tên nghệ sĩ và số lượt nghe thực tế.
- **Bộ điều khiển toàn diện**: Hỗ trợ Play/Pause, Next/Back, tua nhạc bằng Slider (seek), Phát ngẫu nhiên (Shuffle) và Lặp lại (Repeat One / Repeat All).
- **Tải bài hát ngoại tuyến**: Hỗ trợ tải trực tiếp bài hát về lưu trữ cục bộ của thiết bị để nghe khi không có mạng (Offline Playback).
- **Trang nhạc đã tải**: Xem danh sách các bài hát đã tải offline, phát tất cả hoặc xóa bản tải nhanh chóng.
- **Quản lý Hàng đợi (Queue)**: Xem danh sách phát hiện tại bằng Bottom Sheet kéo vuốt và hỗ trợ xóa bài hát khỏi hàng chờ ngay tức thì.
- **Global Control**: Bottom Player Widget luôn hiện diện ở mọi màn hình để điều khiển nhanh.
- **Push Notification**: Điều khiển phát nhạc trực tiếp trên thanh thông báo hệ thống (Play/Pause, Next, Back, Close).
- **Bộ cân bằng âm thanh & Hẹn giờ tắt (Equalizer & Sleep Timer)**:
  - Hẹn giờ tắt nhạc tự động theo thời gian (5m, 15m, 30m, 45m, 60m) hoặc tùy chọn "Hết bài hát hiện tại" (tự động dừng khi bài hát đang phát kết thúc).
  - Tích hợp Equalizer 5-Band Slider (60Hz, 230Hz, 910Hz, 4kHz, 14kHz) thực tế trên Android với các preset mẫu (Flat, Pop, Rock, Jazz, Classical, Bass Booster).
  - Trình mô phỏng sóng nhạc Audio Visualizer chuyển sắc lung linh chuyển động trực quan theo nhịp bài hát.
- **Đồng bộ lời bài hát thời gian thực (Realtime Lyrics Sync)**:
  - Chạm vào đĩa nhạc để chuyển đổi qua lại giữa hình đĩa xoay Vinyl và màn hình lời bài hát.
  - Hỗ trợ định dạng lời nhạc LRC, tự động cuộn mượt mà và làm nổi bật (highlight/center) dòng lời hát đang phát.
- **Hiệu ứng chuyển bài mượt mà (Crossfade)**: Hỗ trợ tự động làm mờ âm thanh bài đang phát (fade out) và tăng dần âm thanh bài tiếp theo (fade in) chạy song song với khoảng thời gian tùy chọn từ 0 đến 12 giây bằng Slider trực quan.


### Bình luận & Phản hồi (Comments & Feedback)
- **Hệ thống bình luận thời gian thực (Comments Section)**:
  - Cho phép người dùng xem và đăng bình luận thảo luận dưới mỗi bài hát trong thời gian thực.
  - Avatar đại diện phối màu tự động ngẫu nhiên theo tên người dùng, hiển thị mốc thời gian đăng thân thiện ("Vừa xong", "10 phút trước"...).
  - Phân quyền bảo mật: Cho phép chính chủ bình luận hoặc tài khoản Admin thực hiện xóa bình luận ngay tại giao diện.
- **Feedback**: Gửi đánh giá theo số sao kèm ý kiến đóng góp lưu về Firestore.
- **Liên hệ**: Tích hợp đầy đủ các kênh liên hệ của nhà phát triển: Gmail, Website, Điện thoại, Facebook, Skype, Zalo, Youtube.

### Hệ thống khám phá & Danh sách phát (Explore & Playlists)
- **Trang chủ (Home Page)**: Banner bài hát nổi bật tự động chạy (Auto Run), các mục đề cử bài hát mới nhất, phổ biến và nghệ sĩ nổi bật (Realtime).
- **Thống kê âm nhạc (Music Wrapped)**: 
  - Ghi nhận lịch sử nghe nhạc của từng cá nhân sau khi nghe tối thiểu 30 giây.
  - Thống kê chi tiết: Tổng lượt nghe, số bài hát khác nhau, nghệ sĩ đã nghe và tổng số phút nghe ước tính.
  - Xếp hạng Top 5 bài hát được nghe nhiều nhất và Top 5 nghệ sĩ yêu thích cùng biểu đồ và danh sách lịch sử nghe gần đây.
- **Danh sách phát cá nhân của người dùng (User Custom Playlists)**:
  - Hỗ trợ người dùng tự tạo playlist cá nhân (tên, mô tả, ảnh bìa tự chọn).
  - Cho phép chỉnh sửa thông tin, xóa playlist.
  - Tích hợp giao diện Tìm kiếm & Thêm bài hát trực tiếp vào playlist vô cùng mượt mà ngay tại trang chi tiết playlist.
- **Phân loại âm nhạc**:
  - Trang danh sách Thể loại (Category List) dạng lưới hiển thị sinh động.
  - Trang danh sách Nghệ sĩ (Artist List) dạng avatar tròn có hiệu ứng neon.
  - Bộ lọc bài hát chi tiết theo Thể loại & Nghệ sĩ tương ứng.
- **Danh sách phát**:
  - Trang Danh sách tất cả bài hát, bài hát yêu thích, bài hát nổi bật, bài hát phổ biến và bài hát mới.
- **Hàng đợi thông minh (Song Options Menu - Nút 3 chấm)**:
  - **Tải để nghe offline**: Tải bài hát về lưu trữ local của thiết bị.
  - **Ưu tiên phát kế tiếp (Play Next)**: Chèn bài hát ngay sau bài đang chạy.
  - **Thêm vào danh sách phát (Add to queue)**: Thêm bài hát vào cuối hàng chờ.
  - **Xóa khỏi danh sách phát (Remove from queue)**: Xóa bài hát khỏi hàng chờ.
  - **Thêm vào Playlist**: Thêm bài hát vào danh sách phát cá nhân của người dùng.

### Quản lý tài khoản (Auth)
- **Hệ thống phân quyền**: Phân chia 2 Role riêng biệt: Admin & User.
- Đăng nhập, đăng ký tài khoản mới, quên mật khẩu, đổi mật khẩu và quản lý thông tin cá nhân (Profile).
- **Yêu thích (Favorites)**: Đồng bộ danh sách bài hát yêu thích theo thời gian thực cho từng User.

### Bảng điều khiển Quản trị viên (Admin Panel - VIP)
- **Dashboard quản trị**: Hiển thị tổng quan số lượng bài hát, người dùng, nghệ sĩ, thể loại và biểu đồ top bài hát có lượt nghe nhiều nhất hệ thống.
- **Quản lý Album (CRUD)**: Cho phép tạo mới album, cập nhật thông tin (tiêu đề, ảnh bìa, nghệ sĩ, năm phát hành) và xóa album. Hỗ trợ liên kết bài hát vào album thông qua giao diện cập nhật bài hát.
- **Quản lý bài hát (CRUD)**: Cho phép hiển thị danh sách bài hát, thêm bài hát mới, chỉnh sửa thông tin và xóa bài hát trực tiếp.
- **Tìm kiếm thông minh**: Tìm kiếm bài hát theo tên hoặc nghệ sĩ trong trang quản lý.
- **Quản lý Thể loại (CRUD)**: Cho phép hiển thị danh sách thể loại nhạc, thêm thể loại mới, chỉnh sửa tên/ảnh và xóa thể loại nhạc trực tiếp.
- **Quản lý Nghệ sĩ (CRUD)**: Cho phép hiển thị danh sách nghệ sĩ, thêm nghệ sĩ mới, chỉnh sửa tên/ảnh và xóa nghệ sĩ trực tiếp.
- **Quản lý Feedback**: Xem danh sách phản hồi từ người dùng và hỗ trợ xóa phản hồi.
- **Tự động Khởi tạo Dữ liệu (Autoseed)**: Tự động tạo dữ liệu mẫu cho Thể loại và Nghệ sĩ từ các bài hát hiện có nếu dữ liệu trên Firestore trống.

---

## Hướng dẫn chạy dự án

1. **Clone dự án**:
   ```bash
   git clone https://github.com/DuyVu550/music_app.git
   ```
2. **Cài đặt thư viện**:
   ```bash
   flutter pub get
   ```
3. **Sinh mã nguồn Freezed**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Kiểm thử & Kiểm tra Code**:
   ```bash
   flutter analyze
   ```
   ```bash
   flutter test
   ```
5. **Khởi chạy**:
   ```bash
   flutter run
   ```
