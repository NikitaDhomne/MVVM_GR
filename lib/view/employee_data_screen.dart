import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gr_assignment/model/employee_model.dart';
import 'package:gr_assignment/respository/employee_repository.dart';
import 'package:gr_assignment/services/api_services.dart';
import 'package:gr_assignment/view_model/view_model_employee.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeView extends StatefulWidget {
  @override
  _EmployeeViewState createState() => _EmployeeViewState();
}

class _EmployeeViewState extends State<EmployeeView> {
  final EmployeeViewModel _viewModel = EmployeeViewModel(
      EmployeeRepository(ApiService())); // Create and inject dependencies
  final _selectedEmployeeIds = Set<int>(); // Use a set to store unique IDs

  @override
  void initState() {
    super.initState();
    _viewModel.fetchData();
    _loadData();
    _loadSelectedEmployeeIds(); // Load deleted IDs from SharedPreferences
  }

  Future<void> _loadData() async {
    final employeeData = await _loadEmployeeData();
    final prefs = await SharedPreferences.getInstance();
    final savedEditedData = prefs.getString('edited_employee_data');

    if (savedEditedData != null) {
      final parsedData = jsonDecode(savedEditedData) as Map<String, dynamic>;
      final editedEmployee = Data.fromJson(parsedData);

      // Find the corresponding employee in the list and update
      final index =
          employeeData.indexWhere((emp) => emp.id == editedEmployee.id);
      if (index != -1) {
        employeeData[index] = editedEmployee;
      }
    }

    setState(() {
      _viewModel.employee = EmployeeModel(data: employeeData);
    });
  }

  Future<void> _loadSelectedEmployeeIds() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedIdsString = prefs.getString('selected_employee_ids');
    if (selectedIdsString != null) {
      _selectedEmployeeIds
          .addAll(selectedIdsString.split(',').map(int.parse).toList());
    }
  }

  void _deleteEmployee(int employeeId) async {
    // Check viewModel.employee is not null before accessing data
    if (_viewModel.employee?.data == null) return;

    final index =
        _viewModel.employee!.data!.indexWhere((emp) => emp.id == employeeId);
    if (index != -1) {
      setState(() {
        _selectedEmployeeIds.add(employeeId);
        _viewModel.employee!.data!
            .removeAt(index); // Remove employee from data list
      });
    }
    _saveSelectedEmployeeIds(); // Save updated deleted IDs to SharedPreferences
  }

  Future<void> _saveSelectedEmployeeIds() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedIdsString = _selectedEmployeeIds.join(',');
    await prefs.setString('selected_employee_ids', selectedIdsString);
  }

  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _salaryController = TextEditingController();

  void _showEditDialog(Data employee) {
    final editedEmployee = employee.copyWith(
      employeeName: employee.employeeName,
      employeeAge: employee.employeeAge,
      employeeSalary: employee.employeeSalary,
    );
    _nameController.text = editedEmployee.employeeName ?? '';
    _ageController.text = editedEmployee.employeeAge != null
        ? editedEmployee.employeeAge.toString()
        : '';
    _salaryController.text = editedEmployee.employeeSalary != null
        ? editedEmployee.employeeSalary.toString()
        : '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Employee'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Employee Name'),
                onChanged: (value) => editedEmployee.employeeName = value,
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                onChanged: (value) =>
                    editedEmployee.employeeAge = int.tryParse(value),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _salaryController,
                decoration: InputDecoration(labelText: 'Salary'),
                onChanged: (value) =>
                    editedEmployee.employeeSalary = int.tryParse(value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _saveEmployeeData(editedEmployee);

              final index = _viewModel.employee?.data
                  ?.indexWhere((emp) => emp.id == employee.id);
              if (index != -1) {
                setState(() {
                  _viewModel.employee!.data![index!] = editedEmployee;
                });
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EmployeeViewModel>(
      create: (context) => _viewModel, // Provide already created view model
      child: Scaffold(
        appBar: AppBar(
          title: Text('Employee Data'),
          centerTitle: true,
        ),
        body: Consumer<EmployeeViewModel>(
          builder: (context, viewModel, child) => viewModel.isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildContent(viewModel.employee),
        ),
      ),
    );
  }

  Widget _buildContent(EmployeeModel? employeeData) {
    if (employeeData == null) {
      return Center(
        child: Text('Error loading data'),
      );
    }

    return ListView.builder(
      itemCount: employeeData.data!.length,
      itemBuilder: (context, index) {
        final employee = employeeData.data![index];
        final isDeleted = _selectedEmployeeIds.contains(employee.id);
        final employeeName = employeeData.data![index].employeeName;
        final employeeAge = employeeData.data![index].employeeAge;
        final employeeSalary = employeeData.data![index].employeeSalary;
        return Dismissible(
          key: Key(employee.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) => _deleteEmployee(employee.id!),
          child: isDeleted
              ? Container()
              : Card(
                  color: _getColorByIndex(index),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('images/profile.jpeg'),
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(employeeName.toString()),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Age: ${employeeAge}'),
                        Text('Salary:${employeeSalary}'),
                      ],
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: IconButton(
                        onPressed: () => _showEditDialog(employee.copyWith()),
                        icon: Icon(Icons.edit),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Color _getColorByIndex(int index) {
    if (index % 3 == 0) {
      return Colors.indigoAccent;
    } else if (index % 3 == 1) {
      return Colors.lightGreen;
    } else {
      return Colors.orange;
    }
  }

  void _saveEmployeeData(Data editedEmployee) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(editedEmployee.toJson());
    await prefs.setString('edited_employee_data', jsonData);
  }

  // Load employee data from local storage
  Future<List<Data>> _loadEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('employee_data');
    if (jsonData != null) {
      final List<dynamic> parsedJson = jsonDecode(jsonData);
      return parsedJson.map((e) => Data.fromJson(e)).toList();
    }
    return []; // Return empty list if no data found
  }
}
