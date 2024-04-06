import 'package:flutter/cupertino.dart';

class PowerPolicy extends StatelessWidget {
  const PowerPolicy({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container();
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         RichText(
    //           text: TextSpan(children: [
    //             TextSpan(
    //                 text: 'Bằng cách tiếp tục, bạn đồng ý với ',
    //                 style: AppTextStyles.regularW400(
    //                   context,
    //                   size: 12,
    //                 )),
    //             TextSpan(
    //                 text: StringConst.termsOfUsages,
    //                 recognizer: TapGestureRecognizer()
    //                   ..onTap = () {
    //                     openUrl(StringConst.termOfUsageLink);
    //                   },
    //                 style: AppTextStyles.regularW400(context,
    //                         size: 12,
    //                         color: AppColors.primary,
    //                         fontStyle: FontStyle.italic)
    //                     .copyWith(decoration: TextDecoration.underline))
    //           ]),
    //         ),
    //       ],
    //     ),
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         RichText(
    //           text: TextSpan(style: TextStyle(height: 2), children: [
    //             TextSpan(
    //                 text: 'và ',
    //                 style: AppTextStyles.regularW400(
    //                   context,
    //                   size: 12,
    //                 )),
    //             TextSpan(
    //                 text: StringConst.privatePowers + ',',
    //                 recognizer: TapGestureRecognizer()
    //                   ..onTap = () {
    //                     openUrl(StringConst.privatePowerLink);
    //                   },
    //                 style: AppTextStyles.regularW400(context,
    //                         size: 12,
    //                         color: AppColors.primary,
    //                         fontStyle: FontStyle.italic)
    //                     .copyWith(decoration: TextDecoration.underline)),
    //             TextSpan(text: '  '),
    //             TextSpan(
    //                 text: StringConst.privacyPolicy,
    //                 recognizer: TapGestureRecognizer()
    //                   ..onTap = () {
    //                     openUrl(StringConst.privacyPolicyLink);
    //                   },
    //                 style: AppTextStyles.regularW400(context,
    //                         size: 12,
    //                         color: AppColors.primary,
    //                         fontStyle: FontStyle.italic)
    //                     .copyWith(decoration: TextDecoration.underline)),
    //           ]),
    //         ),
    //       ],
    //     ),
    //     // Text(
    //     //   StringConst.privatePowers,
    //     //   style: TextStyle(fontSize: 12, color: context.theme.textColor),
    //     // ),
    //     // Text(
    //     //   StringConst.termsOfUsages,
    //     //   style: TextStyle(fontSize: 12, color: context.theme.textColor),
    //     // ),
    //     // Text(
    //     //   StringConst.privacyPolicy,
    //     //   style: TextStyle(fontSize: 12, color: context.theme.textColor),
    //     // ),
    //     SizedBoxExt.h12,
    //   ],
    // );
  }
}
