
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/call/phone_call/model/device_model.dart';
import 'package:app_chat365_pc/utils/data/enums/font_size.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingCall extends StatefulWidget {
  const SettingCall({Key? key,
    required this.windowController})
      : super(key: key);
  final WindowController windowController;
  @override
  State<SettingCall> createState() => _SettingCallState();
}

class _SettingCallState extends State<SettingCall> {

  ValueNotifier<List<String>> listDeviceAudioOutput = ValueNotifier([]);
  ValueNotifier<List<String>> listDeviceAudioInput = ValueNotifier([]);
  ValueNotifier<List<String>> listDeviceVideoInput = ValueNotifier([]);

  @override
  void initState() {
    // TODO: implement initState
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      if(call.method == 'setting_call'){
        listDeviceAudioInput.value = call.arguments['input_audio'].toString().split('*');
        listDeviceAudioOutput.value = call.arguments['output_audio'].toString().split('*');
        listDeviceVideoInput.value = call.arguments['input_video'].toString().split('*');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            child: ValueListenableBuilder(
              valueListenable: listDeviceAudioInput,
              builder: (context,value,_){
                return ValueListenableBuilder(
                  valueListenable: listDeviceAudioOutput,
                  builder: (context,value,_){
                    return ValueListenableBuilder(
                      valueListenable: listDeviceVideoInput,
                      builder: (context,value,_){
                        return  Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 30,bottom: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: AppColors.green1,
                                    width: 1
                                  ),
                                  color: AppColors.green1.withOpacity(0.2)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 5,),
                                    SvgPicture.asset(
                                     Images.ic_video_call,
                                      color: AppColors.black,
                                    ),
                                    SizedBox(width: 5,),
                                    Expanded(
                                      child: Text("Camera đang hoạt động",style: TextStyle(
                                        color: AppColors.black,
                                        fontSize: 15
                                      ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Spacer(),
                                    SvgPicture.asset(
                                      Images.ic_tick,
                                      color: AppColors.green1,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),

                              Text("Camera",
                                style: TextStyle(
                                    color: AppColors.gray,
                                    fontSize: 15
                                ),
                              ),

                              SizedBox(height: 10,),

                              Container(
                                height: 35,
                                padding: EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: AppColors.grayDCDCDC,
                                    width: 1
                                  )
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${listDeviceVideoInput.value[0]}",
                                        style: TextStyle(
                                        color: AppColors.black,
                                        fontSize:  15
                                      ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Spacer(),

                                    SvgPicture.asset(
                                      Images.ic_arrow_down,
                                      color: AppColors.black,
                                    )
                                  ],
                                ),

                              ),

                              SizedBox(height: 10,),

                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                        Images.avatar_user,
                                      ),
                                    fit: BoxFit.cover
                                  ),

                                ),
                              ),

                              SizedBox(height: 15,),


                              Container(
                                margin: EdgeInsets.only(top: 15,bottom: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: AppColors.green1,
                                        width: 1
                                    ),
                                    color: AppColors.green1.withOpacity(0.2)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 5,),
                                    SvgPicture.asset(
                                      Images.ic_mic,
                                      color: AppColors.black,
                                    ),
                                    SizedBox(width: 5,),
                                    Expanded(
                                      child: Text("Micro đang hoạt động",style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 15
                                      ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Spacer(),
                                    SvgPicture.asset(
                                      Images.ic_tick,
                                      color: AppColors.green1,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),

                              Text("Micro",
                                style: TextStyle(
                                    color: AppColors.gray,
                                    fontSize: 15
                                ),
                              ),

                              SizedBox(height: 10,),

                              Container(
                                height: 35,
                                padding: EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                        color: AppColors.grayDCDCDC,
                                        width: 1
                                    )
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${listDeviceAudioInput.value[0]}",
                                        style: TextStyle(
                                            color: AppColors.black,
                                            fontSize:  15
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Spacer(),

                                    SvgPicture.asset(
                                      Images.ic_arrow_down,
                                      color: AppColors.black,
                                    )
                                  ],
                                ),

                              ),

                              SizedBox(height: 15,),


                              Container(
                                margin: EdgeInsets.only(top: 15,bottom: 15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: AppColors.green1,
                                        width: 1
                                    ),
                                    color: AppColors.green1.withOpacity(0.2)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 5,),
                                    SvgPicture.asset(
                                      Images.ic_speaker,
                                      color: AppColors.black,
                                    ),
                                    SizedBox(width: 5,),
                                    Expanded(
                                      child: Text("Loa/tai nghe đang hoạt động",style: TextStyle(
                                          color: AppColors.black,
                                          fontSize: 15
                                      ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Spacer(),
                                    SvgPicture.asset(
                                      Images.ic_tick,
                                      color: AppColors.green1,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),

                              Text("Loa/tai nghe",
                                style: TextStyle(
                                    color: AppColors.gray,
                                    fontSize: 15
                                ),
                              ),

                              SizedBox(height: 10,),

                              Container(
                                height: 35,
                                padding: EdgeInsets.only(left: 5, right: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                        color: AppColors.grayDCDCDC,
                                        width: 1
                                    )
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${listDeviceAudioOutput.value[0]}",
                                        style: TextStyle(
                                            color: AppColors.black,
                                            fontSize:  15
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Spacer(),

                                    SvgPicture.asset(
                                      Images.ic_arrow_down,
                                      color: AppColors.black,
                                    )
                                  ],
                                ),

                              ),

                              SizedBox(height: 10,),

                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
