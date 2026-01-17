import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../design_tokens.dart';

import 'package:video_player/video_player.dart';

class T4LHeroHeader extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? videoUrl; // New parameter
  final double height; // Renamed from expandedHeight
  final bool isDarkMode;
  final Widget? floatingAction;
  final String? heroTag;

  const T4LHeroHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.videoUrl,
    this.height = 440.0,
    this.isDarkMode = true,
    this.floatingAction,
    this.heroTag,
  });

  @override
  State<T4LHeroHeader> createState() => _T4LHeroHeaderState();
}

class _T4LHeroHeaderState extends State<T4LHeroHeader> {
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = true;

  @override
  void initState() {
    super.initState();
    debugPrint('T4LHeroHeader: initState. videoUrl: ${widget.videoUrl}');
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _initializeVideo();
    } else {
      debugPrint('T4LHeroHeader: videoUrl is null or empty');
    }
  }

  @override
  void didUpdateWidget(T4LHeroHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoUrl != oldWidget.videoUrl && widget.videoUrl != null) {
      debugPrint('T4LHeroHeader: videoUrl updated to ${widget.videoUrl}');
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    // Dispose previous controller if exists
    if (_videoController != null) {
      _videoController!.removeListener(_videoListener);
      _videoController!.dispose();
      _videoController = null;
    }

    debugPrint('T4LHeroHeader: Initializing video ${widget.videoUrl}');
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl!),
    );
    try {
      await _videoController!.initialize();
      debugPrint('T4LHeroHeader: Video initialized');
      await _videoController!.setLooping(
        false,
      ); // Don't loop, we want to transition to image
      await _videoController!.setVolume(0.0); // Mute for intro
      _videoController!.addListener(_videoListener);

      if (mounted) {
        setState(() {});
        await _videoController!.play();
        debugPrint('T4LHeroHeader: Video playing');
      }
    } catch (e) {
      debugPrint('Error loading video header: $e');
    }
  }

  void _videoListener() {
    if (_videoController != null &&
        _videoController!.value.position >= _videoController!.value.duration) {
      // Video finished
      if (mounted && _isVideoPlaying) {
        setState(() {
          _isVideoPlaying = false; // Trigger fade out
        });
      }
    }
  }

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController!.removeListener(_videoListener);
      _videoController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base Image (Always there, revealed when video fades)
          if (widget.heroTag != null)
            Hero(
              tag: widget.heroTag!,
              child: _buildImage(),
            )
          else
            _buildImage(),

          // 2. Video Player Layer (Fades out when finished)
          if (_videoController != null &&
              _videoController!.value.isInitialized)
            AnimatedOpacity(
              opacity: _isVideoPlaying ? 1.0 : 0.0,
              duration: const Duration(
                milliseconds: 1500,
              ), // Smooth 1.5s fade
              curve: Curves.easeInOut,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController!.value.size.width,
                    height: _videoController!.value.size.height,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ),
            ),

          // 3. Gradient Overlay (On top of both)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (widget.isDarkMode
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight)
                      .withValues(alpha: 0.54),
                  Colors.transparent,
                  (widget.isDarkMode
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight)
                      .withValues(alpha: 0.87),
                ],
              ),
            ),
          ),
          
          // 4. Content (Title/Subtitle) - Replaces FlexibleSpaceBar title
          Positioned(
            bottom: 32, // Replaces previous align logic
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'RussoOne',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: widget.isDarkMode
                            ? Colors.black54
                            : Colors.white24,
                        blurRadius: 10,
                      ),
                    ],
                    fontSize: 24, // Slightly larger as it's not scaled down by Sliver
                    color: widget.isDarkMode
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          (widget.isDarkMode
                                  ? Colors.white
                                  : AppColors.textPrimary)
                              .withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: widget.isDarkMode
                              ? Colors.black54
                              : Colors.white24,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 5. Floating Action (Play Button)
          if (widget.floatingAction != null)
            Positioned(bottom: 132, right: 16, child: widget.floatingAction!),
        ],
      ),
    );
  }
  
  Widget _buildImage() {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: (widget.isDarkMode
            ? AppColors.backgroundDark
            : AppColors.backgroundLight),
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: (widget.isDarkMode
            ? AppColors.backgroundDark
            : AppColors.backgroundLight),
        child: const Icon(
          Icons.broken_image,
          color: Colors.white24,
          size: 48,
        ),
      ),
    );
  }
}
