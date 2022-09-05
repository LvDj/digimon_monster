class Value {
  static double cardWidth() {
    return 26 * 1.5;
  }

  static double cardHeight() {
    return 36 * 1.5;
  }

  static double padding() {
    return 3 * 1.5;
  }

  static double checkerboardWidth() {
    return cardWidth() * 3 +
        (padding() + cardHeight() + cardWidth() * 5) -
        (padding() * 2 + cardWidth() * 2) +
        padding() * 5;
  }

  static double checkerboardHeight() {
    return cardHeight() * 3 + padding() * 4;
  }

  static double cardShowWidth() {
    double width = cardWidth() * 4;
    return width;
  }

  static double cardShowHeight() {
    double width = cardHeight() * 4;
    return width;
  }

  static double cardShowPadding() {
    double height = cardHeight() * 0.5;
    return height;
  }

  static double maxScale() {
    return 0.45;
  }
}
