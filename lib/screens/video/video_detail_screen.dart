import 'package:cowardly_app/screens/video/better_player_pip_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoDetailScreen extends StatefulWidget {
  final Map<String, dynamic> video;

  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);
    setState(() {
      isFavorite = favorites.contains(widget.video['title']);
    });
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);

    if (isFavorite) {
      favorites.remove(widget.video['title']);
    } else {
      favorites.add(widget.video['title']);
    }

    await docRef.update({'favorites': favorites});
    setState(() => isFavorite = !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(video['title'], style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: isFavorite ? Colors.red : Colors.white),
            onPressed: toggleFavorite,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(video['thumbnailUrl'], width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video['title'], style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(video['description'] ?? '', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BetterPlayerPiPScreen(
                            title: video['title'],
                            description: video['description'],
                            videoUrl: video['videoUrl'],
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.play_arrow),
                    label: Text("Play"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
