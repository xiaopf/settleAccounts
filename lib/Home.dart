import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _activeList;
  String _activeTitle;

  @override
  void initState() { 
    super.initState();
    _readData().then((List value){
      setState((){
        _activeList = value;
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

  Future<Null> _addActive(active) async {
    setState(() {
      _activeList.add(active);
    });
    await (await _getLocalFile()).writeAsString(json.encode(_activeList));
  }

  Future<Null> _removeActive(index) async {
    setState(() {
      _activeList.removeAt(index);
    });
    await (await _getLocalFile()).writeAsString(json.encode(_activeList));
  }

  Widget _activeWidgetList(BuildContext context, int index) {
    if(_activeList.length <= 0 ) {
      return  Column(
        children: <Widget>[
          Center(
            heightFactor: 2.0,
            child: Text('暂无活动', style: TextStyle(color: Colors.blueGrey,fontSize: 20.0),)
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
    final active = _activeList[index];
    return Dismissible(
      key: Key(active['title']),
      background: Container(color: Colors.red,),
      direction:DismissDirection.endToStart,
      onDismissed: (direction) async{
        await _removeActive(index);
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('${active['title']}被删除了'),
            duration: Duration(milliseconds: 500)
          )
        );
      },
      child: Container(
        color: Colors.white10,
        child: Column(
          children: <Widget>[
            ListTile (
              contentPadding: EdgeInsets.all(8.0),
              title: Text(
                active['title'],
                style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18.0)
              ),
              trailing: Icon(Icons.arrow_forward_ios)
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

  void _showAlertDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    _controller.addListener((){
      setState((){
        _activeTitle = _controller.text;
      });
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('活动标题'),
        content: TextField(
          controller: _controller,
          maxLength: 30,
          maxLines: 1,
          autofocus: true,
          onChanged: (text) {
            print(text);
          },
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text("取消"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          new FlatButton(
            child: new Text("确定"),
            onPressed: () async{
              await _addActive({"title": _activeTitle});
              Navigator.of(context).pop();
            },
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新增事件'),
      ),
      body: ListView.builder(
        itemCount: _activeList.length > 0 ?_activeList.length : 1,
        itemBuilder: _activeWidgetList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAlertDialog(context);
        },
        tooltip: '新增事件',
        child: Icon(Icons.add),
      ),
    );
  }
}
