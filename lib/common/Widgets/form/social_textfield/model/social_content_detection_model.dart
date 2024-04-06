import 'package:flutter/material.dart';

///Detection Content
///[type] [DetectedType]
///[range] Range of detection
///[text] substring content created by using [range] value.
enum DetectedType { mention, hashtag, url, plain_text, quick_text }

class SocialContentDetection {
  final DetectedType type;
  final TextRange range;
  final String text;

  SocialContentDetection(this.type, this.range, this.text);

  @override
  String toString() {
    return 'SocialContentDetection{type: $type, range: $range, text: $text}';
  }
}
