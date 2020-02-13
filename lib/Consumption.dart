import 'package:flutter/material.dart';
import './Partner.dart';

class Consumption extends StatefulWidget {
  final detail;
  Consumption({Key key, this.detail}) : super(key: key);

  @override
  _ConsumptionState createState() => _ConsumptionState();
}

class _ConsumptionState extends State<Consumption> {
  GlobalKey<FormState> detailKey = new GlobalKey();
  String detailName = '';
  double money;
  String _payer = '';
  String note = '';
  List _partnerJoined = [];
  final TextEditingController _controllerPayer = TextEditingController();
  final TextEditingController _controllerPartner = TextEditingController();
  void _setTextFieldValue () {
    _controllerPayer.text = _payer;
    _controllerPartner.text = _partnerJoined.join('，');
  }
  @override
  void initState() { 
    super.initState();
    Map detail = widget.detail;
    if(widget.detail is Map){
      setState((){
        detailName = detail['detailName'];
        money = detail['money'];
        _payer = detail['payer'];
        note = detail['note'];
        _partnerJoined = detail['partner'];
      });
    }
    _setTextFieldValue();
  }

  void saveDetail () {
    var detailForm = detailKey.currentState;
    if(detailForm.validate()) {
      detailForm.save();
      Map data = {
        'detailName': detailName,
        'payer': _payer,
        'money': money,
        'partner': _partnerJoined,
        'note': note
      };
      Navigator.of(context).pop(data);
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确定离开本页面?'),
        actions: <Widget>[
          FlatButton(
              child: Text('暂不'),
              onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
              child: Text('确定'),
              onPressed: () => Navigator.pop(context, true),
          ),
        ],
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    _controllerPayer.addListener(_setTextFieldValue);
    _controllerPartner.addListener(_setTextFieldValue);
    return Scaffold(
      appBar: AppBar(
        title: Text('${ widget.detail is Map ? '编辑' : '添加'}明细'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (){
              saveDetail();
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              onWillPop: _onBackPressed,
              key: detailKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    initialValue: detailName,
                    decoration: InputDecoration(
                      labelText: '明细名称',
                      icon: Icon(Icons.local_activity)
                    ),
                    onSaved: (value) {
                      detailName = value.trim();
                    },
                    validator: (value) {
                      return value.length == 0 ? '明细名称不能为空' : null;
                    },
                  ),
                  TextFormField(
                    initialValue: money is double ? money.toString() : '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '花费金额',
                      icon: Icon(Icons.attach_money)
                    ),
                    onSaved: (value) {
                      money = double.tryParse(value);
                    },
                    validator: (value) {
                      if (value.length == 0) {
                        return '花费金额不能为空';
                      }
                      return double.tryParse(value) is double ? null : '花费金额应为数字';
                    },
                  ),
                  TextFormField(
                    // initialValue: '_payer',
                    controller: _controllerPayer,
                    decoration: InputDecoration(
                      labelText: '支付人',
                      icon: Icon(Icons.person),
                      suffix: Icon(Icons.arrow_forward_ios)
                    ),
                    onTap: () async{
                      Map params = {
                        'type': 'single',
                        'payer': [_payer],
                        'title': '支付人'
                      };
                      String payer = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => new Partner(params: params))
                      );
                      if (payer is String) {
                        setState(() {
                          _payer = payer;
                        });
                      }
                    },
                    readOnly: true,
                    validator: (value) {
                      return value.length == 0 ? '支付人不能为空' : null ;
                    },
                  ),
                  TextFormField(
                    controller: _controllerPartner,
                    decoration: InputDecoration(
                      labelText: '参与人',
                      icon: Icon(Icons.people),
                      suffix: Icon(Icons.arrow_forward_ios)
                    ),
                    onTap: () async{
                      Map params = {
                        'type': 'multi',
                        'partner': _partnerJoined,
                        'title': '参与人'
                      };
                      List partnerJoined = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => new Partner(params: params))
                      );
                      if (partnerJoined is List) {
                        setState(() {
                          _partnerJoined = partnerJoined;
                        });
                      }
                    },
                    readOnly: true,
                    validator: (value) {
                      return value.length == 0 ? '参与人不能为空' : null;
                    },
                  ),
                  TextFormField(
                    initialValue: note,
                    decoration: InputDecoration(
                      labelText: '备注',
                      icon: Icon(Icons.message)
                    ),
                    onSaved: (value) {
                        note = value;
                    },
                  ),
                ],
              )
            ),
          )
        ],
      )

    );
  }
}
