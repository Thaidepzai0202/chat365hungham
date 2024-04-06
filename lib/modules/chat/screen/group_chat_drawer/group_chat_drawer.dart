import 'package:app_chat365_pc/modules/chat/screen/group_chat_drawer/general_info_drawer.dart';
import 'package:app_chat365_pc/modules/chat/screen/group_chat_drawer/image_file_link_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum GroupChatDrawerScene {
  generalInfo, // Màn hình chung các chức năng
  files, // Ảnh, files, link đã gửi
  settings, // Cài đặt cá nhân (Có cần không??)
  dataVolume, // Dung lượng trò chuyện
}

/// Ngăn xếp chức năng của cuộc trò chuyện nhóm,
/// Thực ra cái này để phân chia trường hợp thôi.
/// Code chi tiết từng màn thì ở các file *drawer.dart khác
class GroupChatDrawer extends StatelessWidget {
  const GroupChatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupChatDrawerCubit>(
      create: (context) =>
          GroupChatDrawerCubit(GroupChatDrawerScene.generalInfo),
      child: BlocBuilder<GroupChatDrawerCubit, GroupChatDrawerScene>(
        builder: (context, state) {
          switch (state) {
            case GroupChatDrawerScene.generalInfo:
              return GeneralInfoDrawer();
            case GroupChatDrawerScene.files:
              return ImageFileLinkDrawer();
            case GroupChatDrawerScene.dataVolume:
            case GroupChatDrawerScene.settings:
            default:
              return SizedBox(
                child: Text("Đang cập nhật"),
              );
          }
        },
      ),
    );
  }
}

class GroupChatDrawerCubit extends Cubit<GroupChatDrawerScene> {
  GroupChatDrawerCubit(super.initialState);
}
