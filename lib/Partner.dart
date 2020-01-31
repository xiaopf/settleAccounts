import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import './Detail.dart';
class Partner extends StatefulWidget {
  final params;
  Partner({Key key, this.params}) : super(key: key);

  @override
  _PartnerState createState() => _PartnerState();
}

class _PartnerState extends State<Partner> {
  List _partnerList = [];
  String _partnerName;
  List _selectedItem = [];

  @override
  void initState() { 
    super.initState();
    final selected = widget.params['payer'] == null ? widget.params['partner'] : widget.params['payer'];
    _readData().then((List value){
      setState((){
        _partnerList = value;
        _selectedItem = selected;
      });
    });
  }

  Future<File> _getLocalFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/partnerList.json');
  }

  Future<List> _readData() async{
    try {
      File file = await _getLocalFile();
      String data = await file.readAsString();
      List partnerList = json.decode(data);
      return partnerList;
    } on FileSystemException {
      return [];
    }
  }

  Future<Null> _addPartner(partner) async {
    setState(() {
      _partnerList.add(partner);
    });
    await (await _getLocalFile()).writeAsString(json.encode(_partnerList));
  }

  Future<Null> _removePartner(index) async {
    setState(() {
      _partnerList.removeAt(index);
    });
    await (await _getLocalFile()).writeAsString(json.encode(_partnerList));
  }

  Widget _partnerWidgetList(BuildContext context, int index) {
    if(_partnerList.length <= 0 ) {
      return  Column(
        children: <Widget>[
          Center(
            heightFactor: 2.0,
            child: Text('暂无参与人', style: TextStyle(color: Colors.blueGrey,fontSize: 20.0),)
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
    final partner = _partnerList[index];
    final partnerIsJoined = _selectedItem.contains(partner);
    return Dismissible(
      key: Key(partner),
      background: Container(color: Colors.red,),
      direction:DismissDirection.endToStart,
      onDismissed: (direction) async{
        await _removePartner(index);
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('$partner被删除了'),
            duration: Duration(milliseconds: 500)
          )
        );
      },
      child: Container(
        color: Colors.white10,
        child: Column(
          children: <Widget>[
            ListTile (
              onTap: () {  
                setState(() {
                  if (partnerIsJoined) {
                    _selectedItem.remove(partner);
                  } else {
                    if (widget.params['type'] == 'single') {
                      _selectedItem.clear();
                    }
                    _selectedItem.add(partner);
                  }
                });
                // print(_selectedItem);
              },
              contentPadding: EdgeInsets.all(8.0),
              title: Text(
                partner,
                style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18.0)
              ),
              leading: Checkbox(
                value: partnerIsJoined,
                onChanged: (value) {
                  // print(_selectedItem);
                }
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

  void _showAlertDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    _controller.addListener((){
      setState((){
        _partnerName = _controller.text;
      });
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('参与人姓名'),
        content: TextField(
          controller: _controller,
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
              await _addPartner(_partnerName);
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
        title: Text(widget.params['title']),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: (){
              var data = widget.params['type'] == 'single' ? _selectedItem[0] : _selectedItem;
              Navigator.of(context).pop(data);
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _partnerList.length > 0 ?_partnerList.length : 1,
        itemBuilder: _partnerWidgetList,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAlertDialog(context);
        },
        tooltip: '新增参与人',
        child: Icon(Icons.add),
      ),
    );
  }
}
