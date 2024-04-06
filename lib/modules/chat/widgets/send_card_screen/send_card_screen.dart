import 'package:app_chat365_pc/common/blocs/contact_cubit/user_contact_cubit.dart';
import 'package:app_chat365_pc/common/blocs/contact_cubit/user_contact_state.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/models/user_contact_model.dart';
import 'package:app_chat365_pc/core/constants/list_data.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/conversation_item.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../common/images.dart';
import '../../../../main.dart';

class SendCardScreen extends StatefulWidget {
  const SendCardScreen(
      {super.key, required this.conversationId, required this.onSend});

  final int conversationId;
  final ValueChanged<List<ApiMessageModel>> onSend;

  @override
  State<SendCardScreen> createState() => _SendCardScreenState();
}

class _SendCardScreenState extends State<SendCardScreen> {
  late UserContactCubit userContactCubit;

  final ValueNotifier<bool> isSelected = ValueNotifier(false);
  List<UserContactModel> filteredItems = [];

  // tìm kiếm
  void filterSearchResults(String query) {
    List<UserContactModel> listData = [];
    List<UserContactModel> searchResults = [];
    listData = List.from(userContactCubit.listUser);
    if (query.isNotEmpty) {
      // Lọc danh sách dựa trên query
      searchResults = listData.where((item) {
        final textNameLower = item.userName.toLowerCase();
        final queryLower = query.toLowerCase();

        // Chuẩn hóa chuỗi tiếng Việt bằng cách thay thế các ký tự có dấu thành ký tự không dấu
        final normalizedText = removeDiacritics(textNameLower);
        final normalizedQuery = removeDiacritics(queryLower);

        return normalizedText.contains(normalizedQuery);
      }).toList();
      filteredItems = searchResults;
      isSelected.value = !isSelected.value;
    }
  }

  @override
  void initState() {
    super.initState();
    userContactCubit = context.read<UserContactCubit>();
    userContactCubit.getUserCompanyRandom();
    userInfo = context.userInfo();
  }

  final diacriticCharacters = {
    'a': [
      'á',
      'à',
      'ả',
      'ã',
      'ạ',
      'ă',
      'ắ',
      'ằ',
      'ẳ',
      'ẵ',
      'ặ',
      'â',
      'ấ',
      'ầ',
      'ẩ',
      'ẫ',
      'ậ'
    ],
    'e': ['é', 'è', 'ẻ', 'ẽ', 'ẹ', 'ê', 'ế', 'ề', 'ể', 'ễ', 'ệ'],
    'i': ['í', 'ì', 'ỉ', 'ĩ', 'ị'],
    'o': [
      'ó',
      'ò',
      'ỏ',
      'õ',
      'ọ',
      'ô',
      'ố',
      'ồ',
      'ổ',
      'ỗ',
      'ộ',
      'ơ',
      'ớ',
      'ờ',
      'ở',
      'ỡ',
      'ợ'
    ],
    'u': ['ú', 'ù', 'ủ', 'ũ', 'ụ', 'ư', 'ứ', 'ừ', 'ử', 'ữ', 'ự'],
    'y': ['ý', 'ỳ', 'ỷ', 'ỹ', 'ỵ'],
    'd': ['đ']
  };

  String removeDiacritics(String input) {
    for (var key in diacriticCharacters.keys) {
      for (var char in diacriticCharacters[key]!) {
        input = input.replaceAll(char, key);
      }
    }
    return input;
  }

// xoa dau tieng viet

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: userContactCubit,
      builder: (context, state) {
        if (state is LoadedStateUserContact) {
          filteredItems = userContactCubit.listUser;
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: context.theme.backgroundColor
                // color: AppColors.blue,
                ),
            height: 600,
            width: 600,
            child: Column(children: [
              Container(
                height: 50,
                width: 600,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    gradient: context.theme.gradient),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SizedBox(
                    width: 228,
                  ),
                  Text(
                    AppLocalizations.of(context)?.shareContact ?? '',
                    style: AppTextStyles.text(context).copyWith(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  Expanded(child: SizedBox()),
                  InkWell(
                    onTap: () {
                      AppRouter.back(context);
                    },
                    child: SvgPicture.asset(
                      Images.ic_cancel,
                      color: AppColors.white,
                      height: 17,
                      width: 17,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  )
                ]),
              ),
              Container(
                height: 550,
                width: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        cursorRadius: Radius.circular(15),
                        onChanged: (value) {
                          if (value != '') {
                            filterSearchResults(value);
                            print('_______$value');
                          }
                        },
                        decoration: InputDecoration(
                          fillColor: context.theme.backgroundOnForward,
                          hintText: AppLocalizations.of(context)?.search ?? '',
                          hintStyle: AppTextStyles.hintGrey
                              .copyWith(color: context.theme.hitnTextColor),
                          contentPadding: EdgeInsets.symmetric(horizontal: 28),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: context.theme.backgroundOnForward,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(30)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: context.theme.backgroundOnForward,
                                  width: 1),
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        AppLocalizations.of(context)?.recommended ?? '',
                        style: AppTextStyles.text(context),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ValueListenableBuilder(
                      valueListenable: isSelected,
                      builder: (_, __, ___) => Expanded(
                          child: ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                var userItem = filteredItems[index];
                                return ContactUserWidget(
                                    userContactModel: userItem,
                                    conversationId: widget.conversationId,
                                    onSend: widget.onSend,
                                    context: context);
                              })),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: buttonBlue(
                          AppLocalizations.of(context)?.done ?? '', 100, () {
                        AppRouter.back(context);
                      }, context),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ]),
          );
        } else {
          return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: context.theme.backgroundColor,
              ),
              height: 600,
              width: 600,
              child: Center(
                child: CircularProgressIndicator(
                  color: context.theme.colorPirimaryNoDarkLight,
                ),
              ));
        }
      },
    );
  }
}

Widget ContactUserWidget(
    {required UserContactModel userContactModel,
    required int conversationId,
    required ValueChanged<List<ApiMessageModel>> onSend,
    required BuildContext context}) {
  ValueNotifier<int> isSent = ValueNotifier(0);
  return Container(
    padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: isSent,
          builder: (_, __, ___) => Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    image: DecorationImage(
                        image: NetworkImage(userContactModel.avatarUser),
                        fit: BoxFit.cover)),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                  child: Text(
                userContactModel.userName,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.text(context)
                    .copyWith(fontWeight: FontWeight.w700),
              )),
              // const Spacer(),
              isSent.value == 0
                  ? buttonWhite(AppLocalizations.of(context)?.send ?? '', 80,
                      () {
                      var messageId =
                          GeneratorService.generateMessageId(userInfo!.id);
                      var messages = SystemUtils.getListApiMessageModels(
                          senderInfo: userInfo!,
                          messageId: messageId,
                          contact: UserInfo(
                              id: userContactModel.id,
                              userName: userContactModel.userName,
                              avatarUser: userContactModel.avatarUser,
                              active: UserStatus(userContactModel.active,
                                  listUserStatus[userContactModel.active])),
                          conversationId: conversationId);
                      onSend(messages);
                      isSent.value = 1;
                    }, context)
                  : buttonBlue(AppLocalizations.of(context)?.sent ?? '', 80,
                      () => null, context)
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const DottedLine(
          dashColor: AppColors.greyCACA,
          dashLength: 2,
          dashGapLength: 1,
        )
      ],
    ),
  );
}
