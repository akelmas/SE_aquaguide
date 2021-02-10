
class PLocationData {
   var latitude;
   var longitude;
   var accuracy;
   var altitude;

  PLocationData.fromJson(Map<String,dynamic> json):
        latitude=json['lat'],
        longitude=json['long'],
        accuracy=json['acc'],
        altitude=json['alt'];


  Map<String,dynamic> toJson()=>{
    'lat':latitude,
    'long':longitude,
    'acc':accuracy,
    'alt':altitude

  };

  PLocationData({this.latitude, this.longitude, this.altitude ,this.accuracy});

  PLocationData.DEFAULT(){
    latitude=0;
    longitude=0;
    altitude=0;
    accuracy=0;
  }


}