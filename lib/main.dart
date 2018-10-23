import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:steemlog/model/Post.dart';
import 'package:steemlog/model/PostList.dart';
import 'package:steemlog/network/SteemitRequest.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Steemlog',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FeedList(),
    );
  }
}


class FeedList extends StatefulWidget {
  @override
  FeedListState createState() => new FeedListState();
}

class FeedListState extends State<FeedList> {
  final String _username = 'anpigon'; // 사용자 이름
  final _limit = 20; // 가져올 피드 개수

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Feed List'),
        ),
        body: _buildSuggestions()
    );
  }

  Widget _buildSuggestions() {
    return new Center(
        child: FutureBuilder<PostList>(
            future: SteemitRequest().fetchFeedList(_username, _limit),
            builder: (context, post) {
              if (post.hasData) {
                return new ListView.builder(
                  padding: const EdgeInsets.all(5.0),
                  itemCount: post.data.result.length,
                  itemBuilder: (BuildContext _context, int position) {
                    return _buildRow(post.data.result[position]);
                  },
                );
              } else if (post.hasError) {
                return Text("${post.error}");
              }
              return CircularProgressIndicator();
            }
        )
    );
  }

  Widget _buildRow(Post post) {
    return new Column(
        children: <Widget>[
          new ListTile(
            title: new Text(post.title),
            subtitle: new Text(post.body,
                overflow: TextOverflow.ellipsis,
                maxLines: 3
            ),
            onTap: () {
              _launchURL(post.url);
            },
          ),
          const Divider()
        ]
    );
  }

  _launchURL(String _url) async {
    final String url = "https://steemit.com${_url}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}