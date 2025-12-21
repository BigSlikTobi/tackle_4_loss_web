import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import '../../services/audio_player_service.dart';
import '../../../../design_tokens.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: AudioPlayerService().mediaItemStream,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        
        // Hide if no audio is loaded
        if (mediaItem == null) return const SizedBox.shrink();

        return Positioned(
          bottom: kBottomNavigationBarHeight + 50, // Float above nav bar
          left: 16,
          right: 16,
          child: Dismissible(
            key: const Key('mini_player'),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => AudioPlayerService().stop(),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.cardDark.withOpacity(0.95), // Glassy dark look
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: const ColorFilter.mode(
                    Colors.transparent, 
                    BlendMode.multiply // Placeholder for blur if BackdropFilter was supported here 
                  ), 
                  // Note: real glass effect requires BackdropFilter above with ImageFilter.blur
                  // Simplifying for now.
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        // Art
                        if (mediaItem.artUri != null)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(mediaItem.artUri.toString()),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.music_note, color: Colors.white54, size: 20),
                          ),
                        
                        const SizedBox(width: 12),
                        
                        // Info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mediaItem.title,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mediaItem.artist ?? '',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Controls
                        StreamBuilder<PlaybackState>(
                          stream: AudioPlayerService().playbackStateStream,
                          builder: (context, stateSnapshot) {
                            final playing = stateSnapshot.data?.playing ?? false;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    if (playing) {
                                      AudioPlayerService().pause();
                                    } else {
                                      AudioPlayerService().resume();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 24),
                                  onPressed: () => AudioPlayerService().stop(),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }
}
