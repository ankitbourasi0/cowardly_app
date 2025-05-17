import 'package:cached_network_image/cached_network_image.dart';
import 'package:cowardly_app/screens/video/better_player_pip_screen.dart';
import 'package:cowardly_app/utils/VideoMeta.dart';
import 'package:flutter/material.dart';

class VideoDetailScreen extends StatelessWidget {
  final String showTitle;
  final List<Map<String, dynamic>> videos;

  const VideoDetailScreen({
    super.key,
    required this.showTitle,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(showTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                video['thumbnailUrl'] ?? '',
                width: 120,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              video['title'] ?? 'Untitled',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (video['description'] ?? '').toString().length > 100
                      ? '${video['description'].toString().substring(0, 100)}...'
                      : video['description'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.visibility, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text('${video['views'] ?? 0} views', style: const TextStyle(color: Colors.white70)),
                    const Spacer(),
                    const Icon(Icons.timer, size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(video['videoLength'] ?? '0:00', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
            onTap: () {
              final videoId = video['id'];
              final videoUrl = video['videoUrl'];
              final title = video['title'] ?? 'Untitled';
              final description = video['description'] ?? 'No description available';

              if (videoId == null || videoId.toString().isEmpty || videoUrl == null || videoUrl.toString().isEmpty) {
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


          );

        },
      ),
    );
  }
}