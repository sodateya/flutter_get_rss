import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart' as xml;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RssFeedPage(),
    );
  }
}

class RssFeedPage extends StatefulWidget {
  const RssFeedPage({super.key});

  @override
  _RssFeedPageState createState() => _RssFeedPageState();
}

class _RssFeedPageState extends State<RssFeedPage> {
  List<Map<String, String>> articles = [];

  @override
  void initState() {
    super.initState();
    fetchRssFeed();
  }

  Future<void> fetchRssFeed() async {
    final response =
        await http.get(Uri.parse('https://zenn.dev/funbatter/feed'));

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      setState(() {
        articles = items.map((item) {
          final title = item.findElements('title').single.text;
          final link = item.findElements('link').single.text;
          final pubDate = item.findElements('pubDate').single.text;

          final enclosureElement = item.findElements('enclosure').isNotEmpty
              ? item.findElements('enclosure').single.getAttribute('url')
              : '';

          return {
            'title': title,
            'link': link,
            'pubDate': pubDate,
            'enclosure': enclosureElement!,
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load RSS feed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zenn RSS Feed')),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                final url = article['link'];
                if (url != null) {
                  launchUrl(Uri.parse(url));
                }
              },
              child: SizedBox(
                child: Image.network(article['enclosure'] ?? ''),
              ),
            ),
          );
        },
      ),
    );
  }
}
