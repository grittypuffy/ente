import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path/path.dart';
import 'package:photos/core/configuration.dart';
import 'package:photos/models/file_type.dart';
import 'package:photos/models/location.dart';

class File {
  int generatedId;
  int uploadedFileId;
  String localId;
  String title;
  String deviceFolder;
  int remoteFolderId;
  String remotePath;
  String previewURL;
  int createTimestamp;
  int updateTimestamp;
  Location location;
  FileType fileType;

  File();
  File.fromJson(Map<String, dynamic> json) {
    uploadedFileId = json["fileID"];
    localId = json["deviceFileID"];
    deviceFolder = json["deviceFolder"];
    title = json["title"];
    fileType = getFileType(json["fileType"]);
    remotePath = json["path"];
    previewURL = json["previewURL"];
    createTimestamp = json["createTimestamp"];
    updateTimestamp = json["updateTimestamp"];
  }

  static Future<File> fromAsset(
      AssetPathEntity pathEntity, AssetEntity asset) async {
    File file = File();
    file.localId = asset.id;
    file.title = asset.title;
    file.deviceFolder = pathEntity.name;
    file.location = Location(asset.latitude, asset.longitude);
    switch (asset.type) {
      case AssetType.image:
        file.fileType = FileType.image;
        break;
      case AssetType.video:
        file.fileType = FileType.video;
        break;
      default:
        file.fileType = FileType.other;
        break;
    }
    file.createTimestamp = asset.createDateTime.microsecondsSinceEpoch;
    if (file.createTimestamp == 0) {
      try {
        final parsedDateTime = DateTime.parse(
            basenameWithoutExtension(file.title)
                .replaceAll("IMG_", "")
                .replaceAll("DCIM_", "")
                .replaceAll("_", " "));
        file.createTimestamp = parsedDateTime.microsecondsSinceEpoch;
      } catch (e) {
        file.createTimestamp = asset.modifiedDateTime.microsecondsSinceEpoch;
      }
    }
    return file;
  }

  Future<AssetEntity> getAsset() {
    return AssetEntity.fromId(localId);
  }

  Future<Uint8List> getBytes({int quality = 100}) async {
    if (localId == null) {
      return HttpClient().getUrl(Uri.parse(getRemoteUrl())).then((request) {
        return request.close().then((response) {
          return consolidateHttpClientResponseBytes(response);
        });
      });
    } else {
      final originalBytes = (await getAsset()).originBytes;
      if (extension(title) == ".HEIC" || quality != 100) {
        return originalBytes.then((bytes) {
          return FlutterImageCompress.compressWithList(bytes, quality: quality)
              .then((converted) {
            return Uint8List.fromList(converted);
          });
        });
      } else {
        return originalBytes;
      }
    }
  }

  String getRemoteUrl() {
    return Configuration.instance.getHttpEndpoint() +
        "/files/file/" +
        uploadedFileId.toString();
  }

  String getThumbnailUrl() {
    return Configuration.instance.getHttpEndpoint() + "/" + previewURL;
  }

  @override
  String toString() {
    return '''File(generatedId: $generatedId, uploadedFileId: $uploadedFileId, 
      localId: $localId, title: $title, deviceFolder: $deviceFolder, 
      location: $location, remotePath: $remotePath, fileType: $fileType,
      createTimestamp: $createTimestamp, updateTimestamp: $updateTimestamp)''';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is File &&
        o.generatedId == generatedId &&
        o.uploadedFileId == uploadedFileId &&
        o.localId == localId;
  }

  @override
  int get hashCode {
    return generatedId.hashCode ^ uploadedFileId.hashCode ^ localId.hashCode;
  }

  String heroTag() {
    return "local_" +
        localId.toString() +
        ":remote_" +
        uploadedFileId.toString();
  }
}
