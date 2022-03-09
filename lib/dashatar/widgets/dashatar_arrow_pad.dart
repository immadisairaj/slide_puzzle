import 'dart:async';

import 'package:arrow_pad/arrow_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/dashatar/dashatar.dart';
import 'package:very_good_slide_puzzle/helpers/helpers.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';

enum _ArrowDirection { up, down, left, right }

class DashatarArrowPad extends StatefulWidget {
  const DashatarArrowPad(
      {Key? key, this.padding, AudioPlayerFactory? audioPlayer})
      : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  final EdgeInsetsGeometry? padding;

  final AudioPlayerFactory _audioPlayerFactory;

  @override
  State<DashatarArrowPad> createState() => _DashatarArrowPadState();
}

class _DashatarArrowPadState extends State<DashatarArrowPad> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget._audioPlayerFactory()
      ..setAsset('assets/audio/tile_move.mp3');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _handleArrowPress(BuildContext context, _ArrowDirection arrowDirection) {
    final theme = context.read<ThemeBloc>().state.theme;

    // The user may move tiles only when the puzzle is started.
    // There's no need to check the Simple theme as it is started by default.
    final canMoveTiles = !(theme is DashatarTheme &&
        context.read<DashatarPuzzleBloc>().state.status !=
            DashatarPuzzleStatus.started);

    if (canMoveTiles) {
      final puzzle = context.read<PuzzleBloc>().state.puzzle;

      Tile? tile;
      switch (arrowDirection) {
        case _ArrowDirection.up:
          tile = puzzle.getTileRelativeToWhitespaceTile(const Offset(0, 1));
          break;
        case _ArrowDirection.down:
          tile = puzzle.getTileRelativeToWhitespaceTile(const Offset(0, -1));
          break;
        case _ArrowDirection.left:
          tile = puzzle.getTileRelativeToWhitespaceTile(const Offset(1, 0));
          break;
        case _ArrowDirection.right:
          tile = puzzle.getTileRelativeToWhitespaceTile(const Offset(-1, 0));
          break;
      }

      if (tile != null) {
        context.read<PuzzleBloc>().add(TileTapped(tile));
        unawaited(_audioPlayer.replay());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((DashatarThemeBloc bloc) => bloc.state.theme);

    return ArrowPad(
      padding: widget.padding,
      iconColor: PuzzleColors.white,
      outerColor: theme.pressedColor,
      innerColor: theme.buttonColor,
      hoverColor: theme.hoverColor,
      splashColor: theme.defaultColor,
      onPressedUp: () => _handleArrowPress(context, _ArrowDirection.up),
      onPressedDown: () => _handleArrowPress(context, _ArrowDirection.down),
      onPressedLeft: () => _handleArrowPress(context, _ArrowDirection.left),
      onPressedRight: () => _handleArrowPress(context, _ArrowDirection.right),
    );
  }
}
