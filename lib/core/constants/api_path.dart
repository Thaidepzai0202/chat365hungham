import 'package:app_chat365_pc/common/repos/auth_repo.dart';

class ApiPath {
  //Thay api nodejs sang base mới đổi từ 43.239.223.142 sang 210.245.108.202
  /// Dùng cho api nodejs
  // static const String ipDomain2 = 'http://43.239.223.142:9000/api/';
  static const String ipDomain2 = 'http://210.245.108.202:9000/api/';

  static const String ipDomainPC = 'http://210.245.108.202:9009/api/';

  static const String ipDomainOld = 'http://43.239.223.142:9000/api/';

  /// dùng với QLC
  static const String ipDomainQLC = 'http://210.245.108.202:3009/api/';
  static const String ipDomainQLC1 = 'http://210.245.108.202:3000/api/';

  /// dùng cho  Văn thư
  static const String ipDomainVanThu =
      'http://210.245.108.202:3005/api/vanthu/dexuat/';
  static const String ipDomain3 = 'http://43.239.223.142:9000/api/';

  /// dùng với QLC mới
  static const String ipDomainQLCNew = 'http://210.245.108.202:3000/api/qlc/';

  //Dùng cho tiện ích ứng viên, ntd
  static const String ipDomainTimviec = 'https://timviec365.vn/';

  //Dùng cho cơ cấu tổ chức
  static const String ipDomainTimviec365 = 'https://api.timviec365.vn/';

  /// Dùng cho service notification NodeJs
  static const String notificationDomain =
      'http://43.239.223.157:9001/api/V2/Notification';
  static const String notificationDomainPush =
      'http://43.239.223.157:8000/api/V2/Notification';

  /// Dùng cho service user NodeJs
  // static const String ipDomain3 = 'http://43.239.223.142:9006/api/';

  static const String baseUrl = ipDomain2;

  /// Dùng cho service conversation NodeJs
  // static const String ipDomain4 = 'http://210.245.108.202:9000/api/';
  //static const String ipDomain4 = 'http://43.239.223.142:9007/api/';

  /// Dùng cho service message NodeJs
  //static const String ipDomain2 = 'http://43.239.223.142:9009/api/';

  //Hiện tại dùng check tải app, không biết sau có dùng nhiều link này không
  static const String ipDomain6 = 'http://210.245.108.201:9001/api/';

  static const String ipDomain7 = 'http://210.245.108.202:3000/api/';

  ///
  static const String personalDomain = ipDomain3 + 'personal/';

  // Api app chat PC
  // gửi yêu cầu kết bạn
  static const String sendRequestAddFriend = ipDomain2 + 'users/AddFriend';

  static const String getUserName = ipDomain2 + 'users/GetUserName';

  // api quản lý ca làm việc

  static const String getAllShift = ipDomainQLC1 + "qlc/shift/list";

  static const String createShift = ipDomainQLC1 + "qlc/shift/create";

  static const String updateShift = ipDomainQLC1 + "qlc/shift/edit";

  static const String deleteShift = ipDomainQLC1 + "qlc/shift/delete";

  static const String getShiftById = ipDomainQLC1 + "qlc/shift/detail";

  // api cài đặt lịch làm việc tháng

  static const String getAllCycle = ipDomainQLC1 + "qlc/cycle/list";
  static const String createCycle = ipDomainQLC1 + "qlc/cycle/create";
  static const String updateCycle = ipDomainQLC1 + "qlc/cycle/edit";
  static const String deleteCycle = ipDomainQLC1 + "qlc/cycle/del";
  static const String deleteCycleByIdCom = ipDomainQLC1 + "qlc/cycle/delAll";
  static const String addEmployee = ipDomainQLC1 + "qlc/cycle/add_employee";
  static const String deleteEmployee =
      ipDomainQLC1 + "qlc/cycle/delete_employee";
  static const String getEmployeeFromCycle =
      ipDomainQLC1 + "qlc/cycle/list_employee";

  // static const String detailCycle = ipDomainQLC1 + "";

  // api lấy danh sách nhân viên chưa có lịch làm việc
  static const String getEmpNotCy =
      ipDomainQLC1 + "qlc/cycle/list_not_in_cycle";

  // Cài đặt đề xuất------------------------------------------------------------
  //Lấy danh sách nhân viên
  static const String getEmp = ipDomainQLC1 + "qlc/settingConfirm/listUser";

  //Lấy danh sách tổ chức
  // static const String getOrganize = ipDomainQLC1 + "api/qlc/organizeDetail/listAll";
  static const String getOrganize =
      'https://api.timviec365.vn/api/qlc/organizeDetail/listAll';

  // Sửa cấp duyệt
  static const String updateConfirmLevel =
      ipDomainQLC1 + "qlc/settingConfirm/updateAllSettingConfirmLevel";

  // Lấy danh sách vị trí
  static const String getPosition =
      'https://api.timviec365.vn/api/qlc/positions/listAll';

  // Lấy danh sách các đề xuất
  static const String getPropose =
      ipDomainQLC1 + "qlc/settingConfirm/listSettingPropose";

  // Cài đặt đề xuất
  static const String proposeSetting =
      "https://api.timviec365.vn/api/qlc/settingConfirm/settingPropose";

  // Xem chi tiết đề xuất
  static const String proposeDetail =
      ipDomainQLC1 + "qlc/settingConfirm/detailUser";

  // cập nhập số cấp duyệt cho nhân viên
  static const String updatePrivateLevel =
      ipDomainQLC1 + "qlc/settingConfirm/updatePrivateLevel";

  // cập nhập hình thức duyệt cho nhân viên
  static const String updatePrivateType =
      ipDomainQLC1 + "qlc/settingConfirm/updatePrivateType";

  // cập nhập thời gian duyệt đề xuất cho nhân viên
  static const String updatePrivateTime =
      ipDomainQLC1 + 'qlc/settingConfirm/updatePrivateTime';

  //----------------------------------------------------------------------------

  //
  static const String domainNameBaseUrl = 'https://mess.timviec365.vn/';
  static const String authDomain2 = ipDomain2 + 'users/';
  static const String chatDomain2 = ipDomain2 + 'conversations/';
  static const String messageDomain2 = ipDomain2 + 'message/';
  static const String calendarDomain = ipDomain2 + 'calendarappointment/';
  static const String notificationDomain2 = ipDomain2 + 'V2/Notification/';
  static const String privacyDomain = ipDomain2 + 'privacy/';
  static const String takePerChangePass =
      'https://skvideocall.timviec365.vn/api/users/TakePermissionChangePass';
  static const String fileDomain = domainNameBaseUrl + 'uploads/';
  static const String avatarUserDomain =
      'https://ht.timviec365.vn:9002/uploads/';
  static const String imageDomain = 'https://ht.timviec365.vn:9002/uploads/';
  static const String pollDomain = 'http://43.239.223.157:9001/api/poll/';

  // static const String pollDomain = 'http://210.245.108.202:9000/api/poll/';
  //general dairy
  static const String diaryDomain = ipDomain3 + "diary/";
  static const String diaryCommentDomain = ipDomain3 + 'personal/';

  // Đăng nhập QLC mới
  static const String loginQLCNew = ipDomainQLCNew + 'employee/login';

  /// api nhật ký chung
  // <--------------------Bài viết--------------------------------->
  // Đăng bài
  static const String createPostDiary = diaryDomain + 'createpostdiary';

  // Xóa bài
  static const String deletePostDiary = diaryDomain + 'deletepostdiary/';

  // Sửa bải
  static const String editPostDiary = diaryDomain + 'editpostdiary';

  // Danh sách bài
  static const String getAllPostDiary = diaryDomain + 'getallpostdiary';

  // Chi tiết bài
  static const String getPostDiary = diaryDomain + 'getpostdiary';

  // Thả cảm xúc
  static const String releaseEmotion = diaryDomain + 'releaseemotion';

  //<------------------------Album--------------------------------->
  // Tạo album
  static const String createAlbumDiary = diaryDomain + 'createAlbumDiary';

  // Chỉnh sửa album
  static const String editAlbumDiary = diaryDomain + 'editAlbumDiary';

  // Danh sách album
  static const String getAllAlbumDiary = diaryDomain + 'getAllAlbumDiary';

  // Xóa album
  static const String deleteAlbumDiary = diaryDomain + 'deleteAlbumDiary/';

  // <-------------------------------Comment------------------------------->
  // Danh sách bình luận
  static const String getComments = diaryDomain + 'GetComments';

  // Đăng bình luận
  static const String createComment = diaryCommentDomain + 'createComment';

  // Sư bình luận
  static const String updateComment = diaryCommentDomain + 'updateComment';

  // Xóa bình luận
  static const String deleteComment = diaryCommentDomain + 'deleteComment';

  // Thả like
  static const String likeComment = diaryCommentDomain + 'emotionfile';

  // Chuyển đổi âm thanh sang text và ngược lại
  static const String transVoiceToText = 'http://43.239.223.5:5006/convert_app';
  static const String transTextToVoice = 'http://43.239.223.5:5003/tts_app';

  /// API trang cá nhân
  static const String getAllPostPersonal = personalDomain + 'getallpost';
  static const String createPostPersonal = personalDomain + 'createpost';
  static const String getPostPersonal = personalDomain + 'getpost';
  static const String editPostPersonal = personalDomain + 'editpost';
  static const String deletePostPersonal = personalDomain + 'deletepost';
  static const String getAllAlbumPersonal = personalDomain + 'getallalbum';
  static const String createAlbumPersonal = personalDomain + 'createalbum';
  static const String editAlbumPersonal = personalDomain + 'editalbum';
  static const String getAlbumPersonal = personalDomain + 'getalbum';
  static const String deleteAlbumPersonal = personalDomain + 'deleteAlbum';
  static const String releaseEmotionPost = personalDomain + 'releaseemotion';
  static const String countFilePersonal = personalDomain + 'countfile';
  static const String getAllIdPersonal = personalDomain + 'GetAllIdPost';
  static const String getAllImageOfDay = personalDomain + 'GetListLibraApp';
  static const String releaseEmotionImage = personalDomain + 'emotionfile';
  static const String getAllCommentPersonal = personalDomain + 'GetComments';
  static const String createCommentPersonal = personalDomain + 'createcomment';
  static const String updateCommentPersonal = personalDomain + 'updatecomment';
  static const String deleteCommentPersonal = personalDomain + 'deletecomment';
  static const String updateBackGroundPersonal =
      personalDomain + 'backgroundImg';
  static const String getListFavoritePersonal =
      personalDomain + 'GetListFavorLibra';
  static const String getListHighCommentPersonal =
      personalDomain + 'GetListCommentLibra';
  static const String unTagPersonal = personalDomain + 'untagPersonal';
  static const String deleteFileAlbumPersonal =
      personalDomain + 'deleteFileAlbum';
  static const String updateDescriptionPersonal =
      personalDomain + 'changeDescription';
  static const String checkStatusFriendPersonal =
      ipDomain2 + 'users/getBestFriend';
  static const String updateStatusFriendPersonal =
      ipDomain2 + 'users/updateBestFriend';

  //api ẩn bảng tin (toàn bộ bài đăng của người này sẽ bị ẩn)

  static const String hidePost =
      'http://43.239.223.142:9000/api/privacy/HidePost';

  //check tk tải app chat
  static const String updateStatusDownLoadChat365 =
      apiTienich + '/timviec/admin/order/updateStatusDownloadChat365';

// api bảng tin
  static const String getAllNews = personalDomain + 'GetPostsFriend';

  /// Api Tin nhắn
  // danh sách tin nhắn
  /// TL 28/12/2023: DEPRECATED. Dùng loadMessage
  //static const String chatDetail = messageDomain2 + 'loadMessage';

  /// Tải tin nhắn 1 cuộc trò chuyện
  static const String loadMessage = messageDomain2 + 'loadMessage';

  // danh sách file/ảnh/link
  static const String chatLibrary = messageDomain2 + 'GetListLibra';

  // danh sách tin nhắn cho nhiều cuộc trò chuyện
  // static const String listLastMessageOfConversation =
  //     messageDomain2 + 'GetListMessage_v2';
  /// DEPRECATED. Dùng loadListMessage
  static const String messageOfAllConversation =
      messageDomain2 + 'LoadListMessage';

  /// Danh sách tin nhắn cho nhiều cuộc trò chuyện
  static const String loadListMessage = messageDomain2 + 'LoadListMessage';

  // không biết để làm gì vì người trước không comment
  static const String shareAvatar = messageDomain2 + 'ShareAvatar';

  // Gửi tin nhắn
  static const String sendMessage = messageDomain2 + 'SendMessage';

  //cổng này để test tạm thời, đợi Tiến đẩy cổng mới
  // static const String sendMessage =
  //     'http://43.239.223.142:9000/api/message/SendMessage';

  // Chỉnh sửa tin nhắn
  static const String editMessage = messageDomain2 + 'EditMessage';

  // Xóa tin nhắn 1 phía
  static const String deleteMessageOneSide =
      messageDomain2 + 'DeleteMessageOneSide';

  // Xóa tin nhắn
  static const String deleteMessage = messageDomain2 + 'DeleteMessage';

  // Xóa tất cả tin nhắn
  static const String deleteAllMessage =
      messageDomain2 + 'DeleteAllMessageConversation';

  // Thu hồi tin nhắn
  static const String recallMessage = messageDomain2 + 'RecallMessage';

  // Lấy thông tin của tin nhắn
  static const String getMessage = messageDomain2 + 'GetMessage';

  // Đánh dấu tin nhắn
  static const String bookmarkMessage = messageDomain2 + 'SetFavoriteMessage';

  // Bỏ đánh dấu
  static const String unBookmarkMessage =
      messageDomain2 + 'RemoveFavoriteMessage';

  // Danh sách tin nhăn đánh dấu
  static const String getListBookmarkMessage =
      messageDomain2 + 'GetListFavoriteMessage';

  // Thả cảm xúc
  static const String changeEmotionMessage =
      messageDomain2 + 'SetEmotionMessage';

  /// Live Chat cái *** con me đau đầu vc live với chả chatlive

  // tạo cuộc trò chuyện livechat

  static const String createNewLivechat = chatDomain2 + 'CreateNewLiveChat';

  // Cập nhật trạng thái LiveChat
  static const String updateStatusLivechat =
      messageDomain2 + 'UpdateSupportStatusMessage';

  // trên web đếm s rồi không cần phải đếm s nữa
  // Lấy thời gian nhỡ
  static const String getTimeMissLivechat =
      messageDomain2 + 'GetTimeMissLiveChat';

  // Gửi tin nhắn LiveChat
  static const String sendMessage_v2 = messageDomain2 + 'SendMessage_v2';

  ///

  // Đánh dấu tin nhắn là đã được click
  static const String clickMessage =
      messageDomain2 + 'ClickMessageNotification';

  /// các Api nhắc hẹn
  // Tạo nhắc hẹn
  static const String createCalendar = calendarDomain + 'createcalendar';

  // Chỉnh sửa nhắc hẹn
  static const String editCalendar = calendarDomain + 'editcalendar';

  // Xóa nhắc hẹn
  static const String deleteCalendar = calendarDomain + 'deletecalendar/';

  // Chi tiết cuộc hẹn
  static const String getDetailCalendar = calendarDomain + 'getdetailcalendar/';

  // Người tham gia
  static const String handleParticipantCalendar =
      calendarDomain + 'handleparticipantcalendar';

  // api lịch nhóm
  // Danh sách nhắc hẹn của cuộc trò chuyện
  static const String getAllCalendarOfConv =
      calendarDomain + 'getAllCalendarOfConv';

  // Danh sach cuoc binh chon
  static const String getAllVote =
      'http://43.239.223.157:9001/api/poll/CreatePoll';

  // Danh sách nhắc hẹn của cá nhân
  static const String getAllCalendarOfUser =
      calendarDomain + 'getallcalendarofuser';

  //tìm kiếm tin nhắn
  static const String findMessage = ipDomain2 + 'conv/findeachmes';

  static const String downloadDomain = ipDomain2 + 'file/DownloadFile/';
  static const String uploadFileDomain2 = ipDomainOld + 'file/';
  static const String changeGroupAvatar = ipDomain2 + 'file/UploadAvatarGroup';

  //api thêm thành viên vào nhóm - nếu người thêm không phải là admin - các api về nhóm mới đang sử dụng cổng 9000, Tiến chưa up lên cổng 9007
  //thì sẽ tự vào danh sách tv chờ duyệt, admin duyệt cũng dùng api này
  static const String addNewMemberToGroup =
      chatDomain2 + 'AddNewMemberToGroupV2';

  //*mới giờ tv thường muốn xóa người khác thì cần gửi y/c nêu cả lý do
  static const String deleteMemberToGroup = chatDomain2 + 'DeleteMemberToGroup';

  // api bật tắt duyệt thành viên
  static const String updateMemberApproval =
      chatDomain2 + 'UpdateMemberApproval';

  // lấy trạng thái bật tắt duyệt thành viên
  static const String getMemberApproval = chatDomain2 + 'GetMemberApproval';

  //api lấy danh sách thành viên duyệt
  static const String getListRequestAdmin = chatDomain2 + 'GetListRequestAdmin';

  //api thêm phó nhóm
  static const String updateDeputyAdmin = chatDomain2 + 'UpdateDeputyAdmin';

  //Profile
  static const String changeAvatarUser = uploadFileDomain2 + 'UploadNewAvatar';
  static const String changeAvatarGroup =
      uploadFileDomain2 + 'UploadAvatarGroup';
  static const String uploadFile =
      'http://210.245.108.202:9000/api/file/UploadFile';
  static const String downloadFile = fileDomain + 'DownloadFile/';

  /// Notification
  // Danh sách thông báo
  static String getListNoti(int userId) =>
      notificationDomain2 + 'GetListNotificationV2/${userId.toString()}';

  // Gửi thông báo mới
  static const String sendNewNotification_v2 =
      notificationDomain2 + 'SendNewNotification_v2';

  // Đọc thông báo
  static const String markAsReadNoti = notificationDomain2 + 'ReadNotification';

  static String readNoti(String notiId) =>
      notificationDomain2 + 'ReadNotification/${notiId}';

  // Đọc tất cả thông báo
  static String readAllNoti(int userId) =>
      notificationDomain2 + 'ReadAllNotification/${userId.toString()}';

  // Xóa tất cả thông báo
  static String deleteAllNotification(int userId) =>
      '${notificationDomain2}DeleteAllNotification/${userId.toString()}';

  //login
  static const String login = ipDomain2 + 'conv/auth/login';

  ///SignUp
  static const String signUpUrl = 'https://chamcong.24hpay.vn/';
  static const String service = signUpUrl + 'service/';
  static const String webCc = signUpUrl + 'api_web_cham_cong/';

  // Đăng ký cá nhân
  static const String signUpEmployeePrivate =
      'https://chamcong.24hpay.vn/api_web_cham_cong/register_employee_private.php';

  static const String signUpEmployeePrivateNew =
      ipDomainQLC1 + "qlc/individual/register";

  // Đăng nhập nhân viên chamcong24h
  static const String loginEmployeeCC = service + 'login_employee.php';

  // Đăng ký nhân viên
  static const String signUpEmployee = service + 'register_employee.php';

  static const String signUpEmployeeNew =
      ipDomainQLC1 + "qlc/employee/register";

  // Đăng ký công ty
  static const String signUpCompany = service + 'register_company.php';

  static const String signUpCompanyNew = ipDomainQLC1 + "qlc/Company/register";

  // Thông tin công ty
  static const String detailCompany = service + 'detail_company.php';
  static const String newCompanyExists =
      "http://210.245.108.202:3000/api/qlc/company/isExists";

  ///Dung chung cho quen mat khau va xac thuc tai khoan cong ty
  ///
  ///Id type 1: la nhan vien va ca nhan, 2 la cong ty
  // Xác thực tài khoản => đã xác thực
  // static const String verifyOtp = service + 'verify_otp_sms.php';

  static const String verifyOtp =
      "https://skvideocall.timviec365.vn/service/verify_otp_sms";

  // Thêm nhân viên sau khi đăng ký công ty thành công
  static const String addFirstEmployee = service + 'add_employee.php';

  static const String addFirstEmployeeNew =
      ipDomainQLC1 + "qlc/managerUser/createUserNew";

  // Check tên công ty đã tồn tại hay chưa
  static const String checkNameCompany = service + 'check_name_company.php';

  static const String checkNameCompanyNew =
      ipDomainQLC1 + "qlc/Company/checkName";

  // Check email/sđt đăng k đã tồn tại hay chưa
  static const String checkAccount =
      signUpUrl + 'api_chat365/check_email_exits2.php';

  static const String checkAccountNew = ipDomainQLC1 + "qlc/Company/checkInput";

  // Danh sách tổ của công ty
  static const String getListNest = webCc + 'list_nest_dk.php';

  // Danh sách nhóm trong tổ
  static const String getListGroup = webCc + 'list_nhom_dk.php';

  // Màn OTP SMS đăng ký
  static String sendOtpRegisterPhoneNumber(String pNumber, int type) =>
      'https://skvideocall.timviec365.vn/api/renderotp/register/quanlychung/app/$pNumber/$type';

  // Màn OTP SMS Quên mật khẩu
  static String sendOtpForgotPassPhoneNumber(String pNumber) =>
      'https://skvideocall.timviec365.vn/api/renderotp/changePassword/quanlychung/app/$pNumber/${AuthRepo.deviceID}';

  /*--------------------------------------------------------------------------------------*/
  //Chấm công

  /// phan tien ich -> (cai dat) cham cong -> chi tiet
  // lay danh sach chi tiet
  static const String get_list_detail = ipDomain7 + 'qlc/settingTimesheet/list';

  // them mot doi tuong chi tiet moi vao danh sach chi tiet
  static const String create_detail = ipDomain7 + 'qlc/settingTimesheet/add';

  // sua mot doi tuong chi tiet trong danh sach chi tiet
  static const String edit_detail = ipDomain7 + 'qlc/settingTimesheet/edit';

  // xoa mot doi tuong chi tiet trong danh sach chi tiet
  static const String delete_detail = ipDomain7 + 'qlc/settingTimesheet/del';

  // loc chi tiet dua theo id to chuc/id chuc vu/ id nhan vien
  static const String filter_detail = ipDomain7 + 'qlc/timekeeping/filterComp';

  // lay danh sach ca lam viec
  static const String get_list_shift = ipDomain7 + 'qlc/shift/list';

  // lay danh sach loc
  // danh sach loc nay co the lay duoc danh sach cua nhung phan khac la:
  // to chuc, chuc vu, nhan vien, ca lam viec, ip, wifi, vi tri
  static const String get_list_filter =
      ipDomain7 + 'qlc/timekeeping/filterComp';

  /// phan tien ich -> (cai dat) cham cong -> vi tri
  // lay danh sach vi tri
  static const String get_list_location = ipDomain7 + 'qlc/location/list';

  // them mot vi tri moi vao danh sach
  static const String create_location = ipDomain7 + 'qlc/location/add';

  // sua mot vi tri trong danh sach
  static const String edit_location = ipDomain7 + 'qlc/location/update';

  // xoa mot vi tri trong danh sach
  static const String delete_location = ipDomain7 + 'qlc/location/delete';

  // lay danh sach goi y vi tri
  static const String get_suggested_list_location =
      'https://rsapi.goong.io/Place/AutoComplete';

  /// phan tien ich -> (cai dat) cham cong -> gioi han ip cham cong
  // lay danh sach gioi han ip cham cong
  static const String get_list_limit_ip_company =
      ipDomain7 + 'qlc/company_web_ip/list';

  // them mot ip moi vao danh sach gioi han ip cham cong
  static const String create_limit_ip_company =
      ipDomain7 + 'qlc/company_web_ip/add';

  // sua mot doi tuong trong danh sach gioi han ip cham cong
  static const String edit_limit_ip_company =
      ipDomain7 + 'qlc/company_web_ip/edit';

  // xoa mot doi tuong trong danh sach gioi han ip cham cong
  static const String delete_limit_ip_company =
      ipDomain7 + 'qlc/company_web_ip/delete';

  /// phan tien ich -> (cai dat) cham cong -> wifi
  // lay danh sach mang wifi
  static const String get_list_wifi = ipDomain7 + 'qlc/SettingWifi/list';

  // them moi mang wifi
  static const String create_wifi = ipDomain7 + 'qlc/SettingWifi/create';

  // sua mang wifi
  static const String edit_wifi = ipDomain7 + 'qlc/SettingWifi/update';

  // xoa mang wifi
  static const String delete_wifi = ipDomain7 + 'qlc/SettingWifi/delete';

  /// phan tien ich -> (cai dat) cham cong -> cam xuc
  // lấy danh sách cảm xúc
  static const String get_list_emote = ipDomain7 + 'qlc/emotions/list';

  // tạo thang điêm cảm xúc mới
  static const String create_emote_scale = ipDomain7 + 'qlc/emotions/create';

  // cập nhật thang điểm cảm xúc
  static const String update_emote_scale = ipDomain7 + 'qlc/emotions/update';

  // xóa thang điểm cảm xúc
  static const String delete_emote_scale = ipDomain7 + 'qlc/emotions/delete';

  // cập nhật điểm sàn cảm xúc (khi chấm công phải >= thì mới được chấm công
  static const String update_emote_point_floor =
      ipDomain7 + 'qlc/emotions/updateMinScore';

  // Bật/Tắt tính năng cảm xúc
  static const String switch_on_off_emote =
      ipDomain7 + 'qlc/emotions/toggleOnOff';

  // Lấy tình trạng của tính năng cảm xúc (đang được sử dụng hay không được sử dụng)
  static const String get_on_of_emote =
      ipDomain7 + 'qlc/emotions/getToggleEmotion';

  /*---------------------------------*/

  // check giả mạo
  static const String fake_face_detection = 'http://43.239.223.5:4321/predict';

  // static const String fake_face_detection = 'http://43.239.223.5:2005/predict';

  // Quét mặt
  static const String scan_face_timekeeping =
      'http://43.239.223.147:5001/face_verify_app';

  static const String scan_face_timekeeping_new =
      "https://api.timviec365.vn/api/qlc/ai/detectFace";

  //update face
  static const String update_face =
      "https://api.timviec365.vn/api/qlc/ai/updateFaceNew";

  // Cấu hình chm công
  static const String timekeeping_configuration =
      service + 'get_config_timekeeping_new.php';
  static const String timekeeping_new_config =
      ipDomainQLCNew + "managetracking/config";

  // Dữ liệu QR
  static const String decode_qr_attendance =
      'https://chamcong.24hpay.vn/service/decode_qr_data.php';

  // Chấm công khuôn mặt
  static const String timekeeping = service + 'add_time_keeping.php';

  static const String timekeeping_new =
      "https://api.timviec365.vn/api/qlc/timekeeping/create/app";

  // Chấm công QR
  static const String timekeepingQR = service + 'add_time_keeping_qr.php';

  //Lấy ca chấm công
  static const String list_shift = service;

  static const String list_shift_new = ipDomainQLCNew + "shift/list_shift_user";

//Lấy token
  static const String get_token = signUpUrl + 'api_chat365/get_token.php';

  static const String get_token_new = ipDomainQLCNew + 'employee/login';

  // lấy lịch sử chấm công
  static const String historyTimeKeeping =
      webCc + 'get_history_time_keeping_by_company.php';

// refresh token
  static const String refresh_token =
      'http://210.245.108.202:3000/api/qlc/employee/getNewToken';

//Thông tin ứng viên, NTD site .vn
  static const String get_detail_info =
      ipDomainTimviec + 'api_winform/data_user_chat.php';

//Thông tin người dùng bên rao nhanh
  static const String get_info_raonhanh =
      'https://raonhanh365.vn/api/chat_ttin.php';

  /// Quét QR

  // Check phaan quyền tài khoản trước khi ứng tuyển QR
  static const String checkPermission =
      apiTienich + '/timviec/account/getAccPermissionCandi';

  // Lấy dữ liệu tài khoản rao nhanh
  static const String app_login_raonhanh =
      'https://raonhanh365.vn/api/data_qrcode.php';

  ///
  //firebase
  static const String firebaseUrl = ipDomainTimviec + "api_app";

  // Cập nhật Firebase token
  static const String UPDATE_FIREBASE_TOKEN =
      notificationDomain + "/UpdateTokenApp";

  static const String UPDATE_VOIP_TOKEN =
      notificationDomain + "/UpdateTokenVoIP";

  // Gửi thông báo firebase
  static const String PUSH_NOTIFICATION_FIREBASE =
      notificationDomainPush + "/SendNotificationApp";

  //List contact
  static const String get_list_contact =
      ipDomain2 + 'conv/auth/takedatatoverifyloginV2/';
  static const String acceptLogin = ipDomain2 + 'conv/auth/AcceptLogin';

  //confirm Login dùng acceptLogin thay cho confirm để xác nhận đăng nhập máy lạ
  static const String confirm_login = ipDomain2 + 'conv/auth/confirmlogin';
  static const String confirm_login_otp = ipDomain2 + 'conv/auth/confirmotp';

  static const String getSticker =
      'https://chat365.timviec365.vn/api_app/getSticker.php';

  /*--------------------------------------------------------------------------------------*/

  ///fast message - tin nhắn nhanh
  static const String createFastMessage =
      ipDomain2 + 'fastMessage/CreateFastMessage';
  static const String editFastMessage =
      ipDomain2 + 'fastMessage/EditFastMessage';
  static const String getFastMessage = ipDomain2 + 'fastMessage/GetFastMessage';
  static const String deleteFastMessage =
      ipDomain2 + 'fastMessage/DeleteFastMessage';

  // Lấy dữ liệu tài khoản rao nhanh
  // static const String app_login_raonhanh =
  //     'https://raonhanh365.vn/api/data_qrcode.php';
  /*--------------------------------------------------------------------------------------*/
  // Check phaan quyền tài khoản trước khi ứng tuyển QR
  static const String applyJobQr = firebaseUrl + '/nop_ho_so_chat365.php';

  /// api tìm việc
  /// Quét QR
  static const String apiTienich = 'http://210.245.108.202:3001/api';
  static const String apiTienichUV = apiTienich + '/timviec/candidate/';
  static const String apiTienichNTD = apiTienich + '/timviec/company/';
  static const String apiTienichNew = apiTienich + '/timviec/new/';

  //firebase
  static const String createOnlineProfile =
      apiTienichUV + 'app_chat/update_hstt';
  static const String createProfileWithCv =
      apiTienichUV + 'app_chat/update_infor';

  //danh sách tin tuyển dụng giống app ứng viên
  static const String listPostRecruitmentAsAppCandidate =
      apiTienichNew + 'homePageApp';

  // Lấy dữ liệu tài khoản timviec
  static const String app_login_timviec =
      apiTienich + '/timviec/account/checkAccount';
  static const String app_login_timviec_old =
      firebaseUrl + '/check_account.php';

  // check NTD đã dùng điểm chưa
  static const String check_use_point = apiTienichNTD + 'CheckComUsePointYet';

  // đánh giá nhà tuyển dụng
  static const String assess_news = apiTienichUV + 'evaluateCompany';

  // Lưu, bỏ tin tuyển dụng
  static const String save_news = apiTienichUV + 'candidateSavePost';

  // Bỏ ứng tuyển tin tuyển dụng
  static const String cancel_apply = apiTienichUV + 'deleteJobCandidateApply';

  // ứng tuyển tin tuyển dụng
  static const String apply = apiTienichUV + 'candidateApply';

  // chi tiết tin tuyển dụng
  static const String getDetailRecruitment = apiTienichNew + 'detail';

  //vl tương tụ
  static const String getListRelateJob =
      apiTienichNew + 'listSimulateNewForApp';

  //tìm kiếm ứng viên
  static const String searchCandidate = apiTienichUV + 'listAI';

  //đề xuất ứng viên
  static const String recommentCandicate = apiTienichNTD + 'candidateAIForNew';

  // thông tin công ty tuyển dụng v2
  static const String getInforCompanyv2 =
      apiTienichNTD + 'getdetailinfocompany';

  // Danh sách tin tuyển dụng công ty
  static const String listRecruitmentOfCompany = apiTienichNTD + 'listNewsApp';

  // bình luận trong tin tuyển dụng
  static const String getCommentAll = apiTienichNew + 'listComment';

  // gửi bình luận tin tuyển dụng
  static const String sendComment = apiTienichNew + 'comment';

  // sửa bình luận tin tuyển dụng
  static const String editComment = apiTienichNew + 'editComment';

  // xoá bình luận tin tuyển dụng
  static const String removeComment = apiTienichNew + 'deleteComment';

  // tìm kiếm  tin tuyển dụng
  static const String findingRecruitment = apiTienichNew + 'SearchCareer';

  // đăng tin 5
  static const String post = apiTienichNew + 'postNewTv365';

  // send like
  static const String sendLike = apiTienichNew + 'like';

  /// API ứng viên
  // Danh sách ứng viên mới
  static const String listNewCandidate = apiTienichUV + 'list';

  // Chi tiết ứng viên 6
  static const String candidateDetail = apiTienichUV + 'infoCandidate';

  // email, phone của ứng viên 7
  static const String getEmailPhone =
      firebaseUrl + '/get_mail_uv_not_token.php';

  // lưu tin ứng viên 8
  static const String saveCandidate = apiTienichNTD + 'saveUV';

  // trừ điểm của NTD
  static const String subtractPoint = apiTienichNTD + 'seenUVWithPointV2';

  // Danh sách quận huyện
  static const String listDistrict = apiTienich + '/getData/district';

  // Đăng tin không cần tài khoản (chưa cần) 11
  static const String postAnonymous = firebaseUrl + '/new_add_not_account.php';

  // check dung lượng file (chưa có) 12
  static const String checkFile = firebaseUrl + '/check_file_com.php';

  //Lấy danh sách tài khoản phân quyền
  static const String takeDataUserSharePermission =
      authDomain2 + 'TakeDataUserSharePermission';

  /*--------------------------------------------------------------------------------------*/

  /// API conversation
  // tạo cuộc trò chuyện mới
  static const String resolveChatId = chatDomain2 + 'CreateNewConversation';

  // xóa tất cả file/ảnh
  static const String deleteFileConversation =
      chatDomain2 + 'deleteFileConversation';

  // chi tiết cuộc trò chuyện
  static const String chatInfo =
      ipDomain2 + 'conversations/' + 'GetConversation';

  /// Lấy danh sách cuộc trò chuyện
  ///
  /// TL 19/2/2024: V3_app là api mới, anh Hùng bảo sửa thành thế
  static const String chatList =
      ipDomain2 + 'conversations/' + 'GetListConversation_V3_app';
  static const String fastChatList = chatDomain2 + 'GetConversationList';

  // No concatenation because of the unusual port
  static const String chatListPC =
      "http://210.245.108.202:9000/api/conversations/GetListConversation";

  // danh sách cuộc trò chuyện chưa đọc
  static const String ConversationUnreader =
      chatDomain2 + 'GetListConversationUnreader';
  static const String unreadConversation =
      chatDomain2 + 'GetListConversationUnreader';

  // danh sách nhóm chung
  static const String GetCommonConversation =
      chatDomain2 + 'GetCommonConversation';

  // đối tên cuộc trò chuyện 1-1 ở phía mình
  static const String changeNickName = chatDomain2 + 'ChangeNickName';

  // đổi tên nhóm
  static const String changeGroupName = chatDomain2 + 'ChangeNameGroup';

  // Lấy danh sách cuộc trò chuyện với người lạ
  static const String getListConversationStrange =
      chatDomain2 + 'GetListConversationStrange_v2';

  // chuyển quyền admin nhóm
  static const String changeAdmin =
      ipDomain2 + 'conversations/ChangeAdminGroup';

  // giải tán nhóm
  static const String disbandGroup = chatDomain2 + 'DisbandGroup';

// lấy danh sách thành viên trong nhóm
  static const String getListMemberOfGroup =
      ipDomain2 + 'conversations/GetListMemberOfGroup';

  // tạo nhóm
  static const String createGroupChat =
      ipDomain2 + 'conversations/' + 'AddNewConversation';

  // thêm vào cuộc trò chuyện yêu thích - ghim cuộc trò chuyện
  static const String toogleFavoriteChat =
      chatDomain2 + 'AddToFavoriteConversation';

  // đánh dấu đã đọc
  static const String markAsRead = chatDomain2 + 'ReadMessage';

  // đánh dấu chưa đọc - chưa có chức năng
  static const String markAsUnread = chatDomain2 + 'MarkUnreader';

  // ẩn cuộc trò chuyện - cũ rồi - không biết còn dùng nữa không :: chắc chắn là không rồi ))
  static const String toogleHiddenChat = chatDomain2 + 'HiddenConversation';

  /// Ẩn Cuộc trò chuyện
  // Cập nhật mã pin
  static const String updatePinHiddenConversation =
      authDomain2 + 'UpdatePinHiddenConversation';

  // Lấy mã pin
  static const String getPinHiddenConversation =
      authDomain2 + 'GetPinHiddenConversation';

  // Xóa mã pin/xóa cuộc trò chuyện
  static const String deletePinHiddenConversation =
      authDomain2 + 'DeletePinHiddenConversation';

  // Danh sách cuộc trò chuyện bị ẩn
  static const String getListHidden = chatDomain2 + 'GetListHiddenConversation';

  // xác thực mã pin
  //nếu nhập sai quá 5 lần cho cút luôn, xóa sạch cuộc trò chuyện bị ẩn
  static const String inputPinHiddenConversation =
      authDomain2 + 'ConfirmPinHiddenConv';

  // bật/tắt thông báo cuộc trò chuyện
  static const String changeNotiChat = chatDomain2 + 'changeNoTifyConv';

  // xóa cuộc trò chuyện - cũ rồi
  static const String deleteChat = chatDomain2 + 'RemoveConversation';

  // Thêm thành viên vào nhóm => api này đã bỏ thay vào đó là dùng api AddNewMemberToGroupV2
  //static const String addMemberToGroup = chatDomain2 + 'AddNewMemberToGroup';

  // rời nhóm
  static const String leaveGroup = chatDomain2 + 'OutGroup';

  // tìm kiếm cuộc trò chuyện
  static const String searchConversations =
      chatDomain2 + 'GetListConversationForward';

  // api cuộc trò chuyện bí mật
  // cài đặt thời gian
  static const String updateDeleteTime = chatDomain2 + 'UpdateDeleteTime';

  // xóa tin nhắn khi hết giờ
  static const String deleteMessageSecret = chatDomain2 + 'DeleteMessageSecret';

  // tạo bí mật
  static const String createNewSecretConversation =
      chatDomain2 + 'CreateNewSecretConversation';

  // ghim, bỏ tin nhắn
  static const String pinMessage = messageDomain2 + 'pinMessageV2';

  // bỏ ghim tin nhắn
  static const String unPinMessage = chatDomain2 + 'UnPinMessage';

  // xóa tất cả tin nhắn 1 phía
  static const String deleteAllMessageOneSide =
      chatDomain2 + 'DeleteAllMessageOneSide';

  // api tin nhắn tự xóa
  static const String setupDeleteTime = chatDomain2 + 'SetupDeleteTimeV2';

  /// api liên quan đến tài khoản user
  // Cập nhật mật khẩu - Dùng cho màn quên mật khẩu
  static const String updatePassword = authDomain2 + 'UpdatePassword';

  // Đổi mật khẩu - dùng cho màn đổi mật khẩu
  static const String changePassword = authDomain2 + 'ChangePassword';

  // Kiểm tra xem email/sđt đã đăng ký chat chưa, và loại tài khoản là gì
  static const String takeDataUserByMailPhone =
      authDomain2 + 'TakeDataUserByMailPhone';

  // Get thông tin của user theo idChat
  static const String getUserInfo = authDomain2 + 'GetInfoUser';

  // lấy idChat theo email/sđt đăng ký
  static const String getIdChatByEmailPhone =
      authDomain2 + 'GetIdChatByEmailPhone';

  // Lấy idChat theo thông tin từ quản lý chung
  // static const String getUserInfoFromHHP365 =
  //     authDomain2 + 'GetInfoUserFromHHP365';

  // Thay đổi trạng thái hoạt động
  static const String changePresenceStatus = authDomain2 + 'ChangeActive';

  // Đổi tên tài khoản
  static const String changeUserName = authDomain2 + 'ChangeUserName';

  // Kiểm tra trạng thái bạn bè
  static const String checkStatus = authDomain2 + 'CheckStatus';

  // Lấy danh sách bạn bè/liên hệ
  static const String myContacts = authDomain2 + 'GetListContact_v2';

  // Xóa trạng thái bạn bè
  static const String deleteContact = authDomain2 + 'DeleteContact';

  // Danh sách liên hệ trong công ty
  static const String allContactsInCompany2 =
      authDomain2 + 'finduser/app/companyrandom';

  // Tìm kiếm liên hệ trong công ty
  static const String searchContactInCompany2 =
      authDomain2 + 'finduser/app/company';

  // <------Tìm kiếm
  static const String searchContact2 = authDomain2 + 'finduser/app/normal';

  static const String searchAll2 = authDomain2 + 'finduser/app';
  static const String userSearch = authDomain2 + 'finduser/app';

  static const String searchListConversation2 =
      authDomain2 + 'finduser/app/conversation';
  static const String takeListGroupChat =
      authDomain2 + 'finduser/app/conversation';

  // Tìm kiếm liên hệ theo sđt
  static const String searchContactByPhone =
      authDomain2 + 'GetListOfferContactByPhone';

  //------->

  // thay thế get requestlist bằng 2 api lấy danh sách lời mời kết bạn gửi và nhận được
  static const String sentRequest = authDomain2 + 'SentRequest';
  static const String friendRequest = authDomain2 + 'FriendRequest';

  // Gửi yêu cầu Thêm bạn
  static const String addFriend = authDomain2 + 'AddFriend';

  // Xóa/thu hồi yêu cầu kết bạn
  static const String deleteRequestAddFriend =
      authDomain2 + 'DeleteRequestAddFriend';

  // Danh sách lời mời kết bạn
  static const String listFriendRequest = authDomain2 + 'GetListRequest';

  // CHấp nhận thêm bạn
  static const String acceptRequestAddFriend =
      authDomain2 + 'AcceptRequestAddFriend';

  // Từ chối thêm bạn
  static const String decilineRequestAddFriend =
      authDomain2 + 'DecilineRequestAddFriend';

  // Danh sách gợi ý kết bạn
  // static const String getListSuggetContact =
  //     authDomain2 + 'GetListSuggesContact';

  // Danh sách bạn mới
  static String getListNewFriends(int userId) =>
      authDomain2 + 'listnewfriend/${userId.toString()}';

  // Danh sách bạn bè ở gần
  static String getFriendsNearBy(int userId) =>
      authDomain2 + 'findarround/${userId.toString()}';

  // Bắn vị trí khi đăng nhập
  static String updateLocation = ipDomain2 + 'users/updatelocation';

  // Gửi mã OTP email
  static const String sendOtp_nodeJS = authDomain2 + 'RegisterMailOtp';

  // Tham gia nhóm bằng QR
  static const String add_group = authDomain2 + 'QR/QR365';

  // Đăng xuất thiết bị lạ
  static const String logoutStrangeDevice = authDomain2 +
      '.'
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          ''
          '';

  // bật tắt xác thực 2 lớp
  static const String UpdateDoubleVerify = authDomain2 + 'UpdateDoubleVerify';

  // Kiểm tra xem có bật xác thực 2 lớp hay không
  static const String GetStatusDoubleVerify =
      authDomain2 + 'GetStatusDoubleVerify';

  // Cập nhật thiết bị đăng nhập
  static const String change_accept_device = authDomain2 + 'ChangeAcceptDevice';

  // Lịch sử đăng nhập
  static const String list_login_history = authDomain2 + 'gethistoryaccess/';

  // Lấy danh sách id người quen
  static const String getListUserIdFamiliar =
      authDomain2 + 'GetListUserIdFamiliar';

  //phân loại

  ///tạo phân loại
  static const String createClassUser = authDomain2 + 'CreateClassUser';

  ///lấy danh sách phân loại
  static const String getListClassOfOneUser =
      authDomain2 + 'GetListClassOfOneUser';

  ///xóa phân loại
  static const String deleteClassUser = authDomain2 + 'DeleteClassUser';

  ///lấy danh sách user trong phân loại
  static const String getListUserByClassUserAndUserOwner =
      authDomain2 + 'GetListUserByClassUserAndUserOwner';

  ///xóa người dùng trong phân loại
  static const String editClassify = authDomain2 + 'EditClass';

  ///lấy danh sách cuộc trò chuyện trong phân loại
  static const String getListConversationByClassUser =
      ipDomain2 + 'conversations/' + 'GetListConversationByClassUser';

  ///chuyển cuộc hội thoại sang nhãn dán khác
  static const String insertUserToClassUser =
      authDomain2 + 'InsertUserToClassUser';

  //tin nhắn đồng thời
  ///gửi tin nhắn đồng thời
  static const String sendMesListUserId = authDomain2 + 'SendMesListUserId';

  // Đăng tin
  static const String postFeature = firebaseUrl + '/new_add_update_chat365.php';

  // api phần quyền riêng tư

  // Hiện ngày sinh
  static const String changeShowDateOfBirth =
      privacyDomain + 'ChangeShowDateOfBirth';

  // Hiện trạng thái truy cập
  static const String changeActive = privacyDomain + 'ChangeActive';

  // Cho phép nhắn tin
  static const String changeChat = privacyDomain + 'ChangeChat';

  // Cho phép gọi điện
  static const String changeCall = privacyDomain + 'ChangeCall';

  // Cho phép xem và bình luận
  static const String changeShowPost = privacyDomain + 'ChangeShowPost';

  // Chặn tin nhắn
  static const String blockMessage = privacyDomain + 'BlockMessage';

  // Bỏ chặn tin nhắn
  static const String unblockMessage = privacyDomain + 'UnblockMessage';

  // Check 2 người trong cuộc trò chuyện có ai chặn không
  static const String checkBlockMessage = privacyDomain + 'CheckBlockMessage';

  // Lấy danh sách chặn tin nhắn
  static const String getListBlockMessage =
      privacyDomain + 'GetListBlockMessage';

  // Chặn xem tin đăng
  // static const String blockPost = privacyDomain + 'BlockPost';

  //Lấy danh sách người dùng bị chặn tin đăng
  // static const String getListBlockPost = privacyDomain + 'GetListBlockPost';

  // Quản lý nguồn tìm kiếm và kết bạn
  static const String searchSource = privacyDomain + 'SearchSource';

  // Lấy thông tin quyền riêng tư
  static const String getPrivacy = privacyDomain + 'GetPrivacy';

  // Bật tắt hiển thị trạng thái đã xem
  static const String changeSeenMessage = privacyDomain + 'ChangeSeenMessage';

  // Bật tắt hiển thị trạng thái truy cập
  static const String changestatusOnline = privacyDomain + 'ChangestatusOnline';

  // Lấy danh sách các tài khoản đã đăng nhập trên thiết bị này
  static const String getAccountsByDevice =
      ipDomain2 + 'users/GetAccountsByDevice';

  //Các api thăm dò ý kiến
  static const String createPoll = pollDomain + 'CreatePoll';
  static const String getDetailPoll = pollDomain + 'GetDetailPoll';
  static const String votePoll = pollDomain + 'VotePoll';
  static const String deletePoll = pollDomain + 'DeletePoll';

  static const String manageProfilePeronal =
      ipDomainQLC + 'tinhluong/nhanvien/qly_ho_so_ca_nhan';

  // API QLC văn thư
  // danh sách người duyêt và người theo dõi
  static const String listFollowerAndBrowsing = ipDomainVanThu + 'showadd';

  //
  static const String createApplicationForLeave =
      ipDomainVanThu + 'De_Xuat_Xin_Nghi';
  static const String createWorkSchedule =
      ipDomainVanThu + 'De_Xuat_Lich_Lam_Viec';
  static const String createProposalParticipateInProject =
      ipDomainVanThu + 'De_Xuat_Tham_Gia_Du_An';
  static const String createAppointmentProposal =
      ipDomainVanThu + 'De_Xuat_Xin_Bo_Nhiem';
  static const String createProposalShiftChange =
      ipDomainVanThu + 'De_Xuat_Xin_Doi_Ca';
  static const String createProposalForAdvance =
      ipDomainVanThu + 'De_Xuat_Xin_Tam_Ung';
  static const String createProposalPropertyAllocation =
      ipDomainVanThu + 'De_Xuat_Cap_Phat_Tai_San';
  static const String createResignFromWork =
      ipDomainVanThu + 'De_Xuat_Xin_thoi_Viec';
  static const String createProposalSalaryIncrease =
      ipDomainVanThu + 'De_Xuat_Xin_Tang_Luong';
  static const String createProposalWorkingRotation =
      ipDomainVanThu + 'De_Xuat_Luan_Chuyen_Cong_Tac';
  static const String createProposalAddLabour = ipDomainVanThu + 'addDXC';
  static const String createProposalInfrastructure = ipDomainVanThu + 'addDXVC';
  static const String createProposalSignUpUseCar = ipDomainVanThu + 'addDXXe';
  static const String createProposalRose = ipDomainVanThu + 'addDXHH';
  static const String createProposalComplain = ipDomainVanThu + 'addDXKN';
  static const String createProposalUseMeetingRoom = ipDomainVanThu + 'addDxPh';
  static const String createProposalOvertime = ipDomainVanThu + 'addDXTC';
  static const String createProposalTakeMaternityLeave =
      ipDomainVanThu + 'addDxTs';
  static const String createProposalPayment = ipDomainVanThu + 'addDXTT';
  static const String createProposalPayOff = ipDomainVanThu + 'addDXTP';
  static const String createProposalDownloadDocument =
      ipDomainVanThu + 'addDXXTTL';

  // lay danh sach phong ban
  static const String getListOrganize =
      ipDomainTimviec365 + 'api/qlc/organizeDetail/listAll';
  static const String createDep = ipDomain7 + 'qlc/department/create';

  // Thiet lap thuong phat
  static const String showStaffLate =
      ipDomainQLC + 'tinhluong/congty/show_staff_late';

  // lay danh sach nhan vien
  static const String getListStaff =
      ipDomainQLC + 'tinhluong/congty/show_bangluong_coban';
  static const String insertBasisSalary =
      ipDomainQLC + 'tinhluong/congty/insert_basic_salary';

  // them danh sach phat muon
  static const String addFines =
      ipDomainQLC + 'tinhluong/congty/insert_phat_muon';

// take info salary
  static const String takeInfoSalary =
      ipDomainQLC + 'tinhluong/congty/take_salary_em';

  static const String takeInfoFines =
      ipDomainQLC + 'tinhluong/congty/takeinfo_phat_muon';
  static const String editFines =
      ipDomainQLC + 'tinhluong/congty/update_phat_muon';
  static const String deleteFines =
      ipDomainQLC + 'tinhluong/congty/delete_phat_muon';
  static const String takeStaffLate =
      ipDomainQLC + 'tinhluong/congty/show_staff_late';

  // lay danh sach ca lam viec:
  static const String listShift = ipDomainQLC + 'tinhluong/congty/list_shift';

  static const String listShiftWork = ipDomainQLCNew + 'shift/list';

  static const String listDepartment = ipDomainQLCNew + 'department/list';

  // them luong co ban
  static const String insertSb =
      ipDomainQLC + 'tinhluong/congty/insert_basic_salary';

  // edit basic salary
  static const String editSb =
      ipDomainQLC + 'tinhluong/congty/update_basic_salary';

  // delete salary basic
  static const String deleteSb =
      ipDomainQLC + 'tinhluong/congty/delete_basic_salary';
  static int id_com = AuthRepo().userInfo!.id365!;

  // static String token_com = AuthRepo.authToken!;
  // insert contract
  static const String insertContract =
      ipDomainQLC + 'tinhluong/congty/insert_contract';

  //edit contract
  static const String editContract =
      ipDomainQLC + 'tinhluong/congty/edit_contract';

  // delete contract
  static const String deleteContract =
      ipDomainQLC + 'tinhluong/congty/delete_contract';

  // lay danh sach phat ca
  static const String takeListPenalty =
      ipDomainQLC + 'tinhluong/congty/takeinfo_phat_ca_com';

  // lay danh sach nghi sai quy dinh
  static const String listBreakTheRule =
      ipDomainQLC + 'tinhluong/congty/take_listuser_nghi_khong_phep';

  // them phat ca
  static const String insertPenalty =
      ipDomainQLC + 'tinhluong/congty/insert_phat_ca';

  //update phat ca
  static const String updatePenalty =
      ipDomainQLC + 'tinhluong/congty/update_phat_ca';

  //delete phat ca
  static const String deletePenalty =
      ipDomainQLC + 'tinhluong/congty/delete_phat_ca';

  //lay danh sach thue
  static const String takeListTax =
      ipDomainQLC + 'tinhluong/congty/takeinfo_tax_com';

  //them thue moi
  static const String insertTax =
      ipDomainQLC + 'tinhluong/congty/insert_category_tax';

  // them nhan vien
  static const String addStaff =
      ipDomainQLC + 'tinhluong/congty/them_nv_nhom_tax';

  //sửa thuế
  static const String editTax = ipDomainQLC + 'tinhluong/congty/update_tax_com';

  // xoa thue
  static const String deleteTax =
      ipDomainQLC + 'tinhluong/congty/delete_tax_com';

  // take list nv tax
  static const String takeListStaffTax =
      ipDomainQLC + 'tinhluong/congty/take_list_nv_tax';

// delete staff tax
  static const String deleteStaffTax =
      ipDomainQLC + 'tinhluong/congty/delete_nv_tax';

  // edit staff tax
  static const String editStaffTax =
      ipDomainQLC + 'tinhluong/congty/edit_nv_tax';

  // take list user
  static const String takeListUser = ipDomainQLC + 'tinhluong/congty/list_em';

  // take list user tax
  static const String takeListUserTax =
      ipDomainQLC + 'tinhluong/congty/show_list_user_tax';

  //take list user no tax
  static const String takeListUserNoTax =
      ipDomainQLC + 'tinhluong/congty/show_list_user_no_tax';

  //qly ho so ca nhan(API luong nhan vien moi)
  static const String profileUser =
      ipDomainQLC + 'tinhluong/nhanvien/qly_ho_so_ca_nhan';

  //lấy lịch sử chấm công APi moi
  static const String takeHistoryTimeKeepingUser =
      ipDomainQLC + 'tinhluong/nhanvien/qly_ttnv';

  // lay luong hien tai
  static const String takePresentSalary =
      'https://api.timviec365.vn/api/tinhluong/nhanvien/show_payroll_user_new';

  //lấy dữ liệu chấm công gần nhất
  static const String takeDataTimeKeeping =
      'https://api.timviec365.vn/api/qlc/timekeeping/getLatestInOutUser';

  //login QLC
  static const String loginComQlc =
      'http://210.245.108.202:3000/api/qlc/Company/login';

// edit info user
  static const String editInfoUser =
      ipDomainQLC + 'tinhluong/congty/edit_detail_inforuser';

//xuat bang luong
  static const String exportSb =
      ipDomainQLC + 'tinhluong/congty/takedata_salary_report';

  //chinh sua mo ta

// them nhan vien thiet lap cong ty
  static const String takeListMember =
      ipDomainTimviec365 + 'api/qlc/managerUser/listAllFilter';

  static const String editDescription =
      ipDomainQLC + 'tinhluong/congty/edit_desc';

  // history timekeeping new api
  static const String getHistoryTimekeepingNewApi =
      ipDomainTimviec365 + 'api/qlc/timekeeping/employee/home';

  /// Devices Approval (Duyet thiet bi)
  // List all devices
  static const String listDevices = ipDomainQLCNew + "checkdevice/list/";

  // Create new device
  static const String createDevice = ipDomainQLCNew + "checkdevice/create/";

  // Add new device to approval list
  static const String addDevice = ipDomainQLCNew + "checkdevice/add/";

  // Delete a device
  static const String deleteDevice = ipDomainQLCNew + "checkdevice/delete/";

  /// API cu
  // danh sach luong co ban
  static const String takeSalaryBasicOldApi =
      ipTinhLuong + 'api_app/company/tbl_salary_manager.php';

  // dang nhap api cu
  static const String loginOldApi =
      ipTinhLuong + 'api_app/company/login_comp.php';

  // danh sach nhan vien
  static const String takeListUser365 =
      ipTinhLuong + 'api_app/company/list_emp.php';
  static const String takeListDep365 =
      ipTinhLuong + 'api_app/company/list_dep.php';
  static const String ipTinhLuong = 'https://tinhluong.timviec365.vn/';

  // thong tin nhan vien
  static const String infoStaffOldApi =
      'https://api.timviec365.vn/api/tinhluong/nhanvien/show_payroll_user';

  // static const String infoStaffOldApi =
  //     'https://tinhluong.timviec365.vn/api_app/company/profile_ep.php';
  static const String getCompanyWorkday =
      ipDomainQLC1 + "qlc/companyworkday/detail";
  static const String setCompanyWorkday =
      ipDomainQLC1 + "qlc/companyworkday/create";

  static const String getSFUServiceStatus =
      'https://skvideocall.timviec365.vn/api/getServiceStatus';

  static const String deleteAccount =
      "http://210.245.108.202:3020/api/timviec/admin/company/deleteUser";
}
