import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_study/models/article.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// ArticleScreen: 記事を表示する画面
// - Web (kIsWeb) の場合は webview_flutter が利用できないため `url_launcher` で外部ブラウザに遷移します。
// - ネイティブ（Android/iOS/macOS）では `WebViewController` を `initState` 内で初期化します。
//   以前の実装はフィールド初期化で `widget` を参照していたためクラッシュしていました。
//   → 初期化を `initState` に移動して `widget` を安全に使うよう変更しました。

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late final WebViewController controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Web (ブラウザ) では webview_flutter を使えないため外部ブラウザで開く
    if (kIsWeb) {
      // UI が描画された後に外部ブラウザを開く
      WidgetsBinding.instance.addPostFrameCallback((_) => _openInExternalBrowser());
      return;
    }

    // ネイティブ用 WebViewController の初期化
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _hasError = true;
              _errorMessage = error.description;
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.article.url));
  }

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.parse(widget.article.url);
    // webOnlyWindowName を指定すると Web の場合は新しいタブで開けます
    final launched = await launchUrl(uri, webOnlyWindowName: '_blank');
    if (!launched) {
      setState(() {
        _hasError = true;
        _errorMessage = '外部ブラウザを開けませんでした。';
      });
    }
  }

  void _retry() {
    if (kIsWeb) {
      _openInExternalBrowser();
      return;
    }
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    // Web の場合は外部ブラウザへ遷移中の旨を表示
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Article')),
        body: Center(
          child: _hasError
              ? _errorBody()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('外部ブラウザで記事を開きます。'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _openInExternalBrowser,
                      child: const Text('ブラウザで開く'),
                    ),
                  ],
                ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
      ),
      body: Stack(
        children: [
          // エラー時はエラーUIを表示
          if (_hasError) _errorBody(),

          // 正常時は WebView を表示
          if (!_hasError) Positioned.fill(child: WebViewWidget(controller: controller)),

          // ローディング表示
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _errorBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_errorMessage ?? 'ページを読み込めませんでした。'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _retry, child: const Text('再試行')),
          ],
        ),
      ),
    );
  }
}