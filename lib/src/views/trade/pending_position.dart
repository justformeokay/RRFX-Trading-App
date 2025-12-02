import 'package:flutter/cupertino.dart';

import 'components/position_tile.dart';

class PendingPosition extends StatefulWidget {
  const PendingPosition({super.key});

  @override
  State<PendingPosition> createState() => _PendingPositionState();
}

class _PendingPositionState extends State<PendingPosition> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(3, (i){
          return CustomSlideAbleListTile.openListTile(context);
        })
      ),
    );
  }
}
