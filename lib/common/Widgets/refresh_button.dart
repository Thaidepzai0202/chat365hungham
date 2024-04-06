import 'package:app_chat365_pc/common/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RefreshButton extends StatefulWidget {

  final Future<void> Function()? onTap;
  final Color color;
  final double? size;

  const RefreshButton({super.key, this.onTap, required this.color, this.size = 12});

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton> with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {
        if (_controller.status == AnimationStatus.completed) {
          _controller.repeat();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        _controller.forward();
        await Future.wait<dynamic>([
          Future.delayed(const Duration(milliseconds: 1400)),
          if (widget.onTap != null) widget.onTap!()
        ]);
        _controller.reset();
        _controller.stop();
      },
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
        child: SvgPicture.asset(
          Images.ic_refresh_clean,
          width: widget.size,
          height: widget.size,
          colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
        ),
      ),
    );
  }
}