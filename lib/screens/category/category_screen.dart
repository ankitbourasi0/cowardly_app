import 'package:cowardly_app/screens/video/video_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Map<String, List<Map<String, dynamic>>> categorizedVideos = {
    "Featured": [],
    "Cartoon": [],
    "Latest": [],
  };
  bool isLoading = true;
  String searchQuery = '';
  List<Map<String, dynamic>> searchResults = [];

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

    final newVideos = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // ✅ Ensure this line exists
      return data;
    }).toList();

    if (!mounted) return;
    setState(() {
      categorizedVideos = {
        "Featured": newVideos
            .where((v) => v['category']?.contains('featured') ?? false)
            .toList(),
        "Cartoon": newVideos
            .where((v) => v['category']?.contains('cartoon') ?? false)
            .toList(),
        "Latest": newVideos.take(10).toList(),
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> showsGrouped = {};
    for (final video in categorizedVideos['Cartoon'] ?? []) {
      final show = video['show'] ?? 'Unknown';
      showsGrouped.putIfAbsent(show, () => []).add(video);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("CARTOONFLIX", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const ShimmerLoader()
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for cartoons...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                  searchResults = categorizedVideos['Cartoon']!
                      .where((video) => video['title']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: searchQuery.isNotEmpty
                ? buildSearchResults(searchResults)
                : ListView(
              children: [
                for (final entry in showsGrouped.entries)
                  buildShowPlaylistCard(entry.key, entry.value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text("No results found", style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, index) {
        final video = results[index];
        final show = video['show'] ?? 'Unknown Show';

        // Get all videos from the same show to pass as playlist
        final relatedVideos = results
            .where((v) => v['show'] == show)
            .toList();

        return ListTile(
          title: Text(
            video['title'],
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            video['description'] ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          leading: Image.network(
            video['thumbnailUrl'],
            width: 80,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoDetailScreen(
                  showTitle: show,
                  videos: relatedVideos,
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget buildShowPlaylistCard(String showName, List<Map<String, dynamic>> videos) {
    final thumbnail = videos.firstWhere((v) => v['thumbnailUrl'] != null, orElse: () => {})['thumbnailUrl'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoDetailScreen(
              showTitle: showName,
              videos: videos,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[850],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                thumbnail,
                width: 100,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                showName,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade800,
          highlightColor: Colors.grey.shade700,
          child: Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
