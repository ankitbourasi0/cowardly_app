import 'package:flutter/material.dart';

Widget buildVideoMeta(Map<String, dynamic> video) {
  return Row(
    children: [
      const Icon(Icons.visibility, size: 16, color: Colors.white70),
      const SizedBox(width: 4),
      Text('${video['views'] ?? 0} views',
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
      const Spacer(),
      const Icon(Icons.timer, size: 16, color: Colors.white70),
      const SizedBox(width: 4),
      Text(video['duration'] ?? '0:00',
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}
