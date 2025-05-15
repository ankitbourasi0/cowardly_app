// ✅ Update to ProfileScreen.dart to show Favorites

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowardly_app/screens/video/better_player_pip_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  List<Map<String, dynamic>> favoriteVideos = [];
  bool isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    nameController.text = user?.displayName ?? '';
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final favorites = List<String>.from(doc.data()?['favorites'] ?? []);

    if (favorites.isEmpty) {
      setState(() {
        isLoadingFavorites = false;
      });
      return;
    }

    final videosSnap = await FirebaseFirestore.instance
        .collection('videos')
        .where(FieldPath.documentId, whereIn: favorites)
        .get();

    setState(() {
      favoriteVideos = videosSnap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      isLoadingFavorites = false;
    });
  }

  void saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final name = nameController.text.trim();
      await user.updateDisplayName(name);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': user.email,
        'uid': user.uid,
        'createdAt': Timestamp.now(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to save profile: $e")),
      );
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          )
        ],
      ),
      body: user == null
          ? const Center(child: Text("Not logged in", style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/149/149071.png',
                ),
              ),
              const SizedBox(height: 20),
              Text(user.email ?? user.phoneNumber ?? 'Unknown',
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 10),
              Text('UID: ${user.uid}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Update Display Name",
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProfile,
                child: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
              const SizedBox(height: 30),
              const Text("Favorites", style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 10),
              isLoadingFavorites
                  ? const CircularProgressIndicator()
                  : favoriteVideos.isEmpty
                  ? const Text("No favorites yet.", style: TextStyle(color: Colors.white70))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: favoriteVideos.length,
                itemBuilder: (_, index) {
                  final video = favoriteVideos[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(video['thumbnailUrl'], width: 60, fit: BoxFit.cover),
                    ),
                    title: Text(video['title'], style: const TextStyle(color: Colors.white)),
                    subtitle: Text(video['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    onTap: () {
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
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
