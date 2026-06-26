# Harmonix Music App - Phiên bản PRO 🎧

Một ứng dụng Music App (nghe nhạc trực tuyến và ngoại tuyến) được viết bằng Flutter, áp dụng kiến trúc sạch Clean Architecture (Feature-first) cùng bộ quản lý trạng thái hiện đại Riverpod. Phiên bản PRO này đã được hoàn thiện đầy đủ mọi tính năng nghiệp vụ, tối ưu hiệu suất và đạt tiêu chuẩn phân tích tĩnh tuyệt đối.

---

## 🚀 Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod (AsyncNotifierProvider)
- **Network**: Dio, Retrofit, Firebase Firestore
- **Audio Service**: Just Audio, Just Audio Background
- **Code Generation**: Freezed, Build Runner
- **Database**: Firebase (Auth & Firestore)

---

## 📁 Cấu trúc thư mục (Clean Architecture)

- `lib/core/`: Chứa các module dùng chung (network, theme, constants, utils).
- `lib/features/`: Chia theo từng tính năng (auth, player, playlist, explore, favorites, feedback, admin...).
  - **data/**: datasources (API/DB), models (DTOs), repositories (implementations).
  - **domain/**: entities, repositories (interfaces).
  - **presentation/**: controllers (Riverpod Notifiers), pages (UI), widgets.

---

## ✨ Tính năng phiên bản PRO

### 🎵 Trình phát nhạc cao cấp (Music Player Page)
- **Thông tin chi tiết**: Hiển thị ảnh bìa dạng đĩa nhạc xoay (Vinyl Style), tiêu đề, tên nghệ sĩ và **số lượt nghe** thực tế.
- **Bộ điều khiển toàn diện**: Hỗ trợ Play/Pause, Next/Back, tua nhạc bằng Slider (seek), **Phát ngẫu nhiên (Shuffle)** và **Lặp lại (Repeat One / Repeat All)**.
- **Tải bài hát trực tiếp**: Tích hợp nút Tải xuống (`download_rounded`) trên thanh tiêu đề để tải nhạc nhanh qua trình duyệt.
- **Quản lý Hàng đợi (Queue)**: Xem danh sách phát hiện tại bằng Bottom Sheet kéo vuốt và hỗ trợ **xóa bài hát khỏi hàng chờ** ngay tức thì.
- **Global Control**: Bottom Player Widget luôn hiện diện ở mọi màn hình để điều khiển nhanh.
- **Push Notification**: Điều khiển phát nhạc trực tiếp trên thanh thông báo hệ thống (Play/Pause, Next, Back, Close).

### 🌟 Hệ thống khám phá & Danh sách phát (Explore & Playlists)
- **Trang chủ (Home Page)**: Banner bài hát nổi bật tự động chạy (Auto Run), các mục đề cử bài hát mới nhất, phổ biến và nghệ sĩ nổi bật (Realtime).
- **Phân loại âm nhạc**:
  - Trang danh sách **Thể loại (Category List)** dạng lưới hiển thị sinh động.
  - Trang danh sách **Nghệ sĩ (Artist List)** dạng avatar tròn có hiệu ứng neon.
  - Bộ lọc bài hát chi tiết theo Thể loại & Nghệ sĩ tương ứng.
- **Danh sách phát**:
  - Trang Danh sách tất cả bài hát, bài hát yêu thích, bài hát nổi bật, bài hát phổ biến và bài hát mới.
- **Hàng đợi thông minh (Song Options Menu - Nút 3 chấm)**:
  - **Tải bài hát**: Tải trực tiếp qua liên kết bên ngoài.
  - **Ưu tiên phát kế tiếp (Play Next)**: Chèn bài hát ngay sau bài đang chạy.
  - **Thêm vào danh sách phát (Add to queue)**: Thêm bài hát vào cuối hàng chờ.
  - **Xóa khỏi danh sách phát (Remove from queue)**: Xóa bài hát khỏi hàng chờ.

### 🛡 Quản lý tài khoản (Auth)
- **Hệ thống phân quyền**: Phân chia 2 Role riêng biệt: **Admin** & **User**.
- Đăng nhập, đăng ký tài khoản mới, quên mật khẩu, đổi mật khẩu và quản lý thông tin cá nhân (Profile).
- **Yêu thích (Favorites)**: Đồng bộ danh sách bài hát yêu thích theo thời gian thực cho từng User.

### 👑 Bảng điều khiển Quản trị viên (Admin Panel - VIP)
- **Quản lý bài hát (CRUD)**: Cho phép hiển thị danh sách bài hát, thêm bài hát mới, chỉnh sửa thông tin và xóa bài hát trực tiếp.
- **Tìm kiếm thông minh**: Tìm kiếm bài hát theo tên hoặc nghệ sĩ trong trang quản lý.
- **Quản lý Thể loại (CRUD) [VIP]**: Cho phép hiển thị danh sách thể loại nhạc, thêm thể loại mới, chỉnh sửa tên/ảnh và xóa thể loại nhạc trực tiếp.
- **Quản lý Nghệ sĩ (CRUD) [VIP]**: Cho phép hiển thị danh sách nghệ sĩ, thêm nghệ sĩ mới, chỉnh sửa tên/ảnh và xóa nghệ sĩ trực tiếp.
- **Quản lý Feedback**: Xem danh sách phản hồi từ người dùng và hỗ trợ xóa phản hồi.
- **Tự động Khởi tạo Dữ liệu (Autoseed) [VIP]**: Tự động tạo dữ liệu mẫu cho Thể loại và Nghệ sĩ từ các bài hát hiện có nếu dữ liệu trên Firestore trống.

### 💬 Phản hồi & Liên hệ (Feedback & Contact)
- **Feedback**: Gửi đánh giá theo số sao (⭐) kèm ý kiến đóng góp lưu về Firestore.
- **Liên hệ**: Tích hợp đầy đủ các kênh liên hệ của nhà phát triển: Gmail, Website, Điện thoại, Facebook, Skype, Zalo, Youtube.

---

## 🛠 Hướng dẫn chạy dự án

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
   flutter test
   ```
5. **Khởi chạy**:
   ```bash
   flutter run
   ```
