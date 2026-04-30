import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:tackle4loss_mobile/core/services/audio_player_service.dart';
import '../models/radio_station.dart';
import '../models/radio_category.dart';

import 'package:shared_preferences/shared_preferences.dart';

class RadioController extends ChangeNotifier with WidgetsBindingObserver {
  final AudioPlayerService _audioService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedCategoryId = 'all';
  String get selectedCategoryId => _selectedCategoryId;

  final List<RadioCategory> _categories = [
    const RadioCategory(id: 'all', label: 'radioCategoryAll'),
    const RadioCategory(id: 'deep_dive', label: 'radioCategoryDeepDive'),
    const RadioCategory(id: 'news', label: 'radioCategoryNews'),
  ];
  List<RadioCategory> get categories => _categories;

  List<String> _newsImages = [];
  List<String> get newsImages => _newsImages;
  String? _latestNewsImage;
  String? _latestNewsHeadline;
  String? get latestNewsHeadline => _latestNewsHeadline;

  List<RadioStation> _stations = [];
  List<RadioStation> get stations {
    if (_selectedCategoryId == 'all') return _stations;
    return _stations.where((s) => s.categoryId == _selectedCategoryId).toList();
  }

  // Store all deep dives separately for the detailed list view
  List<RadioStation> _allDeepDives = [];
  List<RadioStation> get allDeepDives => _allDeepDives;

  Timer? _newsTimer;
  Set<String> _currentPlaylistIds = {};
  StreamSubscription<void>? _queueExhaustedSub;
  StreamSubscription<MediaItem?>? _mediaItemSub;
  StreamSubscription<PlaybackState>? _playbackStateSub;
  String _activeLanguageCode = 'en';
  String _pollingLanguageCode = 'en';

  bool _isDailyBriefingMode = false;
  bool _isAppForeground = true;
  bool _isPlaying = false;
  DateTime? _latestNewsCreatedAt;

  @visibleForTesting
  bool get isNewsPollingActive => _newsTimer != null;

  RadioController({String? languageCode, AudioPlayerService? audioService})
      : _audioService = audioService ?? AudioPlayerService() {
    WidgetsBinding.instance.addObserver(this);
    _initAndLoad(languageCode ?? 'en');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _newsTimer?.cancel();
    _queueExhaustedSub?.cancel();
    _mediaItemSub?.cancel();
    _playbackStateSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isForeground = state == AppLifecycleState.resumed;
    _isAppForeground = isForeground;

    if (!_isAppForeground) {
      _stopNewsPolling();
      return;
    }

    _evaluateNewsPolling();
  }

  void _evaluateNewsPolling() {
    if (_shouldPollNews()) {
      _startNewsPolling();
    } else {
      _stopNewsPolling();
    }
  }

  bool _shouldPollNews() {
    return _isDailyBriefingMode && _isAppForeground && _isPlaying;
  }

  void _updateLatestNewsCreatedAt(Iterable<Map<String, String>> tracks) {
    for (final track in tracks) {
      final raw = track['createdAt'];
      if (raw == null || raw.isEmpty) continue;
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) continue;

      if (_latestNewsCreatedAt == null ||
          parsed.isAfter(_latestNewsCreatedAt!)) {
        _latestNewsCreatedAt = parsed;
      }
    }
  }

  void _startNewsPolling() {
    if (_newsTimer != null) return;

    // Poll for new news every 30 seconds while Daily Briefing is actively playing.
    _newsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_shouldPollNews()) return;
      _checkForNewNews(_pollingLanguageCode);
    });
  }

  void _stopNewsPolling() {
    _newsTimer?.cancel();
    _newsTimer = null;
  }

  void _initAndLoad(String languageCode) async {
    await _loadPlayedNews();
    await loadStations(languageCode);

    // Listen for playback changes to mark as played
    _mediaItemSub = _audioService.mediaItemStream.listen((mediaItem) {
      if (mediaItem == null) {
        _isPlaying = false;
        _evaluateNewsPolling();
        return;
      }

      // If something else starts playing (not part of the current news playlist),
      // ensure we don't keep polling in the background.
      if (_isDailyBriefingMode && !_currentPlaylistIds.contains(mediaItem.id)) {
        _isDailyBriefingMode = false;
        _evaluateNewsPolling();
      }

      _markAsPlayed(mediaItem.id);
    });

    _playbackStateSub = _audioService.playbackStateStream.listen((state) {
      _isPlaying = state.playing;
      _evaluateNewsPolling();
    });

    // Listen for queue exhaustion to auto-fetch more content for continuous playback
    _queueExhaustedSub = _audioService.onQueueExhausted.listen((_) {
      _onQueueExhausted();
    });
  }

  /// Called when the audio queue is exhausted - fetches more unplayed content
  Future<void> _onQueueExhausted() async {
    if (!_isDailyBriefingMode) return;
    try {
      final allNews = await fetchNewsTracks(_activeLanguageCode);

      // Filter out already played items
      final unplayedNews = allNews
          .where((track) => !_playedNewsIds.contains(track['url']))
          .toList();

      // Also filter out items already in current playlist
      final newItems = unplayedNews
          .where((track) => !_currentPlaylistIds.contains(track['url']))
          .toList();

      if (newItems.isNotEmpty) {
        await _audioService.appendToQueue(newItems);
        _currentPlaylistIds.addAll(newItems.map((e) => e['url']!));
      }
    } catch (e) {
      debugPrint("RadioController: Error fetching more content: $e");
    }
  }

  void selectCategory(String id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  Future<void> loadStations(String languageCode) async {
    _isLoading = true;
    notifyListeners();

    // Fetch latest news for dynamic images

    try {
      final newsTracks = await fetchNewsTracks(languageCode);
      if (newsTracks.isNotEmpty) {
        _newsImages = newsTracks
            .map((e) =>
                (e['imageUrl']) ??
                'https://placehold.co/400/1a1a1a/ffffff?text=News')
            .toList();
        _latestNewsImage = _newsImages.first;
        _latestNewsHeadline = (newsTracks.first['title']) ?? 'News';
      }
    } catch (e) {
      debugPrint("Error loading news images for UI: $e");
    }

    // TODO(restore-on-revive): `get-radio-deepdives` is gone with the new
    // main Supabase project. Radio is flag-off in MVP slim — return no deep
    // dives so the rest of the controller still wires up cleanly.
    const List<RadioStation> deepDiveStations = [];
    _allDeepDives = deepDiveStations;

    // Create a Collection Station for Deep Dives
    final deepDiveCollection = RadioStation(
      id: 'deep_dive_collection',
      title:
          'radioStationDeepDiveCollectionTitle', // Needs localization key or update
      description:
          'radioStationDeepDiveCollectionDesc', // Needs localization key or update
      imageUrl: deepDiveStations.isNotEmpty
          ? deepDiveStations.first.imageUrl
          : 'https://placehold.co/400/1a1a1a/ffffff?text=Deep+Dives',
      slideshowImages: deepDiveStations.map((e) => e.imageUrl).toList(),
      categoryId: 'deep_dive',
    );

    _stations = [
      RadioStation(
        id: 'news',
        title: 'radioStationNewsTitle',
        description: 'radioStationNewsDesc',
        imageUrl: _latestNewsImage ??
            'https://placehold.co/400/1a1a1a/ffffff?text=News',
        slideshowImages: _newsImages.isNotEmpty ? _newsImages : null,
        categoryId: 'news',
      ),
      deepDiveCollection,
    ];

    _isLoading = false;
    notifyListeners();
  }

  RadioStation get dailyBriefingStation => RadioStation(
        id: 'news_briefing',
        title: 'radioStationDailyBriefingTitle',
        description: 'radioStationDailyBriefingDesc',
        imageUrl: _latestNewsImage ??
            'https://placehold.co/400/1a1a1a/ffffff?text=Daily+Briefing',
        slideshowImages: _newsImages.isNotEmpty ? _newsImages : null,
        categoryId: 'news',
      );

  Future<void> playStation(RadioStation station, {String? languageCode}) async {
    _activeLanguageCode =
        languageCode ?? 'en'; // Store for queue exhaustion handler
    _stopNewsPolling();
    List<Map<String, String>> playlist = [];

    if (station.id == 'news_briefing') {
      try {
        final pollingLanguageCode = languageCode ?? 'en';
        final allNews = await fetchNewsTracks(languageCode ?? 'en');
        // SMART PLAYBACK LOGIC:
        // 1. We keep ALL news in the playlist (so user can go back to history).
        // 2. We start playing from the first UNPLAYED item.
        playlist = allNews;

        // Track current playlist to avoid duplicates during polling
        _currentPlaylistIds = playlist.map((e) => e['url']!).toSet();

        int initialIndex = 0;
        final unplayedIndex = allNews
            .indexWhere((track) => !_playedNewsIds.contains(track['url']));

        if (unplayedIndex != -1) {
          initialIndex = unplayedIndex;
        } else {
          // If all are played, start from the beginning (or maybe the latest?)
          // If user clicked "Daily Briefing" and everything is listened to, starting from random or latest is good.
          // Let's start from 0 (latest) if everything is played, assuming they want to re-listen.
          initialIndex = 0;
        }

        if (playlist.isNotEmpty) {
          await _audioService.playPlaylist(playlist,
              initialIndex: initialIndex);
          _isDailyBriefingMode = true;
          _pollingLanguageCode = pollingLanguageCode;
          _updateLatestNewsCreatedAt(playlist);
          _evaluateNewsPolling();
        }
        return; // Return early since we handled playback
      } catch (e) {
        _isDailyBriefingMode = false;
        debugPrint('Error fetching news tracks: $e');
        return;
      }
    } else if (station.id == 'news_collection') {
      // Logic handled by UI (navigation), but if played directly, maybe play all?
      // Let's defer to UI for navigation.
      _isDailyBriefingMode = false;
      _currentPlaylistIds = {};
      return;
    } else if (station.id.startsWith('dd_') && station.streamUrl != null) {
      _isDailyBriefingMode = false;
      _currentPlaylistIds = {};
      // Dynamic Deep Dive Playback
      playlist = [
        {
          'url': station.streamUrl!,
          'title': station.title,
          'author': 'T4L Team',
          'imageUrl': station.imageUrl,
        }
      ];
      await _audioService.playPlaylist(playlist);
    } else {
      _isDailyBriefingMode = false;
      _currentPlaylistIds = {};
      // Manual/Legacy Stations
      playlist = [
        {
          'url':
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          'title': 'Intro: ${station.title}',
          'author': 'T4L Team',
          'imageUrl': station.imageUrl,
        },
        {
          'url':
              'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
          'title': 'Deep Dive Part 1',
          'author': 'Tobias Latta',
          'imageUrl': station.imageUrl,
        },
      ];
      await _audioService.playPlaylist(playlist);
    }
  }

  Future<void> _checkForNewNews(String languageCode) async {
    try {
      if (!_shouldPollNews()) return;
      final latestNews = await fetchNewsTracks(
        languageCode,
        sinceCreatedAt: _latestNewsCreatedAt?.toUtc().toIso8601String(),
        limit: 10,
      );

      // Filter for tracks that are NOT in the current playlist
      // We assume track['url'] is the unique identifier
      final newTracks = latestNews
          .where((track) => !_currentPlaylistIds.contains(track['url']))
          .toList();

      if (newTracks.isNotEmpty) {
        debugPrint(
            "RadioController: Found ${newTracks.length} new news tracks. Inserting into queue.");

        // Insert tracks to be played NEXT
        await _audioService.insertNext(newTracks);

        // Update local awareness of what's in the playlist
        _currentPlaylistIds.addAll(newTracks.map((e) => e['url']!));
        _updateLatestNewsCreatedAt(newTracks);
      }
    } catch (e) {
      debugPrint("RadioController: Error checking for new news: $e");
    }
  }

  Future<void> playTrack(Map<String, String> track) async {
    _isDailyBriefingMode = false;
    _currentPlaylistIds = {};
    _stopNewsPolling();
    // Determine if it's already playing?
    // For simplicity, just replace playlist with this single track
    await _audioService.playPlaylist([track]);
  }

  // TODO(restore-on-revive): `get-radio-news` is gone with the new main
  // Supabase project. Radio is flag-off in MVP slim.
  Future<List<Map<String, String>>> fetchNewsTracks(
    String languageCode, {
    String? sinceCreatedAt,
    int? limit,
  }) async {
    return const [];
  }

  // Played Tracking Logic
  Set<String> _playedNewsIds = {};

  Future<void> _loadPlayedNews() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('played_news_ids') ?? [];
    _playedNewsIds = list.toSet();
  }

  Future<void> _markAsPlayed(String id) async {
    if (_playedNewsIds.contains(id)) return;

    _playedNewsIds.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('played_news_ids', _playedNewsIds.toList());
  }
}
