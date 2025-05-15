// ✅ BetterPlayerPiPPage.dart (Add Favorite button)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

class BetterPlayerPiPScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String description;

  const BetterPlayerPiPScreen({
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

  @override
  void initState() {
    super.initState();
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
    );
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        handleLifecycle: true,
        allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enablePip: true,
          enableFullscreen: true,
          enableMute: true,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
    setState(() {
      isFavorite = favorites.contains(widget.title);
    });
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);

    if (isFavorite) {
      favorites.remove(widget.title);
    } else {
      favorites.add(widget.title);
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
