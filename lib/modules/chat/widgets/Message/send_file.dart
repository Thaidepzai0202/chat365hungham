import 'dart:io';

import 'package:app_chat365_pc/common/images.dart';
import 'package:app_chat365_pc/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart';

class SendFile extends StatefulWidget {
  SendFile({super.key, required this.linkFile, required this.file});

  String linkFile;
  File file;

  @override
  State<SendFile> createState() => _SendFileState();
}

class _SendFileState extends State<SendFile> {
  bool isImageExtension(String extension) {
    List<String> imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp'
    ]; // Các định dạng ảnh phổ biến

    // Kiểm tra xem phần đuôi có trong danh sách định dạng ảnh không
    return imageExtensions.contains(extension.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    //String fileName = Uri.decodeFull(widget.file.uri.path.split('/').last);

    return Container(
      width: 130,
      height: 110,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          // image: DecorationImage(
          //   image: AssetImage(widget.linkFile),
          //   fit: BoxFit.cover
          // ),
          color: AppColors.gray),
      child: Stack(children: [
        //isImageExtension(fileName) ? 
        Positioned(
          child: SizedBox(
            width: 130,
            height: 110,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                widget.file!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ) ,
        //: Positioned(child: Container()),

        
        Positioned(
          left: 10,
          child: Container(
            width: 110,
            height: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SvgPicture.asset(
                  Images.ic_copy,
                  width: 20,
                  height: 20,
                ),
                Text(
                  Uri.decodeFull(widget.file.uri.path.split('/').last),
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white),
                ),
                Text(
                  '12.34 MB',
                  style: TextStyle(color: AppColors.white, fontSize: 13),
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: InkWell(
            onTap: () {},
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(width: 0.5, color: AppColors.white)),
              child: Center(
                child: Icon(
                  Icons.close,
                  color: Colors.white, // Màu icon trắng
                  size: 14, // Kích thước icon
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
