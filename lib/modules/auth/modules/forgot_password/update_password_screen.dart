import 'package:app_chat365_pc/common/models/login_model.dart';
import 'package:app_chat365_pc/common/power_policy_widget.dart';
import 'package:app_chat365_pc/common/widgets/fill_button.dart';
import 'package:app_chat365_pc/common/widgets/label_form_field.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/cubit/login_cubit.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/cubit/signup_cubit.dart';
import 'package:app_chat365_pc/modules/auth/widgets/custom_auth_scaffold.dart';
import 'package:app_chat365_pc/modules/auth/widgets/password_field.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/helpers/validators.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({
    Key? key,
    required this.userType,
    this.email,
  }) : super(key: key);
  final UserType userType;
  final String? email;
  static const userTypeArg = 'userTypeArg';
  static const idEmail = 'email';

  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _form = GlobalKey<FormState>();
  TextEditingController _textEditingPass1Controller = TextEditingController();
  TextEditingController _textEditingPass2Controller = TextEditingController();

  //Dung cho validator cua nhap lai mat khau
  bool isChanging = false;
  late final LoginCubit _loginCubit;
  int typeex = -1;

  //*Dung cho viec unfocus se validate phan nhap lai mat khau
  final FocusNode _focusRepeatPassword = FocusNode();
  final _rePasswordKey = GlobalKey<FormFieldState>();

  _btnUpdatePassword(BuildContext context) {
    SignUpCubit signUpCubit = context.read<SignUpCubit>();
    setState(() {
      isChanging = false;
    });
    if (_form.currentState!.validate() == true) {
      signUpCubit.updatePassword(_textEditingPass1Controller.text, ++typeex);
    } else {
      BotToast.showText(text: AppLocalizations.of(context)!.recheckInfoInput);
      // AppDialogs.toast(AppLocalizations.of(context)!.recheckInfoInput);
    }
  }

  @override
  void initState() {
    _loginCubit = context.read<LoginCubit>();
    //* Kiem tra nhap lai mat khau co dung khong
    _focusRepeatPassword.addListener(() {
      if (!_focusRepeatPassword.hasFocus) {
        setState(() {
          isChanging = false;
        });
        if (_rePasswordKey.currentState != null)
          _rePasswordKey.currentState!.validate();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _textEditingPass1Controller.dispose();
    _textEditingPass2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late List<Widget> childrenCustomer = [
      LabelFormField(title: AppLocalizations.of(context)!.inputPassword, isRequired: true),
      PasswordField(
        hintText: AppLocalizations.of(context)!.inputPassword,
        controller: _textEditingPass1Controller,
        validator: (value) => Validator.inputPasswordValidator(value),
      ),
      SizedBoxExt.h20,
      LabelFormField(title: AppLocalizations.of(context)!.reInputPassword, isRequired: true),
      PasswordField(
        key: _rePasswordKey,
        focusNode: _focusRepeatPassword,
        hintText: AppLocalizations.of(context)!.reInputPassword,
        controller: _textEditingPass2Controller,
        onChanged: (value) {
          setState(() {
            isChanging = true;
          });
        },
        validator: (value) => Validator.reInputPasswordValidator(
            value, _textEditingPass1Controller.text, isChanging),
      ),
      SizedBoxExt.h20,
      FillButton(
        width: 220  ,
        title: AppLocalizations.of(context)!.update,
        onPressed: () => _btnUpdatePassword(context),
      ),
    ];

    void _loginCallback(UserType rightUserType) {
      var emailText = widget.email!;
      var passText = _textEditingPass1Controller.text;
      FocusManager.instance.primaryFocus?.unfocus();
      if (_form.currentState?.validate() == true) {
        _loginCubit.login(
          rightUserType,
          LoginModel(
            emailText,
            passText,
          ),
        );
      }
    }

    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) async {
        if (state is UpdatePassStateLoad) {
          AppDialogs.showLoadingCircle(context);
        } else if (state is UpdatePassStateSuccess) {
          // AppRouter.toPage(context, AppPages.Auth_UpdatePassSuccess,
          //     arguments: {
          //       UpdateSuccessScreen.userTypeArg: widget.userType,
          //       UpdateSuccessScreen.idEmail: widget.email,
          //       UpdateSuccessScreen.idPassword: _textEditingPass1Controller.text
          //     });
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Thông báo'),
                    content: Text('Cập nhật mật khẩu thành công'),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            _loginCallback(typeex == 0
                                ? UserType.customer
                                : typeex == 1
                                    ? UserType.company
                                    : UserType.staff);
                          },
                          child: Text('OK'))
                    ],
                  ));
        } else if (state is UpdatePassStateError) {
          print('---------Sai type khogn cap nhat duoc------------');
          _btnUpdatePassword(context);
          AppDialogs.hideLoadingCircle(context);
          BotToast.showText(text: state.error);
          // AppDialogs.toast(state.error);
        } else if (state is LoginStateSuccess) {
          await AppRouter.toPage(context, AppPages.appLayOut);

          var initialSize = const Size(800, 720);
          appWindow.minSize = initialSize;
          appWindow.maxSize = const Size(2000, 1200);
          appWindow.size = const Size(1200, 750);
          appWindow.alignment = Alignment.center;
        }
      },
      child: CustomAuthScaffold(
        title: AppLocalizations.of(context)!.updatePassword,
        extendBodyBehindAppBar: false,
        useAppBar: true,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBoxExt.h40,
                    SizedBoxExt.h40,
                    Text(
                      AppLocalizations.of(context)!.confirmOtpSuccess,
                      style: AppTextStyles.regularW700(context, size: 18),
                    ),
                    SizedBoxExt.h20,
                    Text(
                      AppLocalizations.of(context)!.contentCongratulations,
                      textAlign: TextAlign.center,
                    ),
                    SizedBoxExt.h30,
                    Column(
                      children:
                          // context.read<AuthRepo>().userType ==
                          //         UserType.customer
                          //     ?
                          childrenCustomer,
                      // : context.read<AuthRepo>().userType == UserType.staff
                      //     ? childrenEmployee
                      //     : [],
                    ),
                    SizedBoxExt.h20,
                    PowerPolicy(context: context),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
