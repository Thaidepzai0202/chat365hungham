enum ProcessMessageType {
  sending,
  deleting,
  recalling,
}

extension ProcessMessageTypeExt on ProcessMessageType {
  String get processingName {
    if (this == ProcessMessageType.sending) return 'Đang gửi';
    if (this == ProcessMessageType.deleting) return 'Đang xóa';
    return 'Đang thu hồi';
  }
}
