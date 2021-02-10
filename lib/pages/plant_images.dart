import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:path/path.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/services/datastorage.dart';
import 'package:predixinote/types/plant.dart';
import 'package:predixinote/widgets/image_view.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class PlantImages extends StatefulWidget {
  final Plant plant;

  const PlantImages({Key key, this.plant}) : super(key: key);

  @override
  _PlantImagesState createState() => _PlantImagesState();
}

class _PlantImagesState extends State<PlantImages> {
  bool isUploadInProgress=false;
  bool isSelectionModeOn=false;
  bool isImgSrcCamera=true;
  File newImage;
  StreamController<List> streamController = BehaviorSubject<List>();
  List<String> imgList = new List<String>();
  List<String> selectedImg = new List<String>();
  @override
  void initState() {
    getImages();

    DatabaseService().plantsCollection.doc(widget.plant.uid).snapshots().listen((event) {
      if(event.data!=null){
        widget.plant.imageIds=Plant.fromJson(event.data()).imageIds;
        getImages().then((value) {
          if(mounted){
            setState(() {
            });
          }
        });
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child:

              StreamBuilder<List>(
                stream: streamController.stream,
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      child: Icon(
                        Icons.do_not_disturb,
                        color: Colors.black12,
                        size: 64,
                      ),
                      alignment: Alignment.center,
                    );
                  }

                  final int imgCount = snapshot.data.length;
                  imgList = snapshot.data;
                  if(imgCount==0){
                    return Container(
                      child: Icon(
                        Icons.do_not_disturb,
                        color: Colors.black12,
                        size: 64,
                      ),
                      alignment: Alignment.center,
                    );
                  }
                  return Container(
                    margin: EdgeInsets.all(5),
                    child: GridView.count(
                      shrinkWrap: true,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      crossAxisCount: MediaQuery.of(context).orientation==Orientation.portrait?3:5,
                      children: List.generate(imgCount, (index) {
                        final dynamic url = imgList[index];
                        return InkWell(
                            onLongPress: (){
                              if(!isSelectionModeOn){
                                setState(() {

                                  selectedImg.add(widget.plant.imageIds[index]);


                                  isSelectionModeOn=true;
                                });
                              }
                            },


                            child: Stack(
                              children: <Widget>[
                                url==null?
                            Container(
                              height: 256,
                              child: Icon(Icons.error,color: Colors.red,),
                            ):
                                CachedNetworkImage(

                                  imageUrl: url,
                                  imageBuilder: (context, imageProvider) => Container(
                                    height: 256,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => Container(
                                    child: SizedBox(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 5,
                                      ),
                                      width: 48,
                                      height: 48,
                                    ),
                                    height: 256,
                                    alignment: Alignment.center,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                (selectedImg.contains(widget.plant.imageIds[index]))?
                                Container(
                                  alignment: Alignment.center,
                                  height: 256,
                                  decoration: BoxDecoration(
                                      color: Colors.black38
                                  ),
                                  child: Icon(Icons.check,size: 32,color: Colors.white,),
                                ):Container(
                                  alignment: Alignment.center,
                                  height: 256,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent
                                  ),
                                ),



                              ],
                            ),
                            onTap: () {
                              if(!isSelectionModeOn){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ImageView(
                                      title: widget.plant.name,
                                      initialIndex: index,
                                      urllist: imgList,
                                    ),));
                              }else{
                                setState(() {
                                  if(selectedImg.contains(widget.plant.imageIds[index])){
                                    selectedImg.remove(widget.plant.imageIds[index]);
                                    if(selectedImg.isEmpty){
                                      isSelectionModeOn=false;
                                    }
                                  }else{
                                    selectedImg.add(widget.plant.imageIds[index]);
                                  }
                                  print(selectedImg);
                                });
                              }
                            });
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.all(10),
          child: isSelectionModeOn?FloatingActionButton(
          onPressed: onDeletePressed,
          child: Icon(Icons.delete),
        ):Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isUploadInProgress?RefreshProgressIndicator():
              FloatingActionButton(
                heroTag: "upload_button",
                onPressed: ()=>onTakePhotoPressed(ImageSource.gallery),
                child: Icon(Icons.cloud_upload),
                backgroundColor: Colors.green,
              ),
              FloatingActionButton(
                heroTag: "take_photo_button",
                onPressed: ()=>onTakePhotoPressed(ImageSource.camera),
                child: Icon(Icons.photo_camera),
                backgroundColor: Colors.pinkAccent,
              ),

            ],
          ),

        )


      ],
    );
  }
  void onDeletePressed ()async{
    for(String i in selectedImg){
      print(i);
      widget.plant.imageIds.remove(i);
    }
    await DatabaseService().updatePlant(widget.plant);
      setState(() {
        selectedImg.clear();
        isSelectionModeOn=false;
      });

  }


  void onTakePhotoPressed(ImageSource src) async {
    print("take photo clicked");
    String filename=Uuid().v1();

    File newImage;
    PickedFile pickedFile;
    FilePickerResult result;
    ImagePicker imagePicker = ImagePicker();
    if(src==ImageSource.gallery&&Platform.isIOS){

      result = await FilePicker.platform.pickFiles(
        type: FileType.image,withData: true
      );
      filename+="."+result.files.single.extension;

      print(filename);

    }else{
      pickedFile = (await imagePicker
          .getImage(source: src, maxHeight: 1200, maxWidth: 1600)
          .catchError((e) => print(e)));
      print(pickedFile.path);

    }



    if(pickedFile!=null){
      newImage = new File(pickedFile.path);
      newImage.writeAsBytesSync((await pickedFile.readAsBytes()).cast<int>());
      filename=basename(newImage.path);
    }else if(result!=null){
      newImage = new File(result.paths.single);
      newImage.writeAsBytesSync((result.files.single.bytes));
    }
    if(newImage==null){
      print("nothing selected");
      return;
    }
      if(mounted){
        setState(() {
          isUploadInProgress=true;
        });
      }
      DataStorageService().imgStorage.child("${widget.plant.groupId}/${widget.plant.uid}/$filename").putFile(newImage).onComplete.then((value) {

      }).catchError((e) {
        if(mounted){
          setState(() {
            isUploadInProgress=false;
          });
        }
        return;
      }).then((value) {
        widget.plant.addImageById(filename);
        DatabaseService().updatePlant(widget.plant).then((value) {
          if(mounted){
            setState(() {
              isUploadInProgress=false;
              getImages();

            });
          }
        });

      });

  }

  Future getImages() async {


    final List<String> imageUrls = new List<String>();


      for(var imageID in widget.plant.imageIds){
        String url = await DataStorageService()
            .imgStorage
            .child(
            '${widget.plant.groupId}/${widget.plant.uid}/$imageID')
            .getDownloadURL().catchError((err)=>print(err));



        imageUrls.add(url);

      }
    streamController.add(imageUrls);
  }

}

