import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qiita_search/models/article.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Article> articles = []; // 検索結果を格納する変数
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qiita Search'),
      ),
      body: Column(
        children: [
          // 検索ボックス
          Padding( // Paddingで囲む
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 36,
              ),
            child: TextField(
              style: TextStyle( // TextStyleを渡す
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: InputDecoration( // InputDecorationを渡す
                hintText: '検索ワードを入力してください',
              ),
              onSubmitted: (String value) {
                final results = await searchQiita(value); // ← 検索処理を実行する
                setState(() => articles = results); // 検索結果を代入
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Article>> searchQiita(String keyword) async {
  // 1. http通信に必要なデータを準備をする
  final uri = Uri.https('qiita.com', '/api/v2/items', { // Uri.https([baseUrl], [Urlパス], Map<String,dynamic>[クエリパラメータ])
    'query': 'title:$keyword',
    'per_page': '10',
  });
  final String token = dotenv.env['QIITA_ACCESS_TOKEN'] ?? ''; // アクセストークンを取得
  // 2. Qiita APIにリクエストを送る
  final http.Response res = await http.get(uri, headers: {  // アクセストークンを含めてリクエストを送信
    'Authorization': 'Bearer $token',
  });
  // 3. 戻り値をArticleクラスの配列に変換
  // 4. 変換したArticleクラスの配列を返す(returnする)
  if (res.statusCode == 200) {
    // モデルクラスへ変換
    final List<dynamic> body = jsonDecode(res.body);  // レスポンスをモデルクラスへ変換
    return body.map((dynamic json) => Article.fromJson(json)).toList();
    } else {
    return [];
    }
  }
}