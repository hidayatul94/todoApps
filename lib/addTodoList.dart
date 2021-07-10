import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTodoScreen extends StatefulWidget {
  final mode;
  final item;
  const AddTodoScreen({Key? key, this.mode, this.item}) : super(key: key);

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  DateTime? datepick;
  String startDateFormat = '';
  String endDateFormat = '';
  var endDateTime = '';
  var startDateTime = '';
  var todoData;
  DatabaseReference _ref = FirebaseDatabase.instance.reference().child('Todo');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController controller = new TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool validate = false;
  int index = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime now = DateTime.now();
    setState(() {
      startDateFormat = DateFormat("dd MMM yyyy").format(now);
      startDateTime = DateFormat("yyyy-MM-dd hh:mm:ss").format(now);
    });
    if (widget.mode == "edit") {
      setState(() {
        todoData = widget.item;
        controller.text = todoData['title'];
        startDateFormat = DateFormat("dd MMM yyyy")
            .format(DateTime.parse(todoData['startDate']));
        endDateFormat = DateFormat("dd MMM yyyy")
            .format(DateTime.parse(todoData['endDate']));
        endDateTime = todoData['endDate'];
        startDateTime = todoData['startDate'];
      });
    }
  }

  Future<void> createRecord() async {
    dismissKeyboard();
    setState(() {
      controller.text.isEmpty ? validate = true : validate = false;
    });
    if (validate == false) {
      if (startDateTime != '' && endDateTime != '') {
        Map<String, String> todo = {
          'title': controller.text,
          'startDate': startDateTime,
          'endDate': endDateTime,
          'status': widget.mode != "edit" ? 'Incomplete' : todoData['status']
        };
        if (widget.mode == "edit") {
          _ref.child(todoData['key']).update(todo).then((value) {
            Navigator.pop(context);
          });
        } else {
          _ref.push().set(todo).then((value) {
            Navigator.pop(context);
          });
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text('Warning'),
              content:
                  new Text("Please select start date and estimate end date."),
              actions: [
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  dismissKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        persistentFooterButtons: [
          Container(
              color: Colors.black,
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                ),
                onPressed: () {
                  print('object');
                  createRecord();
                },
                child: Text(
                  widget.mode != 'edit' ? 'Create Now' : 'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ))
        ],
        appBar: AppBar(
          title: Text('Add new To-Do List'),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Text(
                      'To-Do Title',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Please key in your To-Do title here',
                      border: OutlineInputBorder(),
                      errorText: validate ? 'Value Can\'t Be Empty' : null,
                    ),
                    controller: controller,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Text(
                      'Start Date',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      dismissKeyboard();
                      datepick = await showDatePicker(
                          context: context,
                          initialDate: new DateTime.now(),
                          firstDate:
                              new DateTime.now().add(Duration(days: -365)),
                          lastDate:
                              new DateTime.now().add(Duration(days: 365)));
                      var timeNow =
                          DateFormat("hh:mm:ss").format(DateTime.now());
                      var startDate =
                          DateFormat("yyyy-MM-dd").format(datepick!);
                      setState(() {
                        startDateFormat =
                            DateFormat("dd MMM yyyy").format(datepick!);
                        startDateTime = startDate + ' ' + timeNow;
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1, //                   <--- border width here
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //         <--- border radius here
                            ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  startDateFormat,
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    child: Text(
                      'Estimate End Date',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      dismissKeyboard();
                      datepick = await showDatePicker(
                          context: context,
                          initialDate: new DateTime.now(),
                          firstDate: new DateTime.now(),
                          lastDate:
                              new DateTime.now().add(Duration(days: 365)));
                      print(datepick);
                      var timeNow =
                          DateFormat("hh:mm:ss").format(DateTime.now());
                      var endDate = DateFormat("yyyy-MM-dd").format(datepick!);

                      setState(() {
                        endDateFormat =
                            DateFormat("dd MMM yyyy").format(datepick!);
                        print(endDateFormat);
                        endDateTime = endDate + ' ' + timeNow;
                        print(endDateTime);
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1, //                   <--- border width here
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //         <--- border radius here
                            ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  endDateFormat != ''
                                      ? endDateFormat
                                      : 'Select a date',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
