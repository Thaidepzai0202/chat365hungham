import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class SelectableItem extends Equatable {
  String id;
  String name;
  bool isSelected = false;

  SelectableItem({
    required this.id,
    required this.name,
  });

  // set isSelected(value) => isSelected = value;

  /// để name = '' do api search chỉ cần id
  factory SelectableItem.fromId(String id) => SelectableItem(id: id, name: '');

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'isSelected': this.isSelected,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        isSelected,
      ];
}

extension SelectableItemExt on List<SelectableItem> {
  String get names => map((e) => e.name).join(', ');

  String nameFromId(String id) {
    try {
      return firstWhere((element) => element.id == id).name;
    } catch (e) {
      logger.logError('$e');
      return 'Chưa cập nhật';
    }
  }

  List<SelectableItem> setSelected(String id) {
    var temp = [...this];
    return temp
        .map<SelectableItem>((e) => e..isSelected = (id == e.id ? true : false))
        .toList();
  }
}

class RxSelectableItem extends ValueNotifier<SelectableItem> {
  RxSelectableItem(value) : super(value);
}

class NullableRxSelectableItem extends ValueNotifier<SelectableItem?> {
  NullableRxSelectableItem(value) : super(value);
}
