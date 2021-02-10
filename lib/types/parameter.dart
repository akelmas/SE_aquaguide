class Parameter {
  int index;
  String uid;
  String plantId;
  String name;
  var value;
  String type;
  bool isEssential;
  bool isLocked = false;

  Parameter(this.index,this.plantId,this.uid,this.name, this.type, this.isEssential);

  Parameter.fromJson(Map<String, dynamic> json)
      : index         = json['index'],
        uid           = json['uid'],
        plantId       = json['plantId'],
        name          = json['name'],
        value         = json['value'],
        type          = json['type'],
        isEssential   = json['isEssential'],
        isLocked      = json['isLocked'];

  Map<String, dynamic> toJson() => {
        'index'       : index,
        'uid'         : uid,
        'plantId'     : plantId,
        'name'        : name,
        'value'       : value,
        'type'        : type,
        'isEssential' : isEssential,
        'isLocked'    : isLocked
      };

  Parameter.of({this.plantId,this.name,this.value,this.type});

  bool operator <(other) {
    return index < other.index;
  }

}
