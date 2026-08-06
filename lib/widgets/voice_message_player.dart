import 'package:va_bookats/models/support_message.dart';
import 'package:va_bookats/utilities/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class VoiceMessagePlayer extends StatefulWidget {
  final SupportMessage message;
  final bool isMe;

  const VoiceMessagePlayer({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  late final AudioPlayer _audioPlayer;
  final _isPlaying = false.obs;
  final _position = Duration.zero.obs;
  final _duration = Duration.zero.obs;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.message.fileUrl != null) {
        await _audioPlayer.setUrl(widget.message.fileUrl!);
      }

      _audioPlayer.playerStateStream.listen((state) {
        _isPlaying.value = state.playing;
      });

      _audioPlayer.positionStream.listen((position) {
        _position.value = position;
      });

      _audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          _duration.value = duration;
        }
      });
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: widget.isMe
            ? AppColors.secondary
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => InkWell(
            onTap: _togglePlayPause,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.isMe
                    ? AppColors.white.withValues(alpha: 0.2)
                    : AppColors.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying.value ? Icons.pause : Icons.play_arrow,
                color: widget.isMe ? AppColors.white : AppColors.secondary,
                size: 20,
              ),
            ),
          )),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final duration = _duration.value.inSeconds > 0
                      ? _duration.value
                      : Duration(seconds: widget.message.voiceDuration ?? 0);

                  return SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: widget.isMe
                          ? AppColors.white
                          : AppColors.secondary,
                      inactiveTrackColor: widget.isMe
                          ? AppColors.white.withValues(alpha: 0.3)
                          : AppColors.grey.withValues(alpha: 0.3),
                      thumbColor: widget.isMe
                          ? AppColors.white
                          : AppColors.secondary,
                      overlayColor: widget.isMe
                          ? AppColors.white.withValues(alpha: 0.2)
                          : AppColors.secondary.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: _position.value.inSeconds.toDouble(),
                      max: duration.inSeconds.toDouble(),
                      onChanged: (value) async {
                        await _audioPlayer.seek(
                          Duration(seconds: value.toInt()),
                        );
                      },
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Obx(() {
                    final position = _formatDuration(_position.value);
                    final duration = _duration.value.inSeconds > 0
                        ? _formatDuration(_duration.value)
                        : _formatDuration(
                            Duration(seconds: widget.message.voiceDuration ?? 0),
                          );

                    return Text(
                      '$position / $duration',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isMe
                            ? AppColors.white.withValues(alpha: 0.8)
                            : AppColors.grey.withValues(alpha: 0.8),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}