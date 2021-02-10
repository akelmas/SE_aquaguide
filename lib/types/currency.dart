class Currency{
  final String name;
  final double forexBuying;
  final double forexSelling;


   Currency.fromJson(this.name,Map<String,dynamic> json):
      forexBuying=double.parse(json['Al\u0131\u015f']),
      forexSelling=double.parse(json['Sat\u0131\u015f']);
}