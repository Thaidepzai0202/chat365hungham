import 'dart:math';

import 'package:app_chat365_pc/common/blocs/chat_library_cubit/cubit/chat_library_cubit.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/chat/model/result_socket_chat.dart';
import 'package:app_chat365_pc/modules/chat/screen/group_chat_drawer/general_info_drawer.dart';
import 'package:app_chat365_pc/modules/chat/screen/group_chat_drawer/group_chat_drawer.dart';
import 'package:app_chat365_pc/modules/chat/widgets/chat_screen_dialogs/member_moderation_dialog.dart';
import 'package:app_chat365_pc/modules/chat_conversations/widgets/gradient_text.dart';
import 'package:app_chat365_pc/utils/data/enums/message_type.dart';
import 'package:app_chat365_pc/utils/data/enums/themes.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/num_extension.dart';
import 'package:app_chat365_pc/utils/data/video_call/random_string.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


/// Màn xem ảnh, video, link, file đã gửi của CTC
/// TODO: Chưa tải thêm bất kỳ gì khi kéo xuống tận dưới cùng
/// TODO: Chưa tải file về khi bấm
/// TODO: Chưa có lọc
class ImageFileLinkDrawer extends StatefulWidget {
  @override
  State<ImageFileLinkDrawer> createState() => _ImageFileLinkDrawerState();
}

class _ImageFileLinkDrawerState extends State<ImageFileLinkDrawer> {
  static const tabImageVideo = 0;
  static const tabFile = 1;
  static const tabLink = 2;

  int currentTab = tabImageVideo;

  var loadedEverything = {
    MessageType.image: false,
    MessageType.file: false,
    MessageType.link: false,
  };

  @override
  Widget build(BuildContext context) {
    // Note: Dùng cho hai thanh lọc theo người và ngày
    // var filterBarDecoration = InputDecorationTheme(
    //   hintStyle: TextStyle(
    //       color: AppColors.mineShaft,
    //       fontSize: 14,
    //       fontWeight: FontWeight.w400),
    //   //constraints: BoxConstraints(maxHeight: 37),
    //   filled: true,
    //   fillColor: AppColors.grayEAEDF0,
    //   border: OutlineInputBorder(
    //     borderSide: BorderSide.none,
    //     borderRadius: BorderRadius.circular(50),
    //   ),
    // );
    return ValueListenableBuilder(
        valueListenable: changeTheme,
        builder: (context, value, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: context.theme.backgroundColor,
              elevation: 1,
              // Bấm quay về thì sẽ qua màn chức năng chính
              leading: IconButton(
                icon: ShaderMask(
                    child: SvgPicture.asset(
                      Images.ic_back,
                      color: AppColors.white,
                    ),
                    shaderCallback: (Rect bounds) =>
                        context.theme.gradient.createShader(bounds)),
                onPressed: () {
                  context
                      .read<GroupChatDrawerCubit>()
                      .emit(GroupChatDrawerScene.generalInfo);
                },
              ),

              title: GradientText(
                AppLocalizations.of(context)!.sentFile,
                gradient: context.theme.gradient,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            body: BlocListener<ChatLibraryCubit, ChatLibraryState>(
              listener: (context, state) {
                /// Ngăn chặn màn này tải thêm file
                if (state is ChatLibraryStateLoadedEverything) {
                  loadedEverything[state.messageType] = true;
                }
              },
              child: Container(
                color: context.theme.backgroundColor,
                child: Column(
                  children: [
                    // Thanh tab bật qua lại các màn
                    Row(
                      children: [
                        tabButton(
                          context: context,
                          desc: AppLocalizations.of(context)!.imageVideo,
                          onPressed: () {
                            if (currentTab == tabImageVideo) return;
                            currentTab = tabImageVideo;
                            setState(() {});
                          },
                          active: currentTab == tabImageVideo,
                          underlineHeight: 2,
                        ),
                        tabButton(
                          context: context,
                          desc: "File",
                          onPressed: () {
                            if (currentTab == tabFile) return;
                            currentTab = tabFile;
                            setState(() {});
                          },
                          active: currentTab == tabFile,
                          underlineHeight: 2,
                        ),
                        tabButton(
                          context: context,
                          desc: "Link",
                          onPressed: () {
                            if (currentTab == tabLink) return;
                            currentTab = tabLink;
                            setState(() {});
                          },
                          active: currentTab == tabLink,
                          underlineHeight: 2,
                        ),
                      ],
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.grayHint,
                    ),
                    SizedBoxExt.h8,
                    // // TODO: TL: Chưa làm phần lọc người vội
                    // // TODO: Sửa mấy cái lọc này trông cho đẹp thêm
                    // // Hai bộ lọc theo ngày và theo người gửi
                    // LayoutBuilder(builder: (context, constraints) {
                    //   return Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //     children: [
                    //       DropdownMenu(
                    //         inputDecorationTheme: filterBarDecoration,
                    //         width: constraints.maxWidth / 2 - 10,
                    //         dropdownMenuEntries: const [
                    //           DropdownMenuEntry(value: 1, label: "Đang cập nhật nhé"),
                    //         ],
                    //         hintText: "Người gửi",
                    //       ),
                    //       DropdownMenu(
                    //         inputDecorationTheme: filterBarDecoration,
                    //         width: constraints.maxWidth / 2 - 10,
                    //         dropdownMenuEntries: const [
                    //           DropdownMenuEntry(value: 1, label: "Đang cập nhật nhé"),
                    //         ],
                    //         hintText: "Ngày gửi",
                    //       ),
                    //     ],
                    //   );
                    // }),
                    // SizedBoxExt.h8,
                    // const Divider(
                    //   thickness: 10,
                    //   color: AppColors.E0Gray,
                    // ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          switch (currentTab) {
                            case tabImageVideo:
                              return imageTabBody();
                            case tabLink:
                              return linkTabBody();
                            case tabFile:
                              return fileTabBody();
                            default:
                              return Text("$runtimeType: Tab khỉ gì đây?");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  // TODO: Nhờ anh Huy check thử thì có vẻ đang bị mất ảnh
  // Không biết do API hay do Cubit lọc sai
  Widget imageTabBody() {
    return BlocBuilder<ChatLibraryCubit, ChatLibraryState>(
        builder: (context, state) {
      var chatLibraryCubit = context.read<ChatLibraryCubit>();
      var mostRecentImagesByDay =
          orderFilesByDay(chatLibraryCubit.allFiles[MessageType.image]!.files);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView.builder(
          // + 1 for circular loading widget
          itemCount: mostRecentImagesByDay.length + 1,
          itemBuilder: (context, index) {
            if (index == mostRecentImagesByDay.length) {
              if (loadedEverything[MessageType.image] == false) {
                _tryLoadMoreWhenScrolledToBottom(type: MessageType.image);
                return Container(child: WidgetUtils.loadingCircle(context));
              }
              //return Text("Không còn ảnh nào nữa");
              return SizedBox();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ngày tháng năm
                Padding(
                  padding: const EdgeInsets.fromLTRB(90, 0, 0, 10),
                  child: Text(
                    mostRecentImagesByDay[index].key,
                    style:  TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,color: context.theme.text2Color
                        ),
                  ),
                ),
                // Một lô ảnh ẻo
                Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: mostRecentImagesByDay[index]
                      .value
                      .map((e) => SizedBox(
                          width: 90,
                          height: 90,
                          child: drawerImagePreview(context, e)))
                      .toList(),
                ),
                SizedBoxExt.h20,
              ],
            );
          },
        ),
      );
    });
  }

  Widget fileTabBody() {
    return BlocBuilder<ChatLibraryCubit, ChatLibraryState>(
        builder: (context, state) {
      var mostRecentFilesByDay = orderFilesByDay(
          context.read<ChatLibraryCubit>().allFiles[MessageType.file]!.files);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView.builder(
          // +1 for loading circle
          itemCount: mostRecentFilesByDay.length + 1,
          itemBuilder: (context, index) {
            if (index == mostRecentFilesByDay.length) {
              if (loadedEverything[MessageType.file] == false) {
                _tryLoadMoreWhenScrolledToBottom(type: MessageType.file);
                return WidgetUtils.loadingCircle(context);
              }
              //return Text("Không còn file nào nữa");
              return SizedBox();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ngày tháng năm
                Padding(
                  padding: const EdgeInsets.fromLTRB(90, 0, 0, 5),
                  child: Text(
                    mostRecentFilesByDay[index].key,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,color: context.theme.text2Color),
                  ),
                ),
                // Một lô file fiếc
                Column(
                  children: mostRecentFilesByDay[index]
                      .value
                      .map((e) => drawerFilePreview(e,context))
                      .toList(),
                ),
                SizedBoxExt.h20,
              ],
            );
          },
        ),
      );
    });
  }

  Widget linkTabBody() {
    return BlocBuilder<ChatLibraryCubit, ChatLibraryState>(
        builder: (context, state) {
      var mostRecentLinksByDay = orderFilesByDay(
          context.read<ChatLibraryCubit>().allFiles[MessageType.link]!.files);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView.builder(
          // +1 loading circle
          itemCount: mostRecentLinksByDay.length + 1,
          itemBuilder: (context, index) {
            if (index == mostRecentLinksByDay.length) {
              if (loadedEverything[MessageType.link] == false) {
                _tryLoadMoreWhenScrolledToBottom(type: MessageType.link);
                return WidgetUtils.loadingCircle(context);
              }
              //return Text("Không còn file nào nữa");
              return SizedBox();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ngày tháng năm
                Padding(
                  padding: const EdgeInsets.fromLTRB(90, 0, 0, 10),
                  child: Text(
                    mostRecentLinksByDay[index].key,
                    style:  TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,color: context.theme.text2Color),
                  ),
                ),
                // Một lô file fiếc
                Column(
                  children: mostRecentLinksByDay[index]
                      .value
                      .map((e) => drawerLinkPreview(e,context))
                      .toList(),
                ),
                SizedBoxExt.h20,
              ],
            );
          },
        ),
      );
    });
  }

  // Trả về một dãy đã sort theo date gần hiện tại nhất
  // của các cặp "Ngày Tháng Năm" : [tin nhắn đã sort từ gần đến xa hiện tại nhất],
  List<MapEntry<String, List<SocketSentMessageModel>>> orderFilesByDay(
      Set<SocketSentMessageModel> files) {
    // Ánh xạ ngày - file
    // Lọc file theo ngày
    Map<String, List<SocketSentMessageModel>> filesByDay = {};
    for (final file in files) {
      var d = file.createAt;
      var creationDate = changeLanguage.value == 'vi'
          ? "Ngày ${d.day < 10 ? "0${d.day}" : "${d.day}"} tháng ${d.month} năm ${d.year}"
          : formatDate(d.day, d.month, d.year);
      if (filesByDay.containsKey(creationDate)) {
        filesByDay[creationDate]!.add(file);
      } else {
        filesByDay[creationDate] = [file];
      }
    }

    // Sắp xếp theo ngày
    var mostRecentFirst = filesByDay.entries.toList();
    mostRecentFirst.sort((a, b) => b.key.compareTo(a.key));

    // Sắp xếp theo thời gian gần nhất, trong từng ngày
    for (var day in mostRecentFirst) {
      day.value.sort((a, b) => b.createAt.compareTo(a.createAt));
    }
    return mostRecentFirst;
  }

  String formatDate(int day, int month, int year) {
    // Danh sách tên các tháng trong tiếng Anh
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // Lấy tên tháng tương ứng
    String monthName = months[month - 1];

    // Chuỗi định dạng ngày tháng năm
    String formattedDate = '$monthName $day, $year';

    return formattedDate;
  }

  void _tryLoadMoreWhenScrolledToBottom({required MessageType type}) {
    var chatLibraryCubit = context.read<ChatLibraryCubit>();
    if (loadedEverything[type] == false &&
        chatLibraryCubit.state is! ChatLibraryStateLoading) {
      chatLibraryCubit.loadLibrary(messageType: type);
    }
  }
}

Widget drawerFilePreview(SocketSentMessageModel msg, BuildContext context) {
  return InkWell(
    onTap: () {
      // TODO: Tải trực tiếp thay vì đi qua trình duyệt
      /// Trần Lâm Note 21/12/2023: Giải pháp này copy từ FileDisplay của anh Hùng
      /// do bên MacOS chưa hỗ trợ tải file trực tiếp
      _launchURL(msg.files![0].downloadPath);
    },
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          height: 64,
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: SvgPicture.asset(Images.ic_anh_minh_hoa_file),
              ),
              SizedBoxExt.w10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      msg.files![0].fileName,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500,color: context.theme.text2Color),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      msg.files![0].fileSize.fizeSizeString(),
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w400,color: context.theme.text2Color),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 0,
          thickness: 1,
          color: context.theme.text3Color,
        ),
      ],
    ),
  );
}

Widget drawerLinkPreview(SocketSentMessageModel msg,BuildContext context) {
  Uri linkUri = Uri.parse(msg.message!);
  String linkTitle = linkUri.host.toUpperCase();

  // NOTE: Theo cảm quan Trần Lâm:
  // Chỉnh lowerbound cao lên khiến màu sáng hơn, trông nó sẽ nhàn nhạt mờ mờ
  // Chỉnh UpperBound cao lên khiến màu đa dạng hơn, sáng tối sắc nét đủ cả
  var colorLowerBound = 25;
  var colorUpperBound = 175;

  return Column(
    children: [
      InkWell(
        onTap: () {
          // TODO: Làm cái popup hỏi muốn nhảy qua link không
          launchUrl(linkUri);
        },
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              color: Color.fromARGB(
                255,
                randomBetween(colorLowerBound, colorUpperBound),
                randomBetween(colorLowerBound, colorUpperBound),
                randomBetween(colorLowerBound, colorUpperBound),
              ),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    linkTitle[0],
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w400),
                  )),
            ),
            SizedBoxExt.w10,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    linkTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.theme.text2Color
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    msg.message!,
                    style:  TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400,color: context.theme.text2Color),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBoxExt.h10
    ],
  );
}

//link sang web
_launchURL(String link) async {
  final Uri url = Uri.parse('${link}');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch ');
  }
}
