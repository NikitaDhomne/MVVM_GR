import 'dart:convert';

import 'package:gr_assignment/model/employee_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final url = "https://dummy.restapiexample.com/api/v1/employees";
  var employeedata;
  Future<EmployeeModel> getEmployeeDataApi() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body.toString());
      employeedata = EmployeeModel.fromJson(data);
      return employeedata;
    } else {
      throw Exception('Failed to load employee details');
    }
  }
}
