enum ContactSource {
  company,
  phone,
  friendRequest,
}

extension ContactSourceExt on ContactSource {
  int value() => index;

  static ContactSource fromValue(int value) {
    return ContactSource.values
        .where((element) => element.index == value)
        .first;
  }

  String get source {
    switch (this) {
      case ContactSource.company:
        return '';
      case ContactSource.phone:
        return 'Tìm kiếm số điện thoại';
      case ContactSource.friendRequest:
        return 'Yêu cầu kết bạn';
    }
  }
}
