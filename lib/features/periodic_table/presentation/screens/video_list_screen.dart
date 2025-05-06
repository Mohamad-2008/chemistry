import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> videos;
  final String podmanTitle;

  const VideoListScreen({
    super.key,
    required this.videos,
    required this.podmanTitle,
  });

  Future<void> _launchVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ویدیوهای $podmanTitle',
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Vazir',
          ),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade50,
              Colors.amber.shade100,
            ],
          ),
        ),
        child: videos.isEmpty
            ? const Center(
          child: Text(
            'ویدیویی برای این پودمان یافت نشد.',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Vazir',
            ),
            textDirection: TextDirection.rtl,
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return GestureDetector(
              onTap: () => _launchVideo(video['url']),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900]!.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Icon(
                      Icons.play_circle_filled,
                      color: Colors.amber,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        video['title'],
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Vazir',
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}