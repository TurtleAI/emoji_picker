import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

class PageScrollPosition {
  final double offset;
  final double width;
  const PageScrollPosition({this.offset = 0, this.width = 0});
}

PageScrollPosition scrollPositionForController(PageController controller) {
  final position = controller.position;
  final offset = controller.offset;
  final totalWidth = position.maxScrollExtent - position.minScrollExtent;
  return PageScrollPosition(
    offset: offset / totalWidth,
    width: position.viewportDimension / totalWidth,
  );
}

class HorizontalScrollPositionIndicator extends StatelessWidget {
  final ValueNotifier<PageScrollPosition> position;

  HorizontalScrollPositionIndicator({this.position});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
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
