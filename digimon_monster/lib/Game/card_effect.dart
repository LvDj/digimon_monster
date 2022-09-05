enum EffectPosition {
  none,
  // 作为进化源
  parent,
  // 自身能力
  self,
}
enum EffectMust {
  none,
  // 进化源总量
  parentCount,
  // 进化源倍数
  parentPage,
}

enum EffectWhen {
  // 没效果
  none,
  // 进化时
  update,
  // 攻击时
  attack,
  // 防御时
  defense,
  // 自己主回合
  main,
  // 登场时
  call,
}

enum EffectTarget {
  // 没效果
  none,
  // 自身训练家
  selfMaster,
  // 对手训练家
  enemyMaster,
  // 卡片自身怪兽
  selfMonster,
  // 对手卡片怪兽
  enemyMonster,
}

enum EffectStrengthen {
  // 没效果
  none,
  // 增加效果
  buff,
  // 减少效果
  debuff,
}

enum EffectCountType {
  // 没效果
  none,
  // DP值
  dp,
  // 安防值
  safeCard,
  // 花费
  cost,
  // 怪兽卡
  monster,
  // 效果卡
  master,
  // 卡组
  cardList,
  // 墓地
  dead,
}

class CardEffect {
  // 在哪发生效果
  EffectPosition postion;
  // 必须条件
  EffectMust must;
  // 必须条件数量
  int mustCount;
  // 时机
  EffectWhen when;
  // 目标
  EffectTarget target;
  // 增减
  EffectStrengthen strengthen;
  // 数值类型
  EffectCountType type;
  // 数值
  int effectValue;

  void mapToModelData(Map effectMap) {
    postion = EffectPosition.values[effectMap["postion"] ?? 0];
    must = EffectMust.values[effectMap["must"] ?? 0];
    when = EffectWhen.values[effectMap["when"] ?? 0];
    target = EffectTarget.values[effectMap["target"] ?? 0];
    type = EffectCountType.values[effectMap["type"] ?? 0];
    strengthen = EffectStrengthen.values[effectMap["strengthen"] ?? 0];
    mustCount = effectMap["mustCount"] ?? 0;
    effectValue = effectMap["effectValue"] ?? 0;
  }
}
