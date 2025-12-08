import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models.dart';
import '../design_tokens.dart';

class ArticleViewerScreen extends StatefulWidget {
  final Article article;

  const ArticleViewerScreen({super.key, required this.article});

  @override
  State<ArticleViewerScreen> createState() => _ArticleViewerScreenState();
}

class _ArticleViewerScreenState extends State<ArticleViewerScreen> {
  int _currentSectionIndex = 0;
  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();
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
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.stop(); // Ensure audio stops
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    debugPrint('Audio button tapped');
    HapticFeedback.lightImpact();
    try {
      if (_isPlayingAudio) {
        await _audioPlayer.pause();
      } else {
        if (widget.article.audioFile != null) {
          debugPrint('Playing audio from: ${widget.article.audioFile}');
          await _audioPlayer.play(UrlSource(widget.article.audioFile!));
        }
      }
      if (mounted) {
        setState(() {
          _isPlayingAudio = !_isPlayingAudio;
        });
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
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
                  ]),
                ),
              ),
            ],
          ),
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
