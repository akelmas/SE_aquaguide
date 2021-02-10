import 'dart:ui';

import 'package:flutter/material.dart';

Color appBarBackgroundColor=Colors.black87;


List<String> driverExistence=<String>[
  "Yok",
  "Var"
];


List<String> pumpTypes=<String>[
  'Dik milli',
  'Yatay milli',
  'Salyangoz',
  'Splitcase'
];
List<String> pipeTypes=<String>[
  'Pik demir',
  'Paslanmaz çelik',
  'Polietilen',
  'Asbest',
  'Bakır',
  'Alüminyum',
  'Bitümlü çelik',
  'Bitümlü demir',
  'Galvanizli çelik',
  'Orta pürüzlü beton',
  'Pirinç',
  'Pürüzsüz beton',
  'Pürüzlü beton',
  'PVC',
];

//standart pipe diameters
const List<double> DN=const <double>[
  0.0,
      10.0,
      15.0,
      20.0,
      25.0,
      32.0,
      40.0,
      50.0,
      65.0,
      80.0,
      100.0,
      125.0,
      150.0,
      200.0,
      250.0,
      300.0,
      350.0,
      400.0,
      450.0,
      500.0,
      600.0,
      700.0,
      750.0,
      800.0,
      900.0,
      1000.0,
      1200.0

];


const Map<String,String> units=const
{
  "power":"kW",
  "current":"A",
  "pressure":"Bar",
  "speed":"m/s",
  "distance":"m",
  "diameter":"mm",
  "flow":"m³/h",
  "hm":"mSS",
  "percentage":"%",
  "volume":"m³"
};