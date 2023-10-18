import 'package:flutter/material.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Obtain shared preferences.
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  late TcpSocketConnection socketConnection;
  final textContent = TextEditingController();
  final r1Content = TextEditingController();
  final r2Content = TextEditingController();
  String message = "";
  bool isConnected = false;
  bool r1 = false, r2 = false, lcd = true;
  @override
  void initState() {
    super.initState();

    prefs.then((value) => {
          textContent.text = value.getString('ip') ?? '192.168.254.1',
          debugPrint(value.getString('ip'))
        });
  }

  //receiving and sending back a custom message
  void messageReceived(String msg) {
    setState(() {});

    //socketConnection.sendMessage(1.toString());
  }

  //starting the connection and listening to the socket asynchronously
  Future<bool> startConnection(String ip) async {
    socketConnection = TcpSocketConnection(ip, 1322);
    socketConnection.enableConsolePrint(true);
    if (await socketConnection.canConnect(5000, attempts: 3)) {
      await socketConnection.connect(5000, messageReceived, attempts: 3);
    }
    return socketConnection.isConnected();
  }

  // 0 = relay1 off
  // 1 = relay1 on
  // 2 = relay2 off
  // 3 = relay2 on
  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(15),
              decoration:
                  BoxDecoration(border: Border.all(), color: Colors.blueGrey),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: SizedBox(
                      width: scrWidth * 0.40,
                      height: 55,
                      child: TextField(
                        controller: textContent,
                        decoration: const InputDecoration(
                            labelText: 'IP: ',
                            labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            hintText: '192.168.254.1',
                            hintStyle: TextStyle(fontSize: 12)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        if (!isConnected) {
                          startConnection(textContent.text).then((value) => {
                                setState(() {
                                  isConnected = value;
                                  prefs.then((value) => {
                                        value.setString('ip', textContent.text)
                                      });
                                })
                              });
                        } else {
                          setState(() {
                            socketConnection.disconnect();
                            isConnected = false;
                          });
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              (isConnected
                                  ? Colors.lightGreenAccent
                                  : Colors.redAccent))),
                      icon: const Icon(Icons.connect_without_contact_sharp),
                      label: Text((isConnected ? 'Disconnect' : 'Connect')))
                ],
              ),
            ),
            Container(
              decoration:
                  BoxDecoration(border: Border.all(), color: Colors.blueGrey),
              margin: const EdgeInsets.all(15),
              child: Column(children: [
                ElevatedButton.icon(
                    onPressed: () {
                      if (isConnected) {
                        setState(() {
                          if (!r1) {
                            socketConnection.sendMessage("1");
                            r1 = true;
                          } else {
                            socketConnection.sendMessage("0");
                            r1 = false;
                          }
                        });
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            (r1 ? Colors.lightGreenAccent : Colors.redAccent))),
                    icon: const Icon(Icons.connect_without_contact_sharp),
                    label: Text((r1 ? 'ON' : 'OFF'))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: scrWidth * 0.40,
                      height: 55,
                      child: TextField(
                        controller: r1Content,
                        decoration: const InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            hintText: 'mins',
                            hintStyle: TextStyle(fontSize: 12)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            if (isConnected) {
                              r1 = true;
                              int? val = int.tryParse(r1Content.text);
                              if (val != null) {
                                int tempVal = val | 0x100;
                                socketConnection
                                    .sendMessage(tempVal.toString());
                              }
                            }
                          });
                        },
                        icon: const Icon(Icons.timer),
                        label: const Text('Set Time'))
                  ],
                )
              ]),
            ),
            Container(
              decoration:
                  BoxDecoration(border: Border.all(), color: Colors.blueGrey),
              margin: const EdgeInsets.all(15),
              child: Column(children: [
                ElevatedButton.icon(
                    onPressed: () {
                      if (isConnected) {
                        setState(() {
                          if (!r2) {
                            socketConnection.sendMessage("3");
                            r2 = true;
                          } else {
                            socketConnection.sendMessage("2");
                            r2 = false;
                          }
                        });
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            (r2 ? Colors.lightGreenAccent : Colors.redAccent))),
                    icon: const Icon(Icons.connect_without_contact_sharp),
                    label: Text((r2 ? 'ON' : 'OFF'))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: scrWidth * 0.40,
                      height: 55,
                      child: TextField(
                        controller: r2Content,
                        decoration: const InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            hintText: 'mins',
                            hintStyle: TextStyle(fontSize: 12)),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            if (isConnected) {
                              r2 = true;
                              int? val = int.tryParse(r2Content.text);
                              if (val != null) {
                                int tempVal = val | 512;
                                socketConnection
                                    .sendMessage(tempVal.toString());
                              }
                            }
                          });
                        },
                        icon: const Icon(Icons.timer),
                        label: const Text('Set Time'))
                  ],
                )
              ]),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(
                          lcd ? Colors.lightGreen : Colors.redAccent)),
                  onPressed: () {
                    if (isConnected) {
                      setState(() {
                        if (!lcd) {
                          lcd = true;
                          socketConnection.sendMessage("8");
                        } else {
                          lcd = false;
                          socketConnection.sendMessage("4");
                        }
                      });
                    }
                  },
                  icon: Icon(lcd ? Icons.visibility : Icons.visibility_off),
                  label: Text(lcd ? 'LCD ON' : 'LCD OFF')),
            )
          ],
        ),
      ),
    );
  }
}
