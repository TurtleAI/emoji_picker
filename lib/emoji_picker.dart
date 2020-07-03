library emoji_picker;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'src/emoji_lists.dart' as emojiList;
import 'src/horizontal_scroll_position_indicator.dart';
import 'src/util.dart';

class Emoji {
  final String name;
  final String unicode;

  Emoji({
    @required this.name,
    @required this.unicode,
  });

  @override
  String toString() {
    return "$name, $unicode";
  }
}

class EmojiPicker extends StatefulWidget {
  final EmojiDataSource dataSource;
  final Category selectedCategory;

  final void Function(Emoji emoji) onEmojiPressed;

  EmojiPicker({
    @required this.dataSource,
    this.selectedCategory,
    this.onEmojiPressed,
  });

  @override
  State<StatefulWidget> createState() {
    return _EmojiPickerState();
  }
}

class _EmojiPickerState extends State<EmojiPicker> {
  final pageController = PageController();
  final pageScrollPosition =
      ValueNotifier<PageScrollPosition>(PageScrollPosition());

  Category selectedCategory;

  @override
  void initState() {
    super.initState();

    pageController.addListener(_onPageControllerScroll);
    selectedCategory =
        widget.selectedCategory ?? widget.dataSource.categories[0];
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: EmojiPageView(
            pageController: pageController,
            onEmojiPressed: widget.onEmojiPressed,
            emojis: emojis,
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
  }
}

class Category {
  final IconData icon;
  final String name;
  Category({this.name, this.icon});
}

abstract class EmojiDataSource {
  List<Category> get categories;
  List<Emoji> emojisForCategory(Category category);
}

class DefaultEmojiDataSource implements EmojiDataSource {
  final _emojiCategories = <Category>[
    // Category(name: 'Recent', icon: Icons.search),
    Category(name: 'Faces', icon: Icons.tag_faces),
    Category(name: 'Animals', icon: Icons.pets),
    Category(name: 'Foods', icon: Icons.fastfood),
    Category(name: 'Travel', icon: Icons.location_city),
    Category(name: 'Activities', icon: Icons.directions_run),
    Category(name: 'Objects', icon: Icons.lightbulb_outline),
    Category(name: 'Symbols', icon: Icons.euro_symbol),
    Category(name: 'Flags', icon: Icons.flag),
  ];

  @override
  List<Category> get categories => _emojiCategories;

  @override
  List<Emoji> emojisForCategory(Category category) {
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
              unicode: e.value,
            ))
        .toList();
  }
}

class EmojiPage extends StatelessWidget {
  final List<Emoji> emojis;
  final int pageSize;
  final double buttonSize;
  final void Function(Emoji emoji) onEmojiPressed;

  EmojiPage({
    @required this.emojis,
    @required this.pageSize,
    this.buttonSize = 55,
    this.onEmojiPressed,
  });

  @override
  Widget build(BuildContext context) {
    final numEmptySlots = pageSize - emojis.length;
    return Container(
      color: const Color.fromRGBO(242, 242, 242, 1),
      child: Center(
        child: Wrap(
          children: [
            for (final e in emojis)
              EmojiButton(
                emoji: e,
                size: buttonSize,
                onPressed: () {
                  onEmojiPressed?.call(e);
                },
              ),
            for (int i = 0; i < numEmptySlots; i++)
              SizedBox(
                width: buttonSize,
                height: buttonSize,
              )
          ],
        ),
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
            emoji.unicode,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class EmojiPageView extends StatelessWidget {
  const EmojiPageView({
    @required this.emojis,
    @required this.pageController,
    this.buttonSize = 55.0,
    this.onEmojiPressed,
  });

  final List<Emoji> emojis;
  final PageController pageController;
  final double buttonSize;
  final void Function(Emoji emoji) onEmojiPressed;

  @override
  Widget build(Object context) {
    if (emojis.isEmpty) {
      return Container(
        child: Center(
          child: Text(
            'No items',
            style: TextStyle(fontSize: 20, color: Colors.black26),
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final pageSize = _calculatePageSize(constraints);
      final pages = chunk(emojis, pageSize);

      return PageView.builder(
        controller: pageController,
        itemCount: pages.length,
        itemBuilder: (context, position) {
          final pageForPosition = pages[position];
          return EmojiPage(
            emojis: pageForPosition,
            onEmojiPressed: onEmojiPressed,
            pageSize: pageSize,
            buttonSize: buttonSize,
          );
        },
      );
    });
  }

  int _calculatePageSize(BoxConstraints constraints) {
    final maxRows = constraints.maxWidth ~/ buttonSize;
    final maxCols = constraints.maxHeight ~/ buttonSize;
    return maxRows * maxCols;
  }
}

class CategoryTabBar extends StatelessWidget {
  final List<Category> categories;
  final Category selectedCategory;

  final void Function(Category category) onTabPressed;

  CategoryTabBar({
    @required this.categories,
    this.onTabPressed,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 20, maxHeight: 45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final c in categories)
            Expanded(
              flex: 1,
              child: CategoryIconButton(
                icon: c.icon,
                selected: c == selectedCategory,
                onPressed: () {
                  onTabPressed?.call(c);
                },
              ),
            )
        ],
      ),
    );
  }
}

class CategoryIconButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback onPressed;

  final Color backgroundColor;
  final Color color;

  final bool selected;
  final Color selectedColor;
  final Color selectedBackgroundColor;

  CategoryIconButton({
    @required this.icon,
    this.onPressed,
    this.color = const Color.fromRGBO(211, 211, 211, 1),
    this.backgroundColor = const Color.fromRGBO(242, 242, 242, 1),
    this.selected = false,
    this.selectedColor = const Color.fromRGBO(178, 178, 178, 1),
    this.selectedBackgroundColor = Colors.black12,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      autofocus: false,
      clipBehavior: Clip.none,
      onPressed: this.onPressed,
      color: selected ? selectedBackgroundColor : backgroundColor,
      child: Icon(
        icon,
        size: 22,
        color: selected ? selectedColor : color,
      ),
    );
  }
}
