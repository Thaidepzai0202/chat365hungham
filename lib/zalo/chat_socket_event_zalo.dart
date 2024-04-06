class ChatSocketEventZalo {
  static const String login = 'Login';
  static const String login_v2 = 'Login_v2';
  static const String logout = 'Logout';
  static const String confirmOTPForgot = 'ForgetPassWordOtpSMS';
  static const String confirmOTPAuth = 'VerifyAccountOtpSMS';
  static const String loginWithDeviceId = 'LoginWithIdDevice';

  // User
  static const String userDisplayNameChanged = 'changeName';
  static const String changeUserName = 'changeName';
  static const String changeAvatarUser = 'changeAvatarUser';
  static const String changePresenceStatus = 'changedActive';
  static const String presenceStatusChanged = 'changedActive';
  static const String changeMoodMessage = 'UpdateStatus';
  static const String moodMessageChanged = 'UpdateStatus';
  static const String allowQRLogin = 'qr_image';
  static const String loginQRZaloSuccess = 'success';
  static const String updateListZalo = 'update_list_zalo';
  static const String listFriendZalo = 'list_friend';
  static const String listChat = 'list_chat';

  // Conversation
  static const String checkNotification = 'CheckNotification';
  static const String changeGroupName = 'changeNameGroup';
  static const String groupNameChanged = 'changeNameGroup';
  static const String nickNameChanged = 'changeNickName';
  static const String changeNickName = 'changeNickName';

  static const String changeGroupAvatar = 'changeAvatarGroup';

  static const String sendMessage = 'SendMessage';
  static const String messageSent = 'SendMessage';

  static const String editMessage = 'EditMessage';
  static const String messageEdited = 'EditMessage';

  static const String deleteMessage = 'DeleteMessage';
  static const String messageDeleted = 'DeleteMessage';
  static const String createSecretConversation = 'CreateNewSecretConversation';
  static const String updateDeleteTime = 'UpdateDeleteTime';
  //static const String recallMessage = 'recallMessage';
  static const String typing = 'Typing';
  static const String stopTyping = 'OutTyping';

  static const String createGroup = 'AddNewConversation';
  static const String newConversationAdded = 'AddNewConversation';
  static const String addMemberToGroup = 'AddNewMemberToGroup';

  /// @0: int: conversationId
  /// @1: List<int> dạng String: Id những thành viên mới
  static const String newMemberAddedToGroup = 'AddNewMemberToGroup';
  static const String outGroup = 'OutGroup';
  static const String hiddenConversation = 'HiddenConversation';
  static const String disbandGroup = 'DisbandGroup';
  static const String markReadAllMessage = 'ReadMessage';
  static const String messageMarkedRead = 'ReadMessage';

  static const String recievedEmotionMessage = 'EmotionMessage';
  static const String changeReactionMessage = 'EmotionMessage';

  static const String pinMessage = 'PinMessage';
  static const String unPinMessage = 'UnPinMessage';
  static const String bookmarkMessage = 'BookmarkMessage';
  static const String unBookmarkMessage = 'UnBookmarkMessage';

  static const String changeFavoriteConversationStatus = "AddToFavorite";

  // Friend
  static const String acceptRequestAddFriend = 'AcceptRequestAddFriend';
  static const String declineRequestAddFriend = 'DecilineRequestAddFriend';
  static const String requestAddFriend = 'AddFriend';
  static const String deleteContact = 'DeleteContact';

  // Change Password => LogOut
  static const String logoutAllDevice = 'LogoutAllDevice';
  static const String logoutStrangeDevice = 'LogoutStrangeDevice';
  // Livechat
  static const String updateStatusMessageSupport = 'UpdateStatusMessageSupport';

  /// notification
  static const String sendNotification = 'SendNotification';
  static const String readNotification = 'ReadNotification';
  static const String readAllNotification = 'ReadAllNotification';
  static const String deleteAllNotification = 'DeleteAllNotification';

  static const String tagUser = 'TagUser';
}
