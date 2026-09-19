import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pharmaish/shared/widgets/authenticated_image.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';

/// Plays the voice note uploaded with a voice order.
///
/// The recording is served by the authenticated order input file endpoint, so
/// it is downloaded to a temp file on first play rather than streamed.
class VoiceNotePlayerWidget extends StatefulWidget {
  final String orderId;

  /// Stored file location of the voice note, used to detect the audio format.
  final String? fileUrl;

  const VoiceNotePlayerWidget({
    super.key,
    required this.orderId,
    this.fileUrl,
  });

  @override
  State<VoiceNotePlayerWidget> createState() => _VoiceNotePlayerWidgetState();
}

class _VoiceNotePlayerWidgetState extends State<VoiceNotePlayerWidget> {
  static const List<double> _playbackSpeeds = [1.0, 1.5, 2.0, 0.5];

  FlutterSoundPlayer? _audioPlayer;
  StreamSubscription<PlaybackDisposition>? _playerSubscription;
  String? _audioFilePath;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  Duration _playbackPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackSpeed = 1.0;

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _audioPlayer?.closePlayer();
    _audioPlayer = null;
    final audioFilePath = _audioFilePath;
    if (audioFilePath != null) {
      File(audioFilePath).delete().ignore();
    }
    super.dispose();
  }

  /// File extension of the uploaded voice note. Voice orders are recorded as
  /// AAC (see VoiceOrderScreen), so that is the fallback.
  String get _audioExtension {
    final fileName = extractFileName(widget.fileUrl);
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == fileName.length - 1) return 'aac';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  Codec get _audioCodec {
    switch (_audioExtension) {
      case 'mp3':
        return Codec.mp3;
      case 'm4a':
      case 'mp4':
        return Codec.aacMP4;
      case 'wav':
        return Codec.pcm16WAV;
      case 'ogg':
        return Codec.opusOGG;
      default:
        return Codec.aacADTS;
    }
  }

  /// Downloads the voice note to a temp file. The endpoint needs the JWT
  /// header, so the player cannot stream it straight from the URL.
  Future<String> _downloadVoiceNote() async {
    final token = await StorageService.getAuthToken();
    final dir = await getTemporaryDirectory();
    final savePath =
        '${dir.path}/voice_order_${widget.orderId}.$_audioExtension';

    await Dio().download(
      getOrderInputFileUrl(widget.orderId),
      savePath,
      options: Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      ),
    );
    return savePath;
  }

  Future<void> _togglePlayback() async {
    if (_isLoadingAudio) return;

    try {
      final player = _audioPlayer;
      if (player != null && player.isPlaying) {
        await player.pausePlayer();
        if (mounted) setState(() => _isPlaying = false);
        return;
      }
      if (player != null && player.isPaused) {
        await player.resumePlayer();
        if (mounted) setState(() => _isPlaying = true);
        return;
      }
      await _startPlayback();
    } catch (e) {
      AppLogger.error('Error playing voice note: $e');
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoadingAudio = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to play voice recording')),
        );
      }
    }
  }

  Future<void> _startPlayback() async {
    setState(() => _isLoadingAudio = true);

    _audioFilePath ??= await _downloadVoiceNote();
    if (!mounted) return;

    if (_audioPlayer == null) {
      final player = FlutterSoundPlayer();
      await player.openPlayer();
      await player.setSubscriptionDuration(const Duration(milliseconds: 200));
      if (!mounted) {
        await player.closePlayer();
        return;
      }
      _playerSubscription = player.onProgress!.listen((event) {
        if (!mounted) return;
        setState(() {
          _playbackPosition = event.position;
          _totalDuration = event.duration;
        });
      });
      _audioPlayer = player;
    }

    await _audioPlayer!.startPlayer(
      fromURI: _audioFilePath,
      codec: _audioCodec,
      whenFinished: () {
        if (!mounted) return;
        setState(() {
          _isPlaying = false;
          _playbackPosition = Duration.zero;
        });
      },
    );
    if (_playbackSpeed != 1.0) {
      await _audioPlayer!.setSpeed(_playbackSpeed);
    }

    if (!mounted) return;
    setState(() {
      _isPlaying = true;
      _isLoadingAudio = false;
    });
  }

  Future<void> _seekTo(double fraction) async {
    final player = _audioPlayer;
    if (player == null || _totalDuration == Duration.zero) return;

    final target = Duration(
        milliseconds: (_totalDuration.inMilliseconds * fraction).round());
    setState(() => _playbackPosition = target);

    try {
      if (player.isPlaying || player.isPaused) {
        await player.seekToPlayer(target);
      }
    } catch (e) {
      AppLogger.error('Error seeking voice note: $e');
    }
  }

  Future<void> _cyclePlaybackSpeed() async {
    final nextIndex =
        (_playbackSpeeds.indexOf(_playbackSpeed) + 1) % _playbackSpeeds.length;
    final speed = _playbackSpeeds[nextIndex];
    setState(() => _playbackSpeed = speed);

    try {
      final player = _audioPlayer;
      if (player != null && (player.isPlaying || player.isPaused)) {
        await player.setSpeed(speed);
      }
    } catch (e) {
      AppLogger.error('Error changing playback speed: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalDuration.inMilliseconds > 0
        ? (_playbackPosition.inMilliseconds / _totalDuration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;
    final speedLabel = _playbackSpeed == _playbackSpeed.roundToDouble()
        ? '${_playbackSpeed.toInt()}x'
        : '${_playbackSpeed}x';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _togglePlayback,
            child: _isLoadingAudio
                ? const SizedBox(
                    width: 60,
                    height: 60,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: Colors.purple),
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 60,
                    color: Colors.purple.shade400,
                  ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Voice Recording',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: _isLoadingAudio ? null : _togglePlayback,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
                color: Colors.purple,
              ),
              Expanded(
                child: Slider(
                  value: progress,
                  onChanged: _totalDuration > Duration.zero ? _seekTo : null,
                  activeColor: Colors.purple,
                ),
              ),
              Text(
                '${_formatDuration(_playbackPosition)} / '
                '${_formatDuration(_totalDuration)}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _cyclePlaybackSpeed,
                icon: const Icon(Icons.speed),
                label: Text('Speed $speedLabel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
