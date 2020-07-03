library emoji_picker;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'emoji_lists.dart' as emojiList;

List<List<T>> chunk<T>(List<T> list, int chunkSize) {
  final List<List<T>> chunks = [];
  final len = list.length;
  for (var i = 0; i < list.length; i += chunkSize) {
    int size = i + chunkSize;
    chunks.add(list.sublist(i, size > len ? len : size));
  }
  return chunks;
}

/// A class to store data for each individual emoji
class Emoji {
  /// The name or description for this emoji
  final String name;

  /// The unicode string for this emoji
  ///
  /// This is the string that should be displayed to view the emoji
  final String emoji;

  Emoji({
    @required this.name,
    @required this.emoji,
  });

  @override
  String toString() {
    return "Name: " + name + ", Emoji: " + emoji;
  }
}

class EmojiCategory {
  final IconData icon;
  final String name;
  EmojiCategory({this.name, this.icon});
}

abstract class EmojiDataSource {
  List<EmojiCategory> get categories;
  List<Emoji> emojisForCategory(EmojiCategory category);
}

class DefaultEmojiDataSource implements EmojiDataSource {
  final _emojiCategories = <EmojiCategory>[
    EmojiCategory(name: 'Recent', icon: Icons.search),
    EmojiCategory(name: 'Faces', icon: Icons.tag_faces),
    EmojiCategory(name: 'Animals', icon: Icons.pets),
    EmojiCategory(name: 'Foods', icon: Icons.fastfood),
    EmojiCategory(name: 'Travel', icon: Icons.location_city),
    EmojiCategory(name: 'Activities', icon: Icons.directions_run),
    EmojiCategory(name: 'Objects', icon: Icons.lightbulb_outline),
    EmojiCategory(name: 'Symbols', icon: Icons.euro_symbol),
    EmojiCategory(name: 'Flags', icon: Icons.flag),
  ];

  @override
  List<EmojiCategory> get categories => _emojiCategories;

  @override
  List<Emoji> emojisForCategory(EmojiCategory category) {
    switch (category.name) {
      case 'Recent':
        return [];
      case 'Faces':
        return _toEmojis(emojiList.smileys);
      case 'Animals':
        return _toEmojis(emojiList.animals);
      case 'Foods':
        return _toEmojis(emojiList.foods);
      case 'Travel':
        return _toEmojis(emojiList.travel);
      case 'Activities':
        return _toEmojis(emojiList.activities);
      case 'Objects':
        return _toEmojis(emojiList.objects);
      case 'Symbols':
        return _toEmojis(emojiList.symbols);
      case 'Flags':
        return _toEmojis(emojiList.flags);
      default:
        return [];
    }
  }

  List<Emoji> _toEmojis(Map<String, String> emojiMap) {
    return emojiMap.entries
        .map((e) => Emoji(
              name: e.key,
              emoji: e.value,
            ))
        .toList();
  }
}

class EmojiPickerSheet extends StatefulWidget {
  final EmojiDataSource dataSource;
  final void Function(Emoji emoji) onEmojiPressed;

  EmojiPickerSheet({
    @required this.dataSource,
    this.onEmojiPressed,
  });

  @override
  State<StatefulWidget> createState() {
    return _EmojiPickerSheetState();
  }
}

class _EmojiPickerSheetState extends State<EmojiPickerSheet> {
  final pageController = PageController();
  final pageScrollPosition = ValueNotifier<ScrollPosition>(ScrollPosition());

  EmojiCategory selectedCategory;

  @override
  void initState() {
    super.initState();

    pageController.addListener(_onPageControllerScroll);
    selectedCategory = widget.dataSource.categories[1];
  }

  @override
  void dispose() {
    super.dispose();
    pageController.removeListener(_onPageControllerScroll);
  }

  void _onPageControllerScroll() {
    pageScrollPosition.value = scrollPositionForController(pageController);
  }

  @override
  Widget build(BuildContext context) {
    final emojis = widget.dataSource.emojisForCategory(selectedCategory);

    final pageSize = 21;
    final pages = chunk(emojis, pageSize);

    return LayoutBuilder(
      builder: (context, constraints) {
        print(constraints);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 200,
              child: EmojiPageView(
                pageController: pageController,
                onEmojiPressed: widget.onEmojiPressed,
                pages: pages,
                pageSize: pageSize,
              ),
            ),
            HorizontalScrollPositionIndicator(position: pageScrollPosition),
            SizedBox(height: 1),
            CategoryTabBar(
              categories: widget.dataSource.categories,
              selectedCategory: selectedCategory,
              onTabPressed: (c) {
                setState(() {
                  selectedCategory = c;
                  pageController.jumpToPage(0);
                });
              },
            ),
          ],
        );
      },
    );
  }
}

class ScrollPosition {
  final double offset;
  final double width;
  const ScrollPosition({this.offset = 0, this.width = 0});
}

ScrollPosition scrollPositionForController(PageController controller) {
  final position = controller.position;
  final offset = controller.offset;
  final totalWidth = position.maxScrollExtent - position.minScrollExtent;
  return ScrollPosition(
    offset: offset / totalWidth,
    width: position.viewportDimension / totalWidth,
  );
}

class HorizontalScrollPositionIndicator extends StatelessWidget {
  final ValueNotifier<ScrollPosition> position;

  HorizontalScrollPositionIndicator({this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      color: Colors.black12,
      child: AnimatedBuilder(
        animation: position,
        builder: (context, _) {
          final curPosition = this.position.value;
          return Align(
            alignment: FractionalOffset(curPosition.offset, 0),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              heightFactor: 1,
              widthFactor: curPosition.width,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.blue,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmojiPage extends StatelessWidget {
  final List<Emoji> emojis;
  final void Function(Emoji emoji) onEmojiPressed;

  EmojiPage({
    @required this.emojis,
    this.onEmojiPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(242, 242, 242, 1),
      child: Wrap(
        children: [
          for (final e in emojis)
            EmojiButton(
              emoji: e,
              size: 55,
              onPressed: () {
                onEmojiPressed?.call(e);
              },
            ),
        ],
      ),
    );
  }
}

class EmojiButton extends StatelessWidget {
  const EmojiButton({
    @required this.emoji,
    @required this.size,
    this.onPressed,
  });

  final Emoji emoji;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FlatButton(
        onPressed: onPressed,
        child: Center(
          child: Text(
            emoji.emoji,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class EmojiPageView extends StatelessWidget {
  const EmojiPageView({
    @required this.pages,
    @required this.pageSize,
    @required this.pageController,
    this.onEmojiPressed,
  });

  final List<List<Emoji>> pages;
  final int pageSize;
  final PageController pageController;
  final void Function(Emoji emoji) onEmojiPressed;

  @override
  Widget build(Object context) {
    return PageView.builder(
      controller: pageController,
      itemCount: pages.length,
      itemBuilder: (context, position) {
        final pageForPosition = pages[position];
        return EmojiPage(
          emojis: pageForPosition,
          onEmojiPressed: onEmojiPressed,
        );
      },
    );
  }
}

class CategoryTabBar extends StatelessWidget {
  final List<EmojiCategory> categories;
  final EmojiCategory selectedCategory;

  final void Function(EmojiCategory category) onTabPressed;

  CategoryTabBar({
    @required this.categories,
    this.onTabPressed,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final c in categories)
          CategoryIconButton(
            icon: c.icon,
            selected: c == selectedCategory,
            size: 45,
            onPressed: () {
              onTabPressed?.call(c);
            },
          )
      ],
    );
  }
}

class CategoryIconButton extends StatelessWidget {
  final IconData icon;
  final double size;

  final VoidCallback onPressed;

  final Color backgroundColor;
  final Color color;

  final bool selected;
  final Color selectedColor;
  final Color selectedBackgroundColor;

  CategoryIconButton({
    @required this.icon,
    @required this.size,
    this.onPressed,
    this.color = const Color.fromRGBO(211, 211, 211, 1),
    this.backgroundColor = const Color.fromRGBO(242, 242, 242, 1),
    this.selected = false,
    this.selectedColor = const Color.fromRGBO(178, 178, 178, 1),
    this.selectedBackgroundColor = Colors.black12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FlatButton(
        autofocus: false,
        clipBehavior: Clip.none,
        onPressed: this.onPressed,
        color: selected ? selectedBackgroundColor : backgroundColor,
        child: Center(
          child: Icon(
            icon,
            size: 22,
            color: selected ? selectedColor : color,
          ),
        ),
      ),
    );
  }
}
