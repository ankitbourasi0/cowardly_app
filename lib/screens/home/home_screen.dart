// ✅ lib/HomeScreen.dart (Netflix-style home feed)

import 'package:cowardly_app/screens/video/better_player_pip_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<Map<String, dynamic>>> categorizedVideos = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('videos')
        .orderBy('createdAt', descending: true)
        .get();

    final allVideos = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    // Organize into categories (dynamic)
    final Map<String, List<Map<String, dynamic>>> newMap = {};
    for (final video in allVideos) {
      if (video['category'] is String) {
        final category = video['category'];
        newMap.putIfAbsent(category, () => []).add(video);
      } else if (video['category'] is List) {
        for (final cat in (video['category'] as List)) {
          newMap.putIfAbsent(cat, () => []).add(video);
        }
      }
    }

    setState(() {
      categorizedVideos = newMap;
      isLoading = false;
    });
  }

  Widget buildRow(String title, List<Map<String, dynamic>> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BetterPlayerPiPScreen(
                        title: video['title'] ?? '',
                        description: video['description'] ?? '',
                        videoUrl: video['videoUrl'] ?? '',
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(left: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(video['thumbnailUrl'] ?? '', fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('CARTOONFLIX', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: categorizedVideos.entries
            .map((entry) => buildRow(entry.key, entry.value))
            .toList(),
      ),
    );
  }
}
