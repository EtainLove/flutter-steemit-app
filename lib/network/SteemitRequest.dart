import 'dart:async';    // 비동기
import 'dart:convert';  // JSON 파싱
import 'package:http/http.dart' as http;
import 'package:steemlog/model/PostList.dart';

class SteemitRequest {
  /**
   * 스팀잇 피드 리스트를 조회
   */
  Future<PostList> fetchFeedList(String username, int limit) async {
    final _url = "https://api.steemit.com";

    final body = '{"jsonrpc":"2.0", "method":"condenser_api.get_discussions_by_feed", "params":[{"tag":"${username}","limit":${limit
        .toString()}}], "id":1}';
    final response = await http.post(_url, body: body);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return PostList.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }
}