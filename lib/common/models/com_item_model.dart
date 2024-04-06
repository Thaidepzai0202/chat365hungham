class ComItem {
  final String accessToken;
  final String refreshToken;
  final ComInfo? comInfo;
  final Detail? detail;


  ComItem({
    required this.accessToken,
    required this.refreshToken,
    required this.comInfo,
    required this.detail,

  });

  factory ComItem.fromJson(Map<String, dynamic> json) => ComItem(
    accessToken: json["access_token"]??'',
    refreshToken: json["refresh_token"]??'',
    comInfo: json["com_info"] == null ? null :ComInfo.fromJson(json["com_info"]),
    detail: json["detail"] == null ? null : Detail.fromJson(json["detail"]),
  );
}

class ComInfo {
  final int comId;
  final String comPhoneTk;

  ComInfo({
    required this.comId,
    required this.comPhoneTk,
  });
  factory ComInfo.fromJson(Map<String, dynamic> json) => ComInfo(
    comId: json["com_id"]??0,
    comPhoneTk: json["com_phone_tk"]??'',
  );
}

class Detail {
  final ConfigChat configChat;
  final int id;
  final dynamic email;
  final String phoneTk;
  final String userName;
  final String alias;
  final dynamic phone;
  final String emailContact;
  final dynamic avatarUser;
  final int type;
  final dynamic city;
  final dynamic district;
  final String address;
  final dynamic otp;
  final int authentic;
  final int isOnline;
  final String fromWeb;
  final int fromDevice;
  final int createdAt;
  final int updatedAt;
  final DateTime lastActivedAt;
  final int timeLogin;
  final int role;
  final String latitude;
  final String longtitude;
  final int idQlc;
  final int idTimViec365;
  final int idRaoNhanh365;
  final String chat365Secret;
  final int chat365Id;
  final int scanBase365;
  final int checkChat;
  final List<dynamic> sharePermissionId;
  final dynamic inForPerson;
  final InForCompany inForCompany;
  final dynamic inforRn365;
  final int scan;
  final bool emotionActive;
  final int isAdmin;
  final int scanElacticAdmin;

  Detail({
    required this.configChat,
    required this.id,
    required this.email,
    required this.phoneTk,
    required this.userName,
    required this.alias,
    required this.phone,
    required this.emailContact,
    required this.avatarUser,
    required this.type,
    required this.city,
    required this.district,
    required this.address,
    required this.otp,
    required this.authentic,
    required this.isOnline,
    required this.fromWeb,
    required this.fromDevice,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActivedAt,
    required this.timeLogin,
    required this.role,
    required this.latitude,
    required this.longtitude,
    required this.idQlc,
    required this.idTimViec365,
    required this.idRaoNhanh365,
    required this.chat365Secret,
    required this.chat365Id,
    required this.scanBase365,
    required this.checkChat,
    required this.sharePermissionId,
    required this.inForPerson,
    required this.inForCompany,
    required this.inforRn365,
    required this.scan,
    required this.emotionActive,
    required this.isAdmin,
    required this.scanElacticAdmin,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    configChat: ConfigChat.fromJson(json["configChat"]),
    id: json["_id"]??0,
    email: json["email"]??'',
    phoneTk: json["phoneTK"]??'',
    userName: json["userName"]??'',
    alias: json["alias"]??null,
    phone: json["phone"]??'',
    emailContact: json["emailContact"]??'',
    avatarUser: json["avatarUser"]??'',
    type: json["type"]??0,
    city: json["city"]??0,
    district: json["district"]??0,
    address: json["address"]??'',
    otp: json["otp"]??null,
    authentic: json["authentic"]??0,
    isOnline: json["isOnline"]??0,
    fromWeb: json["fromWeb"]??'',
    fromDevice: json["fromDevice"]??0,
    createdAt: json["createdAt"]??0,
    updatedAt: json["updatedAt"]??0,
    lastActivedAt: DateTime.parse(json["lastActivedAt"]),
    timeLogin: json["time_login"]??0,
    role: json["role"]??0,
    latitude: json["latitude"]??'',
    longtitude: json["longtitude"]??'',
    idQlc: json["idQLC"]??0,
    idTimViec365: json["idTimViec365"]??0,
    idRaoNhanh365: json["idRaoNhanh365"]??0,
    chat365Secret: json["chat365_secret"]??'',
    chat365Id: json["chat365_id"]??0,
    scanBase365: json["scan_base365"]??0,
    checkChat: json["check_chat"]??0,
    sharePermissionId: List<dynamic>.from(json["sharePermissionId"].map((x) => x)),
    inForPerson: json["inForPerson"]??null,
    inForCompany: InForCompany.fromJson(json["inForCompany"]),
    inforRn365: json["inforRN365"]??null,
    scan: json["scan"]??0,
    emotionActive: json["emotion_active"]??true,
    isAdmin: json["isAdmin"]??0,
    scanElacticAdmin: json["scanElacticAdmin"]??0,
  );
}

class ConfigChat {
  final int notificationAcceptOffer;
  final int notificationAllocationRecall;
  final int notificationChangeSalary;
  final int notificationCommentFromRaoNhanh;
  final int notificationCommentFromTimViec;
  final int notificationDecilineOffer;
  final int notificationMissMessage;
  final int notificationNtdExpiredPin;
  final int notificationNtdExpiredRecruit;
  final int notificationNtdPoint;
  final int notificationSendCandidate;
  final int notificationTag;
  final List<dynamic> removeSugges;
  final String userNameNoVn;
  final int doubleVerify;
  final int active;
  final String status;
  final int acceptMessStranger;
  final List<HistoryAccess> historyAccess;

  ConfigChat({
    required this.notificationAcceptOffer,
    required this.notificationAllocationRecall,
    required this.notificationChangeSalary,
    required this.notificationCommentFromRaoNhanh,
    required this.notificationCommentFromTimViec,
    required this.notificationDecilineOffer,
    required this.notificationMissMessage,
    required this.notificationNtdExpiredPin,
    required this.notificationNtdExpiredRecruit,
    required this.notificationNtdPoint,
    required this.notificationSendCandidate,
    required this.notificationTag,
    required this.removeSugges,
    required this.userNameNoVn,
    required this.doubleVerify,
    required this.active,
    required this.status,
    required this.acceptMessStranger,
    required this.historyAccess,
  });
  factory ConfigChat.fromJson(Map<String, dynamic> json) => ConfigChat(
    notificationAcceptOffer: json["notificationAcceptOffer"],
    notificationAllocationRecall: json["notificationAllocationRecall"],
    notificationChangeSalary: json["notificationChangeSalary"],
    notificationCommentFromRaoNhanh: json["notificationCommentFromRaoNhanh"],
    notificationCommentFromTimViec: json["notificationCommentFromTimViec"],
    notificationDecilineOffer: json["notificationDecilineOffer"],
    notificationMissMessage: json["notificationMissMessage"],
    notificationNtdExpiredPin: json["notificationNTDExpiredPin"],
    notificationNtdExpiredRecruit: json["notificationNTDExpiredRecruit"],
    notificationNtdPoint: json["notificationNTDPoint"],
    notificationSendCandidate: json["notificationSendCandidate"],
    notificationTag: json["notificationTag"],
    removeSugges: List<dynamic>.from(json["removeSugges"].map((x) => x)),
    userNameNoVn: json["userNameNoVn"],
    doubleVerify: json["doubleVerify"],
    active: json["active"],
    status: json["status"],
    acceptMessStranger: json["acceptMessStranger"],
    historyAccess: List<HistoryAccess>.from(json["HistoryAccess"].map((x) => HistoryAccess.fromJson(x))),
  );
}

class HistoryAccess {
  final String idDevice;
  final String ipAddress;
  final String nameDevice;
  final DateTime time;
  final bool accessPermision;
  final String id;

  HistoryAccess({
    required this.idDevice,
    required this.ipAddress,
    required this.nameDevice,
    required this.time,
    required this.accessPermision,
    required this.id,
  });

  factory HistoryAccess.fromJson(Map<String, dynamic> json) => HistoryAccess(
    idDevice: json["IdDevice"],
    ipAddress: json["IpAddress"],
    nameDevice: json["NameDevice"],
    time: DateTime.parse(json["Time"]),
    accessPermision: json["AccessPermision"],
    id: json["_id"],
  );
}

class InForCompany {
  final Timviec365 timviec365;
  final Cds cds;
  final int scan;
  final int uscKd;
  final int uscKdFirst;
  final dynamic description;
  final int comSize;
  final String id;

  InForCompany({
    required this.timviec365,
    required this.cds,
    required this.scan,
    required this.uscKd,
    required this.uscKdFirst,
    required this.description,
    required this.comSize,
    required this.id,
  });

  factory InForCompany.fromJson(Map<String, dynamic> json) => InForCompany(
    timviec365: Timviec365.fromJson(json["timviec365"]),
    cds: Cds.fromJson(json["cds"]),
    scan: json["scan"],
    uscKd: json["usc_kd"],
    uscKdFirst: json["usc_kd_first"],
    description: json["description"],
    comSize: json["com_size"],
    id: json["_id"],
  );
}

class Cds {
  final dynamic comParentId;
  final String typeTimekeeping;
  final String idWayTimekeeping;
  final int comRoleId;
  final dynamic comQrLogo;
  final int enableScanQr;
  final int comVip;
  final int comEpVip;
  final int comVipTime;
  final int epCrm;
  final int epStt;

  Cds({
    required this.comParentId,
    required this.typeTimekeeping,
    required this.idWayTimekeeping,
    required this.comRoleId,
    required this.comQrLogo,
    required this.enableScanQr,
    required this.comVip,
    required this.comEpVip,
    required this.comVipTime,
    required this.epCrm,
    required this.epStt,
  });
  factory Cds.fromJson(Map<String, dynamic> json) => Cds(
    comParentId: json["com_parent_id"],
    typeTimekeeping: json["type_timekeeping"],
    idWayTimekeeping: json["id_way_timekeeping"],
    comRoleId: json["com_role_id"],
    comQrLogo: json["com_qr_logo"],
    enableScanQr: json["enable_scan_qr"],
    comVip: json["com_vip"],
    comEpVip: json["com_ep_vip"],
    comVipTime: json["com_vip_time"],
    epCrm: json["ep_crm"],
    epStt: json["ep_stt"],
  );

}

class Timviec365 {
  final dynamic uscName;
  final dynamic uscNameAdd;
  final dynamic uscNamePhone;
  final dynamic uscNameEmail;
  final int uscUpdateNew;
  final dynamic uscCanonical;
  final dynamic uscMd5;
  final int uscType;
  final int uscSize;
  final dynamic uscWebsite;
  final int uscViewCount;
  final int uscActive;
  final int uscShow;
  final int uscMail;
  final int uscStopMail;
  final int uscUtl;
  final int uscSsl;
  final dynamic uscMst;
  final dynamic uscSecurity;
  final dynamic uscIp;
  final int uscLoc;
  final int uscMailApp;
  final dynamic uscVideo;
  final int uscVideoType;
  final int uscVideoActive;
  final int uscBlockAccount;
  final int uscStopNoti;
  final int otpTimeExist;
  final int useTest;
  final int uscBadge;
  final int uscStar;
  final int uscVip;
  final dynamic uscManager;
  final dynamic uscLicense;
  final int uscActiveLicense;
  final dynamic uscMap;
  final dynamic uscDgc;
  final dynamic uscDgtv;
  final int uscDgTime;
  final dynamic uscSkype;
  final dynamic uscVideoCom;
  final dynamic uscLv;
  final dynamic uscZalo;
  final int uscCc365;
  final int uscCrm;
  final dynamic uscImages;
  final int uscActiveImg;
  final int uscFoundedTime;
  final List<dynamic> uscBranches;

  Timviec365({
    required this.uscName,
    required this.uscNameAdd,
    required this.uscNamePhone,
    required this.uscNameEmail,
    required this.uscUpdateNew,
    required this.uscCanonical,
    required this.uscMd5,
    required this.uscType,
    required this.uscSize,
    required this.uscWebsite,
    required this.uscViewCount,
    required this.uscActive,
    required this.uscShow,
    required this.uscMail,
    required this.uscStopMail,
    required this.uscUtl,
    required this.uscSsl,
    required this.uscMst,
    required this.uscSecurity,
    required this.uscIp,
    required this.uscLoc,
    required this.uscMailApp,
    required this.uscVideo,
    required this.uscVideoType,
    required this.uscVideoActive,
    required this.uscBlockAccount,
    required this.uscStopNoti,
    required this.otpTimeExist,
    required this.useTest,
    required this.uscBadge,
    required this.uscStar,
    required this.uscVip,
    required this.uscManager,
    required this.uscLicense,
    required this.uscActiveLicense,
    required this.uscMap,
    required this.uscDgc,
    required this.uscDgtv,
    required this.uscDgTime,
    required this.uscSkype,
    required this.uscVideoCom,
    required this.uscLv,
    required this.uscZalo,
    required this.uscCc365,
    required this.uscCrm,
    required this.uscImages,
    required this.uscActiveImg,
    required this.uscFoundedTime,
    required this.uscBranches,
  });

  factory Timviec365.fromJson(Map<String, dynamic> json) => Timviec365(
    uscName: json["usc_name"],
    uscNameAdd: json["usc_name_add"],
    uscNamePhone: json["usc_name_phone"],
    uscNameEmail: json["usc_name_email"],
    uscUpdateNew: json["usc_update_new"],
    uscCanonical: json["usc_canonical"],
    uscMd5: json["usc_md5"],
    uscType: json["usc_type"],
    uscSize: json["usc_size"],
    uscWebsite: json["usc_website"],
    uscViewCount: json["usc_view_count"],
    uscActive: json["usc_active"],
    uscShow: json["usc_show"],
    uscMail: json["usc_mail"],
    uscStopMail: json["usc_stop_mail"],
    uscUtl: json["usc_utl"],
    uscSsl: json["usc_ssl"],
    uscMst: json["usc_mst"],
    uscSecurity: json["usc_security"],
    uscIp: json["usc_ip"],
    uscLoc: json["usc_loc"],
    uscMailApp: json["usc_mail_app"],
    uscVideo: json["usc_video"],
    uscVideoType: json["usc_video_type"],
    uscVideoActive: json["usc_video_active"],
    uscBlockAccount: json["usc_block_account"],
    uscStopNoti: json["usc_stop_noti"],
    otpTimeExist: json["otp_time_exist"],
    useTest: json["use_test"],
    uscBadge: json["usc_badge"],
    uscStar: json["usc_star"],
    uscVip: json["usc_vip"],
    uscManager: json["usc_manager"],
    uscLicense: json["usc_license"],
    uscActiveLicense: json["usc_active_license"],
    uscMap: json["usc_map"],
    uscDgc: json["usc_dgc"],
    uscDgtv: json["usc_dgtv"],
    uscDgTime: json["usc_dg_time"],
    uscSkype: json["usc_skype"],
    uscVideoCom: json["usc_video_com"],
    uscLv: json["usc_lv"],
    uscZalo: json["usc_zalo"],
    uscCc365: json["usc_cc365"],
    uscCrm: json["usc_crm"],
    uscImages: json["usc_images"],
    uscActiveImg: json["usc_active_img"],
    uscFoundedTime: json["usc_founded_time"],
    uscBranches: List<dynamic>.from(json["usc_branches"].map((x) => x)),
  );
}
