# Music App

Một ứng dụng Music App (nghe nhạc trực tuyến và ngoại tuyến) được viết bằng Flutter, áp dụng Clean Architecture (Feature-first) và state management hiện đại.

## 🚀 Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod (AsyncNotifierProvider)
- **Network**: Dio, Retrofit
- **Code Generation**: Freezed, Build Runner

## 📁 Cấu trúc thư mục (Clean Architecture)

- `lib/core/`: Chứa các module dùng chung (network, theme, constants, utils).
- `lib/features/`: Chia theo từng tính năng (auth, player, playlist, explore, feedback...).
  - **data/**: datasources (API/DB), models (DTOs), repositories (implementations).
  - **domain/**: entities, repositories (interfaces).
  - **presentation/**: controllers (Riverpod Notifiers), pages (UI), widgets.

## ✨ Tính năng

### 🎵 Tính năng cốt lõi (Core)
- **Home**: Slide Images + Auto Run (Realtime), tìm kiếm, hiển thị bài hát phổ biến & mới nhất, Bottom Control Layout.
- **Danh sách bài hát**: Tất cả bài hát, Nổi bật, Phổ biến, Mới nhất (Realtime).
- **Music Player**: Play, Pause, Next, Back, Tua nhạc, hiển thị thời gian, danh sách bài hát đang chạy, Push Notification Control.
- **Tính năng phụ trợ**: Gửi feedback (phản hồi, đánh giá), hiển thị thông tin Contact.

### 🌟 Tính năng nâng cao (Advanced)
- **Quản lý tài khoản (Auth)**:
  - 2 Role riêng biệt: Admin & User.
  - Đăng nhập, đăng ký, quên/đổi mật khẩu, xem Profile, đăng xuất.
- **Role Quản trị viên (Admin)**:
  - Quản lý bài hát (CRUD): Thêm, sửa, xóa, hiển thị danh sách.
  - Tìm kiếm bài hát theo tên trong trang quản trị.
  - Quản lý danh sách Feedback từ người dùng.
- **Role Người dùng (User)**:
  - Quản lý danh sách bài hát yêu thích (Favorite Songs) - Realtime.

## 🛠 Hướng dẫn chạy dự án

1. Clone dự án về máy:
   ```bash
   git clone https://github.com/DuyVu550/music_app.git
   ```
2. Cài đặt các dependencies:
   ```bash
   flutter pub get
   ```
3. Chạy code generation (nếu cần):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Khởi chạy ứng dụng:
   ```bash
   flutter run
   ```
