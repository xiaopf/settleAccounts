import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Result extends StatefulWidget {
  final index;
  Result({Key key, this.index}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Result> {
  int activeIndex;
  Map _resultMap = {};
  String _title = '';

  @override
  void initState() { 
    super.initState();
    
    _readData().then((List value){
      activeIndex = widget.index;
      print(value);
      setState((){
        _title = value[activeIndex]['title'];
        List detailList = value[activeIndex]['detailList'];
        _resultMap = calculate(detailList);
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

          print('value $value');
          
          if (resultMap[key] == null) {
            resultMap[key] = value;
          } else {
            resultMap[key] += value;
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

  List _tableRowList() {
    List<TableRow> rowList = [
      TableRow(
        //第一行样式 添加背景色
        decoration: BoxDecoration(
          color: Colors.blueGrey,
        ),
        children: [
          SizedBox(
            height: 30.0,
            child: Center(
              child:Text('参与人',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
          ),
          SizedBox(
            height: 30.0,
            child: Center(
              child: Text('花费',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          ),
          SizedBox(
            height: 30.0,
            child: Center(
              child: Text('结算',style: TextStyle(fontWeight: FontWeight.bold),),
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
              height: 25.0,
              child:Center(
                child: Text(key),
            ),
            ),
            SizedBox(
              height: 25.0,
              child:Center(
                child: Text(value.toStringAsFixed(1), style: TextStyle(color:value > 0 ? Colors.green : Colors.red)),
              ),
            ),
            SizedBox(
              height: 25.0,
              child:Center(
                child: Text(value.toStringAsFixed(1), style: TextStyle(color:value > 0 ? Colors.green : Colors.red)),
              ),
            ),
          ]
        )
      );
    });
    return rowList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title结算结果'),
      ),
      body: Container (
        child: Column(
          children: <Widget>[
            Table(
              border: TableBorder.all(
                color: Colors.grey,
                width: 2.0,
                style: BorderStyle.solid,
              ),
              children: _tableRowList(),
            )
          ],
        )
      ),
    );
  }
}
