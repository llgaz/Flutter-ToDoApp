/* 

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditableTaskPage extends StatefulWidget {
  final String initialTaskName;
  final DateTime initialTaskDate;
  final String initialTaskNote;

  EditableTaskPage({
    required this.initialTaskName,
    required this.initialTaskDate,
    required this.initialTaskNote,
  });

  @override
  _EditableTaskPageState createState() => _EditableTaskPageState();
}

class _EditableTaskPageState extends State<EditableTaskPage> {
  late TextEditingController _taskNameController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.initialTaskName);
    _selectedDate = widget.initialTaskDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.initialTaskDate);
    _noteController = TextEditingController(text: widget.initialTaskNote);
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Task Date',
                ),
                child: Text(
                  DateFormat('yyyy-MM-dd').format(_selectedDate),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Task Time',
                ),
                child: Text(
                  _selectedTime.format(context),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(labelText: 'Task Note'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Değişiklikleri kaydet
                DateTime newDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );

                Navigator.pop(
                  context,
                  {
                    'name': _taskNameController.text,
                    'datetime': newDateTime,
                    'note': _noteController.text,
                  },
                );
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
