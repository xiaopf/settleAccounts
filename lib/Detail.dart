import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import './Consumption.dart';
import './Result.dart';
class Detail extends StatefulWidget {
  final index;
  Detail({Key key, this.index}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  List _activeList = [];
  int activeIndex;
  List _detailList = [];
  String _title = '';

  @override
  void initState() { 
    super.initState();
    
    _readData().then((List value){
      activeIndex = widget.index;
      print(value);
      setState((){
        _activeList = value;
        _title = value[activeIndex]['title'];
        _detailList = value[activeIndex]['detailList'] == null ? [] : value[activeIndex]['detailList'];
      });
    });
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

  Future<Null> _addDetail(detailItem) async {
    setState(() {
      _detailList.add(detailItem);
      _activeList[activeIndex]['detailList'] = _detailList;
    });
    await (await _getLocalFile()).writeAsString(json.encode(_activeList));
  }

  Future<Null> _removeDetail(index) async {
    setState(() {
      _detailList.removeAt(index);
    });
    await (await _getLocalFile()).writeAsString(json.encode(_activeList));
  }

  Widget _detailWidgetList(BuildContext context, int index) {
    if(_detailList.length <= 0 ) {
      return  Column(
        children: <Widget>[
          Center(
            heightFactor: 2.0,
            child: Text('暂无明细', style: TextStyle(color: Colors.blueGrey,fontSize: 20.0),)
          ),
          Divider(
            indent: 20.0,
            endIndent: 20.0,
            height: 0.0,
            thickness:1.5,
          ),
        ],
      );
    }
    final detail = _detailList[index];
    if (detail == null) {
      return Container(
        height: 0,
      );
    }
    return Dismissible(
      key: Key(detail['detailName']),
      background: Container(color: Colors.red,),
      direction:DismissDirection.endToStart,
      onDismissed: (direction) async{
        await _removeDetail(index);
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('${detail['detailName']}被删除了'),
            duration: Duration(milliseconds: 500)
          )
        );
      },
      child: Container(
        color: Colors.white10,
        child: Column(
          children: <Widget>[
            ListTile (
              onTap: () async{
                Map modifiedDetail = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Consumption(detail: detail))
                );
                if(modifiedDetail is Map){
                  setState(() {
                    _detailList[index] = modifiedDetail;
                  });
                  await (await _getLocalFile()).writeAsString(json.encode(_activeList));
                }
              },
              contentPadding: EdgeInsets.all(8.0),
              title: Text(
                detail['detailName'],
                style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18.0)
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              subtitle: Container(
                child: Text(
                  '${detail['payer']} 支付 ${detail['money'].toString()}元 (${detail['partner'].length}人参与)'
                )
              )
            ),
            Divider(
              height: 0.0,
              thickness:1.5,
            ),
          ],
        )
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title活动明细'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.iso),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Result(index: activeIndex))
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _detailList.length == 0 ?  1 : _detailList.length,
        itemBuilder: _detailWidgetList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          // setState(() {
          //   _detailList.removeAt(0);
          // });
          // await(await _getLocalFile()).writeAsString(json.encode(_activeList));
          Map detailItem = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Consumption())
          );
          _addDetail(detailItem);
        },
        tooltip: '添加明细',
        child: Icon(Icons.add),
      ),
    );
  }
}
