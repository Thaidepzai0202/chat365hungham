import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AutoDeleteMessageDialog extends StatefulWidget {
  @override
  _AutoDeleteMessageDialogState createState() => _AutoDeleteMessageDialogState();
}

class _AutoDeleteMessageDialogState extends State<AutoDeleteMessageDialog> {
  String selectedOption = 'Không bao giờ';


  Widget buildRadioListTile(String title, String value, String groupValue, ValueChanged<String?> onChanged) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20),
    height: 35,
    child: RadioListTile<String>(
      title: Text(title,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400),),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cài đặt tin nhắn tự xóa'),
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      contentTextStyle: TextStyle(color: AppColors.gray),
      content: Container(
        height: 270,
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10,),
            Container(height: 1,color: AppColors.grey666,width: 300-30,),
            buildRadioListTile('Không bao giờ', 'Không bao giờ', selectedOption, (value) {setState(() {selectedOption = value as String;}); }),
            buildRadioListTile('10 giây', '10 giây', selectedOption, (value) {setState(() {selectedOption = value as String;}); }),
            buildRadioListTile('1 phút', '1 phút', selectedOption, (value) { setState(() {selectedOption = value as String;});}),
            buildRadioListTile('1 giờ', '1 giờ', selectedOption, (value) { setState(() {selectedOption = value as String;});}),
            buildRadioListTile('1 ngày', '1 ngày', selectedOption, (value) { setState(() {selectedOption = value as String;});}),
            buildRadioListTile('7 ngày', '7 ngày', selectedOption, (value) { setState(() {selectedOption = value as String;});}),
            buildRadioListTile('30 ngày', '30 ngày', selectedOption, (value) { setState(() {selectedOption = value as String;});}),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text('Hủy',style: TextStyle(color: AppColors.gray7777777),),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedOption);
          },
          child: Text('Xác nhận'),
        ),        
      ],
    );
  }
}

class ContemponaryMessage extends StatefulWidget {
  @override
  _ContemponaryMessageState createState() => _ContemponaryMessageState();
}

class _ContemponaryMessageState extends State<ContemponaryMessage> {
  String selectedOption = 'Không bao giờ';
  String inputData = '';

  Widget search() {
    return Container(
      padding: EdgeInsets.only(left: 15),
      height: 36,
      width: 310,
      child: TextField(
        onChanged: (value) {
          setState(() {
            inputData = value;
          });
        },
        onSubmitted: (value) {
          //
        },
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm với Chat365',
          hintStyle: TextStyle(fontSize: 14),
          contentPadding:
              EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: AppColors.whiteLilac,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.white, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: AppColors.blueBorder, width: 1), // Màu khi focus
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
                color: AppColors.greyD9, width: 1), // Màu khi không focus
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Gửi đồng thời'),
      contentPadding: EdgeInsets.symmetric(vertical: 0),
      contentTextStyle: TextStyle(color: AppColors.gray),
      content: Container(
        height: 270,
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10,),
            Container(height: 1,color: AppColors.grey666,width: 300-30,),
            search(),
            ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text('Hủy',style: TextStyle(color: AppColors.gray7777777),),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, selectedOption);
          },
          child: Text('Xác nhận'),
        ),        
      ],
    );
  }
}


