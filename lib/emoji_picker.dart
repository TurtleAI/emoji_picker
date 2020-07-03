library emoji_picker;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'emoji_data_source.dart';
import 'src/horizontal_scroll_position_indicator.dart';
import 'src/util.dart';

const DEFAULT_BACKGROUND_COLOR = Color.fromRGBO(242, 242, 242, 1);

class EmojiPicker extends StatefulWidget {
  final EmojiDataSource dataSource;
  final Category selectedCategory;
  final Color backgroundColor;

  final void Function(Emoji emoji) onEmojiPressed;

  EmojiPicker({
    @required this.dataSource,
    this.backgroundColor = DEFAULT_BACKGROUND_COLOR,
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
  final pageScrollOffset = ValueNotifier<double>(0);

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
    pageScrollOffset.value = pageController.page;
  }

  @override
  Widget build(BuildContext context) {
    final emojis = widget.dataSource.emojisForCategory(selectedCategory);
    return Container(
      color: widget.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: EmojiPageView(
              pageController: pageController,
              onEmojiPressed: widget.onEmojiPressed,
              emojis: emojis,
              pageScrollOffset: pageScrollOffset,
            ),
          ),
          CategoryTabBar(
            categories: widget.dataSource.categories,
            selectedCategory: selectedCategory,
            backgroundColor: widget.backgroundColor,
            onTabPressed: (c) {
              setState(() {
                selectedCategory = c;
                pageController.jumpToPage(0);
              });
            },
          ),
        ],
      ),
    );
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
    this.pageScrollOffset,
  });

  final List<Emoji> emojis;
  final PageController pageController;
  final double buttonSize;
  final void Function(Emoji emoji) onEmojiPressed;
  final ValueNotifier<double> pageScrollOffset;

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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageView.builder(
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
            ),
          ),
          if (pageScrollOffset != null)
            HorizontalScrollPositionIndicator(
              page: pageScrollOffset,
              pageCount: pages.length,
            ),
        ],
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
  final Color backgroundColor;

  final void Function(Category category) onTabPressed;

  CategoryTabBar({
    @required this.categories,
    this.backgroundColor = DEFAULT_BACKGROUND_COLOR,
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
                backgroundColor: backgroundColor,
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
    this.backgroundColor = DEFAULT_BACKGROUND_COLOR,
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
