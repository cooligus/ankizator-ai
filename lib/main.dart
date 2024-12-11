import 'dart:ffi';

import 'package:ankizator_ai/sources.dart';
import 'package:ankizator_ai/words.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  late Future<List<Source>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnkizatorAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow.shade700),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AnkizatorAI'),
        ),
        body: Center(
          child: FutureBuilder<List<Source>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GridView.count(
                    childAspectRatio: 4 / 6,
                    crossAxisCount: 3,
                    children: snapshot.data!.map<Widget>((doc) {
                      return GestureDetector(
                          onTap: () {
                          // Navigate to another screen (folder in your case)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordsRoute(urlMerula: doc.url), // Replace with your screen
                            ),
                          );
                        },
                          child: Center(
                            child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipOval(
                                          child: Image(image: NetworkImage(
                                              "https://merula.pl/kos/wp-content/uploads/2014/10/merula_logo4@2x.png")
                                          ),
                                        ),
                                      ),
                                      Text(doc.name)
                                    ],
                                  ),
                                )
                            ),
                          )
                      );
                    }
                    ).toList()
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

class WordsRoute extends StatefulWidget {
  final String urlMerula;

  const WordsRoute({super.key, required this.urlMerula});

  @override
  State<WordsRoute> createState() => _WordsRoute();
}

class _WordsRoute extends State<WordsRoute> {
  late Future<List<WordsPair>> futureWords;

  @override
  void initState() {
    super.initState();
    futureWords = fetchWords(widget.urlMerula);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnkizatorAI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow.shade700),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dictionary'),
          leading: BackButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyApp(),
                  ),
                );
              }
          ),
        ),
        body: ListView(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestedFile(),
                  ),
                );
              },
              child: const Text('Send request for full sentences'),
            ),
            Center(
              child: FutureBuilder<List<WordsPair>>(
                future: futureWords,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                        child: WordsTable(words: snapshot.data!));
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  // By default, show a loading spinner.
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ]
        )
      ),
    );
  }
}

class WordsTable extends StatefulWidget {
  final List<WordsPair> words;

  const WordsTable ({super.key, required this.words});

  @override
  State<WordsTable> createState() => _CheckState();
}

class _CheckState extends State<WordsTable> {

  @override
  Widget build(BuildContext context) {
    return Table(
        border: TableBorder.all(),
        columnWidths: const <int, TableColumnWidth>{
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
          2: FixedColumnWidth(80),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: widget.words.map((wordsPair) {
          return TableRow(
            children: [
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Text(wordsPair.pl)
                ),
                TableCell(
                    verticalAlignment: TableCellVerticalAlignment.top,
                    child: Text(wordsPair.en)
                )
            ],
          );
        }).toList()
    );
  }
}

class RequestedFile extends StatelessWidget {
  const RequestedFile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'AnkizatorAI',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow.shade700),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Download an antideck'),
            leading: BackButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyApp(),
                  ),
                );
              }
            ),
          ),
          body: const Center(
            // child: FutureBuilder<List<WordsPair>>(
            //   future: F,
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return Text('${snapshot.data}');
            //     } else if (snapshot.hasError) {
            //       return Text('${snapshot.error}');
            //     }
            //     // By default, show a loading spinner.
            //     return const CircularProgressIndicator();
            //   },
            // )
          ),
        )
    );
  }
}
