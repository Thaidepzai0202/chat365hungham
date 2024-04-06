import 'dart:convert';

import 'package:app_chat365_pc/core/constants/link_web.dart';

class LinkWebModel {
  int id;
  int idEmployer;
  int positionType;
  int idConversation;

  LinkWebModel(
      {required this.id,
      required this.idEmployer,
      required this.positionType,
      required this.idConversation});

  factory LinkWebModel.fromJson(Map<String, dynamic> json) => LinkWebModel(
        id: json["id"] ?? 0,
        idEmployer: json["id"] ?? 0,
        positionType: json["id"] ?? 0,
        idConversation: json["id"] ?? 0,
      );
}

LinkWebModel makeInformationFromApp(String infor) {
  late LinkWebModel linkWebModel;
  late String id;
  late int idDecode;
  late String idEmployer;
  late int idEmployerDecode;
  late String idConversation;
  late int idConversationDecode;
  late int positionType;

  List<String> tmp = infor.split('/');
  id = tmp[1];
  idEmployer = tmp[2];
  positionType = int.parse(tmp[3]);
  

  Codec<String, String> stringToBase64 = utf8.fuse(base64);
  idDecode = int.parse(stringToBase64.decode(id));
  idEmployerDecode = int.parse(stringToBase64.decode(idEmployer));

  idConversationDecode = tmp.length==4 ? 0 : int.parse(stringToBase64.decode(tmp[4]));

  return LinkWebModel(
      id: idDecode,
      idEmployer: idEmployerDecode,
      positionType: positionType,
      idConversation: idConversationDecode);
}
