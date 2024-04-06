class FileModel{
  final String fullName;
  final String nameDisplay;
  final String typeFile;
  final int sizeFile;
  final String? imageSource;
  final String fileSizeInByte;
  final num? width;
  final num? height;
  final bool? isDownload;
  final String? filePath;
  FileModel({
    required this.fullName,
    required this.nameDisplay,
    required this.typeFile,
    required this.sizeFile,
     this.imageSource = '',
    required this.fileSizeInByte,
     this.width = 0,
     this.height = 0,
     this.isDownload = false,
     this.filePath = '',
  });
  // factory FileModel.fromJson(Map<String, dynamic> json) => FileModel(
  //     fullName: fullName, nameDisplay: nameDisplay, typeFile: typeFile, sizeFile: sizeFile, imageSource: imageSource, fileSizeInByte: fileSizeInByte, width: width, height: height, isDownload: isDownload, filePath: filePath)

}