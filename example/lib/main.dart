import 'package:flutter/material.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:emoji_picker/emoji_picker_legacy.dart';

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

final emojiDataSource = DefaultEmojiDataSource();

class MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        Container(
          constraints: BoxConstraints.tight(Size.fromHeight(400)),
          child: EmojiPickerSheet(
            dataSource: emojiDataSource,
            onEmojiPressed: (emoji) {
              print("PRESSED $emoji");
            },
          ),
        ),
      ],
    );
  }
}
