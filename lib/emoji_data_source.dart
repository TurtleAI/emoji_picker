import 'package:flutter/widgets.dart' show IconData;
import 'package:meta/meta.dart';

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

class Category {
  final String id;
  final IconData icon;
  final String name;
  Category({@required this.id, @required this.icon, @required this.name});

  bool operator ==(o) {
    return o is Category && id == o.id;
  }

  @override
  int get hashCode => id.hashCode;
}

abstract class EmojiDataSource {
  List<Category> get categories;
  List<Emoji> emojisForCategory(Category category);
}
