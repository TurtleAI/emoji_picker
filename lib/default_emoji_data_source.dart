import 'package:flutter/material.dart' show Icons;

import 'emoji_data_source.dart';
import 'src/emoji_data.dart' as emojiData;

Map<String, List<Emoji>> _cachedEmojisByCategory;
Map<String, List<Emoji>> _getEmojisByCategory() {
  if (_cachedEmojisByCategory != null) return _cachedEmojisByCategory;
  _cachedEmojisByCategory = {
    'recent': [],
    'faces': _toEmojis(emojiData.smileys),
    'animals': _toEmojis(emojiData.animals),
    'food': _toEmojis(emojiData.foods),
    'travel': _toEmojis(emojiData.travel),
    'activities': _toEmojis(emojiData.activities),
    'objects': _toEmojis(emojiData.objects),
    'symbols': _toEmojis(emojiData.symbols),
    'flags': _toEmojis(emojiData.flags),
  };
  return _cachedEmojisByCategory;
}

List<Emoji> _toEmojis(Map<String, String> emojiMap) {
  return emojiMap.entries
      .map((e) => Emoji(
            name: e.key,
            unicode: e.value,
          ))
      .toList();
}

class DefaultEmojiDataSource implements EmojiDataSource {
  final _emojiCategories = <Category>[
    // Category(id: 'recent', name: 'Recent', icon: Icons.search),
    Category(id: 'faces', name: 'Faces', icon: Icons.tag_faces),
    Category(id: 'animals', name: 'Animals', icon: Icons.pets),
    Category(id: 'food', name: 'Food', icon: Icons.fastfood),
    Category(id: 'travel', name: 'Travel', icon: Icons.location_city),
    Category(id: 'activities', name: 'Activities', icon: Icons.directions_run),
    Category(id: 'objects', name: 'Objects', icon: Icons.lightbulb_outline),
    Category(id: 'symbols', name: 'Symbols', icon: Icons.euro_symbol),
    Category(id: 'flags', name: 'Flags', icon: Icons.flag),
  ];

  @override
  List<Category> get categories => _emojiCategories;

  @override
  List<Emoji> emojisForCategory(Category category) =>
      _getEmojisByCategory()[category.id];
}
