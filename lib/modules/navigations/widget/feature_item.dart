import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FeatureItem extends StatelessWidget {
  const FeatureItem({
    Key? key,
    required this.assetPath,
    required this.gradient,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  final String assetPath;
  final Gradient gradient;
  final String label;
  final VoidCallback onTap;

  // final GlobalKey<State> _key = GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 326/4,
      child: MaterialButton(
        onPressed: () async {
          // logger.log('${_key.currentContext?.size}');
          // Navigator.of(context).popUntil((r) => r is! OverlayRoute);
          //Overlay.of(context).clearObserveOverlay();
          await Future.delayed(Duration(milliseconds: 200));
          onTap();
        },
        child: Column(
          children: [
            Container(
              height: 46,
              width: 46,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: (46 - 24) / 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
              child: SvgPicture.asset(
                assetPath,
                color: AppColors.white,
                width: 22,height: 22,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
