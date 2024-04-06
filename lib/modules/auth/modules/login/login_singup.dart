//import 'package:app_chat365_pc/common/blocs/login_cubit/login_cubit.dart';
import 'dart:async';

import 'package:app_chat365_pc/common/blocs/chat_bloc/chat_bloc.dart';
import 'package:app_chat365_pc/common/blocs/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:app_chat365_pc/common/blocs/typing_detector_bloc/typing_detector_bloc.dart';
import 'package:app_chat365_pc/common/blocs/unread_message_counter_cubit/unread_message_counter_cubit.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/bloc/user_info_bloc.dart';
import 'package:app_chat365_pc/common/blocs/user_info_bloc/repo/user_info_repo.dart';
import 'package:app_chat365_pc/common/components/display/display_avatar.dart';
import 'package:app_chat365_pc/common/models/login_model.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/repos/chat_repo.dart';
import 'package:app_chat365_pc/core/constants/app_enum.dart';
import 'package:app_chat365_pc/core/constants/chat_socket_event.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/constants/status_code.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/auth/linkweb/model/link_web_model.dart';
import 'package:app_chat365_pc/modules/auth/modules/forgot_password/forgot_password_screen.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/cubit/login_cubit.dart';
import 'package:app_chat365_pc/modules/auth/widgets/custom_auth_scaffold.dart';
import 'package:app_chat365_pc/modules/auth/widgets/email_field.dart';
import 'package:app_chat365_pc/modules/auth/widgets/password_field.dart';
import 'package:app_chat365_pc/modules/chat/notification/notificationChat.dart';
import 'package:app_chat365_pc/modules/chat_conversations/chat_conversation_bloc/chat_conversation_bloc.dart';
import 'package:app_chat365_pc/modules/layout/cubit/app_layout_cubit.dart';
import 'package:app_chat365_pc/modules/layout/pages/main_pages.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/sign_up.dart';
import 'package:app_chat365_pc/utils/data/clients/chat_client.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_mode.dart';
import 'package:app_chat365_pc/utils/data/enums/type_screen_to_otp.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/validators.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:sp_util/sp_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class LogInOrSignUp extends StatefulWidget {
  @override
  _LogInOrSignUpState createState() => _LogInOrSignUpState();
}

class _LogInOrSignUpState extends State<LogInOrSignUp> {
  Offset position = const Offset(0, 0);
  StreamSubscription<Uri>? _linkSubscription;
  late final LoginCubit _loginCubit;
  late final AppLayoutCubit _appLayoutCubit;
  late ChatDetailBloc _chatDetailBloc;
  late ChatConversationBloc _chatConversationBloc;
  late TypingDetectorBloc _typingDetectorBloc;

  @override
  void initState() {
    super.initState();
    _loginCubit = context.read<LoginCubit>();

    doWhenWindowReady(() {
      var initialSize = const Size(450, 690);
      appWindow.minSize = initialSize;
      appWindow.maxSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });

    _linkSubscription = appLinks.uriLinkStream.listen((uri) async {
      print('linkwebtoapp : $uri');
      LinkWebModel checkweb = makeInformationFromApp(uri.toString());
      print(
          'onAppLink: ${checkweb.id} ${checkweb.idEmployer} ${checkweb.positionType} ${checkweb.idConversation} ');
      appWindow.show();
      IUserInfo? newAccountFromWeb;
      newAccountFromWeb = await UserInfoRepo().getUserInfo(checkweb.id);

      print(
          "------${newAccountFromWeb!.userType!}--------${newAccountFromWeb!.email!}----------${newAccountFromWeb!.password!}-------");

      _linkSubscription?.cancel();

      if (checkweb.id != 0) {
        await _loginCubit.login(newAccountFromWeb.userType!,
            LoginModel(newAccountFromWeb.email!, newAccountFromWeb.password!),
            isMD5Pass: true);
        AppRouter.toPage(context, AppPages.appLayOut,
            arguments: {'UserInfo': AuthRepo().userInfo,'receiveID':checkweb.idEmployer});
      }

      print(
          '-----------------Link từ web sang app mà đăng nhập được------------------------');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.img_back_ground_login),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              color: AppColors.white,
              child: GestureDetector(
                onPanUpdate: (details) {
                  appWindow.position = Offset(
                    appWindow.position.dx + details.delta.dx,
                    appWindow.position.dy + details.delta.dy,
                  );
                },
                onDoubleTap: () {
                  // showWithSmallImage('cc','cccccc');
                },

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LogoCompany(),
                    WindowButtonSmall(),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 70),
              child: SvgPicture.asset(
                Images.big_chat365,
                width: 150,
                height: 150,
              ),
            ),
            ElevatedButton(
              child:  Text(
                AppLocalizations.of(context)!.signIn,
                style: TextStyle(fontSize: 17),
              ),
              style: ElevatedButton.styleFrom(
                primary: AppColors.primary,
                fixedSize: const Size(371, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              onPressed: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => ChoosePosition(isLogIn:true)));

                AppRouter.toPage(context, AppPages.ChoosePosition,
                    arguments: {'isLogIn': true});

                ///-----------------------------chuyển sang trang chính
                // var initialSize = Size(800, 720);
                // appWindow.minSize = initialSize;
                // appWindow.maxSize = Size(2000, 1200);
                // appWindow.size = Size(1200, 750);
                // appWindow.alignment = Alignment.center;
                // AppRouter.toPage(context,AppPages.testPage);
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => MultiProvider(
                //       providers: [
                //         ChangeNotifierProvider(
                //           create: (context) => DataModel(),
                //         ),
                //       ],
                //       child: HomeScreen(),
                //     ),
                //   ),
                // );
              },

            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Text(
                  AppLocalizations.of(context)!.doNotHaveAnAccount,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                    child:  Text(
                      AppLocalizations.of(context)!.signUp,
                      style: TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        AppRouter.toPage(context, AppPages.ChoosePosition,
                            arguments: {'isLogIn': false});
                      });
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}

class LogoCompany extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 29,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10,
          ),
          SvgPicture.asset(
            AssetPath.logo_non_text,
            width: 29,
            height: 29,
          ),
          Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              SvgPicture.asset(
                AssetPath.chat365,
                height: 13,
              ),
              SvgPicture.asset(
                AssetPath.timviec365,
                height: 9,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class WindowButtonSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(),
        MaximizeWindowButton(
          onPressed: () {},
          colors: WindowButtonColors(
            iconNormal: AppColors.greyCF,
            mouseDown: Colors.transparent,
            mouseOver: Colors.transparent,
            iconMouseDown: AppColors.greyCF,
            iconMouseOver: AppColors.greyCF,
          ),
        ),
        CloseWindowButton(onPressed: () {
          appWindow.hide();
        },),
      ],
    );
  }
}

class ChoosePosition extends StatefulWidget {
  final bool isLogIn;
  ChoosePosition({required this.isLogIn});
  @override
  _ChoosePosotion createState() => _ChoosePosotion();
}

class _ChoosePosotion extends State<ChoosePosition> {
  String yourchoose = '';
  bool extend = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.img_back_ground_login),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width,
              color: AppColors.white,
              child: GestureDetector(
                onPanUpdate: (details) {
                  appWindow.position = Offset(
                    appWindow.position.dx + details.delta.dx,
                    appWindow.position.dy + details.delta.dy,
                  );
                },
                onDoubleTap: () {
                  // showWithSmallImage('thai', 'aloaloaloa','https://game8.vn/media/2016/09/05/20160905214254_12990887_933174810114738_5839333914073107908_n.jpg');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LogoCompany(),
                    WindowButtonSmall(),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    // Quay lại trang trước đó khi nút back được nhấn
                    AppRouter.toPage(context, AppPages.logIn);
                  },
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 10),
                  child: SvgPicture.asset(
                    Images.big_chat365,
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(width: 66,)
              ],
            ),
            Text(
                '${AppLocalizations.of(context)!.pleaseSelectAnAccountTo} ${widget.isLogIn ? AppLocalizations.of(context)!.signIn : AppLocalizations.of(context)!.signUp}!',
                style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.black60,
                    fontWeight: FontWeight.w600)),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      yourchoose = AppLocalizations.of(context)!.personal2;
                      userType = UserType.customer;
                      if (widget.isLogIn) {
                        AppRouter.toPage(context, AppPages.inPutLogIn,
                            arguments: {InPutLogIn.userTypeArg: userType});
                      } else {
                        AppRouter.toPage(context, AppPages.inPutSignUp,
                            arguments: {'yourchoose': yourchoose});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: AppColors.white,
                      fixedSize: const Size(230, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15.0), // Độ bo góc của nút
                        side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.0), // Đường viền của nút
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Images.account_box,
                          width: 40,
                          height: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                         Text(
                          AppLocalizations.of(context)!.personal2,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    )),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        extend = !extend;
                        //AppRouter.toPage(context, page);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: AppColors.white,
                      fixedSize: const Size(60, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.0),
                      ),
                    ),
                    child: SvgPicture.asset(
                      extend ? Images.ic_remove_auth : Images.add,
                      width: 40,
                      height: 40,
                      color: AppColors.primary,
                    )),
              ],
            ),
            extend
                ? Container(
                    width: 300,
                    height: 170,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              yourchoose = AppLocalizations.of(context)!.employee2;
                              userType = UserType.staff;
                              if (widget.isLogIn) {
                                AppRouter.toPage(context, AppPages.inPutLogIn,
                                    arguments: {
                                      InPutLogIn.userTypeArg: userType
                                    });
                              } else {
                                AppRouter.toPage(context, AppPages.inPutSignUp,
                                    arguments: {'yourchoose': yourchoose});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              primary: AppColors.white,
                              fixedSize: const Size(300, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15.0), // Độ bo góc của nút
                                side: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.0), // Đường viền của nút
                              ),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  Images.ic_switch_account,
                                  width: 40,
                                  height: 40,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.employee2,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                                )
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              yourchoose = AppLocalizations.of(context)!.company2;
                              userType = UserType.company;
                              if (widget.isLogIn) {
                                AppRouter.toPage(context, AppPages.inPutLogIn,
                                    arguments: {
                                      InPutLogIn.userTypeArg: userType
                                    });
                              } else {
                                AppRouter.toPage(context, AppPages.inPutSignUp,
                                    arguments: {'yourchoose': yourchoose});
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              primary: AppColors.white,
                              fixedSize: const Size(300, 60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: const BorderSide(
                                    color: AppColors.primary, width: 1.0),
                              ),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  Images.ic_company,
                                  width: 40,
                                  height: 40,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.company2,
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            )),
                      ],
                    ),
                  )
                : Container(
                    width: 250,
                    height: 170,
                  ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.isLogIn
                      ? AppLocalizations.of(context)!.doNotHaveAnAccount
                      : AppLocalizations.of(context)!.doHaveAnAccount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                  child: Text(
                    widget.isLogIn ? AppLocalizations.of(context)!.signUp : AppLocalizations.of(context)!.signIn,
                    style: const TextStyle(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      widget.isLogIn
                          ? AppRouter.toPage(context, AppPages.ChoosePosition,
                              arguments: {'isLogIn': false})
                          : AppRouter.toPage(context, AppPages.ChoosePosition,
                              arguments: {'isLogIn': true});
                    });
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class InPutLogIn extends StatefulWidget {
  InPutLogIn({
    Key? key,
    this.onSuccess,
    required this.userType,
    this.mode,
  }) : super(key: key);

  final VoidCallback? onSuccess;
  final UserType userType;
  final AuthMode? mode;

  static const userTypeArg = 'userTypeArg';
  static const authMode = 'authMode';
  @override
  _InPutLogInState createState() => _InPutLogInState();
}

class _InPutLogInState extends State<InPutLogIn>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin {
  TextEditingController contactLoginTEC = TextEditingController();
  TextEditingController passUse = TextEditingController();
  late final ValueNotifier<String> email;
  bool isQr = false;
  bool _obscureText = true;
  late final LoginCubit _loginCubit;
  late final GlobalKey<FormState> _formKey;
  late final AuthRepo _authRepo;
  late final TextEditingController pass;
  late TabController _controller;
  final FocusNode _emailNode = FocusNode(), _passNode = FocusNode();

  bool _showDialog = false;

  String? Function(String?)? _validatorPassword;
  String? Function(String?)? _validatorAccount;

  get loginModel => LoginModel(
        contactLoginTEC.text.valueIfNull(_loginCubit.emailQR ?? ''),
        pass.text.valueIfNull(_loginCubit.passQR ?? ''),
      );

  bool _rememberAccount = true;
  bool _checkLogin = true;

  void _enterToLogin(key) {
    if (key.isKeyPressed(LogicalKeyboardKey.enter) && mounted)
      _btnLoginPressedHandler(context);
  }

  _verifyHandle() async {
    if (!contactLoginTEC.text.contains('@')) {
      AppRouter.toPage(context, AppPages.Auth_ConfirmOTPWebView, arguments: {
        'email': contactLoginTEC.text,
        'typeOTP': TypeScreenToOtp.CONFIRMACCOUNT,
        'userInfo': UserInfo(
            id: -1,
            userName: '',
            avatarUser: '',
            active: UserStatus.online,
            email: contactLoginTEC.text,
            password: passUse.text,
            userType: widget.userType),
        'isMD5': false,
      });
    } //else
    // AppRouter.toPage(context, AppPages.Auth_ConfirmOTP,
    //     blocValue: SignUpCubit.instance,
    //     arguments: {
    //       ConfirmOTPScreen.isPhoneNumberKey:
    //           !contactLoginTEC.text.contains('@'),
    //       ConfirmOTPScreen.idTypeScreenToOtp: TypeScreenToOtp.CONFIRMACCOUNT,
    //       ConfirmOTPScreen.idEmail: contactLoginTEC.text,
    //       ConfirmOTPScreen.idPassword: pass.text
    //     });
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 2);
    _loginCubit = context.read<LoginCubit>();
    _authRepo = context.read<AuthRepo>();
    _formKey = GlobalKey<FormState>();
    _loginCubit.listenForQRLoginSocket();
    chatClient.stream.listen((event) {
      if (event is ChatEventOnQRLogin) {
        _loginCubit.login(
          UserType.fromId(event.userType),
          LoginModel(
            event.account,
            event.md5,
          ),
          rememberAccount: _rememberAccount,
          isMD5Pass: true
        );
      }
    });
    email = ValueNotifier('');
    // _validatorEmail =
    //     (value) => Validator.requiredInputEmailValidator(contactLoginTEC.text);
    _validatorAccount = (value) =>
        Validator.requiredInputPhoneOrEmailValidator(contactLoginTEC.text);
    _validatorPassword =
        (value) => Validator.requiredNoBlankEmptyPasswordValidator(
              pass.text,
            );
    contactLoginTEC = TextEditingController();
    pass = TextEditingController();

    _emailNode.addListener(_listener);
    _passNode.addListener(_listener);
    //getDeviceInfo();
    WidgetsBinding.instance.addObserver(this as WidgetsBindingObserver);
  }

  bool get _hasFocus => _emailNode.hasFocus || _passNode.hasFocus;

  _listener() {
    if (_hasFocus && mounted) {
      setState(() {
        _validatorAccount = null;
        _validatorPassword = Validator.validateLoginPassword;
      });
    }
  }

  bool extend = false;
  bool rememberMe = true;

  @override
  void dispose() {
    _emailNode.dispose();
    _passNode.dispose();
    pass..removeListener(_listener);
    contactLoginTEC..removeListener(_listener);
    email.dispose();
    super.dispose();
  }

  _handleChangeRememberAccountState(bool? value) => _rememberAccount = value!;

  _btnLoginPressedHandler(BuildContext context) {
    var emailText = contactLoginTEC.text;
    var passText = passUse.text;
    FocusManager.instance.primaryFocus?.unfocus();
    print(_formKey.currentState?.validate());
    if (_formKey.currentState?.validate() == true) {
      // AppDialogs.showLoadingCircle(context);
      _loginCubit.login(
        widget.userType,
        LoginModel(
          emailText,
          passText,
        ),
        rememberAccount: _rememberAccount,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMacOS = Theme.of(context).platform == TargetPlatform.macOS;


    return CustomAuthScaffold(
      title: '',
      showBottomBackgroundImage: true,
      resizeToAvoidBottomInset: false,
      useAppBar: false,
      child: BlocListener<LoginCubit, LoginState>(
        bloc: _loginCubit,
        listener: (context, state) async {
          print('______________${passUse.text}');
          await SpUtil.putString(LocalStorageKey.passwordClass, passUse.text);
          print('____________${SpUtil.getString(LocalStorageKey.passwordClass)}');
          if (state is LoginStateError) {
            //Sai tai khoan mat khau
    
            if (state.errorRes?.messages != null &&
                state.errorRes!.code == 308) {
              final String? loginError = state.errorRes!.messages;
              print('Sai mật khẩu ----------------$loginError');
              setState(() {
                _validatorAccount = (value) => loginError;
                _validatorPassword = (value) => loginError;
              });
            }
    
            //*Tai khoan cong ty chua xac thuc
            else if (state.errorRes?.messages != null &&
                state.errorRes!.code == 402) {
              if (_showDialog)
                AppDialogs.showLoginErrorDialog(context, actions: [
                  CupertinoButton(
                      child: const Text('Sử dụng tài khoản khác'),
                      onPressed: () {
                        _showDialog = false;
                        AppRouter.back(context);
                      }),
                  CupertinoButton(
                      child: const Text('Xác thực'),
                      onPressed: () {
                        //AppDialogs.hideLoadingCircle(context);
                        _showDialog = false;
                        _verifyHandle();
                      }),
                ]);
              else
                _verifyHandle();
            }
          }
    
          //Tai khoan nhan vien chua duoc cong ty duyet
          else if (state is LoginStateUnBrowser) {
            //AppDialogs.hideLoadingCircle(context);
            AppDialogs.showMessConfirm(context, state.nameCompany);
          }
          //Sai loại tài khoản
          else if (state is LoginStateAlternateType) {
            print('Sai loại tài khoản-------------');
            print("----------------Loi-sai-loai-tai-khoan------------------");
            UserType rightUserType;
            switch (state.type) {
              case 0:
                rightUserType = UserType.customer;
                break;
              case 1:
                rightUserType = UserType.company;
                break;
              case 2:
                rightUserType = UserType.staff;
                break;
              default:
                rightUserType = UserType.customer;
            }
    
            void _loginCallback(UserType rightUserType) {
              var emailText = contactLoginTEC.text;
              var passText = passUse.text;
              FocusManager.instance.primaryFocus?.unfocus();
              if (_formKey.currentState?.validate() == true) {
                _loginCubit.login(
                  rightUserType,
                  LoginModel(
                    emailText,
                    passText,
                  ),
                  rememberAccount: _rememberAccount,
                );
              }
            }
    
            // ignore: use_build_context_synchronously
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.notification),
                // content: Text(
                //     'Tài khoản của bạn đang là tài khoản ${rightUserType.type}.\n Bạn có muốn chuyển sang tài khoản ${rightUserType.type}'),
                content: RichText(
                  text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(
                          text: AppLocalizations.of(context)!.yourAccountIs,
                        ),
                        TextSpan(
                          text: rightUserType.id==0 ? AppLocalizations.of(context)!.personal : rightUserType.id==1 ? AppLocalizations.of(context)!.company : AppLocalizations.of(context)!.employee,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                            text: '\n${AppLocalizations.of(context)!.doYouWantToWSwitchTo}'),
                        TextSpan(
                          text: rightUserType.id==0 ? AppLocalizations.of(context)!.personal : rightUserType.id==1 ? AppLocalizations.of(context)!.company : AppLocalizations.of(context)!.employee,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ]),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      //Cho về đúng loại tài khoản
                      _loginCallback(rightUserType);
                    },
                    style: ElevatedButton.styleFrom(primary: AppColors.primary),
                    child: const Text('OK'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Đóng
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(primary: AppColors.gray),
                    child: const Text('Hủy'),
                  ),
                ],
              ),
            );
          } else if (state is LoginStateSuccess) {
            var userInfo = state.userInfo;

            // spService.saveLoggedInInfo(
            //   info: userInfo,
            //   userType: userInfo.userType!,
            // );
            await AppRouter.toPage(context, AppPages.appLayOut,
                arguments: {'UserInfo': userInfo});
            var initialSize = const Size(800, 720);
            appWindow.minSize = initialSize;
            appWindow.maxSize = const Size(2000, 1200);
            appWindow.size = Size(preferedWidth, preferedHeight);
            appWindow.alignment = Alignment.center;
          }
    
          // AppDialogs.showAlternateLoginOptions(
          //     context, state.type, _loginCallback);
    
          print("----------------${state}---------");
        },
        child: Form(
          key: _formKey,
          child: Container(
            color: AppColors.white,
            height: MediaQuery.of(context).size.height-10,//- (isMacOS ? 40 : 50),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  color: AppColors.white,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      appWindow.position = Offset(
                        appWindow.position.dx + details.delta.dx,
                        appWindow.position.dy + details.delta.dy,
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
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
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
                    const SizedBox(
                      width: 110,
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 15, bottom: 20),
                      child: SvgPicture.asset(
                        Images.big_chat365,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${AppLocalizations.of(context)!.logInAccount} ${widget.userType == UserType.customer ? AppLocalizations.of(context)?.personal : widget.userType == UserType.company ? AppLocalizations.of(context)!.company : AppLocalizations.of(context)!.employee}',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black47),
                ),
                const SizedBox(
                  height: 25,
                ),
                isQR(),
                isQr
                    ? Container(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder(
                              future: _loginCubit.generateLoginQRData(),
                              builder: ((context, snapshot) {
                                if (snapshot.hasData) {
                                  return QrImageView(
                                    data: snapshot.data??'',
                                    version: QrVersions.auto,
                                    size: 270.0,
                                  );
                                } else {
                                  return const ShimmerLoading(size: Size(270, 270));
                                }
                              }),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                             Text(
                              AppLocalizations.of(context)!.useChat365ToScanQR,
                              style:const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            GestureDetector(
                              child:  Text(
                                AppLocalizations.of(context)!.scanInstructions,
                                style:const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.primary),
                              ),
                              onTap: () {},
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                             Text(
                              AppLocalizations.of(context)!.otherOptions,
                              style:const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.black47),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: _enterToLogin,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 35,
                              ),
                              EmailField(
                                controller: contactLoginTEC,
                                focusNode: _emailNode,
                                validator: _validatorAccount,
                              ),
                              PasswordField(
                                controller: passUse,
                                hintText: AppLocalizations.of(context)!.inputPassword,
                                validator: _validatorPassword,
                                focusNode: _passNode,
                              ),
                              isRemember(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: AppColors.primary,
                                  fixedSize: const Size(371, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                ),
                                onPressed: () async {
                                  await _btnLoginPressedHandler(context);
                                },
                                child:  Text(
                                  AppLocalizations.of(context)!.signIn,
                                  style: const TextStyle(
                                      fontSize: 18, color: AppColors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              moreInformation(widget.userType),
                              const SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.doNotHaveAnAccount,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.gray,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    child:  Text(
                                      AppLocalizations.of(context)!.signUp,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        AppRouter.toPage(
                                            context, AppPages.ChoosePosition,
                                            arguments: {'isLogIn': false});
                                      });
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Cho người dùng nhập vào từ bàn phím
  ValueNotifier<bool> _onOff = ValueNotifier(true);

  Widget inputInfor(TextEditingController valueInput, String path,
      String hintText, bool isPass, BuildContext context) {
    Key key = UniqueKey();

    return Container(
      //padding: EdgeInsets.symmetric(horizontal: 10),
      height: 42,
      width: 350,
      child: ValueListenableBuilder(
        valueListenable: _onOff,
        builder: (context, _, check) => TextField(
          controller: valueInput,
          onChanged: (value) {
            print(valueInput.value);
          },
          onSubmitted: (value) {
            //print(value);
          },
          style: const TextStyle(fontSize: 16),
          obscureText: _onOff.value && isPass,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 16),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            prefixIcon: Transform.scale(
              scale: 0.5, // Điều chỉnh tỷ lệ theo ý muốn
              child: SvgPicture.asset(path),
            ),
            suffixIcon: isPass
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _onOff.value = !_onOff.value;
                        // print("Da bem ${_onOff.value}");
                      });
                    },
                    icon: SvgPicture.asset(
                      _onOff.value ? Images.eye_off_2 : Images.ic_eye,
                      width: 20,
                      height: 20,
                      color: _onOff.value ? AppColors.gray : AppColors.primary,
                    ),
                  )
                : const SizedBox(),
            filled: true,
            fillColor: AppColors.whiteLilac,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17.0),
              borderSide: const BorderSide(color: Colors.white, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17.0),
              borderSide: const BorderSide(
                  color: AppColors.blueBorder, width: 1), // Màu khi focus
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17.0),
              borderSide: const BorderSide(
                  color: AppColors.gray, width: 1), // Màu khi không focus
            ),
          ),
        ),
      ),
    );
  }

  Widget isQR() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isQr = false;
              });
            },
            
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.phoneNumber2,
                  style: TextStyle(
                    fontSize: 17,
                    color: isQr ? AppColors.dialogBarrier : AppColors.blueD4,
                    fontWeight: isQr ? FontWeight.w600 : FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 2,
                  width: 170,
                  color: isQr ? AppColors.dialogBarrier : AppColors.blueD4,
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isQr = true;
              });
            },
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.scanQR2,
                  style: TextStyle(
                    fontSize: 17,
                    color: isQr ? AppColors.blueD4 : AppColors.dialogBarrier,
                    fontWeight: isQr ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 2,
                  width: 170,
                  color: isQr ? AppColors.blueD4 : AppColors.dialogBarrier,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget isRemember() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 60,
          color: AppColors.white,
          child: Checkbox(
            checkColor: AppColors.white,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: rememberMe,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(color: AppColors.white)),
            onChanged: (newValue) {
              setState(() {
                rememberMe = newValue ?? true;
              });
            },
          ),
        ),
         Text(
          AppLocalizations.of(context)!.rememberAccount,
          style: const TextStyle(fontSize: 16, color: AppColors.black),
        ),
        const SizedBox(
          width: 80,
        ),
        InkWell(
          child: Text(AppLocalizations.of(context)!.forgotPassword,
              style:  const TextStyle(fontSize: 16, color: AppColors.black)),
          onTap: () {
            AppRouter.toPage(
              context,
              AppPages.Auth_ForgotPass,
              arguments: {
                ForgotPasswordScreen.userTypeArg: widget.userType,
              },
            );
          }),
      ],
    );
  }

  Widget moreInformation(UserType yourchoose) {
    switch (yourchoose) {
      case UserType.customer:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              AppLocalizations.of(context)!.personalSuggest,
              style:const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: AppColors.black),
            ),
            GestureDetector(
              onTap: () {},
              child:  Text(
                AppLocalizations.of(context)!.here,
                style:const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                    color: AppColors.primary),
              ),
            )
          ],
        );
        break;
      case UserType.staff:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              AppLocalizations.of(context)!.staffSuggest,
              style:const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: AppColors.black),
            ),
            GestureDetector(
              onTap: () {},
              child:  Text(
                AppLocalizations.of(context)!.here,
                style:const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                    color: AppColors.primary),
              ),
            )
          ],
        );
        break;
      case UserType.company:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              AppLocalizations.of(context)!.companySuggest,
              style:const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: AppColors.black),
            ),
            GestureDetector(
              onTap: () {},
              child:  Text(
                AppLocalizations.of(context)!.here,
                style:const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                    color: AppColors.primary),
              ),
            )
          ],
        );
        break;
      default:
        return Container();
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
