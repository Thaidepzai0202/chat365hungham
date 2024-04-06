class CallPayload {
  final String roomId;
  final String roomCode;
  final String roomUrl;
  final String callerId;
  final String callerName;
  final String callerAvatar;
  final String calleeId;
  final String calleeName;
  final String? calleeAvatar;
  final int callType;
  final String callProtocol;
  CallPayload(
      {required this.roomId,
        required this.roomCode,
        required this.roomUrl,
        required this.callerId,
        required this.callerName,
        required this.callerAvatar,
        required this.calleeId,
        required this.calleeName,
        this.calleeAvatar,
        required this.callType,
        required this.callProtocol});
  Map<String, dynamic> toMap() {
    return {
      'roomId': this.roomId,
      'roomCode': this.roomCode,
      'roomUrl': this.roomUrl,
      'callerId': this.callerId,
      'callerName': this.callerName,
      'callerAvatar': this.callerAvatar,
      'calleeId': this.calleeId,
      'calleeName': this.calleeName,
      'calleeAvatar': this.calleeAvatar,
      'callType': this.callType,
      'callProtocol': this.callProtocol
    };
  }

  factory CallPayload.fromMap(Map<String, dynamic> map) {
    return CallPayload(
      roomId: map["roomId"],
      roomCode: map["roomCode"],
      roomUrl: map["roomUrl"],
      callerId: map["callerId"],
      callerName: map["callerName"],
      callerAvatar: map["callerAvatar"],
      calleeId: map["calleeId"],
      calleeName: map["calleeName"],
      callType: map["callType"],
      callProtocol: map["callProtocol"],
    );
  }
}
