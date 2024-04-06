import 'dart:io';

import 'package:app_chat365_pc/common/Widgets/form/social_textfield/controller/social_text_editing_controller.dart';
import 'package:app_chat365_pc/common/Widgets/form/social_textfield/model/social_content_detection_model.dart';
import 'package:app_chat365_pc/common/Widgets/reply_message_builder.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/api_message_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/widgets/ellipsized_text.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/data/services/generator_service.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/chat_cubit/chat_cubit.dart';
import 'package:app_chat365_pc/modules/chat/model/file_model.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/screen/chat_screen.dart';
import 'package:app_chat365_pc/modules/chat/sticker/cubit/sticker_cubit.dart';
import 'package:app_chat365_pc/modules/chat/widgets/Message/send_file.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_input_field.dart';
import 'package:app_chat365_pc/modules/chat/widgets/send_card_screen/send_card_screen.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/list_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/num_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/file_utils.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/system_utils.dart';
import 'package:app_chat365_pc/utils/ui/app_border_and_radius.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' show join, extension;
import 'package:image/image.dart' as img;
import 'package:cross_file/cross_file.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/data/enums/message_type.dart';

class ChatInputBar extends StatefulWidget {
  ChatInputBar({
    super.key,
    required this.conversationId,
    required this.onSend,
    required this.chatDetailBloc,
    required this.onChangedAutoDeleteTime,
    required this.fileDropStream,
    this.onTypingChanged,
    this.onTapDetectedContentDetection,
    this.onDetectListener,
    this.autoFocus,
    this.image,
    this.isSecret,
    this.inputEditingFastMessage,
  });

  final int conversationId;
  final ChatDetailBloc chatDetailBloc;

  /// Callback khi nhấn nút Gửi
  final ValueChanged<List<ApiMessageModel>> onSend;
  final ValueChanged<SocialContentDetection>? onTapDetectedContentDetection;
  final ValueChanged<SocialContentDetection>? onDetectListener;
  final Stream<List<XFile>> fileDropStream;

  final ValueChanged<int> onChangedAutoDeleteTime;
  final bool? autoFocus;
  final bool? isSecret;
  final ApiFileModel? image;
  final ValueChanged<String?>? inputEditingFastMessage;
  final ValueChanged<bool>? onTypingChanged;

  @override
  State<ChatInputBar> createState() => ChatInputBarState();
}

class ChatInputBarState extends State<ChatInputBar> {
  late Widget _sendButton;
  late Widget _iconSend;
  late final theme;
  late final userInfo;
  File? file;
  FilePickerResult? result;
  late StickerCubit stickerCubit;
  int numberGroupSticker = 0;
  final ValueNotifier<int> numGroupSticker = ValueNotifier(0);

  ValueNotifier<List<ApiFileModel>> imageInput = ValueNotifier([]);
  final ValueNotifier<List<File>> _pickedFiles = ValueNotifier([]);
  final ValueNotifier<ApiReplyMessageModel?> _isReplying = ValueNotifier(null);
  final ValueNotifier<bool> _isEditing = ValueNotifier(false);
  final ValueNotifier<bool> _isInPutFile = ValueNotifier(false);
  late final SocialTextEditingController _inputController;
  final ScrollController fileGridController = ScrollController();

  ApiReplyMessageModel? get replyingMessage => _isReplying.value;

  bool get isEditing => _isEditing.value;

  bool get isInPutFile => _isInPutFile.value;

  SocialTextEditingController get inputController => _inputController;

  FocusNode get focusNode => _focusNode;

  final _focusNode = FocusNode();
  SocketSentMessageModel? originMessage;

  String? get messageId => originMessage?.messageId;
  ValueNotifier<bool> _imagePaste = ValueNotifier(false);

  bool get isEditMode => _isEditing.value && originMessage != null;
  late final originMessageTextColor = theme.replyOriginTextStyle2.color;
  ApiFileModel? fileImageCopy;

  late ChatCubit chatCubit;
  late ApiMessageModel apiMessageModel;

  get isTyping => null;

// Xử lý ontap gửi tin nhắn
  void _onTapSendButton() async {
    String messageText = _inputController.text.trim();
    _inputController.clear();
    inputController.clear();
    var messageId = originMessage?.messageId ??
        GeneratorService.generateMessageId(userInfo.id);
    var replyMsg = _isReplying.value;
    var conversationId = widget.conversationId;
    var messages = SystemUtils.getListApiMessageModels(
        senderInfo: userInfo,
        conversationId: conversationId,
        files: _pickedFiles.value,
        messageId: messageId,
        uploadedFiles: imageInput.value == null ? [] : imageInput.value,
        replyModel: replyMsg,
        text: messageText,
        createdAt: originMessage?.createAt.toLocal(),
        infoLinkMessageType: _pickedFiles.value.isBlank
            ? null
            : fileImageCopy != null
                ? MessageType.image
                : MessageType.voice);
    fileImageCopy = null;
    imageInput.value = [...imageInput.value..clear()];
    _imagePaste.value = !_imagePaste.value;
    _pickedFiles.value = [];
    if (_isReplying.value != null) {
      _cancelReply();
    }
    logger.log(messages.first.toMap().toString(), name: "Messages Log");
    // gửi tin nhắn
    widget.onSend(messages);
    // if ((widget.chatDetailBloc.chatItemModel?.deleteTime ?? -1) > 0 &&
    //     widget.chatDetailBloc.chatItemModel?.typeGroup != 'Secret') {
    //   widget.chatDetailBloc.setupDeleteTime(
    //       conversationId: widget.conversationId,
    //       messageId: messageId,
    //       deleteTime: _autoDeleteTime,
    //       listUserId: [userInfo.id]);
    // }
    // FilePicker.platform.clearTemporaryFiles();
    _pickedFiles.value = [];
    if (!isEditMode) _inputController.clear();
    setState(() {});
  }

  @override
  void initState() {
    chatCubit = context.read<ChatCubit>();
    userInfo = context.userInfo();
    theme = context.theme;
    _setupSendButton();
    _inputController = SocialTextEditingController(
      onTapDetectedContentDetection: widget.onTapDetectedContentDetection,
    )..addListener(_inputListener);
    if (widget.onDetectListener != null) {
      _inputController.subscribeToDetection(widget.onDetectListener!);
    }

    _focusNode.addListener(_focusNodeListener);
    stickerCubit = context.read<StickerCubit>()..getAllSticker();
    widget.fileDropStream.listen((xfiles) {
      if (xfiles.isNotEmpty) {
        _listFiles = xfiles.map((file) => File(file.path)).toList();
        addFiles(_listFiles);
      }
    });
    super.initState();
  }

  _focusNodeListener() {
    _editModeListener();
    // _featureBottomSheetListener();
    // _emojiBottomSheetListener();
  }

  _editModeListener() {
    try {
      if (!_focusNode.hasFocus &&
          inputController.text.isEmpty &&
          originMessage != null) exitEditMode();
    } catch (e) {}
  }

  replyMessage(ApiReplyMessageModel replyModel) {
    logger.log("repl", name: "ListenableLog");
    _isReplying.value = replyModel;
    _isEditing.value = true;
    _focusNode.requestFocus();
  }

  editMessage(SocketSentMessageModel message) {
    var _message = message.message ?? '';
    _inputController..text = _message;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: _inputController.text.length),
    );
    originMessage = message;
    _isEditing.value = true;
    _isReplying.value = message.relyMessage;
    _pickedFiles.value = [];
    _focusNode.requestFocus();
  }

  _addMessagePaste() {
    if (_imagePaste.value &&
        (messagePaste?.file != null ||
            !messagePaste!.file!.fullFilePath.isEmpty)) {
      imageInput.value = [...imageInput.value, messagePaste!.file!];
    }
  }

  @override
  void dispose() {
    _inputController.removeListener(_inputListener);
    _inputController.dispose();
    _focusNode.removeListener(_focusNodeListener);
    _focusNode.dispose();
    getApplicationCacheDirectory().then((dir) {
      final clipboardDir = Directory(join(dir.path, "clipboard"));
      if (clipboardDir.existsSync()) {
        clipboardDir.deleteSync(recursive: true);
      }
    });
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void _setupSendButton() {
    _iconSend = Container(
        height: 42,
        width: 42,
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          // border: Border.all(color: AppColors.red),
        ),
        child: ValueListenableBuilder(
          valueListenable: changeTheme,
          builder: (context, value, child) => ColorFiltered(
            colorFilter: ColorFilter.mode(
                context.theme.colorPirimaryNoDarkLight, BlendMode.srcIn),
            child: SvgPicture.asset(
              Images.ic_send_icon,
            ),
          ),
        ));
    _sendButton = InkWell(
      onTap: _onTapSendButton,
      child: _iconSend,
    );
  }

  List<File> _listFiles = [];
  List<FileModel> listFileModel = [];

  void addFiles(List<File> files) {
    _pickedFiles.value = [..._pickedFiles.value, ...files];
    if (fileGridController.hasClients) {
      fileGridController.animateTo(
        fileGridController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void removeFileAt(int index) {
    if (index < 0 || index >= _pickedFiles.value.length) return;
    _pickedFiles.value.removeAt(index);
    _pickedFiles.value = [..._pickedFiles.value];
  }

  String getFileIcon(String fileExtension) {
    switch (fileExtension) {
      case ".doc": return Images.icon_atch_word;
      case ".docx": return Images.icon_atch_word;
      case ".txt": return Images.icon_atch_txt;
      case ".rtf": return Images.icon_atch_rtf;
      case ".xls": return Images.icon_atch_excel;
      case ".xlsx": return Images.icon_atch_excel;
      case ".zip": return Images.icon_atch_zip;
      case ".pdf": return Images.icon_atch_pdf;
      default: return Images.icon_atch_generic;
    }
  }

  void pasteClipboardImage() {
    Pasteboard.image.then((imageBytes) async {
      if (imageBytes != null) {
        String tempFileUuid = const Uuid().v4();
        addFiles([File(tempFileUuid)]);
        final String tempDir = join((await getApplicationCacheDirectory()).path, "clipboard");
        final bmpPath = join(tempDir, 'clipboard.bmp');
        final pngPath = join(tempDir, 'prtscr${DateTime.now().millisecondsSinceEpoch}.png');
        File file = await File(bmpPath).create(recursive: true);
        await file.writeAsBytes(imageBytes);
        await (img.Command()..decodeBmpFile(bmpPath)..writeToFile(pngPath)).executeThread();
        int tempIndex = _pickedFiles.value.indexWhere((element) => element.path == tempFileUuid);
        _pickedFiles.value[tempIndex] = File(pngPath);
        _pickedFiles.value = [..._pickedFiles.value];
      }
    });
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );
      if (result != null) {
        _listFiles = result.files.map((file) => File(file.path!)).toList();
        // for(var i = 0; i < _listFiles.length && i < 10; i++){
        //   var mb = (_listFiles[i].lengthSync() ~/ 1024).toInt();
        //   var nameFile = _listFiles[i].uri.pathSegments.last;
        //   await chatCubit.getLinkFile(_listFiles[i],ValueNotifier<double>(0));
        //   listFileModel.add(FileModel(
        //     fullName: chatCubit.listLinkFile.first,
        //     nameDisplay: nameFile,
        //     typeFile: 'sendPhoto',
        //     sizeFile: mb.toInt(),
        //     imageSource: '',
        //     fileSizeInByte: '${(mb ~/ 1024).toString()} Mb',
        //   )
        //   );
        // }
        addFiles(_listFiles);
      }
    } catch (e) {
      print("Error picking files: $e");
    }
  }

  late final optionButtons = Row(
    children: [
      SizedBoxExt.w20,
      _OptionButton(
        onPressed: _pickFiles,
        svgIcon: Images.send_file,
      ),
      SizedBoxExt.w15,
      _OptionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: SendCardScreen(
                    conversationId: widget.conversationId,
                    onSend: widget.onSend,
                  ),
                );
              });
        },
        svgIcon: Images.send_card,
      ),
      SizedBoxExt.w15,
      _OptionButton(
        onPressed: () {},
        svgIcon: Images.ic_micro,
      ),
      SizedBoxExt.w15,
      _OptionButton(
        onPressed: () {},
        svgIcon: Images.ic_3_dot,
      ),
    ],
  );

  exitEditMode() {
    logger.log('Exit edit mode');
    originMessage = null;
    _isEditing.value = false;
    _isReplying.value = null;
    _inputController.clear();
    // setState(() {});
  }

  _cancelReply() {
    _isReplying.value = null;
    _isEditing.value = false;
    FocusManager.instance.primaryFocus?.unfocus();
  }

  _computeIsEditing(String value) {
    if (value.isEmpty) {
      if (!imageInput.value.isBlank ) {
        return _isEditing.value = true;
      }
      return _isEditing.value = false;
    }
    // print('$_previousText');

    /// xu ly file image
    if (!_isEditing.value) {
      if (value.isNotEmpty && !_isEditing.value) {
        _isEditing.value = true;
      } else if (value.isEmpty && _isEditing.value) {
        _isEditing.value = false;
      }
    }
  }

  void _inputListener() {
    // _tagListner();
    try {
      if (/*_focusNode.hasFocus &&*/
          !inputController.text.isBlank) {
        _computeIsEditing(inputController.text);
      }
    } catch (e) {}
    if (inputController.text.isBlank && imageInput.value.isBlank) {
      imageInput.value.clear();
      return widget.inputEditingFastMessage?.call('');
    }
    for (var item in imageInput.value) {
      if (inputController.text.isBlank &&
          item.filePath != null &&
          widget.image?.filePath.isBlank == false &&
          (!item.filePath!.contains(widget.image!.filePath!))) {
        imageInput.value.clear();
        return widget.inputEditingFastMessage?.call('');
      }
    }
  }

  void _keyEventListener(RawKeyEvent key) {
    if (key is RawKeyUpEvent) {
      bool isVReleased = key.logicalKey == LogicalKeyboardKey.keyV;
      bool isEnterReleased = key.logicalKey == LogicalKeyboardKey.enter;
      if (isEnterReleased && mounted) {
        if (!key.isShiftPressed) {
          if (_inputController.text.trim().isNotEmpty||_listFiles.isNotEmpty) {
            _onTapSendButton();
          }
        } else {
          if(inputController.text.isNotEmpty) {
            var cursorPos = inputController.selection.base.offset;
            String textAfterCursor =  inputController.text.substring(cursorPos);
            String textBeforeCursor = inputController.text.substring(0, cursorPos);
              inputController.text = "$textBeforeCursor\n$textAfterCursor";
              inputController.selection = TextSelection.collapsed(offset: textBeforeCursor.length+1);
            } else {
              inputController.text = '${inputController.text}\n';
            }
        }
      }
      if (Platform.isWindows) {
        if (key.isControlPressed&&isVReleased) {
          pasteClipboardImage();
        }
      } else if (Platform.isMacOS) {
        if (key.isMetaPressed&&isVReleased) {
          pasteClipboardImage();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _computeIsEditing(_inputController.text);
    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) {
        return Container(
          color: context.theme.backgroundChatContent,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([
                  _isEditing,
                  _pickedFiles,
                  _isReplying,
                  //ValueNotifier(_inputController.text)
                ]),
                builder: (context, child) {
                  logger.log(_isReplying.value, name: "ListenableLog");
                  var isTyping = _isEditing.value || _isReplying.value != null;
                  if (widget.onTypingChanged != null) {
                    widget.onTypingChanged!(isTyping);
                  }
                  return Container(
                    // height: isInPutFile ? 200 : 40,
                    // color: AppColors.white,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: context.theme.backgroundChatContent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBoxExt.w40,
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: context.theme.backgroundInputBar,
                                // theme.chatInputBarColor,
                                borderRadius: _isReplying.value != null||_pickedFiles.value.isNotEmpty
                                    ? BorderRadius.circular(25)
                                    : BorderRadius.circular(50)
                                // AppBorderAndRadius.chatInputFieldBorderRadius,
                                ),
                            child: Column(
                              children: [
                                // if (isEditMode)
                                //   Align(
                                //     alignment: Alignment.topRight,
                                //     child: _ExitModeButton(onPressed: exitEditMode),
                                //   )
                                // else
                                if (_isReplying.value != null)
                                  Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 23,
                                          right: 23,
                                          top: 12,
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: ReplyMessageBuilder(
                                                replyModel: _isReplying.value!,
                                                originMessageTextColor:
                                                    context.theme.replyOriginTextStyle.color,
                                                replyInfoTextColor:
                                                    originMessageTextColor,
                                                originMessageMaxLines: 3,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: _ExitModeButton(
                                          onPressed: _cancelReply,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_pickedFiles.value.isNotEmpty)
                                  Container(
                                    height: 146,
                                    padding: const EdgeInsets.only(
                                      left: 32,
                                      right: 32,
                                      top: 16,
                                      bottom: 10,
                                    ),
                                    child: GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 120,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                      controller: fileGridController,
                                      itemCount: _pickedFiles.value.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index == _pickedFiles.value.length) {
                                          return Stack(
                                            children: [
                                              InkWell(
                                                onTap: _pickFiles,
                                                child: Container(
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    gradient: context.theme.gradient,
                                                    borderRadius: BorderRadius.circular(4)
                                                  ),
                                                  child: const Center(
                                                    child: Icon(Icons.add, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ]
                                          );
                                        }
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Stack(
                                            children: [
                                              Builder(builder: (context) {
                                                File currentFile = _pickedFiles.value[index];
                                                String fileExt = extension(currentFile.path);
                                                bool isImage = ['.jpg', '.jpeg', '.png'].contains(fileExt);
                                                if (!currentFile.existsSync()) {
                                                  return Container(
                                                    color: context.theme.addFriendButtonColor,
                                                    child: Center(
                                                      child: CircularProgressIndicator(color: context.theme.textColor)
                                                    ),
                                                  );
                                                }
                                                if (isImage) {
                                                  return Image.file(
                                                    currentFile,
                                                    fit: BoxFit.cover,
                                                    width: 120,
                                                    height: 120,
                                                  );
                                                }
                                                return Container(
                                                  width: 120,
                                                  height: 120,
                                                  color: context.theme.addFriendButtonColor,
                                                  padding: const EdgeInsets.all(8),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      SvgPicture.asset(
                                                        getFileIcon(fileExt),
                                                        width: 30,
                                                      ),
                                                      Text(
                                                        currentFile.name.replaceAll(fileExt, ""),
                                                        style: TextStyle(
                                                          color: context.theme.textColorInverted,
                                                          fontWeight: FontWeight.bold
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Text(
                                                        "${currentFile.lengthInBytes.fizeSizeString()} - ${fileExt.replaceAll(".", "").toUpperCase()}",
                                                        style: TextStyle(
                                                          color: context.theme.textColorInverted,
                                                          fontWeight: FontWeight.w300,
                                                          fontSize: 10
                                                        ),
                                                        overflow: TextOverflow.clip,
                                                      ),
                                                    ]
                                                  ),
                                                );
                                              }),
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: InkWell(
                                                  onTap: () {
                                                    removeFileAt(index);
                                                  },
                                                  child: Icon(Icons.close, size: 18, color: context.theme.textColorInverted,),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      )
                                  ),
                                child!,
                              ],
                            ),
                          ),
                        ),
                        if (!isTyping&&_pickedFiles.value.isEmpty) optionButtons else _sendButton,
                        SizedBoxExt.w40,
                      ],
                    ),
                  );
                },
                child: RawKeyboardListener(
                  onKey: _keyEventListener,
                  focusNode: FocusNode(),
                  child: ChatInputField(
                    onTapEmoji: (value) {
                      double leftPosition = 750.0; // Vị trí bên trái của Dialog
                      double topPosition = 260.0;
                      _showEmoji();
                    },
                    key: const ValueKey('ChatInputField'),
                    controller: _inputController,
                    onChanged: _computeIsEditing,
                    focusNode: _focusNode,
                    autoFocus: widget.autoFocus ?? false,
                    onTapPaste: (value) {
                      if (value) {
                        if (messagePaste?.type == MessageType.image) {
                          _imagePaste.value = true;
                          _addMessagePaste();
                          setState(() {});
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmoji() async {
    stickerCubit = context.read<StickerCubit>()..getAllSticker();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: numGroupSticker,
            builder: (context, value, child) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                content: Container(
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 8, bottom: 5),
                  decoration: BoxDecoration(
                    color: context.theme.backgroundColor,
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
                            GradientText(
                              'STICKER',
                              gradient: context.theme.gradient,
                              style: AppTextStyles.text(context)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            Container(
                              decoration:  BoxDecoration(
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
                                      .listSticker[numGroupSticker.value]
                                      .stickerList
                                      .length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        var replyMsg = _isReplying.value;
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
                                                        numGroupSticker.value]
                                                    .stickerList[index],
                                                replyMessage: replyMsg,
                                                type: MessageType.sticker);

                                        widget.onSend([apiMessageModel]);
                                        print('ashdlajsldkjalskdjlaksjdl');
                                        AppRouter.back(context);
                                      },
                                      child: Container(
                                        height: 80,
                                        width: 80,
                                        child: Image.network(stickerCubit
                                            .listSticker[
                                                numGroupSticker.value]
                                            .stickerList[index]),
                                      ),
                                    );
                                  }),
                            ),
                            Container(
                              height: 2,
                              width: 350,
                              decoration: BoxDecoration(
                                gradient: context.theme.gradient
                              ),
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
                                        numGroupSticker.value = index;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10),
                                      width: 40,
                                      height: 40,
                                      child: Image.network(stickerCubit
                                          .listSticker[index].icon),
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
              );
            });
      },
    );
  }

  sendSticker(ApiMessageModel apiMessageModel) {
    // apiMessageModel = ApiMessageModel(messageId: 'asda', conversationId: 123, senderId: 123);
    widget.onSend([apiMessageModel]);
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    Key? key,
    this.onPressed,
    required this.svgIcon,
  }) : super(key: key);

  final void Function()? onPressed;
  final String svgIcon;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: changeTheme,
      builder: (context, value, child) {
        return InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.theme.backgroundIconInputBar,
              ),
              child: Transform.scale(
                scale: 0.5, // Điều chỉnh tỷ lệ kích thước của hình ảnh
                child: SvgPicture.asset(
                  svgIcon,
                  color: context.theme.colorIconInputBar,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExitModeButton extends StatelessWidget {
  const _ExitModeButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: Icon(
        Icons.cancel_outlined,
        color: context.theme.text2Color,
      ),
    );
  }
}
