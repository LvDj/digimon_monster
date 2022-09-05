import 'dart:math';

import 'package:digimon_monster/Game/card_model.dart';
import 'package:digimon_monster/Game/GameValue.dart';
import 'package:digimon_monster/Game/card_action_controller.dart';
import 'package:digimon_monster/Game/game_data_controller.dart';
import 'package:flutter/material.dart';

class CardView extends StatefulWidget {
  final ViewModel model;
  final bool isCanClick;
  bool isCanMove;
  final bool isVertical;
  CardLocation cardInArea;
  final GestureTapCallback onTap;
  _CardViewState state;

  CardView({
    /*required*/ this.model,
    /*required*/ this.cardInArea,
    this.isCanClick = true,
    this.isCanMove = true,
    this.isVertical = true,
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() {
    state = _CardViewState();
    return state;
  }

  void dealloc() {
    state = null;
  }
}

class _CardViewState extends State<CardView> {
  bool isRed = false;
  OnCardBlock _callBack;
  OnCardBlock _callBackStack;
  Offset _offset;
  @override
  void initState() {
    super.initState();
    if (widget.model?.nowModel() != null) {
      widget.model.areaKey = GlobalKey();
      _callBack = (view) {
        isRed =
            (view != null && widget.model.nowModel().id == view.nowModel().id);
        setState(() {});
      };
      CardActionController().onCardListener(_callBack);
    }
  }

  @override
  void dispose() {
    CardActionController().removeCardListener(_callBack);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget view = getView(widget.model?.areaKey);
    if (widget.isCanMove) {
      view = _giveViewDraggableAction(view, widget.model);
    }
    if (widget.isCanClick) {
      view = _giveViewClickAction(view, () {
        CardActionController().clickItem(widget.model);
        if (widget.onTap != null) {
          widget.onTap();
        }
      });
    }
    return view;
  }

  _giveViewClickAction(Widget view, GestureTapCallback onTap) {
    return InkWell(
        onTap: () {
          onTap();
        },
        child: view);
  }

  _giveViewDraggableAction(Widget view, ViewModel model) {
    return Draggable(
      child: view,
      feedback: getView(null),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: getView(null),
      ),
      onDragUpdate: (DragUpdateDetails details) {
        _offset = details.globalPosition;
        CardActionController().cardMove(model, details.globalPosition);
      },
      onDragEnd: (DraggableDetails details) {
        CardActionController().cardMoveEnd(widget.model, _offset);
      },
    );
  }

  Widget getView(Key key) {
    Widget view = Container(
      key: key,
      width: Value.cardWidth(),
      height: Value.cardHeight(),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: isRed ? Colors.red : Colors.blue,
          width: isRed ? 3 : 1,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(2.0),
        ),
      ),
      child: Image.asset(
        (widget.model?.nowModel() == null)
            ? "images/default.webp"
            : widget.model.nowModel().getIconPath(),
        height: Value.cardHeight(),
        width: Value.cardWidth(),
      ),
    );
    if (!widget.isVertical) {
      view = Transform.rotate(
        angle: pi * 0.5,
        child: view,
      );
    }
    return view;
  }
}
