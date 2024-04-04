import 'package:flutter/material.dart';
import 'package:gr_assignment/model/employee_model.dart';
import 'package:gr_assignment/respository/employee_repository.dart';

class EmployeeViewModel with ChangeNotifier {
  final EmployeeRepository employeeRepository;

  bool _isLoading = false;
  EmployeeModel? _employee;

  bool get isLoading => _isLoading;
  EmployeeModel? get employee => _employee;

  set employee(EmployeeModel? value) {
    _employee = value;
    notifyListeners();
  }

  EmployeeViewModel(this.employeeRepository);

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final employeeModel = await employeeRepository.getEmployee();
      _employee = employeeModel;
    } on Exception catch (e) {
      print(e);
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
