import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/common/power_policy_widget.dart';
import 'package:app_chat365_pc/common/widgets/fill_button.dart';
import 'package:app_chat365_pc/common/widgets/form/outline_text_form_field.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/core/theme/app_text_style.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/cubit/signup_cubit.dart';
import 'package:app_chat365_pc/modules/auth/modules/signup/sign_up_employee.dart';
import 'package:app_chat365_pc/router/app_pages.dart';
import 'package:app_chat365_pc/router/app_router.dart';
import 'package:app_chat365_pc/utils/data/enums/auth_mode.dart';
import 'package:app_chat365_pc/utils/data/extensions/context_extension.dart';
import 'package:app_chat365_pc/utils/helpers/validators.dart';
import 'package:app_chat365_pc/utils/ui/app_border_and_radius.dart';
import 'package:app_chat365_pc/utils/ui/app_padding%20copy.dart';
import 'package:app_chat365_pc/utils/ui/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class InputSignUpEmployeeIDCompany extends StatefulWidget {
  _InputSignUpEmployeeIDCompanyState createState() =>
      _InputSignUpEmployeeIDCompanyState();
}

class _InputSignUpEmployeeIDCompanyState
    extends State<InputSignUpEmployeeIDCompany> {
  TextEditingController _textEditingController = TextEditingController();
  ValueNotifier<bool> _onOff = ValueNotifier(true);
  final _form = GlobalKey<FormState>();
  FocusNode _focusNode = FocusNode();

  // Gan loi thanh validator
  String? Function(String?)? _validator;

  // Lay do dai cua widget
  final _radioKey = GlobalKey();

  @override
  void initState() {
    _validator = (p0) => Validator.validateStringBlocSpecialCharacters(
        _textEditingController.text, AppLocalizations.of(context)!.inputIdCompany);
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  _btnCompareIdCompanyPressedHandler(BuildContext context, String idCompany) {
    SignUpCubit signUpCubit = context.read<SignUpCubit>();
    if (_form.currentState!.validate()) {
      signUpCubit.checkIdCompany(idCompany);
    } else {
      _form.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignUpCubit>();

    return BlocListener<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is ValidateVipFailureState) {
          //AppDialogs.hideLoadingCircle(context);
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Công ty của bạn đã vượt quá giới hạn nhân viên!\nVui lòng liên hệ với bộ phận chăm sóc khách hàng của Timviec365.vn để được hỗ trợ!',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        onTap: () => AppRouter.back(context),
                        child: Container(
                          height: 36,
                          width: 100,
                          decoration: BoxDecoration(
                              gradient: context.theme.gradient,
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                            child: Text(
                              'Đồng ý',
                              style: AppTextStyles.authTitle
                                  .copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              });
        }
        if (state is CompareIdCompanyStateLoad) {
          //AppDialogs.showLoadingCircle(context);
        }
        if (state is CompareIdCompanyStateSuccess) {
          //AppDialogs.hideLoadingCircle(context);
          AppRouter.toPage(context, AppPages.inPutEmployee,
              blocValue: bloc,
              arguments: {InputSignUpEmployee.authModeArg: AuthMode.REGISTER});
        }
        if (state is CompareIdCompanyStateError) {
          setState(() {
            if (bloc.error != null) {
              if (bloc.error!.code == 200) {
                _validator = (p0) => bloc.error!.messages;
              }
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(20).copyWith(top: 0, bottom: 0),
        child: Form(
          key: _form,
          child: Column(
            children: [
              SizedBoxExt.h30,
              Text(
                AppLocalizations.of(context)!.signUpEmployee,
                style: TextStyle(
                  fontSize: 24,
                  color: context.theme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBoxExt.h40,
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 2 / 3,
                ),

                // Phan hien chuc nang cua man
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    children: [
                      Container(
                        padding: AppPadding.paddingAll20,
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.black99,
                                  spreadRadius: 0,
                                  blurRadius: 4)
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Phan chuc nang quet qr code

                            // Phan chuc nang nhap id cong ty
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${AppLocalizations.of(context)!.inputIdCompanyProvideByHR}:',
                                    style: AppTextStyles.regularW500(context,
                                        size: 16,
                                        lineHeight: 18.75,
                                        color: context.theme.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 10),
                              child: OutlineTextFormField(
                                enable: true,
                                keyboardType: TextInputType.number,
                                controller: _textEditingController,
                                focusNode: _focusNode,
                                style: context.theme.inputStyle,
                                onChanged: (value) {
                                  if (_validator !=
                                      (p0) => Validator
                                          .validateStringBlocSpecialCharacters(
                                              _textEditingController.text,
                                              AppLocalizations.of(context)!.inputIdCompany)) {
                                    setState(() {
                                      _validator = (p0) => Validator
                                          .validateStringBlocSpecialCharacters(
                                              _textEditingController.text,
                                              AppLocalizations.of(context)!.inputIdCompany);
                                    });
                                  }
                                },
                                validator: _validator,
                                decoration:
                                    context.theme.inputDecoration.copyWith(
                                  hintText: AppLocalizations.of(context)!.inputIdCompany,
                                  hintStyle: context.theme.hintStyle,
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius:
                                        AppBorderAndRadius.formBorderRadius,
                                  ),
                                  fillColor: AppColors.white,
                                  prefixIcon: Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child: SvgPicture.asset(
                                      Images.ic_building,
                                      height: 20,
                                      width: 20,
                                      color: AppColors.gray,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBoxExt.h30,

                      // Nut xac thuc ma cong ty

                      InkWell(
                        onTap: () => _btnCompareIdCompanyPressedHandler(
                            context, _textEditingController.text),
                        child: Container(
                          alignment: Alignment.center  ,
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                              gradient: context.theme.gradient,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            AppLocalizations.of(context)!.verifyCompanyCode,
                            style: AppTextStyles.button(context)
                                .copyWith(color: AppColors.white),
                          ),
                        ),
                      ),

                      SizedBoxExt.h20,
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
                      ),

                      // Tao khoang cach cho phep cuon len de toi uu hien thi truong nhap

                      MediaQuery.of(context).viewInsets.bottom >
                              MediaQuery.of(context).size.width *
                                  0.30133333333333334
                          ? SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom -
                                  MediaQuery.of(context).size.width *
                                      0.30133333333333334,
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom,
                            ),
                      SizedBoxExt.h22,
                      PowerPolicy(context: context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          onChanged: (value) {
            print(valueInput.value);
          },
          onSubmitted: (value) {
            //print(value);
          },
          style: TextStyle(fontSize: 16),
          obscureText: onoff.value && isPass,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 16),
            contentPadding:
                EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
                : SizedBox(),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.0),
              borderSide: BorderSide(color: Colors.white, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.0),
              borderSide: BorderSide(
                  color: AppColors.blueBorder, width: 1), // Màu khi focus
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13.0),
              borderSide: BorderSide(
                  color: AppColors.gray, width: 1), // Màu khi không focus
            ),
          ),
        ),
      ),
    );
  }
}
