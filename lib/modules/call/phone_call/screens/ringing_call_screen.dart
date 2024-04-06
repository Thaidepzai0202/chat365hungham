
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/data/services/call_client_service/call_client_events.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/call/phone_call/widget/circle_button.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/router/app_router_helper.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/call_client.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class RingingCall extends StatefulWidget {
  const RingingCall({Key? key,
    required this.idRoom,
    required this.idCaller,
    required this.idCallee,
    required this.checkCall,
    required this.nameAnother,
    this.avatarAnother,
    required this.payload}) : super(key: key);

  final String idRoom;
  final String idCaller;
  final String idCallee;
  final bool checkCall;
  final String nameAnother;
  final String? avatarAnother;
  final dynamic payload;

  @override
  State<RingingCall> createState() => _RingingCallState();
}

class _RingingCallState extends State<RingingCall> {

  ValueNotifier<bool> check = ValueNotifier(false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callEnded();
    check.addListener(() {
      if(check.value){
         _endCall();
      }
    });

  }

  callEnded() {
    callClient.on(CallClientEvents.CALL_ENDED, (response) {
      _endCall();
    });
  }

  _endCall(){
    if (overlayState1 == null) {
      AppRouter.back(context);
    } else {
      try {
        callEntry1?.remove();
      } catch (e) {}
      callEntry1 = null;
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: Center(
          child: Container(
            color: AppColors.blueGradients1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 35,),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100)
                  ),
                  child: widget.avatarAnother != null ?
                  CachedNetworkImage(
                    fit: BoxFit.contain,
                    imageUrl: widget.avatarAnother!,
                    errorWidget:
                        (_, __, ___) {
                      return Image.asset(
                        Images.img_chat365,
                        height: 100,
                        width: 100,
                      );
                    },
                  ):
                  Image.asset(
                    fit: BoxFit.cover, Images.img_non_avatar,
                    height: 100,
                    width: 100,
                  ),
                ),

                SizedBox(height: 30,),

                Text(widget.nameAnother, style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                    fontSize: 18
                ),),

                SizedBox(height: 30,),

                Text( widget.payload['callType'] == 1 ? "Chat365: Cuộc gọi video đến" : "Chat365: Cuộc gọi thoại đến" , style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18
                ),
                ),

                SizedBox(height: 30,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    CircleButton(
                      onTap: (){
                        ccService.rejectCall();
                        _endCall();
                      },
                      assestIcon: Images.ic_hang_up,
                      enable: true,
                      backgroundColor: AppColors.red,
                      widthIcon: 25,
                    ),

                    SizedBox(width: 40,),

                    CircleButton(
                      onTap: () async {
                        AppRouterHelper.toCallScreen(
                            idRoom: widget.idRoom,
                            idCaller: widget.idCaller,
                            idCallee: AuthRepo().userId.toString(),
                            checkCallee: true,
                            checkCall: widget.payload['callType'] == 1 ? true : false,
                            nameAnother: widget.nameAnother,
                            avatarAnother: widget.avatarAnother,
                            accepted: true
                        );
                        check.value = true;
                      },
                      assestIcon: Images.ic_video_call,
                      enable: true,
                      backgroundColor: AppColors.active,
                      widthIcon: 25,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // return Scaffold(
    //   body: Container(
    //     child: Center(
    //       child: Container(
    //         color: AppColors.blueGradients1,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             SizedBox(height: 50,),
    //             Container(
    //               height: 150,
    //               width: 150,
    //               decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(150)
    //               ),
    //               child: widget.avatarAnother != null ?
    //               CachedNetworkImage(
    //                 fit: BoxFit.contain,
    //                 imageUrl: widget.avatarAnother!,
    //                 errorWidget:
    //                     (_, __, ___) {
    //                   return Image.asset(
    //                       Images.img_chat365,
    //                     height: context.mediaQuerySize.width * 0.4,
    //                     width: context.mediaQuerySize.width * 0.4,
    //                   );
    //                 },
    //               ):
    //               Image.asset(
    //                 fit: BoxFit.cover, Images.img_non_avatar,
    //                 height: context.mediaQuerySize.width * 0.4,
    //                 width: context.mediaQuerySize.width * 0.4,
    //               ),
    //             ),
    //
    //             SizedBox(height: 30,),
    //
    //             Text(widget.nameAnother, style: TextStyle(
    //                 fontWeight: FontWeight.w500,
    //                 color: AppColors.white,
    //                 fontSize: 40
    //             ),),
    //
    //             SizedBox(height: 30,),
    //
    //             Text( widget.payload['callType'] == 1 ? "Chat365: Cuộc gọi video đến" : "Chat365: Cuộc gọi thoại đến" , style: TextStyle(
    //                 color: AppColors.white,
    //                 fontSize: 35
    //             ),
    //             ),
    //
    //             SizedBox(height: 70,),
    //
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //
    //                 CircleButton(
    //                   onTap: (){
    //                     ccService.rejectCall();
    //                    _endCall();
    //                   },
    //                   assestIcon: Images.ic_hang_up,
    //                   enable: true,
    //                   backgroundColor: AppColors.red,
    //                   widthIcon: 50,
    //                 ),
    //
    //                 SizedBox(width: 90,),
    //
    //                 CircleButton(
    //                   onTap: () async {
    //                     AppRouterHelper.toCallScreen(
    //                         idRoom: widget.idRoom,
    //                         idCaller: widget.idCaller,
    //                         idCallee: AuthRepo().userId.toString(),
    //                         checkCallee: true,
    //                         checkCall: widget.payload['callType'] == 1 ? true : false,
    //                         nameAnother: widget.nameAnother,
    //                         avatarAnother: widget.avatarAnother,
    //                         accepted: true
    //                     );
    //                     check.value = true;
    //                   },
    //                   assestIcon: Images.ic_video_call,
    //                   enable: true,
    //                   backgroundColor: AppColors.active,
    //                   widthIcon: 50,
    //                 )
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}


