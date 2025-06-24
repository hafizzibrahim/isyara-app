class VideoResponse {
  final String word;
  final String videoData; // base64 tanpa prefix

  VideoResponse({required this.word, required this.videoData});
}