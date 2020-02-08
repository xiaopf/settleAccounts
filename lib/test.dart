List list = [
  {
    'detailName': 1111,
    'payer': 'xiaopf',
    'money': 120.0,
    'partner': [
      'tim',
      'jack',
      'xiaopf'
    ],
    'note': 1111
  },
  {
    'detailName': 2222,
    'payer': 'tim',
    'money': 200.0,
    'partner': [
      'tim',
      'xiaopf'
    ],
    'note': 1111
  },
];

Map result () {
  Map resultMap = {};
  
  list.forEach((item){
    List partner = item['partner'];
    String payer = item['payer'];
    int len = partner.length;
    double money = item['money'];
    double average = double.parse((money / len).toStringAsFixed(1));
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
      print(resultMap);
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

void main () {
  Map resultMap = result();
  print(resultMap);
}