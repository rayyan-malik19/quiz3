import 'package:flutter/material.dart';

void main() => runApp(const FlashcardApp());

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashcards',
      home: FlashcardHome(),
    );
  }
}

class FlashcardHome extends StatefulWidget {
  @override
  State<FlashcardHome> createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Map<String, String>> _cards = [
    {"q": "What is Flutter?", "a": "A UI toolkit by Google"},
    {"q": "Language used?", "a": "Dart"},
    {"q": "Widget types?", "a": "Stateless & Stateful"},
  ];
  int learnedCount = 0;

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      learnedCount = 0;
      _cards = [
        {"q": "What is Dart?", "a": "Programming language"},
        {"q": "Use of setState?", "a": "To update UI"},
        {"q": "What is a widget?", "a": "Building block of UI"},
      ];
    });
  }

  void _addCard() {
    final newCard = {"q": "New Question", "a": "New Answer"};
    _cards.insert(0, newCard);
    _listKey.currentState?.insertItem(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
      FloatingActionButton(onPressed: _addCard, child: const Icon(Icons.add)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                title: Text("Learned: $learnedCount of ${_cards.length}"),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedList(
                key: _listKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: _cards.length,
                itemBuilder: (context, index, animation) {
                  final card = _cards[index];
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Dismissible(
                      key: ValueKey(card),
                      onDismissed: (_) {
                        setState(() => learnedCount++);
                        _cards.removeAt(index);
                        _listKey.currentState?.removeItem(
                          index,
                              (context, animation) => const SizedBox.shrink(),
                        );
                      },
                      background: Container(color: Colors.green),
                      child: FlashcardTile(q: card["q"]!, a: card["a"]!),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardTile extends StatefulWidget {
  final String q, a;
  const FlashcardTile({super.key, required this.q, required this.a});

  @override
  State<FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<FlashcardTile> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(showAnswer ? widget.a : widget.q),
        subtitle: showAnswer ? const Text("Tap to hide") : const Text("Tap to reveal"),
        onTap: () => setState(() => showAnswer = !showAnswer),
      ),
    );
  }
}
