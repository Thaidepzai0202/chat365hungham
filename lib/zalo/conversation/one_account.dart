import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/zalo/features_zalo/add_friend_zalo/add_friend_zalo_screen.dart';
import 'package:app_chat365_pc/zalo/features_zalo/send_message/send_message_to_stranger_screen.dart';
import 'package:app_chat365_pc/zalo/models/conversation_item_model.dart';
import 'package:app_chat365_pc/zalo/models/friend_zalo_model.dart';
import 'package:app_chat365_pc/zalo/models/user_model_zalo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OneAccountZaloScreen extends StatefulWidget {
  UserInfoZalo userInfoZalo;
  List<ConversationItemZaloModel> listConversationZalo = [];
  List<FriendZalo> listFriendZalo=[];

  OneAccountZaloScreen({super.key,
    required this.listConversationZalo,
    required this.listFriendZalo,
    required this.userInfoZalo
  });

  @override
  State<OneAccountZaloScreen> createState() => _OneAccountZaloScreenState();
}

class _OneAccountZaloScreenState extends State<OneAccountZaloScreen> {
  ValueNotifier<bool> isSearch = ValueNotifier(false);
  ValueNotifier<bool> isStranger = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isStranger,
      builder: (context, value, child) => ValueListenableBuilder(
        valueListenable: isSearch,
        builder: (context, value, child) => ValueListenableBuilder(
            valueListenable: changeTheme,
            builder: (context, value, child) => Container(
                height: isSearch.value ? 614 : 314,
                width: 326,
                color: context.theme.backgroundListChat,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        profileChatZalo(),
                        const Spacer(),
                        search(),
                        const SizedBox(width: 10)
                      ],
                    ),
                    isSearch.value ? listFriend() : const SizedBox(),
                    Row(
                      children: [
                        features(),
                        const Spacer(),
                        stranger(),
                        const SizedBox(width: 10)
                      ],
                    ),

                    //ListConversation
                    listConversation(),
                  ],
                ))),
      ),
    );
  }

  listConversation() {
    return Container(
      height: 200,
      width: 322,
      child: ListView.builder(
        itemCount: widget.listConversationZalo.length,
        itemBuilder: (context, index) {
          return Container(
              height: 60,
              width: 322,
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    padding: EdgeInsets.all(6),
                    child: CircleAvatar(
                      backgroundColor: context.theme.backgroundListChat,
                      backgroundImage: NetworkImage(
                          widget.listConversationZalo[index].ava),
                    ),
                  ),
                  SizedBox(
                    width: 322 - 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 180,
                              child: Text(
                                widget.listConversationZalo[index].name,
                                style: TextStyle(
                                  wordSpacing: -2,
                                  height: 20 / 18,
                                  color: context.theme.text1Color,
                                  fontWeight: widget.listConversationZalo
                                              [index].unread ==
                                          true
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            Spacer(),
                            Text(
                              widget.listConversationZalo[index].timeMess,
                              style: TextStyle(
                                  color: context.theme.hitnTextColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              width: 12,
                            )
                          ],
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 240,
                          child: Text(
                            widget.listConversationZalo[index].lastMess,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(context,
                                widget.listConversationZalo[index].unread),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ));
        },
      ),
    );
  }

  TextStyle getTextStyle(BuildContext context, bool isConversationRead) {
    return context.theme.messageTextStyle.copyWith(
        fontWeight: FontWeight.w500,
        color: isConversationRead
            ? context.theme.text2Color
            : context.theme.hitnTextColor,
        fontSize: 13.25,
        letterSpacing: -0.15,
        wordSpacing: -0.75);
  }

  features() {
    return Container(
        height: 40,
        width: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            featuresChild(Images.add_person, () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddFriendZaloScreen();
                },
              );
            }),
            featuresChild(Images.ic_messages3, () {
              showDialog(
                context: context,
                builder: (context) {
                  return SendMessageToStranger();
                },
              );
            }),
            featuresChild(AssetPath.contact, () => null),
            featuresChild(Images.ic_reFresh, () => null),
            featuresChild(Images.ic_message_time, () => null),
          ],
        ));
  }

  featuresChild(String path, Function() ontap) {
    return InkWell(
      onTap: ontap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
            child: SvgPicture.asset(
          path,
          color: context.theme.text2Color,
        )),
      ),
    );
  }

  profileChatZalo() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: context.theme.text2Color),
                shape: BoxShape.circle),
            width: 50,
            height: 50,
            child: CircleAvatar(
                backgroundImage: NetworkImage(widget.userInfoZalo.ava)),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            widget.userInfoZalo.name,
            style: AppTextStyles.nameProfile(context).copyWith(fontSize: 17),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  search() {
    return InkWell(
      onTap: () {
        isSearch.value = !isSearch.value;
      },
      child: Container(
        width: 94,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: context.theme.colorPirimaryNoDarkLight, width: 1.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 6,
            ),
            SvgPicture.asset(
              isSearch.value ? Images.ic_drop_right : Images.ic_ep_search,
              color: context.theme.colorPirimaryNoDarkLight,
              width: 18,
              height: 18,
            ),
            Spacer(),
            Text(
              isSearch.value ? 'Quay lại ' : 'Bạn bè',
              style: TextStyle(color: context.theme.colorPirimaryNoDarkLight),
            ),
            SizedBox(
              width: 6,
            )
          ],
        ),
      ),
    );
  }

  stranger() {
    return InkWell(
      onTap: () {
        isStranger.value = !isStranger.value;
      },
      child: Container(
        width: 94,
        height: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: context.theme.colorPirimaryNoDarkLight, width: 1.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 6,
            ),
            SvgPicture.asset(
              isStranger.value
                  ? Images.ic_drop_right
                  : AssetPath.drop_button_down,
              color: context.theme.colorPirimaryNoDarkLight,
              width: 18,
              height: 18,
            ),
            Spacer(),
            Text(
              isStranger.value ? 'Quay lại' : 'Người lạ',
              style: TextStyle(color: context.theme.colorPirimaryNoDarkLight),
            ),
            SizedBox(
              width: 6,
            )
          ],
        ),
      ),
    );
  }

  listFriend() {
    return Container(
      height: 300,
      width: 326,
      child: ListView.builder(
          itemCount: widget.listFriendZalo.length,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.only(top: 4, bottom: 4, left: 16),
              width: 326,
              height: 50,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 0.5, color: context.theme.text3Color)),
                    child: CircleAvatar(
                        backgroundColor: context.theme.backgroundListChat,
                        backgroundImage: NetworkImage(widget.listFriendZalo[index]
                                    .ava !=
                                ''
                            ? widget.listFriendZalo[index].ava
                            : 'https://as2.ftcdn.net/v2/jpg/03/31/69/91/1000_F_331699188_lRpvqxO5QRtwOM05gR50ImaaJgBx68vi.jpg')),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.listFriendZalo[index].name,
                    style: TextStyle(
                        color: context.theme.colorTextNameProfile,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            );
          }),
    );
  }
}
