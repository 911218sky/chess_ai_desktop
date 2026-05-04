import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/text_sanitizer.dart';

class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.characterDelay = const Duration(milliseconds: 32),
    this.charactersPerTick = 2,
    this.onCompleted,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final Duration characterDelay;
  final int charactersPerTick;
  final VoidCallback? onCompleted;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  Timer? _timer;
  var _targetText = '';
  var _visibleText = '';
  var _visibleLength = 0;
  List<String> _graphemes = const [];

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    _targetText = sanitizeDisplayText(widget.text);
    _graphemes = _targetText.characters.toList(growable: false);
    _timer?.cancel();
    _visibleLength = 0;
    _visibleText = '';
    if (mounted) {
      setState(() {});
    }
    if (_targetText.isEmpty) {
      widget.onCompleted?.call();
      return;
    }
    _timer = Timer.periodic(widget.characterDelay, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final nextLength = (_visibleLength + widget.charactersPerTick).clamp(
        0,
        _graphemes.length,
      );
      setState(() {
        _visibleText += _graphemes.getRange(_visibleLength, nextLength).join();
        _visibleLength = nextLength;
      });
      if (_visibleLength >= _graphemes.length) {
        timer.cancel();
        widget.onCompleted?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _visibleText,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      style: widget.style,
    );
  }
}
