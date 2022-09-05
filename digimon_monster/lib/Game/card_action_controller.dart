import 'dart:async';

import 'package:digimon_monster/Game/card_model.dart';
import 'package:digimon_monster/Game/card_view.dart';
import 'package:digimon_monster/Game/game_data_controller.dart';
import 'package:flutter/material.dart';

typedef ClickCardBlock = void Function(ViewModel model);
typedef AreaChangeBlock = void Function(GlobalKey area);
typedef OnCardBlock = void Function(ViewModel area);

class CardActionController {
  // 标记可选区域
  GlobalKey upArea = GlobalKey();
  GlobalKey downArea = GlobalKey();
  GlobalKey eggArea = GlobalKey();

  // 蛋
  CardModel eggModel;

  ClickCardBlock _clickCardBlock;
  AreaChangeBlock _moveBlock;
  List<OnCardBlock> _onCardBlockList = [];

  static final CardActionController _instance =
      CardActionController._singleton();
  factory CardActionController() {
    return _instance;
  }
  CardActionController._singleton() {
    _init();
  }

  _init() {}

  // 点击卡片监听
  void clickCardListener(ClickCardBlock block) {
    _clickCardBlock = block;
  }

  // 点击了card, 通知其他人
  void clickItem(ViewModel selectModel) {
    if (_clickCardBlock != null) {
      _clickCardBlock(selectModel);
    }
  }

  // 移动卡片监听
  void positionChangeCardListener(AreaChangeBlock block) {
    _moveBlock = block;
  }

  void _sendPositionNotify(GlobalKey key) {
    if (_moveBlock != null) {
      _moveBlock(key);
    }
  }

  // 移动卡片监听
  void onCardListener(OnCardBlock block) {
    _onCardBlockList.add(block);
  }

  // 移动卡片监听
  void removeCardListener(OnCardBlock block) {
    int s = _onCardBlockList.length;
    _onCardBlockList.remove(block);
    int e = _onCardBlockList.length;
    print("remove $s - $e");
  }

  void sendMoveNotify(ViewModel view) {
    _onCardBlockList.forEach((element) {
      element(view);
    });
  }

  ViewModel isMoveCardTop(ViewModel model, Offset offset) {
    for (ViewModel item in GameDataController().monstersCardList) {
      if (_isInAreaWithView(item.areaKey, offset)) {
        for (var updateInfo in model.nowModel().upgradeInfo) {
          if (updateInfo.upgradeLevel == item.nowModel().level) {
            return item;
          }
        }
      }
    }
    return null;
  }

  // 移动了card, 检查是否有区域变红
  void cardMove(ViewModel model, Offset offset) {
    // 查询是否可以放在前场的怪身上
    ViewModel item = isMoveCardTop(model, offset);
    if (item != null) {
      sendMoveNotify(item);
      _sendPositionNotify(null);
    } else {
      // 查询是否在 场地区域内
      sendMoveNotify(null);
      GlobalKey findArea = queryArea(model, offset);
      if (findArea != null) {
        _sendPositionNotify(findArea);
      }
    }
  }

  // card 移动结束, 判断是否在区域内
  void cardMoveEnd(ViewModel view, Offset offset) {
    ViewModel findView = isMoveCardTop(view, offset);
    if (findView != null) {
      GameDataController().moveCardToCard(view, findView);
    } else {
      GlobalKey findArea = queryArea(view, offset);
      if (findArea != null) {
        if (findArea == eggArea) {
          GameDataController().moveCardToEgg(view);
        } else {
          GameDataController().moveCardToArea(view, _areaToType(findArea));
        }
      }
    }
    _sendPositionNotify(null);
  }

  CardLocation _areaToType(GlobalKey area) {
    if (area == upArea) {
      return CardLocation.monster;
    } else if (area == downArea) {
      return CardLocation.master;
    } else if (area == eggArea) {
      return CardLocation.egging;
    } else {
      return null;
    }
  }

  // 检查offset是否在该 Area中
  bool _isInAreaWithView(GlobalKey key, Offset viewOffset) {
    RenderBox areaBox = key.currentContext?.findRenderObject();
    if (areaBox == null) {
      return false;
    }
    var upOffset = areaBox.localToGlobal(Offset.zero);
    return viewOffset.dy <= (upOffset.dy + areaBox.size.height) &&
        viewOffset.dy >= upOffset.dy &&
        viewOffset.dx >= upOffset.dx &&
        viewOffset.dx <= upOffset.dx + areaBox.size.width;
  }

  // 卡组
  // List<CardModel> cardList = [];
  // 联防
  // List<CardModel> defenseCardList = [];
  // 墓地
  // List<CardModel> usedCardList = [];
  // 驯兽师
  // List<CardModel> trainerCardList = [];

// 查询card可能放置的区域
  List<GlobalKey> _queryArea(ViewModel model) {
    switch (model.nowModel().type) {
      case CardType.master:
        return [downArea];
      case CardType.monster:
        return [upArea, eggArea];
      case CardType.egg:
        {
          if (model.nowModel().dp > 0) {
            return [upArea];
          }
          return null;
        }
      default:
        return null;
    }
  }

  GlobalKey queryArea(ViewModel model, Offset offset) {
    List<GlobalKey> areaList = _queryArea(model);
    if (areaList == null) {
      return null;
    }
    GlobalKey inArea;
    for (GlobalKey area in areaList) {
      if (area != null && area.currentContext != null) {
        if (_isInAreaWithView(area, offset)) {
          inArea = area;
          break;
        }
      }
    }
    return inArea;
  }

  Future<num> _xx() {
    final Completer<num> completer = Completer();
    completer.complete(123);
    return completer.future;
  }
}
