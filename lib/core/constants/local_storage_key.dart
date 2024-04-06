class LocalStorageKey {
  /// theme
  static const themeChange = 'themeThai';



  /// Token dùng để test Văn thư
  static const tokenVT = 'tokenVT';
  static const comId   = 'comId';
  static const phoneTk = 'phoneTk';
  static const authToken = 'authToken';

  /// id phong ban
  static const depId = 'DepartmentId';
  /// ten phong ban
  static const nameDepartment = 'nameDepartment';

  /// Token sau đăng nhập
  static const token = 'token';

  /// Token sau đăng nhập Quản lý chung
  static const tokenQLC = 'tokenQLC';

  /// Token sau đăng nhập chấm công
  static const tokenCC = 'tokenCC';

  ///Thông tin thiết bị xin đăng nhập
  static const nameComputer = 'name_computer';
  static const locationComputer = 'location_computer';
  static const timeComputer = 'time_computer';
  static const QRCodeID = 'qr_code_id';

  static const passwordClass = 'password_class';

  ///Refresh token đăng nhập
  static const refresh_token = 'refresh_token';
  static const refresh_tokenQLC = 'refresh_tokenQLC';
  static const refresh_tokenCc = 'refresh_tokenCc';

  static const voip_token = 'voip_token';

  /// UserType đã lưu
  static const userType = 'userType';

  /// Thông tin cơ bản
  static const userInfo = 'userInfo';

  static const userId = 'userId';
  static const userId2 = 'userId';

  static const totalConversation = 'totalConversation';

  static const serverDiffTickWithClient = 'serverDiffTickWithClient';

  static const loggedInEmail = 'loggedInEmail';

  static const uuidDevice = 'uuid_device';

  static const idDevice = 'id_device';
  static const nameDevice = 'name_device';
  static const brand = 'brand';

  static const countUnreadNoti = 'countUnreadNoti';

  static const unreadConversations = 'unreadMessage';

  static const appBadger = 'appBadger';

  static const isDeniedContactPermission = 'isDeniedContactPermission';
  // key khóa ứng dụng
  static const set_lock_code = 'setLockCode';
  static const lock_code = 'lockCode';
  static const local_auth_to_unlock = 'localAuthToUnlock';
  // key lưu tin nhắn
  static const message_error = 'messageError';

  /// Các key sẽ bị clear khi logout
  static List<String> get logoutClearKey => [
        authToken,
        token,
        userType,
        userInfo,
        totalConversation,
        serverDiffTickWithClient,
        uuidDevice,
        countUnreadNoti,
        unreadConversations,
        appBadger,
        userId,
      ];

  /// key sdt đăng kí tk timviec phần đăng tin không tk để check tk bên timviec
  static const String numberphone = 'numberphone';
}
