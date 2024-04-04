import 'package:gr_assignment/model/employee_model.dart';
import 'package:gr_assignment/services/api_services.dart';

class EmployeeRepository {
  final ApiService apiService;

  EmployeeRepository(this.apiService);

  Future<EmployeeModel> getEmployee() => apiService.getEmployeeDataApi();
}
