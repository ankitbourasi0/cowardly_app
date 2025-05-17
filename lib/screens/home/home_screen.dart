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
  bool isFetchingMore = false;
  DocumentSnapshot? lastDoc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchVideos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300 &&
          !isFetchingMore) {
        fetchVideos(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchVideos({bool loadMore = false}) async {
    if (loadMore && mounted) setState(() => isFetchingMore = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection('videos')
          .orderBy('createdAt', descending: true)
          .limit(10);

      if (loadMore && lastDoc != null) {
        query = query.startAfterDocument(lastDoc!);
      }

      final snapshot = await query.get();
      if (!mounted) return; // ← ✅ Don't continue if widget is disposed

      if (snapshot.docs.isNotEmpty) {
        lastDoc = snapshot.docs.last;
        final newVideos = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        if (!mounted) return; // ← ✅ Double-check again before setState
        setState(() {
          for (final video in newVideos) {
            final category = video['category'];

            if (category is String) {
              categorizedVideos.putIfAbsent(category, () => []).add(video);
            } else if (category is List) {
              for (final cat in category) {
                if (cat is String) {
                  categorizedVideos.putIfAbsent(cat, () => []).add(video);
                }
              }
            } else {
              categorizedVideos.putIfAbsent('Other', () => []).add(video);
            }
          }

          isLoading = false;
          isFetchingMore = false;
        });
      } else {
        if (mounted) setState(() => isFetchingMore = false);
      }
    } catch (e) {
      debugPrint("❌ Error fetching videos: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          isFetchingMore = false;
        });
      }
    }
  }

  Widget buildRow(String title, List<Map<String, dynamic>> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return GestureDetector(
                onTap: () {
                  final videoId = video['id'] ?? '';
                  final title = video['title'] ?? 'Untitled';
                  final description = video['description'] ?? 'No description available';
                  final videoUrl = video['videoUrl'] ?? '';

                  if (videoId.isEmpty || videoUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Invalid video data")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BetterPlayerPiPScreen(
                        videoId: videoId,
                        title: title,
                        description: description,
                        videoUrl: videoUrl,
                      ),
                    ),
                  );
                },

                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 100,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            video['thumbnailUrl'] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        video['title'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
        controller: _scrollController,
        children: categorizedVideos.entries
            .map((entry) => buildRow(entry.key, entry.value))
            .toList(),
      ),
    );
  }
}
