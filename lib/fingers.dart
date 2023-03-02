import 'dart:typed_data';

class Finger {
  const Finger({
    required this.image,
    required this.score,
  });

  final Uint8List image;
  final num score;
}

class Fingers {
  const Fingers({
    required this.index,
    required this.middle,
    required this.ring,
    required this.little,
    this.skip = false,
  });

  final Finger? index;
  final Finger? middle;
  final Finger? ring;
  final Finger? little;
  final bool skip;
}
