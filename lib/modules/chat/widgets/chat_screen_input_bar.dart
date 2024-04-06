import 'package:app_chat365_pc/common/Widgets/typing_detector.dart';
import 'package:app_chat365_pc/common/Widgets/wavy_three_dot.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/models/auto_delete_message_time_model.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_input_bar.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/text_extension.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreenInputBar extends StatefulWidget {
  ChatScreenInputBar({
    Key? key,
    required this.chatInputBarKey,
    required this.chatDetailBloc,
    required this.onSend,
    required this.fileDropStream,
    this.onTypingChanged,
    this.autoFocus,
    this.onFullScreen,
    this.imageQuickMessage,
  });

  final GlobalKey<ChatInputBarState> chatInputBarKey;
  final ValueChanged<List<ApiMessageModel>> onSend;
  final ValueChanged<bool>? onTypingChanged;
  final ValueChanged<bool>? onFullScreen;
  final bool? autoFocus;
  final ValueChanged<String?>? imageQuickMessage;
  final ChatDetailBloc chatDetailBloc;
  final Stream<List<XFile>> fileDropStream;

  @override
  State<ChatScreenInputBar> createState() => _ChatScreenInputBarState();
}

class _ChatScreenInputBarState extends State<ChatScreenInputBar> {
  // late final ChatDetailBloc _chatDetailBloc;
  ApiFileModel? imageItem;
  ValueNotifier<bool> isDisable = ValueNotifier(false);
  final ValueNotifier<ApiReplyMessageModel?> _isReplying = ValueNotifier(null);
  late final TypingDetectorBloc _typingDetectorBloc;
  late final Text typingText;
  late final double typingTextWidth;
  late final double typingUserMaxWidth;
  late final Widget typingRowWidget;
  int get _conversationId => widget.chatDetailBloc.conversationId;

  ApiReplyMessageModel? get replyingMessage => _isReplying.value;

  // void _onChangedFocus() {
  //   _updateOverlay();
  // }
  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   widget.chatInputBarKey.currentState!.focusNode
    //       .addListener(_onChangedFocus);
    // });
    /// Trần Lâm Debug 12/12/2023
    /// NOTE 1: Nếu context.read<TypingDetectorBloc>() không ra cái gì,
    /// thì debug console sẽ kêu lỗi không hit test được
    /// thay vì kêu không tìm thấy provider
    /// NOTE 2: Sử dụng context.read<ChatConversationBloc>().typingBlocs để
    /// lấy TypingDetectorBloc tương ứng với từng cuộc trò chuyện
    _typingDetectorBloc =
        TypingDetectorBloc(0); //context.read<TypingDetectorBloc>();
    typingText = Text(
      ' đang nhập ',
      style: context.theme.typingTextStyle,
    );
    typingTextWidth = typingText.getSize().width;

    typingRowWidget = Row(
      children: [
        typingText,
        WavyThreeDot(),
      ],
    );

    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    try {
      typingUserMaxWidth =
          context.mediaQuerySize.width - WavyThreeDot.width - typingTextWidth;
    } catch (e) {}

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: DefaultTextStyle(
            style: context.theme.typingTextStyle,
            child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
              bloc: widget.chatDetailBloc,
              buildWhen: (prev, current) =>
                  current is ChatDetailStateLoadDetailDone,
              builder: (context, state) {
                return BlocProvider<TypingDetectorBloc>.value(
                  value: _typingDetectorBloc,
                  child: TypingDetector(
                    conversationId: _conversationId,
                    builder: (context, userIds) {
                      final List<String> list = [];
                      for (var id in userIds) {
                        for (var info
                            in widget.chatDetailBloc.listUserInfoBlocs.values) {
                          var currentInfo = info.state.userInfo;
                          if (currentInfo.id == id) {
                            list.add(info.state.userInfo.name);
                            break;
                          }
                        }
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: typingUserMaxWidth,
                              ),
                              child: Text(
                                list.join(', '),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          typingRowWidget,
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
        ChatInputBar(
          key: widget.chatInputBarKey,
          conversationId: _conversationId,
          chatDetailBloc: widget.chatDetailBloc,
          onSend: widget.onSend,
          fileDropStream: widget.fileDropStream,
          onChangedAutoDeleteTime: (autoDeleteTime) {
            // if (_chatDetailBloc.detail != null) {
            //   _chatDetailBloc
            //     ..detail!.autoDeleteMessageTimeModel =
            //         AutoDeleteMessageTimeModel(
            //       deleteTime: autoDeleteTime,
            //       deleteType: AutoDeleteMessageType.autoDelete.index,
            //     )
            //     ..autoDeleteTimeMessage = autoDeleteTime;
            // }
          },
          onDetectListener: (detection) {},
          autoFocus: widget.autoFocus ?? false,
          onTypingChanged: (value) => widget.onTypingChanged?.call(value),
          image: imageItem,
          inputEditingFastMessage: (value) {
            if (value.isBlank) {
              isDisable.value = false;
            }
          },
        ),
      ],
    );
  }
}
