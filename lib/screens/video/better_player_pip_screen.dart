import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class BetterPlayerPiPScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String description;
  final String videoId;

  const BetterPlayerPiPScreen({
    super.key,
    required this.videoId,
    required this.videoUrl,
    required this.title,
    required this.description,
  });

  @override
  State<BetterPlayerPiPScreen> createState() => _BetterPlayerPiPScreenState();
}

class _BetterPlayerPiPScreenState extends State<BetterPlayerPiPScreen> {
  late BetterPlayerController _betterPlayerController;
  final GlobalKey _betterPlayerKey = GlobalKey();
  bool isFavorite = false;
  bool hasIncrementedView = false;

  @override
  void initState() {
    super.initState();

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 100 * 1024 * 1024,
        maxCacheFileSize: 10 * 1024 * 1024,
      ),
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.contain,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enablePip: true,
        ),
        eventListener: (event) {
          if (event.betterPlayerEventType == BetterPlayerEventType.play &&
              !hasIncrementedView) {
            incrementViewCount();
            hasIncrementedView = true;
          }
        },
      ),
      betterPlayerDataSource: dataSource,
    );

    // ✅ Add view listener here
    bool hasIncremented = false;
    _betterPlayerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        final progress = event.parameters?["progress"];
        if (progress is Duration && progress.inSeconds > 10 && !hasIncremented) {
          incrementViewCount();
          hasIncremented = true; // ensure only once per session
        }
      }
    });
    checkFavorite();
  }

  Future<void> incrementViewCount() async {
    final doc = await FirebaseFirestore.instance
        .collection('videos')
        .where('title', isEqualTo: widget.title)
        .limit(1)
        .get();

    if (doc.docs.isNotEmpty) {
      final docRef = doc.docs.first.reference;
      await docRef.update({'views': FieldValue.increment(1)});
    }
  }

  Future<void> checkFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
    setState(() {
      isFavorite = favorites.contains(widget.videoId);
    });
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);

    if (isFavorite) {
      favorites.remove(widget.videoId);
    } else {
      favorites.add(widget.videoId);
    }

    await docRef.update({'favorites': favorites});
    setState(() => isFavorite = !isFavorite);
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  void _enterPipMode() {
    _betterPlayerController.enablePictureInPicture(_betterPlayerKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: isFavorite ? Colors.red : Colors.white),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.picture_in_picture_alt),
            onPressed: _enterPipMode,
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BetterPlayer(
              key: _betterPlayerKey,
              controller: _betterPlayerController,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.description,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
