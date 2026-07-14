import 'package:flutter/material.dart';
import 'package:qiita_search/screens/search_screen.dart';

void main() {
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
