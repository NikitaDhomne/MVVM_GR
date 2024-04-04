class EmployeeModel {
  String? status;
  List<Data>? data;
  String? message;

  EmployeeModel({this.status, this.data, this.message});

  EmployeeModel.fromJson(Map<String, dynamic> json) {
    if (json["status"] is String) {
      status = json["status"];
    }
    if (json["data"] is List) {
      data = json["data"] == null
          ? null
          : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
    }
    if (json["message"] is String) {
      message = json["message"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["status"] = status;
    if (data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    _data["message"] = message;
    return _data;
  }
}

class Data {
  int? id;
  String? employeeName;
  int? employeeSalary;
  int? employeeAge;
  String? profileImage;

  Data(
      {this.id,
      this.employeeName,
      this.employeeSalary,
      this.employeeAge,
      this.profileImage});

  Data copyWith({
    int? id,
    String? employeeName,
    int? employeeSalary,
    int? employeeAge,
    String? profileImage,
  }) {
    return Data(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeSalary: employeeSalary ?? this.employeeSalary,
      employeeAge: employeeAge ?? this.employeeAge,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    if (json["id"] is int) {
      id = json["id"];
    }
    if (json["employee_name"] is String) {
      employeeName = json["employee_name"];
    }
    if (json["employee_salary"] is int) {
      employeeSalary = json["employee_salary"];
    }
    if (json["employee_age"] is int) {
      employeeAge = json["employee_age"];
    }
    if (json["profile_image"] is String) {
      profileImage = json["profile_image"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["employee_name"] = employeeName;
    _data["employee_salary"] = employeeSalary;
    _data["employee_age"] = employeeAge;
    _data["profile_image"] = profileImage;
    return _data;
  }
}
