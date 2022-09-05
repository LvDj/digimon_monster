import 'dart:math';

import 'package:digimon_monster/Game/card_model.dart';
import 'package:digimon_monster/Game/CheckerboardView.dart';
import 'package:digimon_monster/Game/CostList.dart';
import 'package:digimon_monster/Game/game_data_controller.dart';
import 'package:digimon_monster/Game/GameValue.dart';
import 'package:digimon_monster/Game/card_action_controller.dart';
import 'package:digimon_monster/Game/card_view.dart';
import 'package:digimon_monster/widget/CustomText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DMGamePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DMGameState();
  }
}

class _DMGameState extends State<DMGamePage> {
  ViewModel clickModel;
  ScrollController _scrollController;
  ScrollController _infoScrollController;
  double _scrollOffSet = 0;
  int effectStrHeight = 120;
  int everyCardPadding = 50;
  @override
  void initState() {
    super.initState();
    GameDataController().readyToStart().then((value) {
      GameDataController().startGame();
      setState(() {});
    });
    CardActionController().clickCardListener((model) {
      clickModel = model;
      _scrollController.jumpTo(0);
      setState(() {});
    });
    GameDataController().addCardChangeListener(() {
      setState(() {});
    });
    _infoScrollController = ScrollController();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      _scrollOffSet = _scrollController.offset;
      double newOffset =
          (_scrollController.offset / everyCardPadding) * effectStrHeight;
      if (newOffset >= 0) {
        _infoScrollController.jumpTo(newOffset);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widget = [
      Positioned(
        // 如果不旋转则是36
        // top: 20,
        bottom: 20,
        // left: 20,
        // right: 80,
        left: 0,
        right: 0,
        height: Value.checkerboardHeight() * 2 + 40,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.004)
            ..rotateX(-pi * 0.05),
          alignment: Alignment.bottomCenter,
          child: CheckerboardView(),
        ),
      ),
      // Positioned(
      //   bottom: Value.checkerboardHeight() + 20,
      //   left: 0,
      //   right: 0,
      //   child: CostList(),
      // ),
    ];
    for (int i = 0; i < GameDataController().handCardList.length; i++) {
      widget.add(
        handlerCard(
          CardView(
            model: GameDataController().handCardList[i],
          ),
          i * (Value.cardWidth() + 10),
          0,
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "images/game_bg.webp",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          top: false,
          child: Row(
            children: [
              Container(
                width: 250,
                height: 500,
                child: Stack(
                  children: [
                    for (int i = 0;
                        i < (this.clickModel?.models?.length ?? 0);
                        i++)
                      _stackWidget(i, _scrollOffSet),
                    Positioned(
                      left: 0,
                      right: 20,
                      top: Value.cardShowHeight() + everyCardPadding,
                      child: Container(
                        height: effectStrHeight.toDouble(),
                        child: ListView.builder(
                          physics: PageScrollPhysics(),
                          controller: _infoScrollController,
                          itemCount: this.clickModel?.models?.length ?? 0,
                          itemBuilder: ((c, index) {
                            return Container(
                              color: (this.clickModel.cardBgColor() ??
                                      Colors.white)
                                  .withOpacity(0.3),
                              width: 200,
                              height: effectStrHeight.toDouble(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomText(
                                        "${this.clickModel.models[(this.clickModel.models.length - 1) - index].name}",
                                        textAlign: TextAlign.left,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      CustomText(
                                        "DP:${this.clickModel.models[(this.clickModel.models.length - 1) - index].dp}",
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                  CustomText(
                                    "效果:${this.clickModel.models[(this.clickModel.models.length - 1) - index].effectStr}",
                                    textAlign: TextAlign.left,
                                    fontSize: 12,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.transparent,
                              width: double.infinity,
                              height: (this.clickModel?.models?.length ?? 0) *
                                  Value.cardShowHeight(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        child: CustomText("${this.clickModel?.getSelfNowDP()}"))
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: widget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stackWidget(int index, double scrollView) {
    int scaleIndex = scrollView ~/ everyCardPadding;
    double scaleValue =
        ((scrollView % everyCardPadding) / everyCardPadding) * Value.maxScale();
    Widget image = Image.asset(
      this.clickModel.models[index].getIconPath(),
    );
    if (scrollView >= 0) {
      if (index > this.clickModel.models.length - 1 - scaleIndex) {
        image = Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(-pi * Value.maxScale()),
          alignment: Alignment.topCenter,
          child: image,
        );
      } else if (index == this.clickModel.models.length - 1 - scaleIndex) {
        image = Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(-pi * scaleValue),
          alignment: Alignment.topCenter,
          child: image,
        );
      }
    }

    return Positioned(
      top: 20 + (10.0 * (this.clickModel.models.length - 1 - index)),
      right: 20 + (10 * (this.clickModel.models.length - 1 - index)).toDouble(),
      height: Value.cardShowHeight(),
      width: Value.cardShowWidth(),
      child: image,
    );
  }

  Widget handlerCard(CardView view, double left, double bottom) {
    double cardLeft = left;
    double cardBottom = bottom;
    return Positioned(
      bottom: cardBottom,
      left: cardLeft,
      child: view,
    );
  }
}

/*

          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.006)
              ..rotateX(-1 / 4),
            alignment: Alignment.bottomCenter,
            child:
              Container(
                color: Colors.red,
                width: 500,
                height: 200,
              ),
          ),



            剪切
            ClipRect(
              裁剪一半高度
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0.5,
                child: Container(
                  color: Colors.red,
                  width: 500,
                  height: 500,
                ),
              ),
            ),
*/
