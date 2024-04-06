import 'package:flutter/cupertino.dart';

extension ListExt<T> on List<T> {
  List<T> slice({
    int start = 0,
    int? end,
  }) =>
      sublist(
        start,
        (end ?? length).clamp(0, length),
      );
}

extension IterableExt<T> on Iterable<dynamic> {
  List get flattenDeep => [
        for (var element in this)
          if (element is! Iterable) element else ...element.flattenDeep,
      ];
}

extension NullableListExt<T> on Iterable<T>? {
  bool get isBlank => this == null || this!.isEmpty;

  valueIfBlank(var value) => this.isBlank ? value : this!;
}

class RxList<T> extends ValueNotifier<List<T>> {
  RxList(value) : super(value);
}
