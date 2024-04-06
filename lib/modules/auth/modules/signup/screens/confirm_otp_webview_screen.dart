import 'package:app_chat365_pc/common/blocs/network_cubit/network_cubit.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/login_model.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';

import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/cubit/login_cubit.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/login_singup.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/enums/type_screen_to_otp.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

class ConfirmOtpWebViewScreen extends StatefulWidget {
  ConfirmOtpWebViewScreen(
      {Key? key,
      required this.email,
      this.typeOTP = TypeScreenToOtp.FORGOTPASSWORD,
      this.userInfo,
      this.userType,
      this.isMD5 = true})
      : super(key: key) {
    // AuthRepo().emitLogin(userInfo?.id ?? int.parse(email));
    chatClient
      ..on(ChatSocketEvent.confirmOTPForgot, (res) async {
        logger.log('${res.toString()}', name: 'On Socket vào sai');
        if (res[0] == AuthRepo.deviceID && res[1] as bool) {
          await confirmSuccessHandle();
        }
      })
      ..on(ChatSocketEvent.confirmOTPAuth, (res) async {
        logger.log('${res.toString()}', name: 'On Socket vào đúng');
        // if (res == true) {
        //   loginHandle();
        // }
      });
  }

  BuildContext get context => navigatorKey.currentContext!;

  loginHandle() async {
    await ApiClient().fetch(
      ApiPath.verifyOtp,
      // method: RequestMethod.get,
      data: {
        'email': email,
        'type_user': userInfo!.userType,
      },
      options: Options(
        receiveTimeout: Duration(milliseconds: 10000),
      ),
    );
    // await context.read<LoginCubit>().login(
    //     userInfo!.userType!, LoginModel(email, userInfo!.password!),
    //     isMD5Pass: isMD5, verifyRequire: false);
    await context.read<LoginCubit>().login(
        userType!, LoginModel(email, userInfo!.password!),
        isMD5Pass: isMD5, verifyRequire: false);
  }

  confirmSuccessHandle({String from = 'socket'}) async {
    if (this.typeOTP == TypeScreenToOtp.FORGOTPASSWORD) {
      logger.log('Vào 1 from $from');
      // AppRouter.replaceWithPage(context, AppPages.Auth_UpdatePass, arguments: {
      //   'userTypeArg': userInfo?.userType ?? AuthRepo().userType,
      //   'email': email,
      // });
    } else {
      logger.log('Vào 2 from $from');
      //AppDialogs.showLoadingCircle(context);
      await Future.delayed(Duration(milliseconds: 500));
      await loginHandle();
    }

    //AppDialogs.showLoadingCircle(context);
    await Future.delayed(Duration(milliseconds: 500));
    //await loginHandle();
  }

  final String email;
  final TypeScreenToOtp typeOTP;
  final IUserInfo? userInfo;
  final bool isMD5;
  final UserType? userType;

  @override
  State<ConfirmOtpWebViewScreen> createState() =>
      _ConfirmOtpWebViewScreenState();
}

class _ConfirmOtpWebViewScreenState extends State<ConfirmOtpWebViewScreen>
    with WidgetsBindingObserver {
  //WebViewController? _viewController;
  bool? _webviewAvailable;
  late TextEditingController _controller;
  @override
  void initState() {
    //WidgetsBinding.instance.addObserver(this);
    _controller = TextEditingController(
      text: widget.typeOTP == TypeScreenToOtp.CONFIRMACCOUNT
          ? ApiPath.sendOtpRegisterPhoneNumber(
              widget.email, widget.userInfo?.userType?.reverseID ?? 0)
          : ApiPath.sendOtpForgotPassPhoneNumber(widget.email),
    );
    WebviewWindow.isWebviewAvailable().then((value) {
      setState(() {
        _webviewAvailable = value;
      });
    });
    super.initState();
    //web();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void web() async {
    try {
      final webview = await WebviewWindow.create(
        configuration: CreateConfiguration(
          title: "Xác thực OTP",
          windowWidth: 1280,
          windowHeight: 720,
          userDataFolderWindows: (await getApplicationCacheDirectory()).path
        ),
      );
      webview
        ..setBrightness(Brightness.dark)
        ..setApplicationNameForUserAgent(" WebviewExample/1.0.0")
        ..launch(_controller.text)
        ..addOnUrlRequestCallback((url) {
          debugPrint('url: $url');
          final uri = Uri.parse(url);
          debugPrint("--------------------${uri.path}");
          if (url.contains("chat365.timviec365.vn")) {
            debugPrint('----Sign-up-Success----');
            webview.close();
            if (widget.typeOTP == TypeScreenToOtp.CONFIRMACCOUNT) {
              print('--------------Tạo-tài-khoản---------------');
              widget.confirmSuccessHandle();
            } else if (widget.typeOTP == TypeScreenToOtp.FORGOTPASSWORD) {
              print('--------------Lấy-lại-mật-khẩu-----------');
              AppRouter.replaceWithPage(context, AppPages.Auth_UpdatePass,
                  arguments: {
                    'userTypeArg': widget.userInfo!.userType,
                    'email': widget.email,
                  });
            }
          }
        })
        ..onClose.whenComplete(() {
          debugPrint("on close");
        });
      await Future.delayed(const Duration(seconds: 10));
      for (final javaScript in _javaScriptToEval) {
        try {
          final ret = await webview.evaluateJavaScript(javaScript);
          debugPrint('evaluateJavaScript: $ret');
        } catch (e) {
          debugPrint('evaluateJavaScript error: $e \n $javaScript');
        }
      }
    } catch (e) {
      print("Loi OTP roi");
    }
  }

  late final webView;

  @override
  Widget build(BuildContext context) {
    print(ApiPath.sendOtpForgotPassPhoneNumber(widget.email));
    return MultiBlocListener(
        listeners: [
          BlocListener<NetworkCubit, NetworkState>(
            listenWhen: (previous, current) =>
                !previous.hasInternet && current.hasInternet,
            listener: (context, networkState) {
              if (networkState.hasInternet) {}
              // AuthRepo()
              //     .emitLogin(widget.userInfo?.id ?? int.parse(widget.email));
            },
          ),
          // BlocListener<LoginCubit, LoginState>(
          //   listener: (context, state) {
          //     //!Phai dat o day moi hien len duoc
          //     if (state is LoginStateUnBrowser) {
          //       // AppDialogs.hideLoadingCircle(context);
          //       logger.log('Có trigger chưa duyệt signup', color: StrColor.cyan);
          //       //AppDialogs.showMessConfirm(context, state.nameCompany);
          //     }
          //   },
          // ),
        ],
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      appWindow.position = Offset(
                        appWindow.position.dx + details.localPosition.dx,
                        appWindow.position.dy + details.localPosition.dy,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LogoCompany(),
                        WindowButtonSmall(),
                      ],
                    ),
                  ),
                  color: AppColors.white,
                ),
                Container(
                  color: AppColors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          Images.ic_back,
                          width: 70,
                          height: 70,
                          color: AppColors.primary,
                        ),
                        iconSize: 50,
                        onPressed: () {
                          AppRouter.back(context);
                          //AppRouter.toPage(context, AppPages.logIn);
                        },
                      ),
                      SizedBox(
                        width: 110,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
                        child: SvgPicture.asset(
                          Images.big_chat365,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    height: MediaQuery.of(context).size.height - 165,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(Images.img_back_ground_login),
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          // '${AppLocalizations.of(context)!.confirmPhone} ${widget.userInfo!.userType!.type}',
                          '${AppLocalizations.of(context)!.confirmPhone} ',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary),
                        ),
                        SizedBox(
                          height: 100,
                        ),
                        Container(
                          width: 360,
                          height: 42,
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: SvgPicture.asset(Images.ic_email)),
                              SizedBox(width: 70),
                              Text(
                                widget.email,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2.0,
                                    color: AppColors.grey666),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              // Viền
                              color: AppColors.gray,
                              width: 1.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(18.0), // Bo tròn cạnh
                          ),
                        ),
                        SizedBox(height: 40),
                        ElevatedButton(
                          // onPressed: () async {
                          //   final webview = await WebviewWindow.create(
                          //     configuration: CreateConfiguration(
                          //       windowHeight: 1280,
                          //       windowWidth: 720,
                          //       title: "ExampleTestWindow",
                          //       userDataFolderWindows: await _getWebViewPath(),
                          //     ),
                          //   );
                          //   webview
                          //     ..registerJavaScriptMessageHandler("test",
                          //         (name, body) {
                          //       debugPrint('on javaScipt message: $name $body');
                          //     })
                          //     ..setApplicationNameForUserAgent(
                          //         " WebviewExample/1.0.0")
                          //     ..setPromptHandler((prompt, defaultText) {
                          //       if (prompt == "test") {
                          //         return "Hello World!";
                          //       } else if (prompt == "init") {
                          //         return "initial prompt";
                          //       }
                          //       return "";
                          //     })
                          //     ..launch("http://youtube.com");
                          // },
                          onPressed: _webviewAvailable != true ? null : web,

                          child: Text(
                            AppLocalizations.of(context)!.getVerificationCode,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          style: ButtonStyle(
                            minimumSize:
                                MaterialStateProperty.all(Size(370, 45)),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.doHaveAnAccount,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              child: Text(
                                AppLocalizations.of(context)!.signIn,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  AppRouter.toPage(
                                      context, AppPages.ChoosePosition,
                                      arguments: {'isLogIn': true});
                                });
                              },
                            )
                          ],
                        )
                      ],
                    ))
              ],
            ),
          ),
        ));
  }
}

const _javaScriptToEval = [
  """
  function test() {
    return;
  }
  test();
  """,
  'eval({"name": "test", "user_agent": navigator.userAgent})',
  '1 + 1',
  'undefined',
  '1.0 + 1.0',
  '"test"',
];

// Future<String> _getWebViewPath() async {
//   final document = await getApplicationDocumentsDirectory();
//   return p.join(
//     document.path,
//     'desktop_webview_window',
//   );
// }
