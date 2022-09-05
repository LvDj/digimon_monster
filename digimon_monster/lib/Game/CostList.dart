import 'package:digimon_monster/Game/game_data_controller.dart';
import 'package:digimon_monster/widget/CustomText.dart';
import 'package:flutter/material.dart';

class CostList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CostListState();
}

class _CostListState extends State<CostList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
              "对方 ${GameDataController().vsMemoryCount < 0 ? 0 : GameDataController().vsMemoryCount}"),
          SizedBox(
            width: 10,
          ),
          countWidget(GameDataController().vsMemoryCount * 10.0, true),
          VerticalDivider(
            width: 1,
            color: Colors.black,
          ),
          countWidget(GameDataController().myMemoryCount * 10.0, false),
          SizedBox(
            width: 10,
          ),
          CustomText(
              "已方 ${GameDataController().myMemoryCount < 0 ? 0 : GameDataController().myMemoryCount}"),
        ],
      ),
    );
  }

  Widget countWidget(double value, bool left) {
    double _value;
    if (value < 0) {
      _value = 0;
    } else {
      _value = value;
    }
    return Container(
      width: 150,
      height: 8,
      color: Colors.white,
      child: Row(
        mainAxisAlignment:
            left ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.green,
            width: _value,
          ),
        ],
      ),
    );
  }
}
