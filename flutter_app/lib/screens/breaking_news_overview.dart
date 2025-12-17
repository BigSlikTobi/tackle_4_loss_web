import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models.dart';
import '../services/global.dart';
import 'package:audio_service/audio_service.dart';
import '../design_tokens.dart';

class BreakingNewsOverview extends StatefulWidget {
  final List<BreakingNews> news;
  final String languageCode;
  final Function(String id) onNavigateToDetail;

  const BreakingNewsOverview({
    super.key,
    required this.news,
    required this.languageCode,
    required this.onNavigateToDetail,
  });

  @override
  State<BreakingNewsOverview> createState() => _BreakingNewsOverviewState();
}

class _BreakingNewsOverviewState extends State<BreakingNewsOverview> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BREAKING NEWS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // List
          Expanded(
            child: ListView.separated(
              itemCount: widget.news.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final item = widget.news[index];
                final isAudioAvailable = item.audioFile != null;
                
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onNavigateToDetail(item.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    DateFormat.jm(widget.languageCode == 'de' ? 'de_DE' : 'en_US')
                                        .format(item.createdAt.toLocal()),
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (isAudioAvailable) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(LucideIcons.headphones, size: 10, color: Colors.blue[600]),
                                          const SizedBox(width: 2),
                                          Text(
                                            'Audio',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.headline,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isAudioAvailable)
                          StreamBuilder<MediaItem?>(
                            stream: audioHandler.mediaItem,
                            builder: (context, mediaSnapshot) {
                              final currentMediaId = mediaSnapshot.data?.id;

                              return StreamBuilder<PlaybackState>(
                                stream: audioHandler.playbackState,
                                builder: (context, playbackSnapshot) {
                                  final playbackState = playbackSnapshot.data;
                                  final isPlaying = playbackState?.playing ?? false;
                                  final isPlayingThis = isPlaying && currentMediaId == item.audioFile;

                                  return GestureDetector(
                                    onTap: () async {
                                      if (isPlayingThis) {
                                        await audioHandler.pause();
                                      } else {
                                        final mediaItem = MediaItem(
                                          id: item.audioFile!,
                                          album: 'Breaking News',
                                          title: item.headline,
                                          extras: {'url': item.audioFile},
                                        );
                                        await audioHandler.playMediaItem(mediaItem);
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 12),
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isPlayingThis ? Colors.red[600] : Colors.grey[100],
                                        shape: BoxShape.circle,
                                        boxShadow: isPlayingThis
                                            ? [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
                                            : null,
                                      ),
                                      child: Icon(
                                        isPlayingThis ? LucideIcons.pause : LucideIcons.headphones,
                                        size: 16,
                                        color: isPlayingThis ? Colors.white : Colors.grey[600],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        else
                          Container( // Placeholder disabled button
                              margin: const EdgeInsets.only(left: 12),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.headphones,
                                size: 16,
                                color: Colors.grey[300],
                              ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
