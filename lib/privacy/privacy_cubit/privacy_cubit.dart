import 'dart:convert';

import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/privacy/models/privacy_model.dart';
import 'package:app_chat365_pc/privacy/privacy_repo/privacy_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'privacy_state.dart';

class PrivacyCubit {
  PrivacyCubit(this.userId)
      : privacyRepo = PrivacyRepo(),
        super() {}
  final PrivacyRepo privacyRepo;
  final int userId;
  int? seenMessage;
  PrivacyModel? privacyModel;
  // lấy thông tin quyền riêng tư
  Future<PrivacyModel> GetPrivacy() async {
    var res = await privacyRepo.GetPrivacy(idUser: userId);
    return res.onCallBack(
        (_) => PrivacyModel.fromJson(json.decode(res.data)['data']['data']));
  }

  // lấy danh sách thông tin tài khoản đã đăng nhập trên thiết bị này
  Future<List<IUserInfo>> GetAccountsByDevice() async {
    var res = await privacyRepo.GetAccountsByDevice(idUser: userId);
    if (res.hasError) return [];
    return (json.decode(res.data)['data']['listUser'] as List)
        .map((e) => IUserInfo.fromJson(e))
        .toList();
  }

  late ValueNotifier<bool> isblock = ValueNotifier<bool>(false);
  ValueNotifier<int>? showPost;
  //hiện ngày sinh
  changeShowDateOfBirth({
    required int status,
  }) {
    return privacyRepo.changeShowDateOfBirth(
        showDateOfBirth: status, idUser: userId);
  }

  // ai được nhắn tin cho bạn
  changeChat({
    required int chat,
  }) {
    return privacyRepo.changeChat(userId, chat);
  }

  // ai được gọi điện cho bạn
  changeCall({
    required int chat,
  }) {
    return privacyRepo.changeCall(userId, chat);
  }

  // bật tắt hiển thị trạng thái đã xem
  changeSeenMessage({
    required int status,
  }) {
    return privacyRepo.changeSeenMessage(userId, status);
  }

  // hiển trị trạng thái truy cập
  changestatusOnline({
    required int status,
  }) {
    return privacyRepo.changestatusOnline(userId, status);
  }

  // chặn tin nhắn
  blockMessage(int userBlocked) {
    return privacyRepo.blockMessage(userId, userBlocked);
  }

  // bỏ chặn tin nhắn
  unblockMessage(int userBlocked) {
    return privacyRepo.unblockMessage(userId, userBlocked);
  }

  // check 2 người có chặn nhau không
  Future<bool> checkBlockMessage(int userIdCheckBlock) async {
    var res = await privacyRepo.checkBlockMessage(userId, userIdCheckBlock);
    isblock.value = res;
    return res;
  }

  changeShowPost(String changeShowPost) {
    return privacyRepo.changeShowPost(userId, changeShowPost);
  }

  searchSource({
    int? searchByPhone,
    int? qrCode,
    int? generalGroup,
    int? businessCard,
    int? suggest,
  }) {
    SearchSource? searchSource = privacyModel?.searchSource;
    privacyRepo.searchSource(
        userId,
        searchByPhone ?? searchSource?.searchByPhone,
        qrCode ?? searchSource?.qrCode,
        generalGroup ?? searchSource?.generalGroup,
        businessCard ?? searchSource?.businessCard,
        suggest ?? searchSource?.suggest);
  }
}
