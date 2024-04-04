import 'package:flutter/material.dart';
import 'package:gr_assignment/model/employee_model.dart';
import 'package:gr_assignment/respository/employee_repository.dart';

class EmployeeViewModel with ChangeNotifier {
  final EmployeeRepository employeeRepository; // Use Repository if included

  bool _isLoading = false;
  EmployeeModel? _employee;

  bool get isLoading => _isLoading;
  EmployeeModel? get employee => _employee;

  set employee(EmployeeModel? value) {
    _employee = value;
    notifyListeners();
  }

  EmployeeViewModel(this.employeeRepository); // Inject Repository if included

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners(); // Notify UI of loading state change

    try {
      final employeeModel = await employeeRepository.getEmployee();
      _employee = employeeModel; // Assign the entire EmployeeModel
    } on Exception catch (e) {
      // Handle error gracefully (e.g., show error message)
      print(e); // Log error for debugging
      throw e; // Re-throw the exception to handle it in the UI
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI of data update or error
    }
  }
}
