import 'dart:math';

import 'package:digimon_monster/Game/CostList.dart';
import 'package:digimon_monster/Game/card_model.dart';
import 'package:digimon_monster/Game/game_data_controller.dart';
import 'package:digimon_monster/Game/GameValue.dart';
import 'package:digimon_monster/Game/card_action_controller.dart';
import 'package:digimon_monster/Game/card_view.dart';
import 'package:flutter/material.dart';

class CheckerboardView extends StatefulWidget {
  // bool isReverse;

  // CheckerboardView({this.isReverse = false});
  @override
  State<StatefulWidget> createState() => _CheckerboardState();

  double cardWidth() {
    return Value.cardWidth();
  }

  double cardHeight() {
    return Value.cardHeight();
  }

  double padding() {
    return Value.padding();
  }

  double checkerboardHeight() {
    return cardHeight() * 3 + padding() * 4;
  }
}

class _CheckerboardState extends State<CheckerboardView> {
  GlobalKey _areaKey;
  @override
  void initState() {
    super.initState();
    // if (!widget.isReverse) {
    CardActionController().positionChangeCardListener((areaKey) {
      if (_areaKey != areaKey) {
        _areaKey = areaKey;
        setState(() {});
      }
    });
    GameDataController().addCardChangeListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.004)
            ..rotateZ(-pi * 1),
          alignment: Alignment.center,
          child: Container(
            height: Value.checkerboardHeight(),
            // width: Value.checkerboardWidth(),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                  child: Opacity(
                    opacity: 0.3,
                    child: Image.asset(
                      "images/bg.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 联防
                Positioned(
                  left: widget.padding(),
                  top: widget.padding(),
                  child: Container(
                    width: widget.cardHeight(),
                    height: widget.cardWidth() * (13.0 / 5.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 1), //边框
                      borderRadius: BorderRadius.all(
                        Radius.circular(2.0),
                      ),
                    ),
                  ),
                ),
                for (int i = 0;
                    i < GameDataController().defenseCardList.length;
                    i++)
                  Positioned(
                    left: widget.padding() * 2,
                    top: Value.cardWidth() * (0.4 * i),
                    child: CardView(
                      model: null,
                      isVertical: false,
                      cardInArea: CardLocation.safe,
                    ),
                  ),
                // 战斗区
                Positioned(
                  left: widget.padding() * 2 + widget.cardHeight(),
                  right: widget.padding() * 2 + widget.cardWidth(),
                  top: widget.padding(),
                  child: Container(
                    height: widget.cardWidth() * (13.0 / 5.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // children: [
                        //   for (ViewModel item
                        //       in GameDataController().monstersCardList)
                        //     Padding(
                        //       padding: EdgeInsets.symmetric(horizontal: 10),
                        //       child: CardView(
                        //         model: item,
                        //       ),
                        //     )
                        // ],
                      ),
                    ),
                  ),
                ),
                // 卡堆
                Positioned(
                  right: widget.padding(),
                  top: widget.padding(),
                  child: CardView(
                    model: null,
                    isCanClick: false,
                    cardInArea: CardLocation.cardList,
                  ),
                ),
                // 废弃区
                Positioned(
                  right: widget.padding(),
                  top: widget.padding() * 2 + widget.cardHeight(),
                  child: CardView(
                    isCanMove: false,
                    cardInArea: CardLocation.used,
                  ),
                ),
                // 阶段
                Positioned(
                  right: widget.padding(),
                  top: widget.padding() * 3 + widget.cardHeight() * 2,
                  child: CardView(model: null),
                ),
                // 育成区1
                Positioned(
                  left: widget.padding(),
                  top: widget.padding() * 2 + widget.cardWidth() * (13.0 / 5.0),
                  child: CardView(
                    model: null,
                    cardInArea: CardLocation.egg,
                  ),
                ),
                // 育成区2
                Positioned(
                  left: widget.padding() * 2 + widget.cardWidth(),
                  top: widget.padding() * 2 + widget.cardWidth() * (13.0 / 5.0),
                  child: Container(
                      // key: CardActionController().eggArea,
                      // child: CardView(
                      //   model: GameDataController().prepareCardList.last,
                      // ),
                      ),
                ),
                // 驯兽师
                Positioned(
                  top: widget.padding() * 2 + widget.cardWidth() * (13.0 / 5.0),
                  left: widget.padding() * 3 + widget.cardWidth() * 2,
                  right: widget.padding() * 2 + widget.cardWidth(),
                  child: Container(
                    // key: CardActionController().downArea,
                    width: (widget.padding() +
                            widget.cardHeight() +
                            widget.cardWidth() * 5) -
                        (widget.padding() * 2 + widget.cardWidth() * 2),
                    height: Value.checkerboardHeight() -
                        (widget.cardWidth() * (13.0 / 5.0)) -
                        widget.padding() * 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // for (ViewModel item
                        //     in GameDataController().masterCardList)
                        //   Padding(
                        //     padding: EdgeInsets.symmetric(horizontal: 10),
                        //     child: CardView(
                        //       model: item,
                        //     ),
                        //   )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 30,
          child: CostList(),
        ),
        Container(
          width: double.infinity,
          height: Value.checkerboardHeight(),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    "images/bg.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 联防
              Positioned(
                left: widget.padding(),
                top: widget.padding(),
                child: Container(
                  width: widget.cardHeight(),
                  height: widget.cardWidth() * (13.0 / 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 1), //边框
                    borderRadius: BorderRadius.all(
                      Radius.circular(2.0),
                    ),
                  ),
                ),
              ),
              for (int i = 0;
                  i < GameDataController().defenseCardList.length;
                  i++)
                Positioned(
                  left: widget.padding() * 2,
                  top: Value.cardWidth() * (0.4 * i),
                  child: CardView(
                    model: null,
                    isVertical: false,
                    cardInArea: CardLocation.safe,
                  ),
                ),
              // 战斗区
              Positioned(
                left: widget.padding() * 2 + widget.cardHeight(),
                right: widget.padding() * 2 + widget.cardWidth(),
                top: widget.padding(),
                child: Container(
                  key: CardActionController().upArea,
                  height: widget.cardWidth() * (13.0 / 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (_areaKey == CardActionController().upArea)
                          ? Colors.red
                          : Colors.blue,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (ViewModel item
                            in GameDataController().monstersCardList)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: CardView(
                              model: item,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              // 卡堆
              Positioned(
                right: widget.padding(),
                top: widget.padding(),
                child: InkWell(
                  child: GameDataController().cardList.length > 0
                      ? CardView(
                          model: null,
                          isCanClick: false,
                          cardInArea: CardLocation.cardList,
                        )
                      : Container(),
                  onTap: () {
                    GameDataController().darwCard();
                  },
                ),
              ),
              // 废弃区
              Positioned(
                right: widget.padding(),
                top: widget.padding() * 2 + widget.cardHeight(),
                child: CardView(
                  isCanMove: false,
                  cardInArea: CardLocation.used,
                ),
              ),
              // 阶段
              Positioned(
                right: widget.padding(),
                top: widget.padding() * 3 + widget.cardHeight() * 2,
                child: CardView(model: null),
              ),
              // 育成区1
              Positioned(
                left: widget.padding(),
                top: widget.padding() * 2 + widget.cardWidth() * (13.0 / 5.0),
                child: CardView(
                  model: null,
                  cardInArea: CardLocation.egg,
                ),
              ),
              // 育成区2
              Positioned(
                left: widget.padding() * 2 + widget.cardWidth(),
                top: widget.padding() * 2 + widget.cardWidth() * (13.0 / 5.0),
                child: Container(
                  key: CardActionController().eggArea,
                  child: CardView(
                    model: GameDataController().prepareCardList.isNotEmpty
                        ? GameDataController().prepareCardList.last
                        : null,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: (_areaKey == CardActionController().eggArea)
                            ? Colors.red
                            : Colors.blue,
                        width: 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2.0),
                    ),
                  ),
                ),
              ),
              // 驯兽师
              Positioned(
                top: widget.padding() * 2 + widget.cardWidth() * (13.0 / 5.0),
                left: widget.padding() * 3 + widget.cardWidth() * 2,
                right: widget.padding() * 2 + widget.cardWidth(),
                child: Container(
                  key: CardActionController().downArea,
                  width: (widget.padding() +
                          widget.cardHeight() +
                          widget.cardWidth() * 5) -
                      (widget.padding() * 2 + widget.cardWidth() * 2),
                  height: Value.checkerboardHeight() -
                      (widget.cardWidth() * (13.0 / 5.0)) -
                      widget.padding() * 3,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: (_areaKey == CardActionController().downArea)
                            ? Colors.red
                            : Colors.blue,
                        width: 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(2.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (ViewModel item
                          in GameDataController().masterCardList)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: CardView(
                            model: item,
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
