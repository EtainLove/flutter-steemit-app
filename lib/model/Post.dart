class Post {
  final num id;
  final String title;
  final String body;
  final String url;

  Post({
    this.id,
    this.title,
    this.body,
    this.url,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as num,
      title: json['title'] as String,
      body: json['body'] as String,
      url: json['url'] as String,
    );
  }
}