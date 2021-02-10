
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
class DataStorageService {
  final StorageReference imgStorage=FirebaseStorage.instance.ref().child("plantImgs");


  Future<File> downloadFile(StorageReference ref) async {
    final String url = await ref.getDownloadURL();
    final String uuid = Uuid().v1();
    final http.Response downloadData = await http.get(url);
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/tmp$uuid.txt');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    return await tempFile.create();
  }

  Future<StorageUploadTask> uploadFile(File file,StorageReference ref) async {
    final StorageUploadTask uploadTask =  ref.putFile(file);
    return uploadTask;
  }

  Future<String> fileUrl(StorageReference ref)async{
    return await ref.getDownloadURL();
  }
}