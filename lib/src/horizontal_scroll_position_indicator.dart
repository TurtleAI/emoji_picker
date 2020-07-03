import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

class HorizontalScrollPositionIndicator extends StatelessWidget {
  final int pageCount;
  final ValueNotifier<double> page;
  final double _pageWidth;

  HorizontalScrollPositionIndicator(
      {@required this.pageCount, @required this.page})
      : _pageWidth = 1 / pageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: Colors.black12,
      child: AnimatedBuilder(
        animation: page,
        builder: (context, _) {
          final alignmentX = _alignmentXForIndicator(page.value, pageCount);

          return FractionallySizedBox(
            alignment: Alignment(alignmentX, -1),
            heightFactor: 1,
            widthFactor: _pageWidth,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.blue,
              ),
            ),
          );
        },
      ),
    );
  }
}

double _alignmentXForIndicator(double pageValue, int pageCount) =>
    -1 + (pageValue / (pageCount - 1)) * 2;
