import 'dart:io';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class AssetModel extends Equatable {
  // final String id;
  final File file;
  final Uint8List? thumbnail;
  final int duration;
  final String? id;

  @override
  List<Object> get props => [file];

  const AssetModel({
    // required this.id,
    required this.file,
    this.thumbnail,
    this.duration = 0,
    this.id,
  });
}
