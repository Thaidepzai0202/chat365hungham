class DepartmentModel {
  String? sId;
  int? depId;
  int? comId;
  String? depName;
  String? depCreateTime;
  int? managerId;
  int? depOrder;
  int? totalEmp;
  String? manager;
  String? deputy;

  DepartmentModel(
      {this.sId,
      this.depId,
      this.comId,
      this.depName,
      this.depCreateTime,
      this.managerId,
      this.depOrder,
      this.totalEmp,
      this.manager,
      this.deputy});

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      sId: json['_id'] ?? '',
      depId: json['dep_id'] ?? 0,
      comId: json['com_id'] ?? 0,
      depName: json['dep_name'] ?? '',
      depCreateTime: json['dep_create_time'] ?? '',
      managerId: json['manager_id'] ?? 0,
      depOrder: json['dep_order'] ?? 0,
      totalEmp: json['total_emp'] ?? 0,
      manager: json['manager'] ?? '',
      deputy: json['deputy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['dep_id'] = this.depId;
    data['com_id'] = this.comId;
    data['dep_name'] = this.depName;
    data['dep_create_time'] = this.depCreateTime;
    data['manager_id'] = this.managerId;
    data['dep_order'] = this.depOrder;
    data['total_emp'] = this.totalEmp;
    data['manager'] = this.manager;
    data['deputy'] = this.deputy;
    return data;
  }
}
