import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/global.dart'; // Access global audioHandler
import '../services/audio_handler.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // We only show the player if there's a valid media item
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, mediaSnapshot) {
        final mediaItem = mediaSnapshot.data;
        if (mediaItem == null) {
           return const SizedBox.shrink();
        }

        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, playbackSnapshot) {
             final playbackState = playbackSnapshot.data;
             final processingState = playbackState?.processingState;
             final isPlaying = playbackState?.playing ?? false;

             if (processingState == AudioProcessingState.idle) {
               return const SizedBox.shrink();
             }

             return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF18181B), // Zinc 900
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF27272A)), // Zinc 800
                ),
                child: Row(
                  children: [
                    // Play/Pause Button
                    GestureDetector(
                      onTap: () {
                        if (isPlaying) {
                          audioHandler.pause();
                        } else {
                          audioHandler.play();
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying ? LucideIcons.pause : LucideIcons.play,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Track Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              color: Color(0xFFA1A1AA), // Zinc 400
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mediaItem.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Close Button
                    GestureDetector(
                      onTap: () => audioHandler.stop(),
                      child: const Icon(
                        LucideIcons.x,
                        color: Color(0xFFA1A1AA), // Zinc 400
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
          },
        );
      },
    );
  }
}
