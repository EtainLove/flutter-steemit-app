import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:steemlog/model/Post.dart';
import 'package:steemlog/model/PostList.dart';
import 'package:steemlog/network/SteemitRequest.dart';

import "package:pull_to_refresh/pull_to_refresh.dart";

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
  final _limit = 5; // 가져올 피드 개수
  RefreshController _refreshController;

  @override
  void initState() {
    _refreshController = new RefreshController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Feed List'),
        ),
        body: _buildSuggestions()
    );
  }

  void _onRefresh(bool up){
    print('_onRefresh: ' + (up?'true':'false'));
//    _refreshController.sendBack(true, RefreshStatus.idle);
    if(up){
      // 위로 당겼을때
      SteemitRequest().fetchFeedList(_username, _limit).then((r) {
        print('result:' + r.toString());
        setState(() {});
//        _refreshController.sendBack(false, RefreshStatus.idle);
        _refreshController.sendBack(true, RefreshStatus.completed);
      }).catchError(() {
        _refreshController.sendBack(true, RefreshStatus.failed);
      });
      // 위로
//      _refreshController.scrollTo(_refreshController.scrollController.offset+100.0);
//      _refreshController.sendBack(true, RefreshStatus.idle);
//      setState(() {});
    }
    else{
      // 아래로 당겼을때
      //footerIndicator Callback
//      setState(() {});
//      _refreshController.sendBack(false, RefreshStatus.idle);
      SteemitRequest().fetchFeedList(_username, _limit).then((r) {
        print('result:' + r.toString());
        setState(() {});
//        _refreshController.sendBack(false, RefreshStatus.idle);
        _refreshController.sendBack(false, RefreshStatus.idle);
      }).catchError(() {
        _refreshController.sendBack(false, RefreshStatus.failed);
      });
    }
  }

  void _onOffsetCallback(bool isUp, double offset) {
    // if you want change some widgets state ,you should rewrite the callback
  }

  Widget _headerCreate(BuildContext context, int mode) {
    return new ClassicIndicator(mode: mode);
  }

  Widget _footerCreate(BuildContext context, int mode) {
    return new ClassicIndicator(
      mode: mode,
      refreshingText: 'Loading...',
//      idleIcon: const Icon(Icons.arrow_upward),
      idleText: 'Loadmore...',
    );
  }

  Widget _buildSuggestions() {
    return new Center(
        child: FutureBuilder<PostList>(
            future: SteemitRequest().fetchFeedList(_username, _limit),
            builder: (context, AsyncSnapshot<PostList> snapshot) {
              print('snapshot.connectionState: ' + snapshot.connectionState.toString());
              if (snapshot.hasData) {
                return new SmartRefresher(
                    enablePullUp: true,
                    enablePullDown: true,
                    controller: _refreshController,
                    onRefresh: _onRefresh,
//                    headerBuilder: _headerCreate,
                    footerBuilder: _footerCreate,
                    footerConfig: new RefreshConfig(),
//                    onOffsetChange: _onOffsetCallback,
                    child: new ListView.builder(
                      padding: const EdgeInsets.all(5.0),
                      itemCount: snapshot.data.result.length,
                      itemBuilder: (BuildContext _context, int position) {
                        return _buildRow(snapshot.data.result[position]);
                      },
                    )
                );
                /*
                return new ListView.builder(
                  padding: const EdgeInsets.all(5.0),
                  itemCount: post.data.result.length,
                  itemBuilder: (BuildContext _context, int position) {
                    return _buildRow(post.data.result[position]);
                  },
                );
                */
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
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