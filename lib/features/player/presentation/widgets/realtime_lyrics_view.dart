import 'package:flutter/material.dart';
import '../../../../core/utils/lrc_parser.dart';
import '../../domain/entities/track.dart';

class RealtimeLyricsView extends StatefulWidget {
  final Track track;
  final Duration currentPosition;

  const RealtimeLyricsView({
    super.key,
    required this.track,
    required this.currentPosition,
  });

  @override
  State<RealtimeLyricsView> createState() => _RealtimeLyricsViewState();
}

class _RealtimeLyricsViewState extends State<RealtimeLyricsView> {
  final ScrollController _scrollController = ScrollController();
  List<LrcLine> _lyrics = [];
  int _activeIndex = -1;
  static const double _itemHeight = 64.0;

  @override
  void initState() {
    super.initState();
    _parseLyrics();
    _updateActiveIndex();
  }

  @override
  void didUpdateWidget(RealtimeLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.id != widget.track.id || oldWidget.track.lyrics != widget.track.lyrics) {
      _parseLyrics();
    }
    _updateActiveIndex();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _parseLyrics() {
    _lyrics = LrcParser.parse(widget.track.lyrics ?? '');
    _activeIndex = -1;
  }

  void _updateActiveIndex() {
    if (_lyrics.isEmpty) return;

    int newIndex = -1;
    for (int i = 0; i < _lyrics.length; i++) {
      // For plain lyrics with timestamp 0, we don't advance the index
      if (_lyrics[i].timestamp == Duration.zero && _lyrics[i].timestamp == widget.currentPosition) {
        newIndex = i;
        break;
      }
      if (_lyrics[i].timestamp <= widget.currentPosition && _lyrics[i].timestamp != Duration.zero) {
        newIndex = i;
      } else if (_lyrics[i].timestamp > widget.currentPosition) {
        break;
      }
    }

    // Special check for plain text fallback (all timestamps are Duration.zero)
    final isPlainText = _lyrics.isNotEmpty && _lyrics.every((line) => line.timestamp == Duration.zero);
    if (isPlainText) {
      newIndex = -1; // Don't highlight any line based on position
    }

    if (newIndex != _activeIndex) {
      setState(() {
        _activeIndex = newIndex;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActiveLine();
      });
    }
  }

  void _scrollToActiveLine() {
    if (!_scrollController.hasClients || _activeIndex < 0) return;

    final contextHeight = context.size?.height ?? 300.0;
    final scrollOffset = (_activeIndex * _itemHeight) - (contextHeight / 2) + (_itemHeight / 2);
    final maxScroll = _scrollController.position.maxScrollExtent;
    final minScroll = _scrollController.position.minScrollExtent;

    double targetOffset = scrollOffset;
    if (targetOffset > maxScroll) targetOffset = maxScroll;
    if (targetOffset < minScroll) targetOffset = minScroll;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_lyrics.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Không có lời bài hát',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ),
      );
    }

    final isPlainText = _lyrics.isNotEmpty && _lyrics.every((line) => line.timestamp == Duration.zero);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final listPadding = isPlainText 
            ? const EdgeInsets.symmetric(vertical: 24.0)
            : EdgeInsets.symmetric(vertical: height / 2 - _itemHeight / 2);

        return ListView.builder(
          controller: _scrollController,
          padding: listPadding,
          itemCount: _lyrics.length,
          itemExtent: isPlainText ? null : _itemHeight,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final line = _lyrics[index];
            final isActive = index == _activeIndex;

            if (isPlainText) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                alignment: Alignment.center,
                child: Text(
                  line.text,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Container(
              height: _itemHeight,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: isActive ? Colors.cyanAccent : Colors.white.withValues(alpha: 0.35),
                  fontSize: isActive ? 20.0 : 16.0,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                child: Text(
                  line.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
