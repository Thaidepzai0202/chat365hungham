class CallClientEvents {
  static const String SOCKET_DISCONNECTED = "disconnect";
  static const String SOCKET_RECONNECTED = "connect";
  static const String USER_LOGIN = "callserver:user_login";
  static const String USER_LOGGEDIN = "callserver:user_loggedin";
  static const String USER_LOGOUT = "callserver:user_logout";
  static const String USER_CONNECTED = "callserver:user_connected";
  static const String USER_DISCONNETED = "callserver:user_disconnected";
  static const String CALL_START = "callserver:call_start";
  static const String CALL_TIMEDOUT = "callserver:call_timedout";
  static const String CALL_INCOMING = "callserver:call_incoming";
  static const String CALL_ACCEPT = "callserver:call_accept";
  static const String CALL_ACCEPTED = "callserver:call_accepted";
  static const String CALL_REJECT = "callserver:call_reject";
  static const String CALL_REJECTED = "callserver:call_rejected";
  static const String CALL_RECONNECTED = "callserver:call_reconnected";
  static const String CALL_SEND_OFFER = "callserver:call_send_offer";
  static const String CALL_RECEIVE_OFFER = "callserver:call_receive_offer";
  static const String CALL_SEND_ANSWER = "callserver:call_send_answer";
  static const String CALL_RECEIVE_ANSWER = "callserver:call_receive_answer";
  static const String CALL_SEND_CANDIDATE = "callserver:call_send_candidate";
  static const String CALL_RECEIVE_CANDIDATE =
      "callserver:call_receive_candidate";

  static const SERVICE_STATUS = "callserver:service_status";
  static const SFU_GET_RTP_CAPABILITIES = "callserver:sfu_get_rtp_capabilities";
  static const SFU_PTRANSPORT_CREATE = "callserver:sfu_ptransport_create";
  static const SFU_CTRANSPORT_CREATE = "callserver:sfu_ctransport_create";
  static const SFU_PTRANSPORT_CONNECT = "callserver:sfu_ptransport_connect";
  static const SFU_CTRANSPORT_CONNECT = "callserver:sfu_ctransport_connect";
  static const SFU_PRODUCE = "callserver:sfu_produce";
  static const SFU_NEW_PRODUCER = "callserver:sfu_new_producer";
  static const SFU_CONSUME = "callserver:sfu_consume";
  static const SFU_RESUME = "callserver:sfu_resume";

  static const String CALL_CLIENT_READY = "callserver:call_client_ready";
  static const String CALL_WEBRTC_READY = "callserver:call_ready";
  static const String CALL_CHANGE_MEDIA_DEVICES =
      "callserver:call_change_media_devices";
  static const String CALL_UPDATE_MEDIA_DEVICES_STATUS =
      "callserver:call_update_media_devices_status";
  static const String CALL_SWITCH_TO_VIDEO = "callserver:call_switch_to_video";
  static const String CALL_SWITCH_TO_VIDEO_REQUESTED =
      "callserver:call_switch_to_video_requested";
  static const String CALL_SWITCH_TO_VIDEO_ACCEPT =
      "callserver:call_switch_to_video_accept";
  static const String CALL_SWITCH_TO_VIDEO_ACCEPTED =
      "callserver:call_switch_to_video_accepted";
  static const String CALL_SWITCH_TO_VIDEO_REJECT =
      "callserver:call_switch_to_video_reject";
  static const String CALL_SWITCH_TO_VIDEO_REJECTED =
      "callserver:call_switch_to_video_rejected";
  static const String CALL_BUSY = "callserver:call_busy";
  static const String CALL_CHECK_BUSY = "callserver:call_check_busy";
  static const String CALL_ONGOING = "callserver:call_ongoing";
  static const String CALL_END = "callserver:call_end";
  static const String CALL_ENDED = "callserver:call_ended";
  static const String CALL_KEEPALIVE = "callserver:call_keepalive";
}
