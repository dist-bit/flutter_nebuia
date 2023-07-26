import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// {@template fingers}
/// A class to represent an scanned finger.
/// {@endtemplate}
class Finger extends Equatable {
  const Finger({
    required this.image,
    required this.score,
  });

  /// {@template fingers.image}
  /// The bytes of the image of this scanned finger.
  /// {@endtemplate}
  final Uint8List image;

  /// {@template fingers.score}
  /// The quality of the finger scan.
  /// {@endtemplate}
  final num score;

  @override
  List<Object?> get props => [
        image,
        score,
      ];
}

/// {@template fingers}
/// A class that contains all scanned fingers excluding thumb.
/// {@endtemplate}
class Fingers extends Equatable {
  const Fingers({
    required this.index,
    required this.middle,
    required this.ring,
    required this.little,
    this.skip = false,
  });

  /// {@template fingers.index}
  /// The index [Finger].
  /// {@endtemplate}
  final Finger? index;

  /// {@template fingers.middle}
  /// The middle [Finger].
  /// {@endtemplate}
  final Finger? middle;

  /// {@template fingers.ring}
  /// The ring [Finger].
  /// {@endtemplate}
  final Finger? ring;

  /// {@template fingers.little}
  /// The little [Finger].
  /// {@endtemplate}
  final Finger? little;

  /// {@template fingers.skip}
  /// Whether to change the message to skip step completely.
  ///
  /// Defaults to false.
  /// {@endtemplate}
  final bool skip;

  @override
  List<Object?> get props => [
        index,
        middle,
        ring,
        little,
        skip,
      ];
}
