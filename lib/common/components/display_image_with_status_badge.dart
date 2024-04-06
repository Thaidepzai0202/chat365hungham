import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DisplayImageWithStatusBadge extends StatelessWidget {
  const DisplayImageWithStatusBadge({
    Key? key,
    required this.isGroup,
    required this.model,
    required this.userStatus,
    this.size,
    this.enable = true,
    this.badge,
    this.badgeSize,
    this.tapCallBack,
    this.isSecret = false,
  }) : super(key: key);

  final bool isGroup;
  final IUserInfo model;
  final UserStatus userStatus;
  final double? size;
  final bool enable;
  final Widget? badge;
  final double? badgeSize;
  final VoidCallback? tapCallBack;
  final bool isSecret;
  @override
  Widget build(BuildContext context) {
    final double _badgeSize = badgeSize ?? (size != null ? size! / 3 - 10 : 12);
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        DisplayAvatar(
          isGroup: isGroup,
          model: model,
          size: size ?? 36,
          enable: enable,
          enabledTapCallback: tapCallBack,
        ),
        if (badge != null)
          badge!
        else if (model.lastActive == null)
          if(isGroup == true)
          userStatus.getStatusBadge(
            context,
            badgeSize: _badgeSize - 2,
          ),
        if (isSecret)
          Positioned(
            child: SvgPicture.asset(Images.ic_lock),
            bottom: 0,
            left: 0,
          )
      ],
    );
  }
}
