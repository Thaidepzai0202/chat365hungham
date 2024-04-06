import 'dart:typed_data';

import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DisplayAvatar extends StatelessWidget {
  DisplayAvatar({
    Key? key,
    this.size = 36,
    required this.isGroup,
    required this.model,
    this.enable = true,
    this.enabledTapCallback,
  }) : super(key: key);

  final double size;
  final IUserInfo model;
  final bool isGroup;
  final bool enable;
  final VoidCallback? enabledTapCallback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: context.theme.backgroundListChat,
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: _buildChild(context),
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (model.avatar is List<int>) {
      logger.log("Bắt gặp ảnh binary ở:\n${StackTrace.current}",
          name: "$runtimeType._buildChild");
      return Image.memory(
        Uint8List.fromList(model.avatar as List<int>),
        height: size,
        width: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, _, __) => _errorBuilder(context),
      );
    } else if (model.avatar != null &&
        model.avatar is String &&
        (model.avatar as String).isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: model.avatar!.contains('_${model.id}')
            ? model.avatar!
            : model.avatar!.replaceFirst('avatarUser', 'avatar'),
        filterQuality: FilterQuality.high,
        progressIndicatorBuilder: (context, _, __) =>
            _loadBuilder(context, size),
        height: size,
        width: size,
        fit: BoxFit.cover,
        errorWidget: (context, _, __) => _errorBuilder(context),
      );
    }

    return _errorBuilder(context);
  }

  Widget _loadBuilder(context, double size) => _errorBuilder(context);

  Widget _errorBuilder(context) {
    return Image.asset(Images.img_non_avatar);
  }
}

/// Trần Lâm note 12/12/2023:
/// Cũng giống DisplayAvatar nhưng ít chức năng hơn.
/// Chỉ hiển thị avatar thôi
class DisplayAvatarOnly extends StatelessWidget {
  DisplayAvatarOnly({
    Key? key,
    required this.avatar,
    this.userId,
  }) : super(key: key);

  /// Nếu @avatar là binary thì không cần.
  /// Nhưng nếu là String thì phải xử lí logic gì với URL ý.
  /// Đến chịu với thiết kế phần mềm.
  /// Tốt nhất vẫn nên truyền cả userId vào, vì ai biết đâu đấy.
  final int? userId;

  /// Có thể là link, có thể là List<int> (dữ liệu binary)
  final dynamic avatar;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      clipBehavior: Clip.antiAlias,
      child: _buildChild(context),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (avatar is List<int>) {
      return Image.memory(
        Uint8List.fromList(avatar as List<int>),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, _, __) => _errorBuilder(context),
      );
    } else if (avatar is String && (avatar as String).isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: avatar.contains('_${userId}')
            ? avatar
            : avatar.replaceFirst('avatarUser', 'avatar'),
        filterQuality: FilterQuality.high,
        progressIndicatorBuilder: (context, _, __) => _loadBuilder(context),
        fit: BoxFit.cover,
        errorWidget: (context, _, __) => _errorBuilder(context),
      );
    }
    // return _loadBuilder(context, size);

    return _errorBuilder(context);
  }

  Widget _loadBuilder(context) => _errorBuilder(context);

  Widget _errorBuilder(context) {
    return Image.asset(Images.img_non_avatar);
  }
}

var alphabet = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'G',
  'H',
  'I',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'Ư',
  'V',
  'X',
  'W',
  'Z',
  'Y',
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
];

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    Key? key,
    this.dimension,
    this.boxDecoration,
    this.size,
  }) : super(key: key);

  final double? dimension;
  final Size? size;
  final BoxDecoration? boxDecoration;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  get shimmerGradient => LinearGradient(
        colors: const [
          Color(0xFFEBEBF4),
          Color(0xFFF4F4F4),
          Color(0xFFEBEBF4),
        ],
        stops: const [
          0.1,
          0.3,
          0.6,
        ],
        begin: const Alignment(-1.0, -0.3),
        end: const Alignment(1.0, 0.3),
        tileMode: TileMode.clamp,
        transform:
            _SlidingGradientTransform(slidePercent: _shimmerController.value),
      );

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000))
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.values[5],
      shaderCallback: (bounds) => shimmerGradient.createShader(bounds),
      child: Container(
        height: widget.size?.height ?? widget.dimension,
        width: widget.size?.width ?? widget.dimension,
        decoration: widget.boxDecoration?.copyWith(
          color: Colors.white,
        ),
        color: widget.boxDecoration == null ? Colors.white : null,
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
