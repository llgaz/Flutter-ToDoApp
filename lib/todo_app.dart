import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:todo/colors.dart';
import 'package:todo/sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:todo/task_detail.dart';

class YapilacaklarAnaSayfa extends StatefulWidget {
  const YapilacaklarAnaSayfa({Key? key}) : super(key: key);

  @override
  _YapilacaklarAnaSayfaState createState() => _YapilacaklarAnaSayfaState();
}

class _YapilacaklarAnaSayfaState extends State<YapilacaklarAnaSayfa> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _controller = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  late SharedPreferences _prefs;
  late Stream<QuerySnapshot<Map<String, dynamic>>>
      _yapilacaklarStream; // Yapılacaklar Stream'i

  DateTime selectedTaskDate = DateTime.now(); // Tarihi ayarla

  @override
  void initState() {
    super.initState();

    _initSharedPreferences();

    final user = _auth.currentUser;
    if (user != null) {
      _yapilacaklarStream =
          _firestore.collection('users/${user.uid}/yapilacaklar').snapshots();
    }
  }

  void _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _signOut() async {
    await _auth.signOut();
    _prefs.setBool('isLoggedIn', false); // Oturum çıkışı durumunu güncelle
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInPage()));
  }

  void _yapilacakEkle(
      String yapilacak, DateTime taskDateTime, String taskNote) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users/${user.uid}/yapilacaklar').add({
        'name': yapilacak,
        'taskDate': taskDateTime,
        'taskNote': taskNote,
        'completed': false,
      });
      _controller.clear();
    }
  }

  void _yapilacakTamamla(DocumentReference reference, bool completed) async {
    await reference.update({'completed': !completed});
  }

  void _yapilacakSil(DocumentReference reference) async {
    await reference.delete();
  }

  void _yapilacakGuncelle(
      String taskId, Map<String, dynamic> updatedData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await _firestore
            .doc('users/${user.uid}/yapilacaklar/$taskId')
            .update(updatedData);
      } catch (e) {
        print('Güncelleme hatası: $e');
      }
    }
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    TextEditingController _noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'New Task'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _selectDate(context);
                },
                child: Text('Select Date'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _selectTime(context);
                },
                child: Text('Select Time'),
              ),
              Text(
                'Selected Date and Time: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate)}',
              ),
              SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Note (optional)'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _yapilacakEkle(
                    _controller.text,
                    _selectedDate,
                    _noteController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedTaskDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.amber),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTaskDate) {
      setState(() {
        selectedTaskDate = picked;
        _selectedDate = DateTime(
          selectedTaskDate.year,
          selectedTaskDate.month,
          selectedTaskDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
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
        _selectedDate = DateTime(
          selectedTaskDate.year,
          selectedTaskDate.month,
          selectedTaskDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

//Görevin durumuna göre rengi ayarlar

  Color getTitleColor(DateTime taskDate, bool completed) {
    // Bugünün tarihini al
    final today = DateTime.now();

    // Görev tamamlanmışsa yeşil olsun
    if (completed) {
      return Colors.green;
    }

    // Görevin tarihi bugünse ve saati geçmişse gri olsun
    if (taskDate.isBefore(today)) {
      return Colors.grey;
    }

    // Görevin tarihi bugünse ve son 1 saat içinde veya daha azsa kırmızı yap
    final difference = taskDate.difference(today);
    if (difference.inMinutes <= 60) {
      return Colors.red;
    }

    // Görevin tarihi bugünse ve saati geçmemişse sarı olsun
    if (difference.inMinutes > 60) {
      return Colors.amber;
    }

    // Diğer durumlarda varsayılan bir renk kullanabilirsiniz, örneğin beyaz:
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /*
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
        */
        backgroundColor: HexColor(appBarColor),
        title: const Column(
          children: [
            Text("Welcome,"),
            Text(
              "ToDo App",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 33),
            )
          ],
        ),
        centerTitle: true,
        toolbarHeight: 135,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: HexColor(appBarColor),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Your Name",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                // Menü öğesi 1'e tıklanınca yapılacak işlemleri ekleyin
              },
            ),
            ListTile(
              title: Text('Menu Item 2'),
              onTap: () {
                // Menü öğesi 2'ye tıklanınca yapılacak işlemleri ekleyin
              },
            ),
            // Diğer menü öğelerini buraya ekleyin
            // const Spacer(),
            SizedBox(height: 488),
            ListTile(
              title: const Icon(
                Icons.logout_outlined,
                size: 37,
              ),
              onTap: () {
                _signOut();
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.active) {
            if (userSnapshot.hasData) {
              // final user = userSnapshot.data;
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _yapilacaklarStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final tasks = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final taskData =
                          tasks[index].data() as Map<String, dynamic>;
                      final taskName = taskData['name'];
                      final taskDate = taskData['taskDate']
                          as Timestamp; // Tarih bilgisini alın
                      final taskNote =
                          taskData['taskNote']; // Not bilgisini alın
                      final completed = taskData['completed'] ??
                          false; // Görev tamamlanmış mı kontrol edin

                      return Padding(
                        padding: EdgeInsets.fromLTRB(15, 18, 15, 0),
                        child: ListTile(
                          shape: StadiumBorder(),
                          tileColor:
                              getTitleColor(taskDate.toDate(), completed),
                          onTap: () {
                            // Görevin detay sayfasına yönlendirme
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailPage(
                                  taskName: taskName,
                                  taskDate: taskDate.toDate(),
                                  taskNote: taskNote,
                                  taskDateTime: taskDate.toDate(),
                                  onUpdateTask: (editedTask) {
                                    _yapilacakGuncelle(
                                        tasks[index].id, editedTask);
                                  },
                                ),
                              ),
                            );
                          },
                          leading: Checkbox(
                            value: completed,
                            onChanged: (value) {
                              _yapilacakTamamla(
                                  tasks[index].reference, completed);
                            },
                            /*fillColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.amber.withOpacity(.32);
                                }
                                return Colors.amber;
                              })*/
                          ),
                          title: Text(
                            taskName,
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: IconButton(
                            iconSize: 28,
                            color: HexColor(appBarColor),
                            icon: Icon(Icons.delete_forever),
                            onPressed: () {
                              _yapilacakSil(tasks[index].reference);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              return const Center(
                child: Text("No user logged in."),
              );
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: Align(
        alignment: const Alignment(0.126, 0.94),
        child: FloatingActionButton.extended(
          icon: Icon(Icons.task_alt_rounded),
          label: const Text(
            "Add Task",
            style: TextStyle(fontSize: 15),
          ),
          onPressed: () async {
            await _showAddTaskDialog(context);
          },
          backgroundColor: Colors.amber,
        ),
      ),
    );
  }
}
