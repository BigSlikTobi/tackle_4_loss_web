import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models.dart';
import '../design_tokens.dart';
import 'article_text_reader.dart';

import '../services/global.dart'; // To access global audioHandler
import 'package:audio_service/audio_service.dart';
import '../services/audio_handler.dart';

class ArticleViewerScreen extends StatefulWidget {
  final Article article;
  final Article? nextArticle;
  final Article? previousArticle;
  final Function(String id)? onNavigate;

  const ArticleViewerScreen({
    super.key,
    required this.article,
    this.nextArticle,
    this.previousArticle,
    this.onNavigate,
  });

  @override
  State<ArticleViewerScreen> createState() => _ArticleViewerScreenState();
}

class _ArticleViewerScreenState extends State<ArticleViewerScreen> {
  VideoPlayerController? _videoController;
  final ScrollController _scrollController = ScrollController();
  
  // Use global audioHandler instead of local _audioPlayer
  // Local state to track "playing" UI
  bool _isPlayingAudio = false;
  bool _isVideoInitialized = false;
  bool _showControls = true;
  
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero; // Local tracking for scroll
  
  // StreamSubscriptions for AudioHandler/AudioService
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();

    // Video Setup
    if (widget.article.videoFile != null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.article.videoFile!))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController!.setLooping(true); // Loop background video
            _videoController!.setVolume(0); // Muted background
            _videoController!.play();
          }
        });
    }

    _initAudioService();
  }

  Future<void> _initAudioService() async {
    // 1. Set Media Item (Reset player with new content)
    if (widget.article.audioFile != null) {
       final mediaItem = MediaItem(
         id: widget.article.audioFile!,
         album: "Deep Dive",
         title: widget.article.title,
         artist: "Tackle4Loss",
         artUri: Uri.parse(widget.article.heroImage),
         extras: {'url': widget.article.audioFile},
       );
       
       // Cast to our handler to access custom setMediaItem if base doesn't suffice (it doesn't have setMediaItem in base?)
       // Actually AudioHandler doesn't have setMediaItem, we added it to OUR implementation.
       // But global 'audioHandler' is abstract AudioHandler. We need to cast or just use custom method if exposed, 
       // OR simpler: Just play URL? 
       // Our implementation handles setMediaItem.
       if (audioHandler is AudioPlayerHandler) {
         await (audioHandler as AudioPlayerHandler).setMediaItem(mediaItem);
         // Don't auto-play yet, wait for user.
       }
    }

    // 2. Listen to streams
    // Duration
    // BaseAudioHandler doesn't expose duration stream directly usually, but we exposed it in our class.
    if (audioHandler is AudioPlayerHandler) {
       _durationSubscription = (audioHandler as AudioPlayerHandler).onDurationChanged.listen((d) {
          debugPrint("Audio Duration Changed: $d");
          setState(() => _audioDuration = d);
       });

       _positionSubscription = (audioHandler as AudioPlayerHandler).onPositionChanged.listen((p) {
          _audioPosition = p; 
          _syncScrollToAudio(p);
       });
    }

    // Playback State
    _playerStateSubscription = audioHandler.playbackState.listen((state) {
      final isPlaying = state.playing;
      final processingState = state.processingState;
      
      if (mounted) {
         setState(() {
           _isPlayingAudio = isPlaying;
           if (processingState == AudioProcessingState.completed) {
             _isPlayingAudio = false;
             _showControls = true;
           }
           if (isPlaying) {
             _showControls = false;
           } else {
             _showControls = true; // Show controls if paused
           }
         });
      }
    });
  }

  void _syncScrollToAudio(Duration position) {
    if (!_scrollController.hasClients) {
      debugPrint("ScrollController has no clients");
      return;
    } 
    if (_audioDuration.inMilliseconds == 0) {
      debugPrint("Audio Duration is 0, cannot sync scroll");
      return;
    }
    
    // Calculate progress (0.0 to 1.0)
    final double progress = position.inMilliseconds / _audioDuration.inMilliseconds;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    
    // User requested 40% slower speed. 
    // This means we might not reach the bottom by end of audio, unless we have large bottom padding.
    final double targetOffset = maxScroll * progress * 0.7;
    
    // debugPrint("Syncing scroll: pos=$position dur=$_audioDuration prog=${progress.toStringAsFixed(2)} target=$targetOffset");

    // jumpTo is more reliable for frequent updates than animateTo which might conflict
    _scrollController.jumpTo(targetOffset);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    // Do NOT stop audioHandler if we want background play? 
    // User asked "control audio ... even if the app is on sleep".
    // Usually deep dive audio implies we want to keep listening if we back out? 
    // "On bottom of screen we see link read article... redirects to screen where user can read". 
    // If we leave this screen, should audio stop?
    // If we go to "text reader", we probably want audio to stop or continue? 
    // Let's NOT stop it automatically on dispose if we want background play capability generally. 
    // BUT if the user backs out to Home, maybe we should stop? 
    // For now, let's keep it playing (background/miniplayer style).
    
    // HOWEVER, if we open another article, we reset content. 
    // Let's leave it running.
    
    _scrollController.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  void _toggleAudio() async {
    HapticFeedback.lightImpact();
    if (_isPlayingAudio) {
      await audioHandler.pause();
    } else {
      await audioHandler.play();
      
      // Fallback duration check
       if (_audioDuration.inMilliseconds == 0 && audioHandler is AudioPlayerHandler) {
         final d = await (audioHandler as AudioPlayerHandler).getDuration();
         if (d != null) {
           setState(() => _audioDuration = d);
         }
      }
    }
  }

  void _navigateToReadMode() {
    HapticFeedback.selectionClick();
    audioHandler.pause(); 
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleTextReaderScreen(
          article: widget.article,
          nextArticle: widget.nextArticle,
          previousArticle: widget.previousArticle,
          onNavigate: widget.onNavigate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.article.languageCode != 'de') {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(LucideIcons.x, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            "This content is only available in German.", 
            style: TextStyle(color: Colors.white)
          )
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image
          CachedNetworkImage(
             imageUrl: widget.article.heroImage,
             fit: BoxFit.cover,
          ),
          
          // 2. Background Video (Layered on top if available)
          if (_isVideoInitialized && _videoController != null)
             SizedBox.expand(
               child: FittedBox(
                 fit: BoxFit.cover,
                 child: SizedBox(
                   width: _videoController!.value.size.width,
                   height: _videoController!.value.size.height,
                   child: VideoPlayer(_videoController!),
                 ),
               ),
             ),

          // 3. Dark Overlay for readability
          Container(
             color: Colors.black.withOpacity(0.6), // Adjust opacity as needed
          ),

          // 4. Scrolling Text Content (Credit Roll)
          // Only visible/scrolling effectively when audio plays, but we can show it always.
          // User said "when ... button clicks ... text is running".
          // If stopped, text stays still? 
          if (_isPlayingAudio || _audioPosition > Duration.zero)
            Positioned.fill(
              top: 100, // Leave space for header/controls if needed
              bottom: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const NeverScrollableScrollPhysics(), // Disable manual scroll during playback? Or allow user to override?
                  // User said "user can read as well as listen". 
                  // If "running in the speed of audio", manual scroll fights with auto-scroll.
                  // I'll disable manual scroll for the auto-sync effect to work perfectly, or make it "bouncy" but resetting. 
                  // Let's stick to auto-scroll (NeverScrollable) for "credit roll" feel.
                  child: Column(
                    children: [
                      const SizedBox(height: 300), // Initial buffer to start text lower
                      Text(
                        widget.article.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.article.subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Combine all sections
                      ...widget.article.sections.map((section) => Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Column(
                          children: [
                            Text(
                              section.headline,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.brandBase,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              section.content.join('\n\n'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 400), // End buffer
                    ],
                  ),
                ),
              ),
            ),
          
          // 5. Big Center Audio Button
          if (!_isPlayingAudio)
            Center(
              child: GestureDetector(
                onTap: _toggleAudio,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    LucideIcons.headphones,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            )
          else 
            // Optional: Pause handler, tapping screen anywhere pauses?
            GestureDetector(
              onTap: _toggleAudio,
              behavior: HitTestBehavior.translucent,
              child: Container(), // Invisible overlay to catch taps to pause?
            ),

          // 6. Top Header (Back Button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 7. Bottom Link "Read Article"
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton.icon(
                onPressed: _navigateToReadMode,
                icon: const Icon(LucideIcons.volumeX, color: Colors.white70, size: 20), // Silent sign
                label: const Text(
                  "READ ARTICLE", 
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
