import 'package:flutter/material.dart';
import 'package:emoji_picker/emoji_picker.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Test",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Emoji Picker Test"),
        ),
        body: MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => new MainPageState();
}

final emojisForCategory = EmojiCollection.getForCategory(Category.SMILEYS);
final smileyPages = chunk(emojisForCategory, 21);

class MainPageState extends State<MainPage> {
  final PageController pageController = PageController();

  ValueNotifier<ScrollPosition> pageScrollPosition =
      ValueNotifier(ScrollPosition());

  @override
  void initState() {
    super.initState();

    pageController.addListener(() {
      pageScrollPosition.value = scrollPositionForController(pageController);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // EmojiPickerLegacy(
        //   rows: 3,
        //   columns: 7,
        //   buttonMode: ButtonMode.MATERIAL,
        //   numRecommended: 10,
        //   onEmojiSelected: (emoji, category) {
        //     print(emoji);
        //   },
        // ),
        SizedBox(height: 20),
        EmojiPicker(
          rows: 3,
          columns: 7,
          buttonMode: ButtonMode.MATERIAL,
          numRecommended: 10,
          onEmojiSelected: (emoji, category) {
            print(emoji);
          },
        ),
        SizedBox(height: 50),
        SizedBox(
          height: 200,
          child: EmojiPageView(
            pageController: pageController,
            pages: smileyPages,
            pageSize: 21,
          ),
        ),
        HorizontalScrollPositionIndicator(position: pageScrollPosition),
      ],
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
      height: 20,
      color: Colors.yellow,
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
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
