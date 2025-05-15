import 'package:cowardly_app/screens/video/better_player_pip_screen.dart';
import 'package:cowardly_app/screens/video/video_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class NetflixStyleHome extends StatefulWidget {
  @override
  _NetflixStyleHomeState createState() => _NetflixStyleHomeState();
}

class _NetflixStyleHomeState extends State<NetflixStyleHome> {
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

    final allVideos =
    snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    setState(() {
      categorizedVideos = {
        "Featured": allVideos
            .where((v) => v['category']?.contains('featured') ?? false)
            .toList(),
        "Cartoon": allVideos
            .where((v) => v['category']?.contains('cartoon') ?? false)
            .toList(),
        "Latest": allVideos.take(10).toList(),
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("CARTOONFLIX",
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? ShimmerLoader()
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for cartoons...',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: Icon(Icons.search, color: Colors.white),
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
              children: categorizedVideos.entries
                  .map((entry) => buildVideoRow(entry.key, entry.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return Center(
          child: Text("No results found",
              style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, index) {
        final video = results[index];
        return ListTile(
            title: Text(video['title'], style: TextStyle(color: Colors.white)),
            subtitle:
            Text(video['description'], style: TextStyle(color: Colors.grey)),
            leading: Image.network(video['thumbnailUrl'], width: 80, fit: BoxFit.cover),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoDetailScreen(video: video),
                ),
              );
            }

        );
      },
    );
  }

  Widget buildVideoRow(String label, List<Map<String, dynamic>> videos) {
    if (videos.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (_, index) {
              final video = videos[index];
              return GestureDetector(
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
                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(left: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      video['thumbnailUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShimmerLoader extends StatelessWidget {
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
