class RecviceListMemberCallGroupPSDataModel {
  final String codeAdd;
  final String linkGroup;
  final String idCaller;
  final String nameCaller;
  final List<String> idListCallee;
  final bool isVideoCall;
  final dynamic avatarAnother;
  final String nameAnother;

  RecviceListMemberCallGroupPSDataModel({
    required this.codeAdd,
    required this.linkGroup,
    required this.idCaller,
    required this.nameCaller,
    required this.idListCallee,
    required this.isVideoCall,
    required this.avatarAnother,
    required this.nameAnother,
  });

  factory RecviceListMemberCallGroupPSDataModel.fromMap(
      Map<String, dynamic> map) {
    return RecviceListMemberCallGroupPSDataModel(
      codeAdd: map['codeAccess'],
      linkGroup: map['linkGroup'],
      idCaller: map['caller'],
      nameCaller: map['userCaller'],
      avatarAnother: map['avatarAnother'] ?? '',
      nameAnother: map['nameAnother'] ?? '',
      idListCallee: map['listUser'] == null ? [] : List<String>.from(map['listUser'].map((e)=> e)),
      isVideoCall: map['isVideoCall'] == '1' || map['isVideoCall'] == 1,
    );
  }
}
