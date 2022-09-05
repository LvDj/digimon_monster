import 'dart:math';

import 'package:digimon_monster/Game/card_action_controller.dart';
import 'package:digimon_monster/Game/card_model.dart';
import 'package:digimon_monster/Game/card_view.dart';
import 'package:digimon_monster/utils/db_manager.dart';
import 'package:nanoid/nanoid.dart';

typedef HandCardAddBlock = void Function();

class GameDataController {
  // card 数据变更通知
  List<HandCardAddBlock> _clickCardBlockList = [];

  // 卡组
  List<ViewModel> cardList = [];
  // 手牌
  List<ViewModel> handCardList = [];
  // 联防
  List<ViewModel> defenseCardList = [];
  // 墓地
  List<ViewModel> usedCardList = [];
  // 育成场
  List<ViewModel> prepareCardList = [];
  // 前场
  List<ViewModel> monstersCardList = [];
  // 驯兽师
  List<ViewModel> masterCardList = [];

  int myMemoryCount = 0;
  int vsMemoryCount = 0;

  Map<String, CardModel> cardInfoMap = {};

  static final GameDataController _instance = GameDataController._singleton();
  factory GameDataController() {
    return _instance;
  }
  GameDataController._singleton() {
    _init();
  }

  _init() {}

  void addCardChangeListener(HandCardAddBlock block) {
    _clickCardBlockList.add(block);
  }

  void _sendNotify() {
    _clickCardBlockList.forEach((element) {
      element();
    });
  }

  Future<CardModel> _queryCardInfo(String cardId) async {
    CardModel model = cardInfoMap[cardId];
    if (model == null) {
      Map jsonMap = await DBManager().queryCardWithId(cardId);
      if (jsonMap != null) {
        model = CardModel.fromMap(jsonMap);
        model.id = nanoid();
        cardInfoMap[cardId] = model;
      }
    }
    return model;
  }

  // 准备比赛
  Future<void> readyToStart() async {
    await DBManager().initDB();
    cardInfoMap[""] = null;

    cardList.clear();
    List<String> cardModelList = loadCardList();
    for (String item in cardModelList) {
      CardModel model = await _queryCardInfo(item);
      cardList.add(ViewModel(model));
    }

    prepareCardList.clear();
    List<String> prepareModelList = loadEggList();
    for (String cardId in prepareModelList) {
      Map jsonMap = await DBManager().queryCardWithId(cardId);
      if (jsonMap != null) {
        CardModel eggModel = CardModel.fromMap(jsonMap);
        eggModel.type = CardType.egg;
        eggModel.id = nanoid();
        ViewModel egg = ViewModel(eggModel);
        egg.cardInArea = CardLocation.egg;
        prepareCardList.add(egg);
      }
    }
    handCardList = [];
    defenseCardList = [];
    usedCardList = [];
    monstersCardList = [];
    masterCardList = [];
  }

  // 开始比赛
  void startGame() {
    cardList = _randomCardList<ViewModel>(cardList);

    // 安防区放置卡片
    for (int i = 0; i < 5; i++) {
      ViewModel view = cardList.removeAt(0);
      view.cardInArea = CardLocation.safe;
      defenseCardList.add(view);
    }
    // 手牌抽取卡片
    for (int i = 0; i < 5; i++) {
      ViewModel view = cardList.removeAt(0);
      view.cardInArea = CardLocation.handList;
      handCardList.add(view);
    }
  }

  //回合开始
  void trunStart() {
    darwCard();
  }

  // 抽卡
  void darwCard({int count = 1}) {
    for (int i = 0; i < count; i++) {
      if (cardList.isNotEmpty) {
        ViewModel model = cardList.removeLast();
        model.cardInArea = CardLocation.handList;
        handCardList.add(model);
      }
    }
    _sendNotify();
  }

// 随机打乱卡组
  List<T> _randomCardList<T>(List<T> list) {
    List<T> resultList = [];
    while (list.length > 0) {
      Random random = Random(DateTime.now().millisecond);
      int value = random.nextInt(list.length);
      resultList.add(list.removeAt(value));
    }
    return resultList;
  }

  List<ViewModel> _getCardListFromArea(CardLocation type) {
    switch (type) {
      case CardLocation.cardList:
        return cardList;
      case CardLocation.handList:
        return handCardList;
      case CardLocation.safe:
        return defenseCardList;
      case CardLocation.used:
        return usedCardList;
      case CardLocation.egg:
        return prepareCardList;
      // case CardLocation.egging:
      //   return prepareCardList;
      case CardLocation.monster:
        return monstersCardList;
      case CardLocation.master:
        return masterCardList;
      // case CardLocation.egging:
      //   return [];
    }
  }

// 将卡片移动至前场
  void moveCardToArea(
    ViewModel model,
    CardLocation toArea,
  ) {
    if (toArea != null &&
        model.cardInArea != null &&
        model.nowModel().type != CardType.egg) {
      List<ViewModel> fromList = _getCardListFromArea(model.cardInArea);
      List<ViewModel> toList = _getCardListFromArea(toArea);
      if (fromList != null && toList != null) {
        for (var i = 0; i < fromList.length; i++) {
          ViewModel item = fromList[i];
          if (item.nowModel().id == model.nowModel().id) {
            fromList.removeAt(i);
            break;
          }
        }
        if (model.cardInArea == CardLocation.handList) {
          myMemoryCount -= model.nowModel().cost;
        }
        if (myMemoryCount <= 0) {
          vsMemoryCount += myMemoryCount * -1;
          myMemoryCount = 0;
        }

        model.cardInArea = toArea;
        toList.add(model);
        Future.delayed(Duration(milliseconds: 0), () {
          _sendNotify();
        });
      } else {
        print("happen error");
      }
    }
  }

  void moveCardToCard(
    ViewModel model,
    ViewModel toModel,
  ) {
    if (toModel != null && model.cardInArea != null) {
      bool isAllowUpdate = false;
      for (var item in model.nowModel().upgradeInfo) {
        if (item.upgradeLevel == toModel.nowModel().level) {
          myMemoryCount -= item.upgradeCost;
          isAllowUpdate = true;
          break;
        }
      }
      if (isAllowUpdate) {
        List<ViewModel> fromList = _getCardListFromArea(model.cardInArea);
        for (var i = 0; i < fromList.length; i++) {
          ViewModel item = fromList[i];
          if (item.nowModel().id == model.nowModel().id) {
            fromList.removeAt(i);
            break;
          }
        }
        toModel.stackModel(model.nowModel());
      }
    }
    Future.delayed(Duration(milliseconds: 0), () {
      CardActionController().sendMoveNotify(null);
      _sendNotify();
    });
  }

  void moveCardToEgg(
    ViewModel model,
  ) {
    if (prepareCardList.isNotEmpty) {
      ViewModel egg = prepareCardList.last;
      moveCardToCard(model, egg);
    }
  }

  List<String> loadCardList() {
    return [
      "st1-02",
      "st1-02",
      "st1-02",
      "st1-02",
      "st1-03",
      "st1-03",
      "st1-03",
      "st1-03",
      "st1-04",
      "st1-04",
      "st1-04",
      "st1-04",
      "st1-05",
      "st1-05",
      "st1-05",
      "st1-06",
      "st1-06",
      "st1-06",
      "st1-06",
      "st1-07",
      "st1-07",
      "st1-07",
      "st1-08",
      "st1-08",
      "st1-08",
      "st1-09",
      "st1-09",
      "st1-09",
      "st1-10",
      "st1-10",
      "st1-10",
      "st1-11",
      "st1-11",
      "st1-11",
      "st1-12",
      "st1-12",
      "st1-12",
      "st1-12",
      "st1-13",
      "st1-13",
      "st1-13",
      "st1-13",
      "st1-14",
      "st1-14",
      "st1-14",
      "st1-15",
      "st1-15",
      "st1-15",
      "st1-16",
      "st1-16",
    ];
  }

  List<String> loadEggList() {
    return [
      "st1-01",
      "st1-01",
      "st1-01",
      "st1-01",
      "st1-01",
    ];
  }
}
