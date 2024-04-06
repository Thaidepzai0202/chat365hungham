
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:flutter/material.dart';
class UserListTile extends StatefulWidget {
  const UserListTile({
    Key? key,
    required this.avatar,
    required this.userName,
    this.bottom,
    this.onTapUserName,
    this.mainAxisSize,
    this.isInConversation,
  }) : super(key: key);

  final Widget avatar;
  final String userName;
  final Widget? bottom;
  final VoidCallback? onTapUserName;
  final MainAxisSize? mainAxisSize;
  final bool? isInConversation;
  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  late Widget _avatar;
  late String _userName;
  late bool _isInConver;
  @override
  void initState() {
    super.initState();
    _avatar = widget.avatar;
    _userName = widget.userName;
    _isInConver = widget.isInConversation ?? false;
  }

  @override
  void didUpdateWidget(covariant UserListTile oldWidget) {
    if (_avatar != widget.avatar ||
        _userName != widget.userName ||
        _isInConver != widget.isInConversation) {
      _avatar = widget.avatar;
      _userName = widget.userName;
      _isInConver = widget.isInConversation ?? false;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisSize: widget.mainAxisSize ?? MainAxisSize.min,
      children: [
        _avatar,
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: widget.onTapUserName,
                child: Text(
                  _userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _isInConver
                      ? context.theme.userListTileTextTheme
                      .copyWith(color: Colors.white)
                      : context.theme.userListTileTextTheme,
                ),
              ),
              if (widget.bottom != null) widget.bottom!,
            ],
          ),
        ),
      ],
    );
  }
}
