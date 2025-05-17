import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cowardly_app/screens/video/better_player_pip_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> favoriteVideos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final List<dynamic> favorites = userDoc.data()?['favorites'] ?? [];

    // ✅ FILTER EMPTY IDs
    final videoIds = favorites.where((id) => id != null && id.toString().isNotEmpty).toList();

    if (videoIds.isEmpty) {
      setState(() {
        favoriteVideos = [];
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('videos')
        .where(FieldPath.documentId, whereIn: videoIds)
        .get();

    setState(() {
      favoriteVideos = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Favorites", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteVideos.isEmpty
          ? const Center(child: Text("No favorites found.", style: TextStyle(color: Colors.white70)))
          : ListView.builder(
        itemCount: favoriteVideos.length,
        itemBuilder: (context, index) {
          final video = favoriteVideos[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                video['thumbnailUrl'],
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              video['title'] ?? 'Untitled',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              video['description'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BetterPlayerPiPScreen(
                    videoId: video['id'],
                    title: video['title'],
                    description: video['description'],
                    videoUrl: video['videoUrl'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
