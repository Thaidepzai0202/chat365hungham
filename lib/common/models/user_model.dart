// class ListUser {
//   final int id;
//   final String? email;
//   final String phoneTk;
//   final String userName;
//   final dynamic alias;
//   final String? phone;
//   final String? emailContact;
//   final AvatarUser? avatarUser;
//   final int type;
//   final int? city;
//   final int? district;
//   final String address;
//   final String? otp;
//   final int authentic;
//   final int isOnline;
//   final String fromWeb;
//   final num fromDevice;
//   final num createdAt;
//   final num updatedAt;
//   final DateTime? lastActivedAt;
//   final int timeLogin;
//   final int role;
//   final String? latitude;
//   final String? longtitude;
//   final int idQlc;
//   final int idTimViec365;
//   final int idRaoNhanh365;
//   final String chat365Secret;
//   final List<dynamic> sharePermissionId;
//   final InForPerson inForPerson;
//   final dynamic inForCompany;
//   final dynamic inforRn365;
//   final int scan;
//   final List<Department> department;
//   final List<Contract> contract;
//   final List<Salary> salary;
//   final int? chat365Id;
//   final int? scanBase365;
//   final int? checkChat;
//   final bool? emotionActive;
//   final int? idGiaSu;
//   final int? idVltg;
//   final InforVltg? inforVltg;
//   final int? phanTramHopDong;
//   final int? luongCoBan;
//   final String? infoPosition;
//
//   ListUser({
//     required this.id,
//     required this.email,
//     required this.phoneTk,
//     required this.userName,
//     required this.alias,
//     required this.phone,
//     required this.emailContact,
//     required this.avatarUser,
//     required this.type,
//     required this.city,
//     required this.district,
//     required this.address,
//     required this.otp,
//     required this.authentic,
//     required this.isOnline,
//     required this.fromWeb,
//     required this.fromDevice,
//     required this.createdAt,
//     required this.updatedAt,
//      this.lastActivedAt,
//     required this.timeLogin,
//     required this.role,
//     required this.latitude,
//     required this.longtitude,
//     required this.idQlc,
//     required this.idTimViec365,
//     required this.idRaoNhanh365,
//     required this.chat365Secret,
//     required this.sharePermissionId,
//     required this.inForPerson,
//     required this.inForCompany,
//     required this.inforRn365,
//     required this.scan,
//     required this.department,
//     required this.contract,
//     required this.salary,
//     this.chat365Id,
//     this.scanBase365,
//     this.checkChat,
//     this.emotionActive,
//     this.idGiaSu,
//     this.idVltg,
//     this.inforVltg,
//     this.phanTramHopDong,
//     this.luongCoBan,
//     this.infoPosition,
//   });
//
//
//   factory ListUser.fromJson(Map<String, dynamic> json) => ListUser(
//     id: json["_id"],
//     email: json["email"],
//     phoneTk: json["phoneTK"]??'',
//     userName: json["userName"],
//     alias: json["alias"],
//     phone: json["phone"],
//     emailContact: json["emailContact"],
//     avatarUser:json["avatarUser"] == null ? null : avatarUserValues.map[json["avatarUser"]],
//     type: json["type"],
//     city: json["city"],
//     district: json["district"],
//     address: json["address"]??'',
//     otp: json["otp"],
//     authentic: json["authentic"],
//     isOnline: json["isOnline"],
//     fromWeb: json["fromWeb"]??'',
//     fromDevice: json["fromDevice"],
//     createdAt: json["createdAt"],
//     updatedAt: json["updatedAt"],
//     lastActivedAt: json["lastActivedAt"] == null ? null : DateTime.parse(json["lastActivedAt"]),
//     timeLogin: json["time_login"],
//     role: json["role"],
//     latitude: json["latitude"],
//     longtitude: json["longtitude"],
//     idQlc: json["idQLC"],
//     idTimViec365: json["idTimViec365"],
//     idRaoNhanh365: json["idRaoNhanh365"],
//     chat365Secret: json["chat365_secret"],
//     sharePermissionId: List<dynamic>.from(json["sharePermissionId"].map((x) => x)),
//     inForPerson: InForPerson.fromJson(json["inForPerson"]),
//     inForCompany: json["inForCompany"],
//     inforRn365: json["inforRN365"],
//     scan: json["scan"]??0,
//     // department: List<Department>.from(json["department"].map((x) => Department.fromJson(x))),
//     contract: List<Contract>.from(json["contract"].map((x) => Contract.fromJson(x))),
//     salary: List<Salary>.from(json["salary"].map((x) => Salary.fromJson(x))),
//     chat365Id: json["chat365_id"],
//     scanBase365: json["scan_base365"],
//     checkChat: json["check_chat"],
//     emotionActive: json["emotion_active"],
//     idGiaSu: json["idGiaSu"],
//     idVltg: json["idVLTG"],
//     inforVltg: json["inforVLTG"] == null ? null : InforVltg.fromJson(json["inforVLTG"]),
//     phanTramHopDong: json["phan_tram_hop_dong"],
//     luongCoBan: json["luong_co_ban"],
//     infoPosition: json["info_position"],
//   );
//
//
// }
//
// enum AvatarUser {
//   EMPTY,
//   EP284670_APP_ARTBOARD_3900_PNG
// }
//
// final avatarUserValues = EnumValues({
//   "": AvatarUser.EMPTY,
//   "ep284670/app_Artboard 3900.png": AvatarUser.EP284670_APP_ARTBOARD_3900_PNG
// });
//
// class Contract {
//   final String id;
//   final int conId;
//   final int conIdUser;
//   final String conName;
//   final DateTime conTimeUp;
//   final DateTime conTimeEnd;
//   final String conFile;
//   final String conSalaryPersent;
//   final DateTime conTimeCreated;
//
//   Contract({
//     required this.id,
//     required this.conId,
//     required this.conIdUser,
//     required this.conName,
//     required this.conTimeUp,
//     required this.conTimeEnd,
//     required this.conFile,
//     required this.conSalaryPersent,
//     required this.conTimeCreated,
//   });
//
//
//
//   factory Contract.fromJson(Map<String, dynamic> json) => Contract(
//     id: json["_id"],
//     conId: json["con_id"],
//     conIdUser: json["con_id_user"],
//     conName: json["con_name"],
//     conTimeUp: DateTime.parse(json["con_time_up"]),
//     conTimeEnd: DateTime.parse(json["con_time_end"]),
//     conFile: json["con_file"],
//     conSalaryPersent: json["con_salary_persent"].toString(),
//     conTimeCreated: DateTime.parse(json["con_time_created"]),
//   );
//
//
// }
//
// class Department {
//   final String id;
//   final int depId;
//   final int comId;
//   final String depName;
//   final DateTime depCreateTime;
//   final int? managerId;
//   final int depOrder;
//
//   Department({
//     required this.id,
//     required this.depId,
//     required this.comId,
//     required this.depName,
//     required this.depCreateTime,
//     required this.managerId,
//     required this.depOrder,
//   });
//
//
//
//   factory Department.fromJson(Map<String, dynamic> json) => Department(
//     id: json["_id"],
//     depId: json["dep_id"],
//     comId: json["com_id"],
//     depName: json["dep_name"],
//     depCreateTime: DateTime.parse(json["dep_create_time"]),
//     managerId: json["manager_id"],
//     depOrder: json["dep_order"],
//   );
//
//
// }
//
// enum FromWeb {
//   CC365,
//   CHAT365,
//   QUANLYCHUNG,
//   TIMVIEC365,
//   TV365
// }
//
// final fromWebValues = EnumValues({
//   "cc365": FromWeb.CC365,
//   "chat365": FromWeb.CHAT365,
//   "quanlychung": FromWeb.QUANLYCHUNG,
//   "timviec365": FromWeb.TIMVIEC365,
//   "tv365": FromWeb.TV365
// });
//
// class InForPerson {
//   final int scan;
//   final Account account;
//   final Employee employee;
//   final Candidate? candidate;
//   final String id;
//
//   InForPerson({
//     required this.scan,
//     required this.account,
//     required this.employee,
//     required this.candidate,
//     required this.id,
//   });
//
//
//   factory InForPerson.fromJson(Map<String, dynamic> json) => InForPerson(
//     scan: json["scan"],
//     account: Account.fromJson(json["account"]),
//     employee: Employee.fromJson(json["employee"]),
//     candidate: json["candidate"] == null ? null : Candidate.fromJson(json["candidate"]),
//     id: json["_id"],
//   );
//
// }
//
// class Account {
//   final dynamic birthday;
//   final int gender;
//   final int married;
//   final int? experience;
//   final int? education;
//   final String id;
//
//   Account({
//     required this.birthday,
//     required this.gender,
//     required this.married,
//     required this.experience,
//     required this.education,
//     required this.id,
//   });
//
//
//
//   factory Account.fromJson(Map<String, dynamic> json) => Account(
//     birthday: json["birthday"] == null ? null : json["birthday"],
//     gender: json["gender"],
//     married: json["married"],
//     experience: json["experience"],
//     education: json["education"],
//     id: json["_id"],
//   );
//
//
// }
//
// class Candidate {
//   final int useType;
//   final int userResetTime;
//   final int useView;
//   final int useNoti;
//   final int useShow;
//   final int useShowCv;
//   final int useActive;
//   final int useTd;
//   final int useCheck;
//   final int useTest;
//   final int pointTimeActive;
//   final String cvTitle;
//   final String? cvMuctieu;
//   final List<int> cvCityId;
//   final List<int> cvCateId;
//   final int cvCapbacId;
//   final int cvMoneyId;
//   final int cvLoaihinhId;
//   final int cvTime;
//   final int cvTimeDl;
//   final String? cvKynang;
//   final int? umType;
//   final dynamic umMinValue;
//   final dynamic umMaxValue;
//   final int? umUnit;
//   final String? cvTcName;
//   final String? cvTcCv;
//   final String? cvTcDc;
//   final String? cvTcPhone;
//   final String? cvTcEmail;
//   final String? cvTcCompany;
//   final String? cvVideo;
//   final int cvVideoType;
//   final int cvVideoActive;
//   final String? useIp;
//   final int? timeSendVl;
//   final int percents;
//   final int vip;
//   final int checkCreateUsc;
//   final int empId;
//   final String id;
//   final List<dynamic> profileDegree;
//   final List<dynamic> profileNgoaiNgu;
//   final List<dynamic> profileExperience;
//   final int scanAudio;
//   final int? useBadge;
//   final dynamic cvGiaiThuong;
//   final dynamic cvHoatDong;
//   final dynamic cvSoThich;
//
//   Candidate({
//     required this.useType,
//     required this.userResetTime,
//     required this.useView,
//     required this.useNoti,
//     required this.useShow,
//     required this.useShowCv,
//     required this.useActive,
//     required this.useTd,
//     required this.useCheck,
//     required this.useTest,
//     required this.pointTimeActive,
//     required this.cvTitle,
//     required this.cvMuctieu,
//     required this.cvCityId,
//     required this.cvCateId,
//     required this.cvCapbacId,
//     required this.cvMoneyId,
//     required this.cvLoaihinhId,
//     required this.cvTime,
//     required this.cvTimeDl,
//     required this.cvKynang,
//     required this.umType,
//     required this.umMinValue,
//     required this.umMaxValue,
//     required this.umUnit,
//     required this.cvTcName,
//     required this.cvTcCv,
//     required this.cvTcDc,
//     required this.cvTcPhone,
//     required this.cvTcEmail,
//     required this.cvTcCompany,
//     required this.cvVideo,
//     required this.cvVideoType,
//     required this.cvVideoActive,
//     required this.useIp,
//     this.timeSendVl,
//     required this.percents,
//     required this.vip,
//     required this.checkCreateUsc,
//     required this.empId,
//     required this.id,
//     required this.profileDegree,
//     required this.profileNgoaiNgu,
//     required this.profileExperience,
//     required this.scanAudio,
//     this.useBadge,
//     this.cvGiaiThuong,
//     this.cvHoatDong,
//     this.cvSoThich,
//   });
//
//
//
//   factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
//     useType: json["use_type"],
//     userResetTime: json["user_reset_time"],
//     useView: json["use_view"],
//     useNoti: json["use_noti"],
//     useShow: json["use_show"],
//     useShowCv: json["use_show_cv"],
//     useActive: json["use_active"],
//     useTd: json["use_td"],
//     useCheck: json["use_check"],
//     useTest: json["use_test"],
//     pointTimeActive: json["point_time_active"],
//     cvTitle: json["cv_title"] ?? '',
//     cvMuctieu: json["cv_muctieu"],
//     cvCityId: List<int>.from(json["cv_city_id"].map((x) => x)),
//     cvCateId: List<int>.from(json["cv_cate_id"].map((x) => x)),
//     cvCapbacId: json["cv_capbac_id"],
//     cvMoneyId: json["cv_money_id"],
//     cvLoaihinhId: json["cv_loaihinh_id"],
//     cvTime: json["cv_time"],
//     cvTimeDl: json["cv_time_dl"],
//     cvKynang: json["cv_kynang"],
//     umType: json["um_type"],
//     umMinValue: json["um_min_value"],
//     umMaxValue: json["um_max_value"],
//     umUnit: json["um_unit"],
//     cvTcName: json["cv_tc_name"],
//     cvTcCv: json["cv_tc_cv"],
//     cvTcDc: json["cv_tc_dc"],
//     cvTcPhone: json["cv_tc_phone"],
//     cvTcEmail: json["cv_tc_email"],
//     cvTcCompany: json["cv_tc_company"],
//     cvVideo: json["cv_video"],
//     cvVideoType: json["cv_video_type"],
//     cvVideoActive: json["cv_video_active"],
//     useIp: json["use_ip"],
//     timeSendVl: json["time_send_vl"],
//     percents: json["percents"].toInt(),
//     vip: json["vip"],
//     checkCreateUsc: json["check_create_usc"]??0,
//     empId: json["emp_id"],
//     id: json["_id"],
//     profileDegree: List<dynamic>.from(json["profileDegree"].map((x) => x)),
//     profileNgoaiNgu: List<dynamic>.from(json["profileNgoaiNgu"].map((x) => x)),
//     profileExperience: List<dynamic>.from(json["profileExperience"].map((x) => x)),
//     scanAudio: json["scan_audio"],
//     useBadge: json["use_badge"],
//     cvGiaiThuong: json["cv_giai_thuong"],
//     cvHoatDong: json["cv_hoat_dong"],
//     cvSoThich: json["cv_so_thich"],
//   );
//
//
// }
//
// enum CvTitle {
//   EMPTY,
//   NHN_VIN_LI_XE_BNG_D
// }
//
// final cvTitleValues = EnumValues({
//   "": CvTitle.EMPTY,
//   "Nhân viên lái xe bằng D": CvTitle.NHN_VIN_LI_XE_BNG_D
// });
//
// class Employee {
//   final int comId;
//   final int depId;
//   final dynamic startWorkingTime;
//   final int? positionId;
//   final int? teamId;
//   final int? groupId;
//   final int? timeQuitJob;
//   final EpDescription? epDescription;
//   final EpStatus epStatus;
//   final int epSignature;
//   final int allowUpdateFace;
//   final int versionInUse;
//   final String id;
//   final List<ListOrganizeDetailId>? listOrganizeDetailId;
//   final int? organizeDetailId;
//   final int? roleId;
//
//   Employee({
//     required this.comId,
//     required this.depId,
//     required this.startWorkingTime,
//     this.positionId,
//     required this.teamId,
//     required this.groupId,
//     required this.timeQuitJob,
//     required this.epDescription,
//     required this.epStatus,
//     required this.epSignature,
//     required this.allowUpdateFace,
//     required this.versionInUse,
//     required this.id,
//     this.listOrganizeDetailId,
//     this.organizeDetailId,
//     this.roleId,
//   });
//
//
//   factory Employee.fromJson(Map<String, dynamic> json) => Employee(
//     comId: json["com_id"],
//     depId: json["dep_id"],
//     startWorkingTime: json["start_working_time"] == null ? null : json["start_working_time"],
//     positionId: json["position_id"],
//     teamId: json["team_id"],
//     groupId: json["group_id"],
//     timeQuitJob: json["time_quit_job"],
//     epDescription:json["ep_description"] == null ? null : epDescriptionValues.map[json["ep_description"]],
//     epStatus: epStatusValues.map[json["ep_status"]]!,
//     epSignature: json["ep_signature"],
//     allowUpdateFace: json["allow_update_face"],
//     versionInUse: json["version_in_use"],
//     id: json["_id"],
//     listOrganizeDetailId: json["listOrganizeDetailId"] == null ? [] : List<ListOrganizeDetailId>.from(json["listOrganizeDetailId"]!.map((x) => ListOrganizeDetailId.fromJson(x))),
//     organizeDetailId: json["organizeDetailId"],
//     roleId: json["role_id"],
//   );
//
//
// }
//
// enum EpDescription {
//   EMPTY,
//   FAFAFAF
// }
//
// final epDescriptionValues = EnumValues({
//   "": EpDescription.EMPTY,
//   "fafafaf": EpDescription.FAFAFAF
// });
//
// enum EpStatus {
//   ACTIVE,
//   DENY,
//   PENDING
// }
//
// final epStatusValues = EnumValues({
//   "Active": EpStatus.ACTIVE,
//   "Deny": EpStatus.DENY,
//   "Pending": EpStatus.PENDING
// });
//
// class ListOrganizeDetailId {
//   final int level;
//   final int organizeDetailId;
//
//   ListOrganizeDetailId({
//     required this.level,
//     required this.organizeDetailId,
//   });
//
//
//   factory ListOrganizeDetailId.fromJson(Map<String, dynamic> json) => ListOrganizeDetailId(
//     level: json["level"],
//     organizeDetailId: json["organizeDetailId"],
//   );
//
//
// }
//
// class InforVltg {
//   final dynamic uvDay;
//   final int luotXem;
//
//   InforVltg({
//     required this.uvDay,
//     required this.luotXem,
//   });
//
//
//   factory InforVltg.fromJson(Map<String, dynamic> json) => InforVltg(
//     uvDay: json["uv_day"],
//     luotXem: json["luot_xem"],
//   );
//
//
// }
//
// class Salary {
//   final String id;
//   final int sbId;
//   final int sbIdUser;
//   final int sbIdCom;
//   final int sbSalaryBasic;
//   final int sbSalaryBh;
//   final int sbPcBh;
//   final DateTime sbTimeUp;
//   final int sbLocation;
//   final String sbLydo;
//   final String sbQuyetdinh;
//   final int sbFirst;
//   final DateTime sbTimeCreated;
//   final int? sbType;
//
//   Salary({
//     required this.id,
//     required this.sbId,
//     required this.sbIdUser,
//     required this.sbIdCom,
//     required this.sbSalaryBasic,
//     required this.sbSalaryBh,
//     required this.sbPcBh,
//     required this.sbTimeUp,
//     required this.sbLocation,
//     required this.sbLydo,
//     required this.sbQuyetdinh,
//     required this.sbFirst,
//     required this.sbTimeCreated,
//     this.sbType,
//   });
//
//
//   factory Salary.fromJson(Map<String, dynamic> json) => Salary(
//     id: json["_id"],
//     sbId: json["sb_id"],
//     sbIdUser: json["sb_id_user"],
//     sbIdCom: json["sb_id_com"],
//     sbSalaryBasic: json["sb_salary_basic"],
//     sbSalaryBh: json["sb_salary_bh"],
//     sbPcBh: json["sb_pc_bh"],
//     sbTimeUp: DateTime.parse(json["sb_time_up"]),
//     sbLocation: json["sb_location"],
//     sbLydo: json["sb_lydo"],
//     sbQuyetdinh: json["sb_quyetdinh"],
//     sbFirst: json["sb_first"],
//     sbTimeCreated: DateTime.parse(json["sb_time_created"]),
//     sbType: json["sb_type"],
//   );
//
//
// }
//
// class EnumValues<T> {
//   Map<String, T> map;
//   late Map<T, String> reverseMap;
//
//   EnumValues(this.map);
//
//   Map<T, String> get reverse {
//     reverseMap = map.map((k, v) => MapEntry(v, k));
//     return reverseMap;
//   }
// }
