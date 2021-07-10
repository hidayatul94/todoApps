import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/addTodoList.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: 'To-Do List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final databaseReference = FirebaseDatabase.instance.reference().child('Todo');
  late Query _ref;
  DatabaseReference reference =
      FirebaseDatabase.instance.reference().child('Todo');
  List listTodo = [];
  bool select = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTodoList();
  }

  getTodoList() {
    _ref = FirebaseDatabase.instance
        .reference()
        .child('Todo')
        .orderByChild('name');
    print(_ref);
  }

  String _durationTransform(int seconds) {
    var d = Duration(seconds: seconds);
    List<String> parts = d.toString().split(':');
    return '${parts[0]} hrs ${parts[1]} min';
  }

  Widget listCardWidget({required Map item}) {
    item['startDateFormat'] =
        DateFormat("dd MMM yyyy").format(DateTime.parse(item['startDate']));
    item['endDateFormat'] =
        DateFormat("dd MMM yyyy").format(DateTime.parse(item['endDate']));
    final difference =
        DateTime.parse(item['endDate']).difference(DateTime.now()).inSeconds;
    print(difference);
    item['timeLeft'] = _durationTransform(difference);
    if (item['status'] == "Complete") {
      item['select'] = true;
    } else {
      item['select'] = false;
    }
    // print(time);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          AddTodoScreen(mode: 'edit', item: item)))
              .then((value) => {getTodoList()});
        },
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        item['title'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: new Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      print(item['index']);
                                      reference
                                          .child(item['key'])
                                          .remove()
                                          .whenComplete(() => null);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Start Date',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          item['startDateFormat'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'End Date',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          item['endDateFormat'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Time Left',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          item['timeLeft'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //     padding: const EdgeInsets.only(
                        //         top: 10, left: 10.0, right: 10.0),
                        //     child: Text('data')),
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text('Status : '),
                          Text(
                            item['status'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text('Tick if complete : '),
                          Checkbox(
                              checkColor: Colors.black,
                              activeColor: Colors.white,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: item['select'],
                              onChanged: (value) {
                                setState(() {
                                  item['select'] = value!;
                                  print(item['select']);
                                  Map<String, String> todo = {
                                    'title': item['title'],
                                    'startDate': item['startDate'],
                                    'endDate': item['endDate'],
                                    'status': item['select']
                                        ? 'Complete'
                                        : 'Incomplete'
                                  };

                                  reference
                                      .child(item['key'])
                                      .update(todo)
                                      .then((value) {
                                    getTodoList();
                                  });
                                });
                              }),
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: _ref,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map todo = snapshot.value;
            todo['key'] = snapshot.key;
            return listCardWidget(item: todo);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AddTodoScreen()))
              .then((value) => {getTodoList()});
        },
        tooltip: 'Increment',
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
