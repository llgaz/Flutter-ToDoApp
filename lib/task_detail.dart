import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:todo/colors.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskName;
  final DateTime taskDate;
  final String taskNote;
  final Function(Map<String, dynamic>) onUpdateTask;

  TaskDetailPage({
    required this.taskName,
    required this.taskDate,
    required this.taskNote,
    required this.onUpdateTask,
    required DateTime taskDateTime,
  });

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _taskNameController;
  late TextEditingController _taskNoteController;
  late DateTime _selectedDate; // Yeni seçilen tarih
  late TimeOfDay _selectedTime; // Yeni seçilen saat

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.taskName);
    _taskNoteController = TextEditingController(text: widget.taskNote);
    _selectedDate = widget.taskDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.taskDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // Temanın örneğini oluşturun
            primaryColor:
                Colors.blue, // İstediğiniz renkleri burada ayarlayabilirsiniz
            hintColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.amber),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.amber),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor(appBarColor),
        title: const Column(
          children: [
            Text(
              "Task Detail",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            )
          ],
        ),
        centerTitle: true,
        toolbarHeight: 135,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text('Task Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 3, color: HexColor(appBarColor)),
                      borderRadius: BorderRadius.circular(30.0)),
                  prefixIcon: const Icon(Icons.text_fields_rounded)),
            ),
            const SizedBox(height: 30),
            const Text('Task Date',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Row(
              children: [
                Text(
                  DateFormat('dd.MM.yyyy').format(_selectedDate),
                  style: TextStyle(fontSize: 19),
                ),
                const SizedBox(width: 154),
                ElevatedButton(
                  onPressed: () async {
                    await _selectDate(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, // background color
                      foregroundColor: Colors.white, // text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  child: const Text('Change Date'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Task Time',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Row(
              children: [
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(fontSize: 19),
                ),
                const SizedBox(width: 171),
                ElevatedButton(
                  onPressed: () async {
                    await _selectTime(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, // background color
                      foregroundColor: Colors.white, // text color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  child: const Text('Change Time'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Task Note',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            TextField(
              controller: _taskNoteController,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 3, color: HexColor(appBarColor)),
                      borderRadius: BorderRadius.circular(30.0)),
                  prefixIcon: const Icon(Icons.text_fields_rounded)),
            ),
          ],
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final updatedTask = {
            'name': _taskNameController.text,
            'taskDate': DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            ),
            'taskNote': _taskNoteController.text,
            // Diğer verileri burada güncelleyebilirsiniz
          };

          // onUpdateTask'i çağırarak verileri güncelleyin
          widget.onUpdateTask(updatedTask);

          // Geri dön
          Navigator.pop(context);
        },
        child: Icon(Icons.save),
      ),
      */
      floatingActionButton: Align(
        alignment: const Alignment(0.126, 0.94),
        child: FloatingActionButton.extended(
          icon: Icon(Icons.save_rounded),
          label: const Text(
            "Save",
            style: TextStyle(fontSize: 18),
          ),
          onPressed: () {
            final updatedTask = {
              'name': _taskNameController.text,
              'taskDate': DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _selectedTime.hour,
                _selectedTime.minute,
              ),
              'taskNote': _taskNoteController.text,
              // Diğer verileri burada güncelleyebilirsiniz
            };

            // onUpdateTask'i çağırarak verileri güncelleyin
            widget.onUpdateTask(updatedTask);

            // Geri dön
            Navigator.pop(context);
          },
          backgroundColor: Colors.amber,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskNoteController.dispose();
    super.dispose();
  }
}
