// ignore_for_file: camel_case_types

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

late String robot;
late String qrData;
bool autoMove = false;
String autoMoveMessage = "The robot did not taxi";
TextEditingController nameC = TextEditingController();
TextEditingController matchN = TextEditingController();
String teamNumber = "0";
late int matchNumber;
int autoTopScore = 0;
String password = "";
String passwordMessage = "";
int autoMiddleScore = 0;
int autoBottomScore = 0;
int teleopTopScore = 0;
int teleopMiddleScore = 0;
int teleopBottomScore = 0;
String defenseScore = "1";
String offenseScore = "1";
String autoDockState = "neither";
String robotState = "played";
String pieceState = "neither";
String teleopDockState = "none";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();
  createInfoFile();
  createBackgroundFile();
  await getMatchNum();
  await getQRdata();
  await getRobot();
  runApp(const MyApp());
}

createInfoFile() async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    Directory? localDir = await getApplicationDocumentsDirectory();
    String localPath = localDir.path;
    File file = File('$localPath/info.json');
    await file.create();
  }
}

createBackgroundFile() async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    Directory? localDir = await getApplicationDocumentsDirectory();
    String localPath = localDir.path;
    File file = File('$localPath/app.json');
    await file.create();
  }
}

Future<File> writeData(String data) async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    Directory? localDir = await getApplicationDocumentsDirectory();
    String localPath = localDir.path;
    File file = File('$localPath/info.json');
    return file.writeAsString(data);
  }
  return File("File not found");
}

Future<File> writeInternalData(String data) async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    Directory? localDir = await getApplicationDocumentsDirectory();
    String localPath = localDir.path;
    File file = File('$localPath/app.json');
    return file.writeAsString(data);
  }
  return File("File not found");
}

Future<String> readFile() async {
  try {
    if (await Permission.manageExternalStorage.request().isGranted) {
      Directory? localDir = await getApplicationDocumentsDirectory();
      String localPath = localDir.path;
      File file = File('$localPath/info.json');
      final contents = await file.readAsString();
      return contents;
    }
    return "An Error occured";
  } catch (e) {
    return "an Error occured";
  }
}

Future<String> readInternalFile() async {
  try {
    if (await Permission.manageExternalStorage.request().isGranted) {
      Directory? localDir = await getApplicationDocumentsDirectory();
      String localPath = localDir.path;
      File file = File('$localPath/app.json');
      final contents = await file.readAsString();
      return contents;
    }
    return "An Error occured";
  } catch (e) {
    return "an Error occured";
  }
}

getMatchNum() async {
  String data = await readInternalFile();
  if (data == "An Error occured" || data.isEmpty) {
    matchNumber = 1;
  } else {
    int index = data.indexOf("match") + 8;
    int lastIndex = data.indexOf("}");
    matchNumber = int.parse(data.substring(index, lastIndex));
  }
}

getQRdata() async {
  String data = await readFile();
  if (data == "An Error occured" || data.isEmpty) {
    qrData = "";
  } else {
    qrData = data;
  }
}

setRobot(String selected) async {
  String data = await readInternalFile();
  if (data.isEmpty || data == "An Error occured") {
    writeInternalData(
        "{\"password\": \"root\", \"robot\": \"$selected\", \"match\": \"$matchNumber\"}");
  } else {
    int index = data.indexOf("robot") + 9;
    String partial = data.substring(index);
    int finalIndex = partial.indexOf(",") - 1;
    writeInternalData(data.substring(0, index) +
        selected +
        data.substring(finalIndex + index));
  }
}

getRobot() async {
  String data = await readInternalFile();
  if (data.isEmpty || data == "An Error occured") {
    robot = "No Bot";
  } else {
    int index = data.indexOf("robot") + 9;
    String partial = data.substring(index);
    int finalIndex = partial.indexOf(",") - 1;
    robot = data.substring(index, index + finalIndex);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scouting app',
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
        primarySwatch: Colors.blue,
      ),
      home: const StateAuto(),
    );
  }
}

class StateAuto extends StatefulWidget {
  const StateAuto({Key? key}) : super(key: key);

  @override
  State<StateAuto> createState() => auto();
}

class StateTeleop extends StatefulWidget {
  const StateTeleop({Key? key}) : super(key: key);

  @override
  State<StateTeleop> createState() => teleOp();
}

class StateAdmin extends StatefulWidget {
  const StateAdmin({Key? key}) : super(key: key);

  @override
  State<StateAdmin> createState() => adminPage();
}

class StatePortal extends StatefulWidget {
  const StatePortal({Key? key}) : super(key: key);

  @override
  State<StatePortal> createState() => adminPortal();
}

class auto extends State<StateAuto> {
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
          leading: PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return const [
                  PopupMenuItem(value: "Scouting", child: Text("Scouting")),
                  PopupMenuItem(value: "Admin", child: Text("Admin"))
                ];
              },
              icon: const Icon(Icons.menu),
              onSelected: (value) {
                if (value == "Admin") {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (ctx) => const StateAdmin()));
                }
              }),
          title: Padding(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: TabBar(
                tabs: const [
                  Tab(text: 'Auto'),
                  Tab(text: 'Teleop'),
                ],
                labelColor: Colors.white,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (ctx) => const StateAuto()));
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const StateTeleop()));
                  }
                },
              ),
            ),
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 50, top: 10),
                child: Text(robot, style: const TextStyle(fontSize: 25)))
          ]),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/background.jpg"), fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 200.0,
                        child: TextField(
                          onChanged: (text) {
                            teamNumber = text;
                          },
                          controller: nameC,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: 'Team Number',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(children: const [
                        Text("Rate Defense (1-5)",
                            style: TextStyle(fontSize: 20))
                      ]),
                      Row(
                        children: [
                          DropdownButton(
                              value: defenseScore,
                              underline:
                                  Container(height: 2, color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: "1", child: Text("1")),
                                DropdownMenuItem(value: "2", child: Text("2")),
                                DropdownMenuItem(value: "3", child: Text("3")),
                                DropdownMenuItem(value: "4", child: Text("4")),
                                DropdownMenuItem(value: "5", child: Text("5")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  defenseScore = value!;
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(children: const [
                        Text("Rate Offense (1-5)",
                            style: TextStyle(fontSize: 20))
                      ]),
                      Row(
                        children: [
                          DropdownButton(
                              value: offenseScore,
                              underline:
                                  Container(height: 2, color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: "1", child: Text("1")),
                                DropdownMenuItem(value: "2", child: Text("2")),
                                DropdownMenuItem(value: "3", child: Text("3")),
                                DropdownMenuItem(value: "4", child: Text("4")),
                                DropdownMenuItem(value: "5", child: Text("5")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  offenseScore = value!;
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(children: const [
                        Text("Robot State", style: TextStyle(fontSize: 20))
                      ]),
                      Row(
                        children: [
                          DropdownButton(
                              value: robotState,
                              underline:
                                  Container(height: 2, color: Colors.white),
                              items: const [
                                DropdownMenuItem(
                                    value: "played", child: Text("played")),
                                DropdownMenuItem(
                                    value: "tipped", child: Text("tipped")),
                                DropdownMenuItem(
                                    value: "almost tipped",
                                    child: Text("almost tipped")),
                                DropdownMenuItem(
                                    value: "lost comms",
                                    child: Text("lost comms")),
                                DropdownMenuItem(
                                    value: "no show", child: Text("no show")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  robotState = value!;
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 100, bottom: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text("Match Number",
                          style: TextStyle(fontSize: 25)),
                      Text("$matchNumber",
                          style: const TextStyle(fontSize: 20)),
                      Row(
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Decrease score"),
                              onPressed: () {
                                setState(() {
                                  if (matchNumber > 0) {
                                    matchNumber--;
                                  }
                                });
                              }),
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Increase score"),
                              onPressed: () {
                                setState(() {
                                  matchNumber++;
                                });
                              })
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Auto Top Score",
                          style: TextStyle(fontSize: 25)),
                      Text("$autoTopScore",
                          style: const TextStyle(fontSize: 20)),
                      Row(
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Decrease score"),
                              onPressed: () {
                                setState(() {
                                  if (autoTopScore > 0) {
                                    autoTopScore--;
                                  }
                                });
                              }),
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Increase score"),
                              onPressed: () {
                                setState(() {
                                  autoTopScore++;
                                });
                              })
                        ],
                      )
                    ],
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 10, bottom: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text("Did the robot taxi",
                          style: TextStyle(fontSize: 25)),
                      Text(autoMoveMessage,
                          style: const TextStyle(fontSize: 20)),
                      Switch(
                          activeColor: Colors.white,
                          value: autoMove,
                          onChanged: (value) {
                            setState(() {
                              autoMove = value;
                              if (value) {
                                autoMoveMessage = "The robot taxied";
                              } else {
                                autoMoveMessage = "The robot did not taxi";
                              }
                            });
                          }),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Auto Middle Score",
                          style: TextStyle(fontSize: 25)),
                      Text("$autoMiddleScore",
                          style: const TextStyle(fontSize: 20)),
                      Row(
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Decrease score"),
                              onPressed: () {
                                setState(() {
                                  if (autoMiddleScore > 0) {
                                    autoMiddleScore--;
                                  }
                                });
                              }),
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Increase score"),
                              onPressed: () {
                                setState(() {
                                  autoMiddleScore++;
                                });
                              })
                        ],
                      )
                    ],
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 10, bottom: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text("Did the robot dock",
                          style: TextStyle(fontSize: 25)),
                      DropdownButton(
                        underline: Container(height: 2, color: Colors.white),
                        value: autoDockState,
                        items: const [
                          DropdownMenuItem(
                              value: "neither", child: Text("neither")),
                          DropdownMenuItem(
                              value: "on platform", child: Text("on platform")),
                          DropdownMenuItem(
                              value: "balance platform",
                              child: Text("balance platform"))
                        ],
                        onChanged: (value) {
                          setState(() {
                            autoDockState = value!;
                          });
                        },
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Auto Bottom Score",
                          style: TextStyle(fontSize: 25)),
                      Text("$autoBottomScore",
                          style: const TextStyle(fontSize: 20)),
                      Row(
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Decrease score"),
                              onPressed: () {
                                setState(() {
                                  if (autoBottomScore > 0) {
                                    autoBottomScore--;
                                  }
                                });
                              }),
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Increase score"),
                              onPressed: () {
                                setState(() {
                                  autoBottomScore++;
                                });
                              })
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class teleOp extends State<StateTeleop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return const [
                  PopupMenuItem(value: "Scouting", child: Text("Scouting")),
                  PopupMenuItem(value: "Admin", child: Text("Admin"))
                ];
              },
              icon: const Icon(Icons.menu),
              onSelected: (value) {
                if (value == "Admin") {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (ctx) => const StateAdmin()));
                }
              }),
          title: Padding(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: DefaultTabController(
              length: 2,
              initialIndex: 1,
              child: TabBar(
                tabs: const [
                  Tab(text: 'Auto'),
                  Tab(text: 'Teleop'),
                ],
                labelColor: Colors.white,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (ctx) => const StateAuto()));
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const StateTeleop()));
                  }
                },
              ),
            ),
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 50, top: 10),
                child: Text(robot, style: const TextStyle(fontSize: 25)))
          ]),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/background.jpg"), fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 200.0,
                        child: TextField(
                          onChanged: (text) {
                            teamNumber = text;
                          },
                          controller: nameC,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: 'Team Number',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(children: const [
                        Text("Rate Defense (1-5)",
                            style: TextStyle(fontSize: 20))
                      ]),
                      Row(
                        children: [
                          DropdownButton(
                              value: defenseScore,
                              underline:
                                  Container(height: 2, color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: "1", child: Text("1")),
                                DropdownMenuItem(value: "2", child: Text("2")),
                                DropdownMenuItem(value: "3", child: Text("3")),
                                DropdownMenuItem(value: "4", child: Text("4")),
                                DropdownMenuItem(value: "5", child: Text("5")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  defenseScore = value!;
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(children: const [
                        Text("Rate Offense (1-5)",
                            style: TextStyle(fontSize: 20))
                      ]),
                      Row(
                        children: [
                          DropdownButton(
                              value: offenseScore,
                              underline:
                                  Container(height: 2, color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: "1", child: Text("1")),
                                DropdownMenuItem(value: "2", child: Text("2")),
                                DropdownMenuItem(value: "3", child: Text("3")),
                                DropdownMenuItem(value: "4", child: Text("4")),
                                DropdownMenuItem(value: "5", child: Text("5")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  offenseScore = value!;
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(children: const [
                        Text("Robot State", style: TextStyle(fontSize: 20))
                      ]),
                      Row(
                        children: [
                          DropdownButton(
                              value: robotState,
                              underline:
                                  Container(height: 2, color: Colors.white),
                              items: const [
                                DropdownMenuItem(
                                    value: "played", child: Text("played")),
                                DropdownMenuItem(
                                    value: "tipped", child: Text("tipped")),
                                DropdownMenuItem(
                                    value: "almost tipped",
                                    child: Text("almost tipped")),
                                DropdownMenuItem(
                                    value: "lost comms",
                                    child: Text("lost comms")),
                                DropdownMenuItem(
                                    value: "no show", child: Text("no show")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  robotState = value!;
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 100, bottom: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text("piece type scored",
                          style: TextStyle(fontSize: 25)),
                      DropdownButton(
                        underline: Container(height: 2, color: Colors.white),
                        value: pieceState,
                        items: const [
                          DropdownMenuItem(
                              value: "neither", child: Text("neither")),
                          DropdownMenuItem(value: "cube", child: Text("cube")),
                          DropdownMenuItem(value: "cone", child: Text("cone")),
                          DropdownMenuItem(value: "both", child: Text("both"))
                        ],
                        onChanged: (value) {
                          setState(() {
                            pieceState = value!;
                          });
                        },
                      )
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Teleop Top Score",
                          style: TextStyle(fontSize: 25)),
                      Text("$teleopTopScore",
                          style: const TextStyle(fontSize: 20)),
                      Row(
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Decrease score"),
                              onPressed: () {
                                setState(() {
                                  if (teleopTopScore > 0) {
                                    teleopTopScore--;
                                  }
                                });
                              }),
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Increase score"),
                              onPressed: () {
                                setState(() {
                                  teleopTopScore++;
                                });
                              })
                        ],
                      )
                    ],
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 10, bottom: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text("Robot dock state",
                          style: TextStyle(fontSize: 25)),
                      DropdownButton(
                          underline: Container(height: 2, color: Colors.white),
                          value: teleopDockState,
                          items: const [
                            DropdownMenuItem(
                                value: "none", child: Text("none")),
                            DropdownMenuItem(
                                value: "in community",
                                child: Text("in community")),
                            DropdownMenuItem(
                                value: "on platform",
                                child: Text("on platform")),
                            DropdownMenuItem(
                                value: "balance platform",
                                child: Text("balance platform"))
                          ],
                          onChanged: (value) {
                            setState(() {
                              teleopDockState = value!;
                            });
                          })
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Teleop Middle Score",
                          style: TextStyle(fontSize: 25)),
                      Text("$teleopMiddleScore",
                          style: const TextStyle(fontSize: 20)),
                      Row(
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Decrease score"),
                              onPressed: () {
                                setState(() {
                                  if (teleopMiddleScore > 0) {
                                    teleopMiddleScore--;
                                  }
                                });
                              }),
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Increase score"),
                              onPressed: () {
                                setState(() {
                                  teleopMiddleScore++;
                                });
                              })
                        ],
                      )
                    ],
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 10, bottom: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text("Submit current data",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                          onPressed: () {
                            String data =
                                "{\"match\": \"$matchNumber\",\"teamNumber\": \"$teamNumber\",\"defenseScore\": \"$defenseScore\",\"offenseScore\": \"$offenseScore\",\"tipped\": \"$robotState\",\"matchNum\": \"$matchNumber\",\"autoMove\": \"$autoMove\",\"autoBottomScore\": \"$autoBottomScore\",\"autoMiddleScore\": \"$autoMiddleScore\",\"autoTopScore\": \"$autoTopScore\",\"autoDockedState\": \"$autoDockState\",\"pieceType\": \"$pieceState\",\"teleopBottomScore\": \"$teleopBottomScore\",\"teleopMiddleScore\": \"$teleopMiddleScore\",\"teleopTopScore\": \"$teleopTopScore\",\"teleopDockState\": \"$teleopDockState\"}";
                            readFile().then((String content) {
                              if (content.isEmpty) {
                                writeData("{\"root\": [$data]}");
                                qrData = "{\"root\": [$data]}";
                              } else {
                                content =
                                    content.substring(0, content.length - 2);
                                writeData("$content, $data]}");
                                qrData = "$content, $data]}";
                              }
                              setState(() {
                                autoMove = false;
                                autoMoveMessage = "The robot did not taxi";
                                teamNumber = "0";
                                autoTopScore = 0;
                                autoMiddleScore = 0;
                                autoBottomScore = 0;
                                teleopTopScore = 0;
                                teleopMiddleScore = 0;
                                teleopBottomScore = 0;
                                matchNumber++;
                                defenseScore = "1";
                                offenseScore = "1";
                                autoDockState = "neither";
                                robotState = "played";
                                pieceState = "neither";
                                teleopDockState = "none";
                              });
                              readInternalFile().then((String data) {
                                if (data.isEmpty) {
                                  writeInternalData(
                                      "{\"password\": \"root\", \"robot\": \"No Bot\", \"match\": $matchNumber}");
                                } else {
                                  int index = data.indexOf("match") + 8;
                                  // ignore: prefer_interpolation_to_compose_strings
                                  data = data.substring(0, index) +
                                      "$matchNumber" +
                                      "}";
                                  writeInternalData(data);
                                }
                              });
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) => const StateAuto()));
                            });
                          })
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Teleop Bottom Score",
                          style: TextStyle(fontSize: 25)),
                      Text("$teleopBottomScore",
                          style: const TextStyle(fontSize: 20)),
                      Row(
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Decrease score"),
                              onPressed: () {
                                setState(() {
                                  if (teleopBottomScore > 0) {
                                    teleopBottomScore--;
                                  }
                                });
                              }),
                          TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Increase score"),
                              onPressed: () {
                                setState(() {
                                  teleopBottomScore++;
                                });
                              })
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class adminPage extends State<StateAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Admin Page"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                passwordMessage = "";
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (ctx) => const StateAuto()));
              },
            )),
        body: Container(
            height: double.infinity,
            width: double.infinity,
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 500,
                      child: TextField(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: 'Enter Password',
                          ),
                          onChanged: (value) {
                            password = value;
                          }),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            child: const Text("Submit"),
                            onPressed: () {
                              setState(() {
                                if (password == "root") {
                                  passwordMessage = "";
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) =>
                                              const StatePortal()));
                                } else {
                                  passwordMessage = "Incorrect Password";
                                }
                              });
                            })),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(passwordMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 30))
                  ],
                )
              ],
            )));
  }
}

class adminPortal extends State<StatePortal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Admin Portal"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (ctx) => const StateAuto()));
            },
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 50, top: 10),
                child: Text(robot, style: const TextStyle(fontSize: 25)))
          ]),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/background.jpg"), fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(left: 20)),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: const Text("Blue 1"),
                      onPressed: () {
                        setState(() {
                          robot = "Blue 1";
                        });
                        setRobot(robot);
                      }),
                ),
                const Padding(padding: EdgeInsets.only(right: 20)),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Red 1"),
                      onPressed: () {
                        setState(() {
                          robot = "Red 1";
                        });
                        setRobot(robot);
                      }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(left: 20)),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: const Text("Blue 2"),
                      onPressed: () {
                        setState(() {
                          robot = "Blue 2";
                        });
                        setRobot(robot);
                      }),
                ),
                const Padding(padding: EdgeInsets.only(right: 20)),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Red 2"),
                      onPressed: () {
                        setState(() {
                          robot = "Red 2";
                        });
                        setRobot(robot);
                      }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(left: 20)),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: const Text("Blue 3"),
                      onPressed: () {
                        setState(() {
                          robot = "Blue 3";
                        });
                        setRobot(robot);
                      }),
                ),
                const Padding(padding: EdgeInsets.only(right: 20)),
                SizedBox(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Red 3"),
                      onPressed: () {
                        setState(() {
                          robot = "Red 3";
                        });
                        setRobot(robot);
                      }),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Padding(padding: EdgeInsets.only(right: 20)),
                Container(
                    color: Colors.white,
                    child: QrImage(
                      size: 300,
                      data: qrData,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
