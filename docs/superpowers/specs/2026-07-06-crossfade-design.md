# Crossfade Feature Design

**Date:** 2026-07-06
**App:** Harmonix Music (Flutter + Riverpod + just_audio)
**Status:** Approved by user

---

## Problem

Khi chuyển bài, âm thanh bị cắt đột ngột. Người dùng muốn crossfade mượt mà giữa các bài.

## Goal

Crossfade: bài hiện tại fade out, bài tiếp theo fade in, chạy song song trong khoảng crossfadeDuration giây. Hoạt động trên Android, iOS, Web.

---

## Approach: Dual AudioPlayer + Volume Fade

just_audio không có native crossfade API. Giải pháp: 2 AudioPlayer instance song song, dùng setVolume() + Timer để fade.

Không thêm dependency mới — just_audio đã cài, setVolume() hoạt động mọi platform.

---

## Architecture

### Dual-player model
- _primaryPlayer   — đang phát bài hiện tại
- _secondaryPlayer — standby, load bài tiếp theo khi cần crossfade

Khi crossfade hoàn tất, vai trò hai player swap (primary <-> secondary).

### Crossfade trigger
positionStream:
  khi (duration - position) <= crossfadeDuration
  AND crossfadeDuration > 0
  AND _isCrossfading == false
  -> _startCrossfade(nextTrack)

### Fade loop
Timer.periodic(50ms):
  t = elapsed / crossfadeDuration  (0.0 -> 1.0)
  _primaryPlayer.setVolume(1.0 - t)
  _secondaryPlayer.setVolume(t)
  t >= 1.0: stop primary, swap, cancel timer

---

## Components

### Modified: AudioPlayerService
- _secondaryPlayer: AudioPlayer instance mới
- _isCrossfading: bool guard
- _crossfadeDuration: Duration, default Duration.zero
- setCrossfadeDuration(Duration): setter public
- _startCrossfade(Track next): load + fade timer
- dispose(): dispose ca hai players

### Modified: PlayerState
Them field: @Default(0) int crossfadeDurationSeconds

### Modified: PlayerNotifier
- setCrossfadeDuration(int seconds)
- positionStream listener: check va trigger crossfade

### Modified: player_page.dart
Them Slider crossfade (0-12s) trong Settings section.

---

## Edge Cases
- Crossfade = 0: disable, behavior cu
- Loop one: seek ve 0, khong crossfade
- Playlist 1 bai: khong trigger
- User seek thu cong: reset _isCrossfading, huy timer

---

## Out of Scope
- Equalizer tren secondary player (YAGNI)
- Luu setting ve Firestore (chi in-memory)
- Crossfade khi nhan next thu cong
