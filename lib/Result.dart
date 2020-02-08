import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
 import 'package:flutter/services.dart';
class Result extends StatefulWidget {
  final index;
  Result({Key key, this.index}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Result> {
  GlobalKey rootWidgetKey = GlobalKey();
  int activeIndex;
  Map _resultMap = {};
  List _detailList = [];
  String _title = '';

  @override
  void initState() { 
    super.initState();
    
    _readData().then((List value){
      activeIndex = widget.index;
      print(value);
      setState((){
        _title = value[activeIndex]['title'];
        _detailList = value[activeIndex]['detailList'];
        _resultMap = calculate(_detailList);
        print(_resultMap);
      });
    });
  }

  Map calculate (list) {
    Map resultMap = {};
    list.forEach((item){
      List partner = item['partner'];
        String payer = item['payer'];
        int len = partner.length;
        double money = item['money'];
        double average = double.parse((money / len).toStringAsFixed(1));
        print(average);
        bool isPayerInPartner = partner.contains(payer);
        if (!isPayerInPartner) {
          partner.add(payer);
        }
        for (int i = 0; i < partner.length; i ++) {
          String key = partner[i];
          double value;
          if (!isPayerInPartner && key == payer) {
            value = money;
          } else {
            value = key == payer ? money - average : -average;
          }
          if (resultMap[key] == null) {
            resultMap[key] = List(2);
            resultMap[key][0] = value;
          } else {
            resultMap[key][0] += value;
          }
          if (key == payer) {
            resultMap[key][1] = money;
          } else {
            resultMap[key][1] = 0;
          }
        }
      });
    return resultMap;
  }

  Future<File> _getLocalFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/activeList.json');
  }

  Future<List> _readData() async{
    try {
      File file = await _getLocalFile();
      String data = await file.readAsString();
      List activeList = json.decode(data);
      return activeList;
    } on FileSystemException {
      return [];
    }
  }

  List _detailTableRowList() {
    List<TableRow> rowList = [
      TableRow(
        //第一行样式 添加背景色
        decoration: BoxDecoration(
          color: Colors.cyan[50],
        ),
        children: [
          SizedBox(
            height: 38.0,
            child: Center(
              child:Text(
                '参与人',
                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 38.0,
            child: Center(
              child: Text(
                '垫付',
                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 38.0,
            child: Center(
              child: Text(
                '结算',
                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ]
      )
    ];

    _resultMap.forEach((key, value){
      rowList.add(
        TableRow(
          children: [
            SizedBox(
              height: 36.0,
              child:Center(
                child: Text(
                  key,
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
            SizedBox(
              height: 36.0,
              child:Center(
                child: Text(
                  value[1].toStringAsFixed(1),
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
            SizedBox(
              height: 36.0,
              child:Center(
                child: Text(value[0].toStringAsFixed(1),
                style: TextStyle(fontSize: 18.0, color:value[0] > 0 ? Colors.green : Colors.red)
                ),
              ),
            ),
          ]
        )
      );
    });
    return rowList;
  }
  Widget _tips() {
    double error = 0;
    _resultMap.forEach((key,value){
      error += value[0];
    });
    return error == 0 ?
     Text('') :
     Text(
      '*由于平均值计算,所以计算结果有误差$error',
      style: TextStyle(fontSize:16.0 ,color: Colors.red)
    );
  }
  List _overviewTableRowList() {
    List<TableRow> rowList = [
      TableRow(
        children: [
          SizedBox(
            height: 38.0,
            child: Center(
              child:Text(
                '活动总览',
                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ]
      )
    ];

    _detailList.asMap().forEach((index, detail){
      rowList.add(
        TableRow(
          children: [
            SizedBox(
              height: 36.0,
              child:Container(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "${detail['detailName']} (${detail['partner'].length}人)",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      detail['money'].toStringAsFixed(1),
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                )
              ),
            ),
          ]
        )
      );
    });
    return rowList;
  }
  // _capturePng() async {
  //   try {
  //     RenderRepaintBoundary boundary = rootWidgetKey.currentContext.findRenderObject();
  //     var image = await boundary.toImage(pixelRatio: 3.0);
  //     ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
  //     Uint8List pngBytes = byteData.buffer.asUint8List();
  //     return pngBytes;
  //   } catch (e) {
  //     print(e);
  //   }
  //   return null;
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title结算结果'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.share),
        //     onPressed: () {
        //       Uint8List img = _capturePng();
        //       print(img);
        //       // Clipboard.setData(ClipboardData(text: img.toString()));
        //     },
        //   )
        // ],
      ),
      body: RepaintBoundary(
        key: rootWidgetKey,
        child: ListView(
          children: <Widget>[
            Container (
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Table(
                    border: TableBorder.all(
                      color: Colors.grey,
                      width: 2.0,
                      style: BorderStyle.solid,
                    ),
                    children: _overviewTableRowList(),
                  ),
                  Table(
                    border: TableBorder(
                      left: BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                        style: BorderStyle.solid,
                      ),
                      right: BorderSide(
                        color: Colors.grey,
                        width: 2.0,
                        style: BorderStyle.solid,
                      )
                    ),
                    children: <TableRow>[
                      TableRow(
                        children: [
                          SizedBox(
                            height: 38.0,
                            child: Center(
                              child:Text(
                                '人员明细',
                                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ]
                      ),
                    ],
                  ),
                  Table(
                    border: TableBorder.all(
                      color: Colors.grey,
                      width: 2.0,
                      style: BorderStyle.solid,
                    ),
                    children: _detailTableRowList(),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _tips(),
                    )
                  )
                ],
              )
            ),
          ],
        )
      )  
    );
  }
}
