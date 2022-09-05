import 'dart:convert';

import 'package:digimon_monster/Base/base_model.dart';
import 'package:digimon_monster/Game/card_effect.dart';
import 'package:digimon_monster/res/ResColors.dart';
import 'package:flutter/material.dart';

enum CardColor {
  red,
  green,
  yellow,
  white,
  purple,
  black,
}

enum CardType {
  master,
  option,
  monster,
  egg,
}

enum CardLocation {
  cardList,
  handList,
  monster,
  master,
  egg,
  egging,
  used,
  safe,
}

class ViewModel {
  List<CardModel> models = [];
  CardLocation cardInArea = CardLocation.handList;
  GlobalKey areaKey;

  ViewModel(CardModel model) {
    models.add(model);
  }

  CardModel nowModel() {
    return models.last;
  }

  int getSelfNowDP() {
    CardModel now = nowModel();
    if (now == null) {
      return 0;
    }
    int baseDP = now.dp;
    for (CardModel item in models) {
      baseDP += getEffectDP(item, EffectWhen.main);
    }
    return baseDP;
  }

// 查看自身DP加成
  int getEffectDP(CardModel model, EffectWhen nowTime) {
    List<CardEffect> effects = model.getEffectInfo();
    int dp = 0;
    for (CardEffect effect in effects) {
      // 加成类型是DP
      if (effect.type == EffectCountType.dp) {
        // 进化源效果
        if (effect.postion == EffectPosition.parent) {
          // 如果当前最上方是. 则结束
          if (model.id == nowModel().id) {
            break;
          }
        } else if (effect.postion == EffectPosition.self) {
          // 在场效果, 如果不是最上方, 则结束
          if (model.id != nowModel().id) {
            break;
          }
        }
        // 必须条件是 进化源数量. 不满足则退出
        if (effect.must == EffectMust.parentCount &&
            models.length <= effect.mustCount) {
          break;
        }
        if (effect.when != nowTime) {
          break;
        }
        // 目标是自身
        if (effect.target == EffectTarget.selfMonster) {
          // 增益就正数. 减益就负数
          if (effect.strengthen == EffectStrengthen.buff) {
            dp += effect.effectValue;
          } else if (effect.strengthen == EffectStrengthen.debuff) {
            dp -= effect.effectValue;
          }
        }
      }
    }

    return dp;
  }

  void stackModel(CardModel model) {
    models.add(model);
  }

  Color cardBgColor() {
    Color color;
    switch (nowModel().color) {
      case CardColor.red:
        color = ResColors.red;
        break;
      case CardColor.green:
        color = ResColors.green;
        break;
      case CardColor.yellow:
        color = ResColors.yellow;
        break;
      case CardColor.white:
        color = ResColors.white;
        break;
      case CardColor.purple:
        color = ResColors.purple;
        break;
      case CardColor.black:
        color = ResColors.black;
        break;
    }
    return color;
  }
}

class UpgradeInfo {
// 进化花费
  int upgradeCost = 0;
  // 等级
  int upgradeLevel = 0;
  UpgradeInfo(this.upgradeCost, this.upgradeLevel);

  Map<String, String> toMap() {
    return {
      "upgradeCost": "$upgradeCost",
      "upgradeLevel": "$upgradeLevel",
    };
  }
}

class CardModel implements BaseModel {
  String id;

  String name;
  // id
  String cardId;
  // 等级
  int level = 0;
  // 直接花费
  int cost = 0;
  // 进化要求
  List<UpgradeInfo> upgradeInfo = [];
  // DP
  int dp = 0;
  // 颜色
  CardColor color = CardColor.red;
  // 类型
  CardType type = CardType.master;

  String effectStr = "";
  String safeEffectStr = "";

  String effect = "";
  String safeEffect = "";
  bool isTakeEffect = false;

  List<CardEffect> getEffectInfo() {
    List<CardEffect> list = [];
    List effectList;
    try {
      effectList = json.decode(effect);
    } catch (e) {
      return list;
    }
    for (Map item in effectList) {
      CardEffect eff = CardEffect();
      eff.mapToModelData(item);
      list.add(eff);
    }
    return list;
  }

  CardModel(this.id, this.cardId);
  CardModel.fromMap(Map map) {
    name = map["name"];
    cardId = map["cardId"];
    level = int.parse(map["level"]);
    cost = int.parse(map["cost"]);
    dp = int.parse(map["dp"]);
    int colorIndex = int.parse(map["color"]);
    color = CardColor.values[colorIndex];
    int typeIndex = int.parse(map["type"]);
    type = CardType.values[typeIndex];

    upgradeInfo.clear();
    String jsonStr = map["upgradeInfo"];
    List upgradeInfoList = json.decode(jsonStr);
    for (Map item in upgradeInfoList) {
      UpgradeInfo info = UpgradeInfo(
        int.parse(
          item["upgradeCost"] ?? "0",
        ),
        int.parse(
          item["upgradeLevel"] ?? "0",
        ),
      );
      upgradeInfo.add(info);
    }
    effectStr = map["effectStr"];
    safeEffectStr = map["safeEffectStr"];
    effect = map["effect"];
    safeEffect = map["safeEffect"];
  }

  String getIconPath() {
    return "images/$cardId.png";
  }

  Map<String, String> paramaDBMap() {
    return {
      "name": "TEXT",
      "cardId": "TEXT",
      "cost": "TEXT",
      "upgradeInfo": "TEXT",
      "level": "TEXT",
      "dp": "TEXT",
      "color": "TEXT",
      "type": "TEXT",
      "effectStr": "TEXT",
      "safeEffectStr": "TEXT",
      "effect": "TEXT",
      "safeEffect": "TEXT",
    };
  }

  Map<String, dynamic> toJsonMap() {
    List<Map<String, String>> list = [];
    for (var item in this.upgradeInfo) {
      list.add(item.toMap());
    }
    String upgradeInfoJsonStr = json.encode(list);
    Map<String, dynamic> map = {
      "name": '"${this.name}"',
      "cardId": '"${this.cardId}"',
      "cost": '"${this.cost}"',
      "upgradeInfo": '"[]"', //
      "level": '"${this.level}"',
      "dp": '"${this.dp}"',
      "color": '"${this.color.index}"',
      "type": '"${this.type.index}"',
      "effectStr": '"$effectStr"',
      "safeEffectStr": '"$safeEffectStr"',
      "effect": '"$effect"',
      "safeEffect": '"$safeEffect"',
    };
    return map;
  }

  @override
  String tableName() {
    return "CARD_TABLE";
  }
}
