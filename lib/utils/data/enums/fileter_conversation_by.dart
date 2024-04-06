enum FilterConversationBy {
  nearest,
  favorite,
  unread
}

extension FilterConversationByExt on FilterConversationBy {
  String get name {
    switch (this) {
      case FilterConversationBy.nearest:
        return 'Cuộc trò chuyện gần đây';
      case FilterConversationBy.favorite:
        return 'Cuộc trò chuyện yêu thích';
      case FilterConversationBy.unread:
        return 'Tin nhan chua doc';
      default:
        return '';
    }
  }

  int get index => FilterConversationBy.values.indexOf(this);
}
