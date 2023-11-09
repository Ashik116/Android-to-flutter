import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';




import 'package:http/http.dart' as https;
import 'package:image/image.dart' as images;
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'device_show.dart';
import 'login_page.dart';

class CardDesign extends StatefulWidget {
  const CardDesign({Key? key}) : super(key: key);

  @override
  State<CardDesign> createState() => _CardDesignState();
}

class _CardDesignState extends State<CardDesign> {
  bool connected = false;
  List cardList = [];
  List itemGridList = [];
  int min = 1;
  int max = 100000;
  int randomNumber = 0;

  DateTime now = DateTime.now();

  //String time = DateFormat.jms().format(DateTime.now());
  //var date = DateFormat("d/MM/yyyy").format(DateTime.now());

  // var time = int.parse(DateFormat.Hm().format(DateTime.now()).toString());
  String formateddate= DateFormat('yyyy-MM-dd H:m:s').format(DateTime.now());

  String vehiclenumber = "Dhaka-Metro-LA-45-8897";
  var vehicleclass;
  var avc="-";
  var ammount=0;
  var lane=0;
  var user;

  TextStyle textS() {
    return TextStyle(
      color: Color(0xFF000000),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle textStyle() {
    return TextStyle(
      color: Color(0xFF000000),
      fontSize: 25,
      fontWeight: FontWeight.bold,
    );
  }

  var response;
  var jsonData;
  var pass;
  var headers_cookie;

  Future addVehicle() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    user = sharedPreferences.getString('username');
    pass = sharedPreferences.getString('password');
    headers_cookie = sharedPreferences.getString("headers");

    response = await https.post(
        Uri.parse("http://103.101.197.249:8080/tollapi/api/toll"),
        headers: {
          "Cookie": headers_cookie.toString(),
        },
        body: {
          "pass_id": randomNumber.toString(),
          "registration_number": vehiclenumber.toString(),
          "amount": ammount.toString(),
          "lan": lane.toString(),
          "user_name": user.toString(),
          "vehicle_class": vehicleclass.toString(),
        });
    jsonData = json.decode(response.body);
    print("Ticket---$jsonData");

  }

  Future<void> logout() async {
    return showDialog(
        context: (context),
        builder: (context) {
          return AlertDialog(
            title: Text("Are you sure you want to LogOut?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));

                },
                child: Text("Yes"),
              ),
            ],
          );
        });
  }

  Widget items(text, image) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.13,
        width: MediaQuery.of(context).size.width * 0.45,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.fill,
            ),
            gradient: LinearGradient(
                colors: [Colors.grey.shade900, Colors.grey.shade900])),
      ),
    );
  }

  void motorcycle() {
    print('ticket');

    print("Vehicle Class:-$vehicleclass");

    print("Vehicle Number:-$vehiclenumber");

    print("Pass ID:-$randomNumber");

    print('Lane Number-$lane');

    print("Ammount:-$ammount TK");

    print("NAME:--- $user");
  }

  Future<void> sendData() async{
    String? isConnected= await BluetoothThermalPrinter.connectionStatus;
    if(isConnected == "true"){
      setState(() {
        connected=true;
        addVehicle();
      });
    }
  }

  Future<void> printTicket() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<void> printGraphics() async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      List<int> bytes = await getGraphicsTicket();
      final result = await BluetoothThermalPrinter.writeBytes(bytes);
      print("Print $result");
    } else {
      //Hadnle Not Connected Senario
    }
  }

  Future<List<int>> getGraphicsTicket() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    // Print QR Code using native function
    bytes += generator.qrcode('Charsindur Toll Plaza');

    bytes += generator.hr();

    // Print Barcode using native function
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.cut();

    return bytes;
  }

  Future<List<int>> getTicket() async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    final ByteData data = await rootBundle.load('assets/RHDC.bmp');
    final Uint8List imgBytes = data.buffer.asUint8List();
    // final image = decodeImage(imgBytes)!;
    final images.Image image = images.decodeImage(imgBytes)!;
    images.Image resizeimage = images.copyResize(
      image,
      width: 350,
      height: 150,
    );
    bytes += generator.image(resizeimage);
    bytes += generator.text("--------------------------------");
    bytes += generator.row([
      PosColumn(
          text: 'Reg NO:',
          width: 2,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: '$vehiclenumber',
          width: 10,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "AVC:",
          width: 3,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "$avc",
          width: 9,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "Pass ID:",
          width: 3,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "$randomNumber",
          width: 9,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "Toll Rate:",
          width: 3,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "$ammount",
          width: 9,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "Lane No:",
          width: 3,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "$lane",
          width: 9,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    bytes += generator.row([
      PosColumn(
          text: "TC ID:",
          width: 3,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
      PosColumn(
          text: "$user",
          width: 9,
          styles:
              PosStyles(height: PosTextSize.size1, width: PosTextSize.size1)),
    ]);
    // ticket.feed(2);
    bytes += generator.row([
      PosColumn(
          text: 'Time:',
          width: 2,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: "${now}",
          width: 10,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);
    bytes += generator.row([
      PosColumn(
          text: 'Date:',
          width: 2,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
      PosColumn(
          text: "${formateddate}",
          width: 10,
          styles: PosStyles(
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          )),
    ]);

    // bytes += generator.text("26-11-2020 15:22:45",
    //     styles: PosStyles(align: PosAlign.center), linesAfter: 1);

    bytes += generator.text('Thank you! Have A Safe Journey..',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('O&M by Regnum Resource Ltd.', styles: PosStyles(align: PosAlign.center, bold: false));
    bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => DeviceList()));
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  logout();
                });
              },
              icon: Icon(Icons.logout_sharp)),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backg.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        SizedBox(
                            height: size.height * 0.1,
                            width: size.width * 0.1,
                            child: Image.asset(
                              "assets/logo.png",
                            )),
                        Text(
                          "Regnum ETC Toll",
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 2,
                      width: double.infinity,
                      color: Colors.white70,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Select Vehicle Class',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            InkWell(
                              child: items(
                                'Mototrcycle',
                                'assets/motor_cycle2.png',
                              ),
                              onTap: () {
                                setState(() {
                                  lane = 1;
                                  ammount = 10;
                                  vehicleclass = 'motor_cycle';
                                  avc = "MOTORCYCLE";
                                  vehiclenumber;
                                  randomNumber =
                                      Random().nextInt(max - min) + min;
                                });
                               // connected? this.addVehicle:null;
                                sendData();
                                printTicket();
                                // printGraphics();
                              },
                            ),
                            Text(
                              "MotorCycle",
                              style: textS(),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              child: items(
                                'Rickshaw',
                                'assets/rickshaw_van.png',
                              ),
                              onTap: () {
                                setState(() {
                                  lane = 1;
                                  ammount = 10;
                                  vehicleclass = 'rickshaw_van';
                                  avc = "RICKSHAW";
                                  vehiclenumber;
                                  randomNumber =
                                      Random().nextInt(max - min) + min;
                                });
                                sendData();
                                printTicket();
                              },
                            ),
                            Text(
                              "Rickshaw",
                              style: textS(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              child: items(
                                '3/4 Wheeler',
                                'assets/three_four_wheeler.png',
                              ),
                              onTap: () {
                                setState(() {
                                  lane = 1;
                                  ammount = 15;
                                  vehicleclass = 'three_four_wheeler';
                                  avc = "3/4 WHEELER";
                                  vehiclenumber;
                                  randomNumber =
                                      Random().nextInt(max - min) + min;
                                });
                                sendData();
                                printTicket();
                              },
                            ),
                            Text(
                              "3/4 Wheeler",
                              style: textS(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.values[4],
                      children: [
                        Text(
                          "Vehicle No",
                        ),
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                          height: size.height * 0.05,
                          width: size.width * 0.6,
                          child: Center(child: Text("$vehiclenumber")),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.values[5],
                      children: [
                        Text(
                          "AVC Class",
                        ),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                          height: size.height * 0.05,
                          width: size.width * 0.6,
                          child: Center(
                            child: Builder(
                              builder: (context) {
                                var avc = vehicleclass;
                                if (avc == "three_four_wheeler") {
                                  return Text("3/4 WHEELER",
                                      style: textStyle());
                                } else if (avc == "rickshaw_van") {
                                  return Text(
                                    "RICKSHAW",
                                    style: textStyle(),
                                  );
                                } else if (avc == 'motor_cycle') {
                                  return Text(
                                    "MOTORCYCLE",
                                    style: textStyle(),
                                  );
                                } else {
                                  return Text("avc");
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.values[5],
                      children: [
                        const Text(
                          "Toll Rate",
                          style: TextStyle(),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                          height: size.height * 0.05,
                          width: size.width * 0.6,
                          child: Center(
                              child: Text(
                            "$ammount",
                            style: textStyle(),
                          )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.values[5],
                      children: [
                        const Text(
                          "Ticket ID",
                          style: TextStyle(),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent)),
                          height: size.height * 0.05,
                          width: size.width * 0.6,
                          child: Center(
                              child: Text(
                            "$randomNumber",
                            style: textStyle(),
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
