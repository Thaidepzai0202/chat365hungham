import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/power_policy_widget.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/widgets/fill_button.dart';
import 'package:app_chat365_pc/common/widgets/form/outline_text_form_field.dart';
import 'package:app_chat365_pc/common/widgets/label_form_field.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/interfaces/interface_user_info.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/cubit/signup_cubit.dart';
import 'package:app_chat365_pc/modules/auth/widgets/custom_auth_scaffold.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_mode.dart';
import 'package:app_chat365_pc/utils/data/enums/type_screen_to_otp.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:app_chat365_pc/utils/helpers/validators.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    Key? key,
    required this.userType,
  }) : super(key: key);
  final UserType userType;

  static const userTypeArg = 'userTypeArg';

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with WidgetsBindingObserver {
  final _form = GlobalKey<FormState>();
  // Phan nhap
  TextEditingController _textEditingController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  // Ho tro phan validator
  String? Function(String?)? _validator;
  bool isChanging = false;
  bool isTrueUserType = false;
  late final authRepo = context.read<AuthRepo>();
  int userId = -1;
  List<IUserInfo> dataUser = [];
  _TakeDataUserByMailPhone(String email) async {
    dataUser = await authRepo.takeDataUserByMailPhone(email);
  }

  bool _isTrueUserType() {
    isTrueUserType = false;
    for (var i = 0; i < dataUser.length; i++) {
      if (widget.userType == dataUser[i].userType) {
        isTrueUserType = true;
        userId = dataUser[i].id;
      }
    }
    return isTrueUserType;
  }

  Future<bool> _checkVerify(String email) async {
    bool res = await authRepo.getIdChat365(email);
    if (res)
      return true;
    else {

      BotToast.showText(text: 'Tài khoản nhập vào không chính xác');
      // AppDialogs.toast('Tài khoản nhập vào không chính xác');
      return false;
    }
  }

  _sendOTP(BuildContext context, String email, UserType? userType,
      IUserInfo? userInfo) async {
    if (!email.contains('@')) {
      AppRouter.toPage(context, AppPages.Auth_ConfirmOTPWebView, arguments: {
        'email': email,
        'userInfo': userInfo,
      });
    }
    if (email.contains('@')) {
      if (_form.currentState!.validate()) {
        bloc.sendOTPForgetPassword(email, userType ?? widget.userType, false);
      } else {}
    }
  }

  _btnSendOTPPressedHandler(BuildContext context, String email) async {
    //comment để đẩy app 11/1/2023
    //if email is phone number
    await _TakeDataUserByMailPhone(email);
    logger.log(dataUser, name: "TakeDataUserByMailPhone");
    if (dataUser.isNotEmpty) {
      if (dataUser.length ==
              1 /*||
          (_isTrueUserType() && widget.userType != UserType.customer)*/
          ) {
        _sendOTP(context, email, widget.userType, dataUser[0]);
        // cứ email hoặc sdt nào có > 2 loại tk thì hiện dialog kể cả chọn đúng loại tk
      } else {
        // ignore: use_build_context_synchronously
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                backgroundColor: AppColors.white,
                contentPadding: const EdgeInsets.all(16),
                actionsPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                content: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Email hoặc số điện thoại đăng kí cho loại tài khoản khác',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                      TextSpan(
                        text:
                            '.\nVui lòng chọn loại tài khoản muốn lấy lại mật khẩu',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text(dataUser[0].userType?.type ?? ''),
                    onPressed: () async {
                      await authRepo.emitLogin(dataUser[0].id);
                      // gán lại <AuthRepo>().userType theo user mình chọn
                      context.read<AuthRepo>().userType =
                          (dataUser[0].userType ?? UserType.staff);
                      _sendOTP(
                          context, email, dataUser[0].userType, dataUser[0]);
                    },
                  ),
                  if (dataUser.length == 2)
                    ElevatedButton(
                      child: Text(dataUser[1].userType?.type ?? ''),
                      onPressed: () async {
                        await authRepo.emitLogin(dataUser[1].id);
                        _sendOTP(
                            context, email, dataUser[1].userType, dataUser[1]);
                        context.read<AuthRepo>().userType =
                            (dataUser[1].userType ?? UserType.staff);
                      },
                    ),
                ],
                actionsAlignment: MainAxisAlignment.spaceAround,
              );
            });
      }
    } else if (dataUser.isEmpty) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Image.asset(
                Images.img_unregistered,
                height: 90,
                width: 90,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.unregisteredEmail,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: '.\n${AppLocalizations.of(context)!.checkAgainEmail}',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text(AppLocalizations.of(context)!.confirm),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
              actionsAlignment: MainAxisAlignment.center,
            );
          });
    }
  }

  _btnChangeScreenHandler(BuildContext context) {
    //context.read<AuthRepo>().userType = widget.userType;
    // if (widget.userType == UserType.customer) {
    //   AppRouter.replaceWithPage(context, AppPages.Auth_SetUpAccount_CreatCubit,
    //       arguments: {
    //         SetUpAccountInformationScreen.authModeArg: AuthMode.LOGIN
    //       });
    // } else if (widget.userType == UserType.staff) {
    //   AppRouter.replaceWithPage(context, AppPages.Auth_ConfirmIdCompany,
    //       arguments: {ConfirmIdCompanyScreen.formLogin: AuthMode.LOGIN});
    // } else if (widget.userType == UserType.company) {
    //   AppRouter.replaceWithPage(context, AppPages.Auth_SetUpAccount_CreatCubit,
    //       arguments: {
    //         SetUpAccountInformationScreen.authModeArg: AuthMode.LOGIN
    //       });
    AppRouter.toPage(context, AppPages.ChoosePosition,
        arguments: {'isLogIn': false});
  }

  // Check type value input
  // bool isPhoneNumber = true;

  @override
  void initState() {
    _validator = (value) => Validator.requiredInputPhoneOrEmailValidator(
        _textEditingController.text);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if(state == AppLifecycleState.resumed) {
  //     /// check xem trạng thái khi quay lại app là đã xác thực OTP chưa
  //    _checkVerify(isReset: false);
  //   }
  // }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  late final bloc = navigatorKey.currentContext!.read<SignUpCubit>();
  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SendOtpStateLoad) {
          AppDialogs.showLoadingCircle(context);
          isChanging = false;
        } else if (state is SendOtpStateSuccess) {
          AppDialogs.hideLoadingCircle(context);
          AppRouter.toPage(context, AppPages.Auth_ConfirmOTPWebView,
              blocValue: bloc,
              arguments: {
                'email' : _textEditingController.text,
                'userType': dataUser[0].userType
              });
        } else if (state is CompareOTPStateSuccess) {
          // AppRouter.toPage(context, AppPages.Auth_UpdatePass,
          //     blocValue: bloc,
          //     arguments: {
          //       UpdatePasswordScreen.userTypeArg:
          //           context.read<AuthRepo>().userType,
          //       UpdatePasswordScreen.idEmail: _textEditingController.text,
          //     });

          
          
        } else if (state is SendOtpStateError) {
          AppDialogs.hideLoadingCircle(context);
          // widget.userType == UserType.customer
          //     ? AppDialogs.toast(state.error)
          //     : AppDialogs.toast(state.error);
          // if (context.read<SignUpCubit>().error != null) {
          //   // AppDialogs.toast(context.read<SignUpCubit>().error!.error);
          // } else {}
          if (bloc.error != null) {
            if (bloc.error!.code == 200) {
              setState(() {
                _validator = (value) => bloc.contactSignUp.contains('@')
                    ? 'Email không tồn tại'
                    : 'Số điện thoại không tồn tại';
              });
            }
          } else {
            BotToast.showText(text: 'Đã xảy ra lỗi vui lòng thử lại sau');
            // AppDialogs.toast('Đã xảy ra lỗi vui lòng thử lại sau');
          }
        }
      },
      child: CustomAuthScaffold(
        title: AppLocalizations.of(context)!.forgotPasswordNoQuestionMark,
        extendBodyBehindAppBar: false,
        useAppBar: true,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(
              children: [
                SizedBoxExt.h40,
                SizedBoxExt.h40,
                Text(
                  AppLocalizations.of(context)!.forgotYourPassword,
                  style: AppTextStyles.regularW700(context,
                      size: 18, color: AppColors.lightThemeTextColor),
                ),
                SizedBoxExt.h20,
                Text(
                  AppLocalizations.of(context)!.contentForgotPasswordEmployee,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regularW400(context,
                      size: 14, color:  AppColors.lightThemeTextColor),
                ),
                SizedBoxExt.h40,
                // widget.userType == UserType.customer ||
                //         widget.userType == UserType.staff
                //     ?
                LabelFormField(title: AppLocalizations.of(context)!.loginAccount, isRequired: true),
                OutlineTextFormField(
                  key: ValueKey(_textEditingController),
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  style: context.theme.inputStyle,
                  // keyboardType: TextInputType.,
                  validator: _validator,
                  onChanged: (value) {
                    bloc.contactSignUp = _textEditingController.text;
                    isChanging = true;
                    if (isChanging)
                      setState(() {
                        _validator = (value) =>
                            Validator.requiredInputPhoneOrEmailValidator(
                                _textEditingController.text);
                        // Validator.requiredInputPhoneOrEmailValidator(
                        //     _textEditingController.text,
                        //     StringConst.inputPhoneNumberOrEmail);
                      });
                  },
                  decoration: context.theme.inputDecoration.copyWith(
                    hintText: AppLocalizations.of(context)!.inputPhoneOrEmail,
                    prefixIcon: WidgetUtils.getFormFieldColorPrefixIcon(
                      Images.ic_person,
                      color: AppColors.lightThemeTextColor,
                    ),
                    hintStyle: context.theme.hintStyle.copyWith(
                      color: AppColors.lightThemeHintTextColor
                    ),
                  ),
                ),
                // : OutlineTextFormField(
                //     controller: _textEditingController,
                //     focusNode: _focusNode,
                //     style: context.theme.inputStyle,
                //     validator: _validator,
                //     onChanged: (value) {
                //       //Doi vaidator ve xac nhan dinh dang email neu validator xac nhan loi(email trung);
                //       if (_validator !=
                //           (value) => Validator.inputEmailValidator(
                //               _textEditingController.text))
                //         setState(() {
                //           _validator = (value) =>
                //               Validator.inputEmailValidator(
                //                   _textEditingController.text);
                //         });
                //     },
                //     decoration: context.theme.inputDecoration.copyWith(
                //           hintText: StringConst.inputEmail,
                //           prefixIcon:
                //               WidgetUtils.getFormFieldColorPrefixIcon(
                //             // AssetPath.phone,
                //             AssetPath.email,
                //             color: context.theme.iconColor,
                //           ),
                //           hintStyle: context.theme.hintStyle,
                //         ),
                //   ),
                SizedBoxExt.h40,
                FillButton(
                  width: double.infinity,
                  title: AppLocalizations.of(context)!.getVerificationCode,
                  onPressed: () => _btnSendOTPPressedHandler(
                      context, _textEditingController.text),
                  // _btnSendToEmailPressedHandler(
                  //     context, _textEditingController.text),
                ),
                SizedBoxExt.h30,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.doNotHaveAnAccount,
                      style: TextStyle(
                        fontSize: 16,
                        color:  AppColors.lightThemeTextColor,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () => _btnChangeScreenHandler(context),
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                        style: TextStyle(
                          fontSize: 18,
                          color: context.theme.colorPirimaryNoDarkLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                ),
                // MediaQuery.of(context).viewInsets.bottom >
                //         MediaQuery.of(context).size.width * 0.30133333333333334
                //     ? SizedBox(
                //         height: MediaQuery.of(context).viewInsets.bottom -
                //             MediaQuery.of(context).size.width *
                //                 0.30133333333333334,
                //       )
                //     : SizedBox(
                //         height: MediaQuery.of(context).viewInsets.bottom,
                //       ),
                SizedBoxExt.h30,
                PowerPolicy(context: context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
