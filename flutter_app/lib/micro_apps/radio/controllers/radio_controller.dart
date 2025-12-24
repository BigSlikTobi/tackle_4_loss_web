import 'package:flutter/foundation.dart';
import 'package:tackle4loss_mobile/core/services/audio_player_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/radio_station.dart';
import '../models/radio_category.dart';

import 'package:shared_preferences/shared_preferences.dart';

class RadioController extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedCategoryId = 'all';
  String get selectedCategoryId => _selectedCategoryId;

  List<RadioCategory> _categories = [
    RadioCategory(id: 'all', label: 'radioCategoryAll'),
    RadioCategory(id: 'deep_dive', label: 'radioCategoryDeepDive'),
    RadioCategory(id: 'news', label: 'radioCategoryNews'),
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

  RadioController({String? languageCode}) {
    _initAndLoad(languageCode ?? 'en');
  }

  void _initAndLoad(String languageCode) async {
    await _loadPlayedNews();
    await loadStations(languageCode);
    
    // Listen for playback changes to mark as played
    _audioService.mediaItemStream.listen((mediaItem) {
      if (mediaItem != null) {
        _markAsPlayed(mediaItem.id);
      }
    });
  }

  void selectCategory(String id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  Future<void> loadStations(String languageCode) async {
    _isLoading = true;
    notifyListeners();

    // Fetch latest news for dynamic images
    List<String> newsImages = [];
    String? latestNewsImage;

    try {
      final newsTracks = await fetchNewsTracks(languageCode);
      if (newsTracks.isNotEmpty) {
        _newsImages = newsTracks
            .map((e) => (e['imageUrl'] as String?) ??
                'https://placehold.co/400/1a1a1a/ffffff?text=News')
            .toList();
        _latestNewsImage = _newsImages.first;
        _latestNewsHeadline =
            (newsTracks.first['title'] as String?) ?? 'News';
      }
    } catch (e) {
      debugPrint("Error loading news images for UI: $e");
    }

    // 2. Fetch Deep Dive Articles via Edge Function
    List<RadioStation> deepDiveStations = [];
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-radio-deepdives',
        body: {'language_code': languageCode},
      );
      
      if (response.status == 200 && response.data != null && response.data is List) {
        final List<dynamic> ddData = response.data;
        deepDiveStations = ddData
          .map<RadioStation>((item) => RadioStation(
            id: 'dd_${item['id']}',
            title: item['title'] ?? '',
            description: item['subtitle'] ?? '',
            imageUrl: item['hero_image_url'] ?? 'https://placehold.co/400/1a1a1a/ffffff?text=Deep+Dive',
            categoryId: 'deep_dive',
            streamUrl: item['audio_file'] as String?, // Store the URL directly for easy access
          )).toList();
      } else {
        debugPrint("RadioController: get-radio-deepdives failed: ${response.data}");
      }
    } catch (e) {
      debugPrint("RadioController: Error fetching deep dives via Edge Function: $e");
    }

    _allDeepDives = deepDiveStations;

    // Create a Collection Station for Deep Dives
    final deepDiveCollection = RadioStation(
      id: 'deep_dive_collection',
      title: 'radioStationDeepDiveCollectionTitle', // Needs localization key or update
      description: 'radioStationDeepDiveCollectionDesc', // Needs localization key or update
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
        imageUrl: _latestNewsImage ?? 'https://placehold.co/400/1a1a1a/ffffff?text=News',
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
    imageUrl: _latestNewsImage ?? 'https://placehold.co/400/1a1a1a/ffffff?text=Daily+Briefing',
    slideshowImages: _newsImages.isNotEmpty ? _newsImages : null,
    categoryId: 'news',
  );

  Future<void> playStation(RadioStation station, {String? languageCode}) async {
    List<Map<String, String>> playlist = [];

    if (station.id == 'news_briefing') {
      try {
        final allNews = await fetchNewsTracks(languageCode ?? 'en');
        // SMART PLAYBACK LOGIC:
        // 1. We keep ALL news in the playlist (so user can go back to history).
        // 2. We start playing from the first UNPLAYED item.
        playlist = allNews;
        
        int initialIndex = 0;
        final unplayedIndex = allNews.indexWhere((track) => !_playedNewsIds.contains(track['url']));
        
        if (unplayedIndex != -1) {
          initialIndex = unplayedIndex;
        } else {
          // If all are played, start from the beginning (or maybe the latest?)
          // If user clicked "Daily Briefing" and everything is listened to, starting from random or latest is good.
          // Let's start from 0 (latest) if everything is played, assuming they want to re-listen.
          initialIndex = 0;
        }

        if (playlist.isNotEmpty) {
          await _audioService.playPlaylist(playlist, initialIndex: initialIndex);
        }
        return; // Return early since we handled playback
      } catch (e) {
        debugPrint('Error fetching news tracks: $e');
        return; 
      }
    } else if (station.id == 'news_collection') {
      // Logic handled by UI (navigation), but if played directly, maybe play all?
      // Let's defer to UI for navigation.
      return;
    } else if (station.id.startsWith('dd_') && station.streamUrl != null) {
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
      // Manual/Legacy Stations
      playlist = [
        {
          'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          'title': 'Intro: ${station.title}',
          'author': 'T4L Team',
          'imageUrl': station.imageUrl,
        },
        {
          'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
          'title': 'Deep Dive Part 1',
          'author': 'Tobias Latta',
          'imageUrl': station.imageUrl,
        },
      ];
      await _audioService.playPlaylist(playlist);
    }
  }

  Future<void> playTrack(Map<String, String> track) async {
    // Determine if it's already playing?
    // For simplicity, just replace playlist with this single track
    await _audioService.playPlaylist([track]);
  }

  Future<List<Map<String, String>>> fetchNewsTracks(String languageCode) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'get-radio-news',
        body: {'language_code': languageCode}, 
      );

      if (response.data == null) return [];

      final List<dynamic> data = response.data;
      return data.map<Map<String, String>>((item) {
        final team = item['primaryTeam'];
        return {
          'id': item['id']?.toString() ?? '', 
          'url': item['audioUrl'] ?? '',
          'title': item['title'] ?? 'News Update',
          'author': team != null ? team['team_name'] ?? 'T4L News' : 'T4L News',
          'imageUrl': item['imageUrl'] ?? 'https://placehold.co/400x400/png',
          'teamName': team != null ? team['team_name'] ?? '' : '',
          'teamLogoUrl': team != null ? team['logo_url'] ?? '' : '',
        };
      }).where((track) => track['url'] != null && track['url']!.isNotEmpty).toList();

    } catch (e) {
      debugPrint('Error in fetchNewsTracks: $e');
      rethrow;
    }
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
