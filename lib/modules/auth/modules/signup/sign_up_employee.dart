import 'dart:io';

import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/models/result_login.dart';
import 'package:app_chat365_pc/common/models/selectable_Item.dart';
import 'package:app_chat365_pc/common/repos/auth_repo.dart';
import 'package:app_chat365_pc/common/widgets/fill_button.dart';
import 'package:app_chat365_pc/common/widgets/form/outline_text_form_field.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/cubit/login_cubit.dart';
import 'package:app_chat365_pc/modules/auth/modules/login/login_singup.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/cubit/signup_cubit.dart';
import 'package:app_chat365_pc/modules/auth/widgets/custom_auth_scaffold.dart';
import 'package:app_chat365_pc/modules/auth/widgets/password_field.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/academic_level.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_mode.dart';
import 'package:app_chat365_pc/utils/data/enums/gender.dart';
import 'package:app_chat365_pc/utils/data/enums/marital_status.dart';
import 'package:app_chat365_pc/utils/data/enums/position.dart';
import 'package:app_chat365_pc/utils/data/enums/type_screen_to_otp.dart';
import 'package:app_chat365_pc/utils/data/enums/user_status.dart';
import 'package:app_chat365_pc/utils/data/enums/user_type.dart';
import 'package:app_chat365_pc/utils/data/enums/work_experience.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/validators.dart';
import 'package:app_chat365_pc/utils/ui/app_border_and_radius.dart';
import 'package:app_chat365_pc/utils/ui/app_dialogs.dart';
import 'package:app_chat365_pc/utils/ui/app_padding%20copy.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class InputSignUpEmployee extends StatefulWidget {
  final AuthMode mode;

  const InputSignUpEmployee({Key? key, required this.mode}) : super(key: key);

  static const authModeArg = 'authModeArg';
  @override
  _InputSignUpEmployeeState createState() => _InputSignUpEmployeeState();
}

class _InputSignUpEmployeeState extends State<InputSignUpEmployee> {
  final _form = GlobalKey<FormState>();

  bool verifying = false;

  //*Dung de cuon trong -> ngoai
  final ScrollController _scrollController = ScrollController();

  //*Dung cho man nhan vien
  TextEditingController _textNameCompanyController = TextEditingController();
  TextEditingController _textDateController = TextEditingController();
  late SelectableItem _department;
  TextEditingController _textDepartmentController = TextEditingController();
  late SelectableItem _position;
  TextEditingController _textPositionController = TextEditingController();
  late SelectableItem _gender;
  TextEditingController _textGenderController = TextEditingController();
  late SelectableItem _marriage;
  TextEditingController _textMarriageController = TextEditingController();
  late SelectableItem _education;
  TextEditingController _textEducationController = TextEditingController();
  SelectableItem? _group;
  TextEditingController _textGroupController = TextEditingController();
  SelectableItem? _nest;
  TextEditingController _textNestController = TextEditingController();
  late SelectableItem _work;
  TextEditingController _textWorkController = TextEditingController();
  late SelectableItem _permision;
  TextEditingController _textPermisionController = TextEditingController();

  //*Dung chung cac man
  bool accept = false;
  TextEditingController _textAccountController = TextEditingController();
  TextEditingController _textPhoneNumberController = TextEditingController();
  TextEditingController _textNameController = TextEditingController();
  TextEditingController _textPass1Controller = TextEditingController();
  TextEditingController _textEditingPass2Controller = TextEditingController();
  TextEditingController _textAddressController = TextEditingController();

  //*Dung cho validator cua nhap lai mat khau
  bool isChanging = false;
  bool _isAgree = false;

  //*Dung cho viec unfocus se validate phan nhap lai mat khau
  final FocusNode _focusRepeatPassword = FocusNode();
  final _rePasswordKey = GlobalKey<FormFieldState>();

  //*Dung cho validator trung ten cong ty
  final FocusNode _focusNameCompany = FocusNode();
  String? Function(String?)? _validatorNameCompany;
  final _companyKey = GlobalKey<FormState>();

  //*Dung cho validator trung tai khoan
  final FocusNode _focusAccount = FocusNode();
  String? Function(String?)? _validator;
  final _accountKey = GlobalKey<FormState>();

  //* Dung de luu lại gia tri cu cua ten cong ty
  TextEditingController _textOldCompnayNameController = TextEditingController();

  //late final LoginCubit loginCubit;
  late final SignUpCubit signUpCubit;
  late final LoginCubit loginCubit;

  ///La ham dang ky tai khoan
  _btnSetUpAccount(BuildContext context) {
    // SignUpCubit signUpCubit = signUpCubit;
    setState(() {
      isChanging = false;
    });

    signUpCubit.signUpEmployee(
        userName: _textNameController.text,
        contactSignUp: _textAccountController.text,
        password: _textPass1Controller.text,
        gender: _gender,
        address: _textAddressController.text,
        date: _textDateController.text,
        department: _department,
        education: _education,
        group: _group,
        marriage: _marriage,
        nest: _nest,
        phoneNumber: _textPhoneNumberController.text,
        position: _position,
        work: _work);
  }

  late AuthRepo _authRepo;
  @override
  void initState() {
    _authRepo = context.read<AuthRepo>();
    loginCubit = context.read<LoginCubit>();
    signUpCubit = context.read<SignUpCubit>();
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
    //* Kiem tra trung tai khoan cong ty
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

    //*
    _validator = (value) => Validator.requiredInputPhoneOrEmailValidator(value);

    //* Gan gia tri mac dinh ban dau cho khach
    // if (_authRepo.userType == UserType.customer) {
    //   _validator = (value) => Validator.requiredInputPhoneValidator(value);
    // }

    //* Gan cac gia tri mac dinh ban dau cho nhan vien

    // _validator = (value) => Validator.requiredInputPhoneValidator(value);
    _textNameCompanyController.text = signUpCubit.nameCompany;
    _position =
        Position.selectableItemList.firstWhere((element) => element.id == '3');
    _textPositionController.text = _position.name;
    _department = signUpCubit.listDepartment.first;
    _textDepartmentController.text = _department.name;
    _gender = Gender.selectableItemList.first;
    _textGenderController.text = _gender.name;
    _marriage = MaritalStatus.selectableItemList.first;
    _textMarriageController.text = _marriage.name;
    _work = WorkExperience.selectableItemList[1];
    _textWorkController.text = _work.name;
    _education = AcademicLevel.selectableItemList.first;
    _textEducationController.text = '';

    //WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _focusRepeatPassword.dispose();
    _focusNameCompany.dispose();
    _focusAccount.dispose();
    _textNameCompanyController.dispose();
    _textOldCompnayNameController.dispose();
    _textNameController.dispose();
    _textPhoneNumberController.dispose();
    _textDateController.dispose();
    _textAccountController.dispose();
    _textPass1Controller.dispose();
    _textEditingPass2Controller.dispose();
    _textPositionController.dispose();
    _textDepartmentController.dispose();
    _textAddressController.dispose();
    _textGenderController.dispose();
    _textNestController.dispose();
    _textGroupController.dispose();
    _textEducationController.dispose();
    _textMarriageController.dispose();
    _textWorkController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = _authRepo;
    //* Phan tong tin nhap cho dang ky tai khoan
    final List<Widget> children = [
      //Phan nhap tai khoan
      Container(
        width: 360,
        height: 62,
        child: OutlineTextFormField(
          key: _accountKey,
          controller: _textAccountController,
          style: context.theme.inputStyle,
          focusNode: _focusAccount,
          // keyboardType: TextInputType.number,
          decoration: context.theme.inputDecoration.copyWith(
            hintText: AppLocalizations.of(context)!.inputPhoneAccount,
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 10),
              child: SvgPicture.asset(
                Images.ic_person_setup,
                height: 20,
                width: 20,
                color: AppColors.grey666,
              ),
            ),
            hintStyle: context.theme.hintStyle,
          ),
          onChanged: (value) {
            if (_validator !=
                (value) => Validator.requiredInputPhoneValidator(value)) {
              setState(() {
                _validator =
                    (value) => Validator.requiredInputPhoneValidator(value);
              });
            }
          },
          validator: _validator,
        ),
      ),

      //Ten cong ty
      Container(
        width: 360,
        height: 62,
        child: OutlineTextFormField(
          key: _companyKey,
          controller: _textNameCompanyController,
          readOnly: true,
          style: context.theme.inputStyle,
          focusNode: _focusNameCompany,
          decoration: context.theme.inputDecoration.copyWith(
            hintText: signUpCubit.nameCompany,
            focusedBorder: authRepo.userType == UserType.company
                ? AppBorderAndRadius.outlineInputFocusedBorder
                : AppBorderAndRadius.outlineInputBorder,
            // disabledBorder: AppBorderAndRadius.outlineInputBorder,
            fillColor: authRepo.userType == UserType.company
                ? AppColors.white
                : Color.fromARGB(255, 215, 215, 215),
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 10),
              child: SvgPicture.asset(
                Images.ic_building,
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
                  _textNameCompanyController.text)
                _validatorNameCompany = (value) => Validator.validateStringName(
                    _textNameCompanyController.text,
                    AppLocalizations.of(context)!.inputNameCompany);
            });
          },
          validator: _validatorNameCompany,
        ),
      ),

      //Nhap ho va ten
      Container(
        width: 360,
        height: 62,
        child: OutlineTextFormField(
          controller: _textNameController,
          style: context.theme.inputStyle,
          textCapitalization: TextCapitalization.words,
          decoration: context.theme.inputDecoration.copyWith(
            hintText: AppLocalizations.of(context)!.inputFullName,
            prefixIcon: Container(
              padding: const EdgeInsets.only(left: 10),
              child: SvgPicture.asset(
                Images.ic_edit_name,
                height: 20,
                width: 20,
                color: AppColors.grey666,
              ),
            ),
            hintStyle: context.theme.hintStyle,
          ),
          validator: (value) => Validator.validateStringName(
            value,
            AppLocalizations.of(context)!.inputFullName,
          ),
        ),
      ),

      //So dien thoai

      Container(
        width: 360,
        height: 62,
        child: OutlineTextFormField(
          controller: _textPhoneNumberController,
          style: context.theme.inputStyle,
          keyboardType: TextInputType.number,
          decoration: context.theme.inputDecoration.copyWith(
            hintText: AppLocalizations.of(context)!.phoneNumber,
            prefixIcon: Container(
              padding: EdgeInsets.only(left: 10),
              child: SvgPicture.asset(
                Images.ic_phone,
                height: 20,
                width: 20,
                color: AppColors.grey666,
              ),
            ),
            hintStyle: context.theme.hintStyle,
          ),
          validator: (value) => Validator.requiredInputLandlinePhoneValidator(
            value,
          ),
        ),
      ),

      //Nhap mat khau
      PasswordField(
        hintText: AppLocalizations.of(context)!.inputPassword,
        controller: _textPass1Controller,
        validator: (value) => Validator.inputPasswordValidator(value),
      ),

      //Nhap lai mat khau
      PasswordField(
        key: _rePasswordKey,
        focusNode: _focusRepeatPassword,
        hintText: AppLocalizations.of(context)!.reInputNewPassword,
        controller: _textEditingPass2Controller,
        // autovalidateMode: AutovalidateMode.disabled,
        onChanged: (value) {
          setState(() {
            isChanging = true;

            // _form.currentState.
          });
        },
        validator: (value) => Validator.reInputPasswordValidator(
            value, _textPass1Controller.text, isChanging),
      ),

      //địa chỉ
      Container(
        width: 360,
        height: 62,
        child: OutlineTextFormField(
          controller: _textAddressController,
          style: context.theme.inputStyle,
          keyboardType: TextInputType.streetAddress,
          maxLine: 1,
          minLine: 1,
          textCapitalization: TextCapitalization.words,
          decoration: context.theme.inputDecoration.copyWith(
            hintText: AppLocalizations.of(context)!.inputDetailAddress,
            contentPadding: AppPadding.formFieldContentPadding,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Container(
                padding: EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  Images.ic_location,
                  height: 20,
                  width: 20,
                  color: AppColors.grey666,
                ),
              ),
            ),
            hintStyle: context.theme.hintStyle,
          ),
          validator: (value) =>
              Validator.validateStringAddess(_textAddressController.text),
        ),
      ),

      //giới tính
      GestureDetector(
        onTap: () => AppDialogs.showListDialog(
                context: context,
                list: Gender.selectableItemList,
                value: _gender)
            .then((value) {
          if (value != null) _gender = value;
          _textGenderController.text = _gender.name;
        }),
        child: Container(
          width: 360,
          height: 62,
          child: OutlineTextFormField(
            controller: _textGenderController,
            enable: false,
            style: context.theme.inputStyle,
            textCapitalization: TextCapitalization.words,
            decoration: context.theme.inputDecoration.copyWith(
              hintText: AppLocalizations.of(context)!.selectGender,
              disabledBorder: AppBorderAndRadius.outlineInputBorder,
              prefixIcon: Container(
                padding: EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  Images.ic_gender,
                  height: 20,
                  width: 20,
                  color: AppColors.grey666,
                ),
              ),
              suffixIcon: WidgetUtils.getFormFieldColorSuffixIcon(
                Images.ic_dropdownArrow,
                color: AppColors.gray,
              ),
              hintStyle: context.theme.hintStyle,
            ),
          ),
        ),
      ),

      //ngày sinh
      GestureDetector(
        onTap: () async {
          DateTime? datePick;
          datePick = await showDatePicker(
            context: context,
            confirmText: 'XÁC NHẬN',
            initialDate: _textDateController.text != ''
                ? DateFormat('dd-MM-yyyy').parse(_textDateController.text)
                : DateTime.now(),
            firstDate: DateTime(1925),
            lastDate: DateTime.now(),
          );
          _textDateController.text = datePick != null
              ? DateFormat("dd-MM-yyyy").format(datePick).toString()
              : '';
          setState(() {});
        },
        child: Container(
          width: 360,
          height: 62,
          child: TextFormField(
            key: ValueKey(_textDateController.text),
            enabled: false,
            controller: _textDateController,
            style: context.theme.inputStyle,
            decoration: context.theme.inputDecoration.copyWith(
                disabledBorder: AppBorderAndRadius.outlineInputBorder,
                hintText: AppLocalizations.of(context)!.selectDateOfBirth,
                hintStyle: context.theme.hintStyle,
                prefixIcon: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: SvgPicture.asset(
                    Images.ic_date_birth,
                    height: 20,
                    width: 20,
                    color: AppColors.grey666,
                  ),
                ),
                errorStyle: TextStyle(color: AppColors.red)),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => Validator.validateStringBlank(
                _textDateController.text, AppLocalizations.of(context)!.selectDateOfBirth),
          ),
        ),
      ),

      //trình độ học vấn
      GestureDetector(
        onTap: () => AppDialogs.showListDialog(
                context: context,
                list: AcademicLevel.selectableItemList,
                value: _education)
            .then((value) {
          if (value != null) _education = value;
          if (_education.id == '0') {
            _textEducationController.text = '';
          } else {
            _textEducationController.text = _education.name;
          }
          setState(() {});
        }),
        child: Container(
          width: 360,
          height: 62,
          child: OutlineTextFormField(
            key: ValueKey(_textEducationController.text),
            controller: _textEducationController,
            enable: false,
            style: context.theme.inputStyle,
            textCapitalization: TextCapitalization.words,
            decoration: context.theme.inputDecoration.copyWith(
              hintText: AppLocalizations.of(context)!.selectAcademicLevel,
              disabledBorder: AppBorderAndRadius.outlineInputBorder,
              prefixIcon: Container(
                padding: EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  Images.ic_education,
                  height: 20,
                  width: 20,
                  color: AppColors.grey666,
                ),
              ),
              suffixIcon: WidgetUtils.getFormFieldColorSuffixIcon(
                Images.ic_dropdownArrow,
                color: AppColors.gray,
              ),
              errorStyle: TextStyle(color: AppColors.red),
              hintStyle: context.theme.hintStyle,
            ),
            validator: (value) => Validator.validateStringBlank(
                _textEducationController.text, AppLocalizations.of(context)!.selectAcademicLevel),
          ),
        ),
      ),

      //Quan hệ
      GestureDetector(
        onTap: () => AppDialogs.showListDialog(
                context: context,
                list: MaritalStatus.selectableItemList,
                value: _marriage)
            .then((value) {
          if (value != null) _marriage = value;
          _textMarriageController.text = _marriage.name;
        }),
        child: Container(
          width: 360,
          height: 62,
          child: OutlineTextFormField(
            enable: false,
            controller: _textMarriageController,
            style: context.theme.inputStyle,
            textCapitalization: TextCapitalization.words,
            decoration: context.theme.inputDecoration.copyWith(
              hintText: AppLocalizations.of(context)!.selectMaritalStatus,
              disabledBorder: AppBorderAndRadius.outlineInputBorder,
              prefixIcon: Container(
                padding: EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  Images.ic_marriage,
                  height: 20,
                  width: 20,
                  color: AppColors.grey666,
                ),
              ),
              suffixIcon: WidgetUtils.getFormFieldColorSuffixIcon(
                Images.ic_dropdownArrow,
                color: AppColors.gray,
              ),
              hintStyle: context.theme.hintStyle,
            ),
          ),
        ),
      ),

      //kinh nghiệm
      GestureDetector(
        onTap: () => AppDialogs.showListDialog(
                context: context,
                list: WorkExperience.selectableItemList,
                value: _work)
            .then((value) {
          if (value != null) _work = value;
          _textWorkController.text = _work.name;
        }),
        child: Container(
          width: 360,
          height: 62,
          child: OutlineTextFormField(
            enable: false,
            controller: _textWorkController,
            style: context.theme.inputStyle,
            textCapitalization: TextCapitalization.words,
            decoration: context.theme.inputDecoration.copyWith(
              hintText: AppLocalizations.of(context)!.selectMaritalStatus,
              disabledBorder: AppBorderAndRadius.outlineInputBorder,
              prefixIcon: Container(
                padding: EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  Images.ic_work,
                  height: 20,
                  width: 20,
                  color: AppColors.grey666,
                ),
              ),
              suffixIcon: WidgetUtils.getFormFieldColorSuffixIcon(
                Images.ic_dropdownArrow,
                color: AppColors.gray,
              ),
              hintStyle: context.theme.hintStyle,
            ),
          ),
        ),
      ),

      //vị trí
      GestureDetector(
        onTap: () => AppDialogs.showListDialog(
                context: context,
                list: Position.selectableItemList,
                value: _position)
            .then((value) {
          if (value != null) _position = value;
          _textPositionController.text = _position.name;
        }),
        child: Container(
          width: 360,
          height: 62,
          child: OutlineTextFormField(
            controller: _textPositionController,
            enable: false,
            style: context.theme.inputStyle,
            textCapitalization: TextCapitalization.words,
            decoration: context.theme.inputDecoration.copyWith(
              hintText: AppLocalizations.of(context)!.selectPosition,
              disabledBorder: AppBorderAndRadius.outlineInputBorder,
              prefixIcon: Container(
                padding: EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  Images.ic_position,
                  height: 20,
                  width: 20,
                  color: AppColors.grey666,
                ),
              ),
              suffixIcon: WidgetUtils.getFormFieldColorSuffixIcon(
                Images.ic_dropdownArrow,
                color: AppColors.gray,
              ),
              hintStyle: context.theme.hintStyle,
            ),
          ),
        ),
      ),

      //phòng ban
      GestureDetector(
        onTap: () => AppDialogs.showListDialog(
                context: context,
                list: signUpCubit.listDepartment,
                value: _department)
            .then((value) {
          setState(() {
            if (value != null) {
              //*Kiem tra gia tri chon cu co giong moi khong
              if (value != _department) {
                _department = value;
                _textDepartmentController.text = _department.name;

                //*Xoa gia tri cu
                signUpCubit.listNest.clear();
                signUpCubit.listGroup.clear();
                _nest = null;
                _group = null;
                _textNestController.text = '';
                _textGroupController.text = '';

                //*Lay gia tri moi
                //id = '0' la Chon phong ban
                if (_department.id != '0') signUpCubit.getNest(_department.id);
              }
            }
          });
        }),
        child: Container(
          width: 360,
          height: 62,
          child: OutlineTextFormField(
            controller: _textDepartmentController,
            enable: false,
            style: _department.id == '0'
                ? context.theme.hintStyle
                : context.theme.inputStyle,
            textCapitalization: TextCapitalization.words,
            decoration: context.theme.inputDecoration.copyWith(
              hintText: AppLocalizations.of(context)!.selectDepartment,
              disabledBorder: AppBorderAndRadius.outlineInputBorder,
              prefixIcon: Container(
                padding: EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  Images.ic_department,
                  height: 20,
                  width: 20,
                  color: AppColors.grey666,
                ),
              ),
              suffixIcon: WidgetUtils.getFormFieldColorSuffixIcon(
                Images.ic_dropdownArrow,
                color: AppColors.gray,
              ),
              hintStyle: context.theme.hintStyle,
            ),
          ),
        ),
      ),

      //tổ
      BlocConsumer<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is GetNestStateError) {
            //AppDialogs.toast('Lấy danh sách tổ thất bại');
          }
        },
        buildWhen: (previous, current) =>
            current is GetNestStateLoad ||
            current is GetNestStateSuccess ||
            current is GetNestStateError,
        builder: (context, state) {
          if (state is GetNestStateLoad) {
            return OutlineTextFormField(
              controller: _textNestController,
              enable: false,
              style: context.theme.inputStyle,
              textCapitalization: TextCapitalization.words,
              decoration: context.theme.inputDecoration.copyWith(
                hintText: AppLocalizations.of(context)!.selectNest,
                // disabledBorder: AppBorderAndRadius.outlineInputBorder,
                prefixIcon: WidgetUtils.getFormFieldColorPrefixIcon(
                  Images.ic_nest,
                  color: AppColors.gray.withOpacity(0.8),
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 18),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: AppColors.gray.withOpacity(0.8)),
                  ),
                ),
                hintStyle: context.theme.hintStyle,
              ),
            );
          } else if (state is GetNestStateSuccess &&
              signUpCubit.listNest.isNotEmpty) {
            return GestureDetector(
              onTap: () => AppDialogs.showListDialog(
                      context: context,
                      list: signUpCubit.listNest,
                      value: _nest)
                  .then((value) {
                setState(() {
                  if (value != null) {
                    if (_nest != value) {
                      _nest = value;
                      _textNestController.text = _nest!.name;
                      _group = null;
                      _textGroupController.text = '';
                      signUpCubit.getGroup(_nest!.id);
                    }
                  }
                });
              }),
              child: Container(
                width: 360,
                height: 62,
                child: OutlineTextFormField(
                  controller: _textNestController,
                  enable: false,
                  style: context.theme.inputStyle,
                  textCapitalization: TextCapitalization.words,
                  decoration: context.theme.inputDecoration.copyWith(
                    hintText: AppLocalizations.of(context)!.selectNest,
                    disabledBorder: AppBorderAndRadius.outlineInputBorder,
                    prefixIcon: WidgetUtils.getFormFieldColorPrefixIcon(
                      Images.ic_nest,
                      color: AppColors.gray,
                    ),
                    suffixIcon: WidgetUtils.getFormFieldColorSuffixIcon(
                      Images.ic_dropdownArrow,
                      color: AppColors.gray,
                    ),
                    hintStyle: context.theme.hintStyle,
                  ),
                ),
              ),
            );
          }
          return Container(
            width: 360,
            height: 62,
            child: GestureDetector(
              onTap: () {
                // if (_department.id == '0') {
                //   AppDialogs.toast('Vui lòng chọn phòng ban');
                // }
                // if (_department.id != '0') {
                //   AppDialogs.toast('Phòng ban không có tổ');
                // }
              },
              child: OutlineTextFormField(
                controller: _textNestController,
                enable: false,
                style: context.theme.inputStyle,
                textCapitalization: TextCapitalization.words,
                decoration: context.theme.inputDecoration.copyWith(
                  hintText: AppLocalizations.of(context)!.selectNest,
                  // disabledBorder: AppBorderAndRadius.outlineInputBorder,
                  prefixIcon: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: SvgPicture.asset(
                      Images.ic_nest,
                      height: 20,
                      width: 20,
                      color: AppColors.grey666,
                    ),
                  ),
                  suffixIcon: WidgetUtils.getFormFieldColorSuffixIcon(
                    Images.ic_dropdownArrow,
                    color: AppColors.gray.withOpacity(0.6),
                  ),
                  hintStyle: context.theme.hintStyle,
                ),
              ),
            ),
          );
        },
      ),

      //nhóm
      BlocConsumer<SignUpCubit, SignUpState>(
          listener: (context, state) {
            if (state is GetNestStateError) {
              //AppDialogs.toast('Lấy danh sách tổ thất bại');
            }
          },
          buildWhen: (previous, current) =>
              current is GetGroupStateLoad ||
              current is GetGroupStateSuccess ||
              current is GetGroupStateError,
          builder: (context, state) {
            if (state is GetGroupStateLoad) {
              return OutlineTextFormField(
                controller: _textGroupController,
                enable: false,
                style: context.theme.inputStyle,
                textCapitalization: TextCapitalization.words,
                decoration: context.theme.inputDecoration.copyWith(
                  hintText: AppLocalizations.of(context)!.selectGroup,
                  // disabledBorder:
                  //     AppBorderAndRadius.outlineInputBorder,
                  prefixIcon: WidgetUtils.getFormFieldColorPrefixIcon(
                    Images.ic_group,
                    color: AppColors.gray.withOpacity(0.6),
                  ),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 18),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: AppColors.gray.withOpacity(0.8)),
                    ),
                  ),
                  hintStyle: context.theme.hintStyle,
                ),
              );
            } else if (state is GetGroupStateSuccess &&
                signUpCubit.listGroup.isNotEmpty) {
              return GestureDetector(
                onTap: () => AppDialogs.showListDialog(
                        context: context,
                        list: signUpCubit.listGroup,
                        value: _position)
                    .then((value) {
                  if (value != null) _group = value;
                  if (_group != null) _textGroupController.text = _group!.name;
                }),
                child: Container(
                  width: 360,
                  height: 62,
                  child: OutlineTextFormField(
                    controller: _textGroupController,
                    enable: false,
                    style: context.theme.inputStyle,
                    textCapitalization: TextCapitalization.words,
                    decoration: context.theme.inputDecoration.copyWith(
                      hintText: AppLocalizations.of(context)!.selectGroup,
                      disabledBorder: AppBorderAndRadius.outlineInputBorder,
                      prefixIcon: WidgetUtils.getFormFieldColorPrefixIcon(
                        Images.ic_group,
                        color: AppColors.gray,
                      ),
                      suffixIcon: WidgetUtils.getFormFieldColorSuffixIcon(
                        Images.ic_dropdownArrow,
                        color: AppColors.gray,
                      ),
                      hintStyle: context.theme.hintStyle,
                    ),
                  ),
                ),
              );
            }
            return GestureDetector(
              onTap: () {
                // if (_nest == null) {
                //   AppDialogs.toast('Vui lòng chọn tổ');
                // }
                // if (_nest != null) {
                //   AppDialogs.toast('Tổ không có nhóm');
                // }
              },
              child: Container(
                width: 360,
                height: 62,
                child: OutlineTextFormField(
                  controller: _textGroupController,
                  enable: false,
                  style: context.theme.inputStyle,
                  textCapitalization: TextCapitalization.words,
                  decoration: context.theme.inputDecoration.copyWith(
                    hintText: AppLocalizations.of(context)!.selectGroup,
                    // disabledBorder:
                    //     AppBorderAndRadius.outlineInputBorder,
                    prefixIcon: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: SvgPicture.asset(
                        Images.ic_group,
                        height: 20,
                        width: 20,
                        color: AppColors.grey666,
                      ),
                    ),
                    suffixIcon: WidgetUtils.getFormFieldColorSuffixIcon(
                      Images.ic_dropdownArrow,
                      color: AppColors.gray.withOpacity(0.6),
                    ),
                    hintStyle: context.theme.hintStyle,
                  ),
                ),
              ),
            );
          }),
    ];

    return MultiBlocListener(
      listeners: [
        BlocListener<SignUpCubit, SignUpState>(
            bloc: signUpCubit,
            listener: (context, state) async {
              //*Kiem tra trung tai khoan
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
                  //AppDialogs.hideLoadingCircle(context);
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
                        'isMD5': false,
                        'userType': UserType.staff,
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
                      if (_textAccountController.text.contains('@'))
                        _validator =
                            (value) => 'Địa chỉ email đăng ký đã tồn tại';
                      if (!_textAccountController.text.contains('@'))
                        _validator =
                            (value) => 'Số điện thoại đăng ký đã tồn tại';
                    });
                  }
                }
                //AppDialogs.toast(state.error);
              }
            }),
      ],
      child: CustomAuthScaffold(
        // title: 'Thiết lập thông tin tài khoản',
        extendBodyBehindAppBar: true,
        scrollAble: true,
        useAppBar: false,
        child: Container(
          color: AppColors.white,
          width: MediaQuery.of(context).size.width,
          //padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Form(
            key: _form,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (Platform.isMacOS) const SizedBox(height: 20),
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

                  Text(
                    AppLocalizations.of(context)!.fillInfoAccount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: context.theme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBoxExt.h10,
                  Container(
                    // constraints: BoxConstraints(
                    //     maxHeight:
                    //         MediaQuery.of(context).size.height /
                    //             2.5
                    // ),
                    height: 350,
                    child: SingleChildScrollView(
                      child: Column(
                        children: children,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 25,
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
                          value: _isAgree,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _isAgree = newValue!;
                            });
                          }),
                      Text(
                        AppLocalizations.of(context)!.agrreewith,
                        style: TextStyle(
                            color: AppColors.grey666,
                            fontWeight: FontWeight.w500),
                      ),
                      GestureDetector(
                        child: Text(
                          AppLocalizations.of(context)!.chat365Rules,
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          launch(
                              'https://chat365.timviec365.vn/thoa-thuan-su-dung.html');
                        },
                      )
                    ],
                  ),

                  SizedBoxExt.h5,
                  // Nut chuc nang
                  // FillButton(
                  //   backgroundColor: _isAgree ? AppColors.primary : AppColors.gray,
                  //   width: 360,
                  //   title: 'Tiếp tục',
                  //   onPressed: () {
                  //     if(_isAgree) {
                  //       _btnSetUpAccount(context);
                  //     }
                  //   } ,
                  // ),
                  InkWell(
                    onTap: () {
                      if (_isAgree) {
                        _btnSetUpAccount(context);
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 40,
                      decoration: BoxDecoration(
                          gradient: _isAgree
                              ? context.theme.gradient
                              : Gradients.offLinearLight,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        AppLocalizations.of(context)!.done,
                        style: AppTextStyles.button(context)
                            .copyWith(color: AppColors.white),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 5,
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                            AppRouter.toPage(context, AppPages.ChoosePosition,
                                arguments: {'isLogIn': true});
                          });
                        },
                      )
                    ],
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
