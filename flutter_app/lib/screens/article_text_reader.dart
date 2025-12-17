import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models.dart';
import '../design_tokens.dart';
import '../services/global.dart';
import 'package:audio_service/audio_service.dart';
import '../services/audio_handler.dart';

class ArticleTextReaderScreen extends StatefulWidget {
  final Article article;
  final Article? nextArticle;
  final Article? previousArticle;
  final Function(String id)? onNavigate;

  const ArticleTextReaderScreen({
    super.key,
    required this.article,
    this.nextArticle,
    this.previousArticle,
    this.onNavigate,
  });

  @override
  State<ArticleTextReaderScreen> createState() => _ArticleTextReaderScreenState();
}

class _ArticleTextReaderScreenState extends State<ArticleTextReaderScreen> {
  int _currentSectionIndex = 0;
  VideoPlayerController? _videoController;
  // Removed local _audioPlayer
  bool _isPlayingAudio = false;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.article.videoFile != null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.article.videoFile!))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController!.setLooping(false);
            _videoController!.setVolume(0);
            _videoController!.play();
          }
        });
    }
    
    // Listen to global state to update UI
    audioHandler.playbackState.listen((state) {
      if (mounted) {
        final isPlaying = state.playing;
        // Check if playing THIS article? Or just playing?
        // Since TextReader is for the SAME article as Viewer usually, we assume yes.
        // Or we can check mediaItem.id but let's keep it simple: if audio is playing, show pause.
        setState(() {
          _isPlayingAudio = isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    // Do NOT stop global audioHandler on dispose, allow background play.
    super.dispose();
  }

  void _toggleAudio() async {
    debugPrint('Global Audio button tapped');
    HapticFeedback.lightImpact();
    
    final currentMediaItem = audioHandler.mediaItem.value;
    final isPlayingThis = currentMediaItem?.id == widget.article.audioFile;

    if (_isPlayingAudio && isPlayingThis) {
      await audioHandler.pause();
    } else {
      if (widget.article.audioFile != null) {
          // Play new item
         final mediaItem = MediaItem(
           id: widget.article.audioFile!,
           album: "Deep Dive",
           title: widget.article.title,
           artist: "Tackle4Loss",
           artUri: Uri.parse(widget.article.heroImage),
           extras: {'url': widget.article.audioFile},
         );
         
         if (audioHandler is AudioPlayerHandler) {
           await (audioHandler as AudioPlayerHandler).setMediaItem(mediaItem);
           await audioHandler.play();
         }
      }
    }
  }

  void _nextSection() {
    HapticFeedback.lightImpact();
    if (_currentSectionIndex < widget.article.sections.length - 1) {
      setState(() {
        _currentSectionIndex++;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _prevSection() {
    HapticFeedback.lightImpact();
    if (_currentSectionIndex > 0) {
      setState(() {
        _currentSectionIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final section = widget.article.sections[_currentSectionIndex];
    final isFirstSection = _currentSectionIndex == 0;
    final isLastSection = _currentSectionIndex == widget.article.sections.length - 1;

    return Scaffold(
      backgroundColor: AppColors.neutralBase,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.black,
                leading: IconButton(
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
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.article.heroImage,
                        fit: BoxFit.cover,
                      ),
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
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      if (isFirstSection)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.article.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppTypography.fontFamilyPrimary,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 40,
                                    color: AppColors.brandBase,
                                    margin: const EdgeInsets.only(top: 4),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.article.subtitle,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      section.headline,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutralText,
                        fontFamily: AppTypography.fontFamilyPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    ...section.content.map((paragraph) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
                      child: Text(
                        paragraph,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          color: AppColors.neutralText,
                          fontFamily: 'Merriweather', // Assuming we might add this later, or fallback
                        ),
                      ),
                    )),
                    const SizedBox(height: AppSpacing.space4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!isFirstSection)
                          TextButton.icon(
                            onPressed: _prevSection,
                            icon: const Icon(LucideIcons.chevronLeft),
                            label: const Text('Prev'),
                            style: TextButton.styleFrom(foregroundColor: AppColors.neutralText),
                          )
                        else
                          const SizedBox(),
                        TextButton.icon(
                          onPressed: _nextSection,
                          icon: Icon(isLastSection ? LucideIcons.check : LucideIcons.chevronRight),
                          label: Text(isLastSection ? 'Done' : 'Next'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.neutralText,
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80), // Space for FAB
                    
                    // --- Navigation Footer ---
                    if ((widget.nextArticle != null || widget.previousArticle != null) && widget.onNavigate != null) ...[
                      const Divider(height: 1, color: AppColors.neutralBorder),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous Button
                          if (widget.previousArticle != null)
                             InkWell(
                               onTap: () => widget.onNavigate!(widget.previousArticle!.id),
                               borderRadius: BorderRadius.circular(8),
                               child: Row(
                                 children: [
                                   // Thumbnail
                                   Container(
                                     width: 48,
                                     height: 48,
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(8),
                                       color: AppColors.neutralSoft,
                                       image: widget.previousArticle!.heroImage.isNotEmpty ? DecorationImage(
                                         image: CachedNetworkImageProvider(widget.previousArticle!.heroImage),
                                         fit: BoxFit.cover,
                                       ) : null,
                                     ),
                                     child: widget.previousArticle!.heroImage.isEmpty ? const Icon(LucideIcons.chevronLeft, size: 16, color: Colors.grey) : null,
                                   ),
                                   const SizedBox(width: 12),
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       const Text(
                                         "PREVIOUS",
                                         style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                                       ),
                                     ],
                                   ),
                                 ],
                               ),
                             )
                          else
                             const SizedBox(width: 48),

                          // Next Button
                          if (widget.nextArticle != null)
                             InkWell(
                               onTap: () => widget.onNavigate!(widget.nextArticle!.id),
                               borderRadius: BorderRadius.circular(8),
                               child: Row(
                                 children: [
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.end,
                                     children: [
                                       const Text(
                                         "NEXT",
                                         style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2),
                                       ),
                                     ],
                                   ),
                                   const SizedBox(width: 12),
                                   // Thumbnail
                                   Container(
                                     width: 48,
                                     height: 48,
                                     decoration: BoxDecoration(
                                       borderRadius: BorderRadius.circular(8),
                                       color: AppColors.neutralSoft,
                                       image: widget.nextArticle!.heroImage.isNotEmpty ? DecorationImage(
                                          image: CachedNetworkImageProvider(widget.nextArticle!.heroImage),
                                          fit: BoxFit.cover,
                                       ) : null,
                                     ),
                                     child: widget.nextArticle!.heroImage.isEmpty ? const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey) : null,
                                   ),
                                 ],
                               ),
                             )
                          else
                             const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ]),
                ),
              ),
            ],
          ),
          // Audio Button Removed in Text Reader mode if redundant, but user asked for "Read article with silent sign". 
          // I will keep the audio button here just in case they want to listen in this mode too, or remove it as per "silent sign" implying this IS the silent mode.
          // The prompt says "redirects to the screen where the user can read as it is at the moment".
          // So I'm keeping it exactly "as it is", which INCLUDES the audio button. 
          // If the user wants "silent", maybe they just mean "go to text mode", but they might still want to play audio? 
          // I will Keep it for now, can perform cleanup if requested.
          if (widget.article.audioFile != null)
            Positioned(
              bottom: 32,
              right: 24,
              child: GestureDetector(
                onTap: _toggleAudio,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isPlayingAudio ? AppColors.brandBase : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: _isPlayingAudio ? AppColors.brandBase : AppColors.neutralBorder,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      LucideIcons.headphones,
                      color: _isPlayingAudio ? Colors.white : AppColors.brandBase,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
