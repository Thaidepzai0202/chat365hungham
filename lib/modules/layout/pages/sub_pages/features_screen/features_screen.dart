import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/constants/asset_path.dart';
import 'package:app_chat365_pc/core/constants/string_constants.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:app_chat365_pc/modules/navigations/widget/feature_item.dart';
import 'package:app_chat365_pc/modules/navigations/widget/utilities_dialog.dart';
import 'package:flutter/material.dart';

class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureSection(
            title: StringConst.message,
            features: [
              _buildFeatureItem(
                assetPath: AssetPath.trash,
                gradient: LinearGradient(colors: AppColors.colorGeneral6),
                label: StringConst.autoDeleteMessage,
                onTap: () {
                  _showDialog(context, AutoDeleteMessageDialog());
                },
              ),
              _buildFeatureItem(
                assetPath: Images.message_tick_msg,
                gradient: LinearGradient(colors: AppColors.colorGeneral9),
                label: StringConst.contemponary_message,
                onTap: () {
                  _showDialog(context, ContemponaryMessage());
                },
              ),
              _buildFeatureItem(
                assetPath: Images.flash_circle,
                gradient: LinearGradient(colors: AppColors.colorGeneral7),
                label: StringConst.fastMessage,
                onTap: () {},
              ),
              _buildFeatureItem(
                assetPath: Images.star_msg,
                gradient: LinearGradient(colors: AppColors.colorGeneral8),
                label: StringConst.bookmarkMessage,
                onTap: () {},
              ),
            ],
          ),
          _buildFeatureSection(
            title: StringConst.tools,
            features: [
              _buildFeatureItem(
                assetPath: Images.ic_poll,
                gradient: LinearGradient(colors: AppColors.colorGeneral10),
                label: StringConst.searchExploration,
                onTap: () {},
              ),
              _buildFeatureItem(
                assetPath: Images.ic_screen_capture,
                gradient: LinearGradient(colors: AppColors.colorGeneral11),
                label: StringConst.screenCapture,
                onTap: () {},
              ),
            ],
          ),
          _buildFeatureSection(
            title: StringConst.content,
            features: [
              _buildFeatureItem(
                assetPath: Images.alarm_clock_01,
                gradient: LinearGradient(colors: AppColors.colorGeneral12),
                label: StringConst.create_reminders,
                onTap: () {},
              ),
              _buildFeatureItem(
                assetPath: Images.ic_fluent_contact_card,
                gradient: LinearGradient(colors: AppColors.colorGeneral13),
                label: StringConst.sendContactCard,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection({
    required String title,
    required List<Widget> features,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 14, top: 15),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.tundora,
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(children: features),
      ],
    );
  }

  Widget _buildFeatureItem({
    required String assetPath,
    required LinearGradient gradient,
    required String label,
    required VoidCallback onTap,
  }) {
    return FeatureItem(
      assetPath: assetPath,
      gradient: gradient,
      label: label,
      onTap: onTap,
    );
  }

  void _showDialog(BuildContext context, Widget dialog) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }
}
