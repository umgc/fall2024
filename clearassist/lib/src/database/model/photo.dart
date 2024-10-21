import 'package:clearassistapp/src/database/model/media.dart';
import 'package:clearassistapp/src/database/model/media_type.dart';
import 'package:clearassistapp/src/database/repository/photo_repository.dart';
import 'package:clearassistapp/src/utils/directory_manager.dart';
import 'package:clearassistapp/src/utils/file_manager.dart';
import 'package:flutter/widgets.dart';

class Photo extends Media {
  final String photoFileName;

  late Image? photo;

  Photo({
    super.id,
    String? title,
    super.description,
    super.tags,
    required super.timestamp,
    super.physicalAddress,
    required super.storageSize,
    required super.isFavorited,
    required this.photoFileName,
  }) : super(
          mediaType: MediaType.photo,
          title: title ?? photoFileName,
        ) {
    _loadPhoto();
  }

  @override
  Photo copy({
    int? id,
    String? title,
    String? description,
    List<String>? tags,
    DateTime? timestamp,
    String? physicalAddress,
    int? storageSize,
    bool? isFavorited,
    String? photoFileName,
  }) =>
      Photo(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        timestamp: timestamp ?? this.timestamp,
        physicalAddress: physicalAddress ?? this.physicalAddress,
        storageSize: storageSize ?? this.storageSize,
        isFavorited: isFavorited ?? this.isFavorited,
        photoFileName: photoFileName ?? this.photoFileName,
      );

  @override
  Map<String, Object?> toJson() {
    return {
      ...super.toJson(),
      PhotoFields.photoFileName: photoFileName,
    };
  }

  static Photo fromJson(Map<String, Object?> json) {
    try {
      return Photo(
        id: json[MediaFields.id] as int?,
        title: json[MediaFields.title] as String?,
        description: json[MediaFields.description] as String?,
        tags: (json[MediaFields.tags] as String?)?.split(','),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          (json[MediaFields.timestamp] as int),
          isUtc: true,
        ),
        physicalAddress: json[MediaFields.physicalAddress] as String,
        storageSize: json[MediaFields.storageSize] as int,
        isFavorited: json[MediaFields.isFavorited] == 1,
        photoFileName: json[PhotoFields.photoFileName] as String,
      );
    } catch (e) {
      throw FormatException('Error parsing JSON for Photo: $e');
    }
  }

  Future<void> _loadPhoto() async {
    photo = FileManager.loadImage(
      DirectoryManager.instance.photosDirectory.path,
      photoFileName,
    );
  }
}
