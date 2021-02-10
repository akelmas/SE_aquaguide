import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/location_data.dart';

class Plant {
  static const String KUYU  = "KUYU";
  static const String TERFI = "TERFI";
  static const String DEPO  = "DEPO";
  final String uid;

  String userId;
  String groupId;
  String type;
  String name;
  DateTime dateCreated;
  DateTime lastChange;
  PLocationData locationData;
  List<String> imageIds = new List<String>();
  String additionalInfo;

  int addImageById(String id) {
    if (imageIds.contains(id)) {
      return 1;
    } else {
      imageIds.add(id);
      return 0;
    }
  }

  int removeImageById(String id) {
    if (imageIds.contains(id)) {
      imageIds.remove(id);
      return 0;
    } else {
      return 1;
    }
  }

  Plant.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        userId = json['userId'],
        groupId = json['groupId'],
        type = json['type'],
        name = json['name'],
        dateCreated = DateTime.parse(json['date']),
        lastChange=DateTime.parse(json['lastChange']??DateTime.now().toIso8601String()),
        locationData = PLocationData.fromJson(json['loc']),
        imageIds = (json['imgs'] as List).cast<String>(),
        additionalInfo = json['inf'];
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'userId': userId,
        'groupId': groupId,
        'type': type,
        'name': name,
        'date': dateCreated.toIso8601String(),
        'lastChange':(lastChange??dateCreated).toIso8601String(),
        'loc': locationData.toJson(),
        'imgs': imageIds,
        'inf': additionalInfo,
      };

  @override
  bool operator ==(other) {
    // TODO: implement ==
    return this.name == (other.name);
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;

  Plant.kuyu({this.uid, this.name, this.groupId}) {
    userId = activeUser.uid;
    type = Plant.KUYU;
    dateCreated = DateTime.now();
    lastChange =DateTime.now();
    locationData=PLocationData.DEFAULT();
  }

  Plant.terfi({this.uid, this.name, this.groupId}) {
    userId = activeUser.uid;
    type = Plant.TERFI;
    dateCreated = DateTime.now();
    lastChange =DateTime.now();
    locationData=PLocationData.DEFAULT();
  }

  Plant.depo({this.uid, this.name, this.groupId}) {
    userId = activeUser.uid;
    type = Plant.DEPO;
    dateCreated = DateTime.now();
    lastChange =DateTime.now();
    locationData=PLocationData.DEFAULT();
  }

  Plant(this.uid);
}
