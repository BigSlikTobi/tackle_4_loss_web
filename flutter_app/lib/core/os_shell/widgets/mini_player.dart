import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import '../../theme/t4l_theme.dart';
import '../../services/audio_player_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<T4LThemeColors>()!;
    final audioService = AudioPlayerService();

    return StreamBuilder<MediaItem?>(
      stream: audioService.mediaItemStream,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.8), // Glassier
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              // Art
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  mediaItem.artUri?.toString() ?? '',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (c,e,s) => Container(width: 48, height: 48, color: colors.background),
                ),
              ),
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mediaItem.title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold, 
                        fontSize: 14,
                        color: colors.textPrimary
                      ),
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      mediaItem.artist ?? '',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: colors.textSecondary
                      ),
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.skip_previous_rounded, color: colors.textPrimary, size: 28),
                    onPressed: audioService.skipToPrevious,
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<PlaybackState>(
                    stream: audioService.playbackStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                          color: colors.brand,
                          size: 40,
                        ),
                        onPressed: playing ? audioService.pause : audioService.resume,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.skip_next_rounded, color: colors.textPrimary, size: 28),
                    onPressed: audioService.skipToNext,
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.close_rounded, color: colors.textSecondary, size: 18),
                    onPressed: audioService.stop,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
