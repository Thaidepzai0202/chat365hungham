import 'dart:math';

import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/widgets/form/outline_text_form_field.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/cubit/signup_cubit.dart';
import 'package:app_chat365_pc/modules/auth/widgets/password_field.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/type_screen_to_otp.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/validators.dart';
import 'package:app_chat365_pc/utils/ui/app_border_and_radius.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InputSignUpCompany extends StatefulWidget {
  @override
  _InputSignUpCompanyState createState() => _InputSignUpCompanyState();
}

class _InputSignUpCompanyState extends State<InputSignUpCompany> {
  final TextEditingController _textPhoneNumberController =
      TextEditingController();
  final TextEditingController _textNameCompanyController =
      TextEditingController();
  final TextEditingController _textAccountController = TextEditingController();
  final TextEditingController _textPass1Controller = TextEditingController();
  final TextEditingController _textPass2Controller = TextEditingController();
  final TextEditingController _textAddressController = TextEditingController();
  bool isAgree = false;
  late AuthRepo _authRepo;
  bool isChanging = false;
  late final SignUpCubit signUpCubit;
  bool verifying = false;


  //validate for company name
  final FocusNode _focusNameCompany = FocusNode();
  String? Function(String?)? _validatorNameCompany;
  final _companyKey = GlobalKey<FormState>();

  // validate for company account
  //*Dung cho validator trung tai khoan
  final FocusNode _focusAccount = FocusNode();
  String? Function(String?)? _validator;
  final _accountKey = GlobalKey<FormState>();

  // validate cho email
  final FocusNode _focusEmail = FocusNode();
  String? Function(String?)? _validatorEmail;
  final _emailKey = GlobalKey<FormState>();

  //* Dung de luu lại gia tri cu cua ten cong ty
  final TextEditingController _textOldCompnayNameController =
      TextEditingController();

  // ------------Nhap lại mật khẩu
  final FocusNode _focusRepeatPassword = FocusNode();
  final _rePasswordKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    _authRepo = context.read<AuthRepo>();
    signUpCubit = context.read<SignUpCubit>();
    //Kiem tra nhap lai mat khau dung ko
    _focusRepeatPassword.addListener(() {
      if (!_focusRepeatPassword.hasFocus) {
        setState(() {
          _validator =
              (value) => Validator.requiredInputPhoneOrEmailValidator(value);
          isChanging = false;
        });
        if (_rePasswordKey.currentState != null) {
          _rePasswordKey.currentState!.validate();
        }
      }
    });

    //Kiem tra trung ten cong ty
    _focusNameCompany.addListener(() {
      if (!_focusNameCompany.hasFocus &&
          Validator.validateStringName(_textNameCompanyController.text, '') ==
              null &&
          _authRepo.userType == UserType.company) {
        _textOldCompnayNameController.text = _textNameCompanyController.text;
        signUpCubit.checkNameCompany(_textNameCompanyController.text);
      }
    });

    //Kiem tra trung tai khoan cong ty
    _focusAccount.addListener(() {
      if (!_focusAccount.hasFocus &&
          Validator.requiredInputPhoneOrEmailValidator(
                  _textAccountController.text) ==
              null) {
        signUpCubit.checkAccountExist(
            contactSignUp: _textAccountController.text,
            userType: _authRepo.userType);
      }
    });

    _validator = (value) => Validator.requiredInputPhoneOrEmailValidator(value);
  }

  void dispose() {
    _focusRepeatPassword.dispose();
    _focusNameCompany.dispose();
    _focusAccount.dispose();
    _textNameCompanyController.dispose();
    _textOldCompnayNameController.dispose();
    _textPhoneNumberController.dispose();
    _textAccountController.dispose();
    _textPass1Controller.dispose();
    _textAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = _authRepo;

    return MultiBlocListener(
        listeners: [
          BlocListener<SignUpCubit, SignUpState>(
            bloc: signUpCubit,
            listener: (context, state) async {
              if (state is CheckAccountStateLoad) {
              } else if (state is CheckAccountStateSuccess) {
                setState(() {
                  _validator = (v) => null;
                });
              } else if (state is CheckAccountStateError) {
                if (state.errorRes != null) {
                  setState(() {
                    _validator = (value) => state.errorRes!.messages;
                  });
                }
              }

              //*Phan dang ky
              else if (state is SignUpStateLoad) {
                //AppDialogs.showLoadingCircle(context);
              } else if (state is SignUpStateSuccess) {
                if (!_textAccountController.text.contains('@')) {
                  AppDialogs.hideLoadingCircle(context);
                  verifying = true;
                  AppRouter.toPage(context, AppPages.Auth_ConfirmOTPWebView,
                      arguments: {
                        'email': _textAccountController.text,
                        'typeOTP': TypeScreenToOtp.CONFIRMACCOUNT,
                        'userInfo': UserInfo(
                            id: int.tryParse(_textAccountController.text) ?? -1,
                            userName: '',
                            avatarUser: '',
                            active: UserStatus.online,
                            email: _textAccountController.text,
                            password: _textPass1Controller.text,
                            userType: state.userType),
                        'userType': UserType.company,
                        'isMD5': false,
                      });
                }
              } else if (state is SignUpCompanyStateSuccess) {
                if (!_textAccountController.text.contains('@')) {
                  verifying = true;

                  AppRouter.toPage(context, AppPages.Auth_ConfirmOTPWebView,
                      arguments: {
                        'email': _textAccountController.text,
                        'typeOTP': TypeScreenToOtp.CONFIRMACCOUNT,
                        'userInfo': UserInfo(
                            id: int.tryParse(_textAccountController.text) ?? -1,
                            userName: '',
                            avatarUser: '',
                            active: UserStatus.online,
                            email: _textAccountController.text,
                            password: _textPass1Controller.text,
                            userType: _authRepo.userType),
                        'isMD5': false,
                      });
                } else {}
              } else if (state is SignUpStateError) {
                //AppDialogs.hideLoadingCircle(context);
                if (signUpCubit.error != null) {
                  if (signUpCubit.error!.code == 200) {
                    setState(() {
                      if (_textAccountController.text.contains('@')) {
                        _validator =
                            (value) => 'Địa chỉ email đăng ký đã tồn tại';
                      }
                      if (!_textAccountController.text.contains('@')) {
                        _validator =
                            (value) => 'Số điện thoại đăng ký đã tồn tại';
                      }
                    });
                  }
                }
                //AppDialogs.toast(state.error);
              }
            },
          )
        ],
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
               Text(
                AppLocalizations.of(context)!.signUpAccCompany,
                style:const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                // width: double.infinity,
                height: 350,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 15),
                      Container(
                        width: 360,
                        height: 62,
                        child: OutlineTextFormField(
                          key: _accountKey,
                          controller: _textAccountController,
                          style: context.theme.inputStyle,
                          focusNode: _focusAccount,
                          //keyboardType: TextInputType.number,
                          decoration: context.theme.inputDecoration.copyWith(
                            hintText: AppLocalizations.of(context)!.inputPhoneAccountSignIn,
                            prefixIcon: Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: SvgPicture.asset(
                                Images.ic_person,
                                height: 20,
                                width: 20,
                                color: AppColors.grey666,
                              ),
                            ),
                            hintStyle: context.theme.hintStyle,
                          ),
                          onChanged: (value) {
                            if (_validator !=
                                (value) =>
                                    Validator.requiredInputPhoneValidator(
                                        value)) {
                              setState(() {
                                _validator = (value) =>
                                    Validator.requiredInputPhoneValidator(
                                        value);
                              });
                            }
                          },
                          validator: _validator,
                        ),
                      ),
                      Container(
                        width: 360,
                        height: 62,
                        color: AppColors.white,
                        child: OutlineTextFormField(
                          key: _companyKey,
                          controller: _textNameCompanyController,
                          readOnly: authRepo.userType == UserType.staff,
                          style: context.theme.inputStyle,
                          focusNode: _focusNameCompany,
                          decoration: context.theme.inputDecoration.copyWith(
                            hintText: AppLocalizations.of(context)!.inputNameCompany,
                            focusedBorder:
                                AppBorderAndRadius.outlineInputFocusedBorder,
                            // disabledBorder: AppBorderAndRadius.outlineInputBorder,
                            fillColor: AppColors.white,
                            prefixIcon: Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: SvgPicture.asset(
                                Images.ic_company,
                                height: 20,
                                width: 20,
                                color: AppColors.grey666,
                              ),
                            ),
                            hintStyle: context.theme.hintStyle,
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (_textOldCompnayNameController.text !=
                                  _textNameCompanyController.text) {
                                _validatorNameCompany = (value) =>
                                    Validator.validateStringName(
                                        _textNameCompanyController.text,
                                        AppLocalizations.of(context)!.inputNameCompany);
                              }
                            });
                          },
                          validator: _validatorNameCompany,
                        ),
                      ),
                      Container(
                        width: 360,
                        height: 62,
                        child: OutlineTextFormField(
                          controller: _textPhoneNumberController,
                          style: context.theme.inputStyle,
                          decoration: context.theme.inputDecoration.copyWith(
                            hintText: AppLocalizations.of(context)!.inputEmail,
                            prefixIcon: Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: SvgPicture.asset(
                                Images.ic_email,
                                height: 20,
                                width: 20,
                                color: AppColors.grey666,
                              ),
                            ),
                            hintStyle: context.theme.hintStyle,
                          ),
                          onChanged: (value) {
                            if (_validatorEmail !=
                                (value) =>
                                    Validator.requiredInputEmailValidator(
                                        value)) {
                              setState(() {
                                setState(() {
                                  _validatorEmail = (value) =>
                                      Validator.requiredInputEmailValidator(
                                          value);
                                });
                              });
                            }
                            ;
                          },
                          validator: _validatorEmail,
                          key: _emailKey,
                        ),
                      ),
                      PasswordField(
                        hintText: AppLocalizations.of(context)!.inputPassword,
                        controller: _textPass1Controller,
                        validator: (value) =>
                            Validator.inputPasswordValidator(value),
                      ),
                      //Nhap lai mat khau
                      PasswordField(
                        key: _rePasswordKey,
                        focusNode: _focusRepeatPassword,
                        hintText: AppLocalizations.of(context)!.reInputNewPassword,
                        controller: _textPass2Controller,
                        // autovalidateMode: AutovalidateMode.disabled,
                        onChanged: (value) {
                          setState(() {
                            isChanging = true;

                            // _form.currentState.
                          });
                        },
                        validator: (value) =>
                            Validator.reInputPasswordValidator(
                                value, _textPass1Controller.text, isChanging),
                      ),
                      inputInfor(_textAddressController, Images.ic_location,
                          AppLocalizations.of(context)!.inputAddress, false, context, _onOff),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Row(
                children: <Widget>[
                  const SizedBox(
                    width: 40,
                  ),
                  Checkbox(
                      checkColor: AppColors.white,
                      activeColor: AppColors.primary,
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          // Màu nền khi kiểm tra
                          return AppColors.primary;
                        }
                        // Màu nền khi không kiểm tra
                        return AppColors.white;
                      }),
                      focusColor: AppColors.white,
                      value: isAgree,
                      onChanged: (bool? newValue) {
                        setState(() {
                          isAgree = newValue!;
                        });
                      }),
                  Text(
                    AppLocalizations.of(context)!.agrreewith,
                    style: const TextStyle(
                        color: AppColors.grey666, fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                      child: Text(
                        AppLocalizations.of(context)!.chat365Rules,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        launch(
                            'https://chat365.timviec365.vn/thoa-thuan-su-dung.html');
                      })
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                child:  Text(
                  AppLocalizations.of(context)!.complete,
                  style:const TextStyle(fontSize: 17),
                ),
                style: ElevatedButton.styleFrom(
                  primary: isAgree ? AppColors.primary : AppColors.grey666,
                  fixedSize: const Size(200, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                onPressed: () {
                  signUpCubit.signUpCompany(
                      nameCompany: _textNameCompanyController.text,
                      contactSignUp: _textAccountController.text,
                      userName: _textNameCompanyController.text,
                      password: _textPass1Controller.text,
                      phoneNumber: _textPhoneNumberController.text,
                      address: _textAddressController.text);
                },
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    AppLocalizations.of(context)!.doHaveAnAccount,
                    style:const TextStyle(
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
                      AppLocalizations.of(context)!.signIn,
                      style:const TextStyle(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        AppRouter.toPage(context, AppPages.ChoosePosition,
                            arguments: {'isLogIn': true});
                      });
                    },
                  )
                ],
              )
            ],
          ),
        ));
  }

  final ValueNotifier<bool> _onOff = ValueNotifier(true);
  final ValueNotifier<bool> _onOff2 = ValueNotifier(true);

  Widget inputInfor(
      TextEditingController valueInput,
      String path,
      String hintText,
      bool isPass,
      BuildContext context,
      ValueNotifier<bool> onoff) {
    Key key = UniqueKey();

    return Container(
      color: AppColors.white,
      //padding: EdgeInsets.symmetric(horizontal: 10),
      height: 42,
      width: 360,
      child: ValueListenableBuilder(
        valueListenable: onoff,
        builder: (context, _, check) => TextField(
          controller: valueInput,
          onChanged: (value) {},
          onSubmitted: (value) {
            //print(value);
          },
          style: const TextStyle(fontSize: 16),
          obscureText: onoff.value && isPass,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 16, color: AppColors.gray),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            prefixIcon: Transform.scale(
              scale: 0.5, // Điều chỉnh tỷ lệ theo ý muốn
              child: SvgPicture.asset(
                path,
                color: AppColors.grey666,
              ),
            ),
            suffixIcon: isPass
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        onoff.value = !onoff.value;
                      });
                    },
                    icon: SvgPicture.asset(
                      onoff.value ? Images.eye_off_2 : Images.ic_eye,
                      width: 20,
                      height: 20,
                      color: onoff.value ? AppColors.gray : AppColors.primary,
                    ),
                  )
                : const SizedBox(),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(color: Colors.white, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                  color: AppColors.blueBorder, width: 1), // Màu khi focus
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: const BorderSide(
                  color: AppColors.gray, width: 1), // Màu khi không focus
            ),
          ),
        ),
      ),
    );
  }
}
