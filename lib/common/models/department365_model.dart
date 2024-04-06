class Department365 {
  final String depId;
  final String comId;
  final String depName;
  final DateTime depCreateTime;
  final List<dynamic> manager;
  final List<dynamic> deputy;
  final String totalEmp;

  Department365({
    required this.depId,
    required this.comId,
    required this.depName,
    required this.depCreateTime,
    required this.manager,
    required this.deputy,
    required this.totalEmp,
  });

  factory Department365.fromJson(Map<String, dynamic> json) => Department365(
    depId: json["dep_id"],
    comId: json["com_id"],
    depName: json["dep_name"],
    depCreateTime: DateTime.parse(json["dep_create_time"]),
    manager:json["manager"] == [] ? [] : List<dynamic>.from(json["manager"].map((x) => x)),
    deputy:json["deputy"] == [] ? [] : List<dynamic>.from(json["deputy"].map((x) => x)),
    totalEmp: json["total_emp"],
  );


}
