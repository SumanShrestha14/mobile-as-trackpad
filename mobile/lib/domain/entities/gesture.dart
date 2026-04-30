enum GestureType { move, tap, scroll }

enum ClickButton { left, right }

class Gesture {
  final GestureType type;
  final double deltaX;
  final double deltaY;
  final int fingers;
  final ClickButton? clickButton;
  final int? clicks;

  const Gesture({
    required this.type,
    this.deltaX = 0,
    this.deltaY = 0,
    this.fingers = 1,
    this.clickButton,
    this.clicks = 1,
  });
}
