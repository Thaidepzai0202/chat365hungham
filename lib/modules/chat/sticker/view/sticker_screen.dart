import 'package:app_chat365_pc/common/models/address_model.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/modules/chat/sticker/cubit/sticker_cubit.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_input_bar.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StickerScreen extends StatefulWidget {
  StickerScreen(
      this.onTapSendButton,
      // this.sendSticker,
      this.conversationId);
  void Function() onTapSendButton;
  // void Function(ApiMessageModel) sendSticker;
  final int conversationId;
  @override
  State<StickerScreen> createState() => _StickerScreenState();
}

class _StickerScreenState extends State<StickerScreen> {
  late StickerCubit stickerCubit;
  int numberGroupSticker = 0;

  @override
  void initState() {
    stickerCubit = context.read<StickerCubit>()..getAllSticker();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return BlocBuilder(
          bloc: stickerCubit,
          builder: (context, state) {
            if (state is StickerLoadedState) {
              return Positioned(
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  content: Container(
                    // margin: EdgeInsets.only(left: leftPosition, top: topPosition),
                    // height: 350,
                    // width: 450,
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 8, bottom: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GradientText('STICKER',
                                  gradient: context.theme.gradient,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.white
                                  )),
                              Container(
                                decoration: BoxDecoration(
                                    gradient: context.theme.gradient),
                                height: 1,
                                width: 30,
                              ),
                              Container(
                                height: 400,
                                width: 400,
                                child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount: stickerCubit
                                        .listSticker[numberGroupSticker]
                                        .stickerList
                                        .length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          ApiMessageModel apiMessageModel =
                                              ApiMessageModel(
                                                  messageId: GeneratorService
                                                      .generateMessageId(
                                                          AuthRepo().userId!),
                                                  conversationId:
                                                      widget.conversationId,
                                                  senderId: AuthRepo().userId!,
                                                  message: stickerCubit
                                                      .listSticker[
                                                          numberGroupSticker]
                                                      .stickerList[index],
                                                  //relyMessage: replyMsg,
                                                  type: MessageType.sticker);
                                          //ChatInputBar chatInputBar = ChatInputBar(conversationId: , onSend: onSend, chatDetailBloc: chatDetailBloc, onChangedAutoDeleteTime: onChangedAutoDeleteTime)
                                          widget.onTapSendButton();
                                        },
                                        child: Container(
                                          height: 80,
                                          width: 80,
                                          child: Image.network(stickerCubit
                                              .listSticker[numberGroupSticker]
                                              .stickerList[index]),
                                        ),
                                      );
                                    }),
                              ),
                              Container(
                                height: 2,
                                width: 350,
                                color: AppColors.gray,
                              ),
                              Container(
                                height: 40,
                                width: 400,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: stickerCubit.listSticker.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          numberGroupSticker = index;
                                        });
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 10),
                                        width: 40,
                                        height: 40,
                                        child: Image.network(
                                            stickerCubit.listSticker[index].icon),
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              print('_____________acbsad___${state}');
              return Center(child: CircularProgressIndicator());
            }
          });
    } catch (e, s) {
      AppDialogs.toast("$e: $s");
      return SizedBox();
    }
  }
}
