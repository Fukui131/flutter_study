import 'package:flutter/material.dart';
import 'package:qiita_search/screens/search_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env'); // .envファイルを読み込み
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qiita Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Hiragino sans',
        appBarTheme: const AppBarTheme(
           backgroundColor: Color(0xFF55C500),
         ),
         textTheme: Theme.of(context).textTheme.apply(
               bodyColor: Colors.white,
         ),
      ),
      home: const SearchScreen(),
    );
  }
}
