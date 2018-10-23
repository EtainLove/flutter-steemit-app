import 'Post.dart';

class PostList {
  final List<Post> result;

  PostList({this.result});

  factory PostList.fromJson(Map<String, dynamic> json) {
    return PostList(
        result: (json['result'] as List)
            ?.map((e) => e == null ? null : new Post.fromJson(e as Map<String, dynamic>))
            ?.toList()
    );
  }
}