import 'dart:io';

import 'package:clearassistapp/src/database/controller/audio_controller.dart';
import 'package:clearassistapp/src/database/controller/photo_controller.dart';
import 'package:clearassistapp/src/database/model/audio.dart';
import 'package:clearassistapp/src/database/model/media.dart';
import 'package:clearassistapp/src/database/model/photo.dart';
import 'package:clearassistapp/src/utils/format_utils.dart';
import 'package:clearassistapp/src/database/repository/audio_repository.dart';
import 'package:clearassistapp/src/database/repository/photo_repository.dart';
import 'package:clearassistapp/src/utils/logger.dart';

class DataService {
  DataService._internal();

  static final DataService _instance = DataService._internal();
  static DataService get instance => _instance;

  late List<Media> mediaList = [];
  bool hasBeenInitialized = false;

  Future<void> initializeData() async {
    await loadMedia();
  }

  // Used to show local database and objects
  Future<void> loadMedia() async {
    final audios = await AudioRepository.instance.readAll();
    final photos = await PhotoRepository.instance.readAll();

    mediaList = [...audios, ...photos];

    if (!hasBeenInitialized) {
      FormatUtils.logBigMessage("LOCAL DATABASE OBJECTS START");

      if (audios.isNotEmpty) {
        FormatUtils.logBigMessage("AUDIO OBJECTS START");
        for (var audio in audios) {
          print('Audio #${audio.id}: ${audio.toJson()}');
        }
        FormatUtils.logBigMessage("AUDIO OBJECTS END");
      }

      if (photos.isNotEmpty) {
        FormatUtils.logBigMessage("PHOTO OBJECTS START");
        for (var photo in photos) {
          print('Photo #${photo.id}: ${photo.toJson()}');
        }
        FormatUtils.logBigMessage("PHOTO OBJECTS END");
      }

      FormatUtils.logBigMessage("LOCAL DATABASE OBJECTS END");
      hasBeenInitialized = true;
    }
  }

  Future<void> unloadMedia() async {
    mediaList.clear();
  }

  Future<void> refreshMedia() async {
    await unloadMedia();
    await loadMedia();
  }

  // |-------------------------------------------------------------------------|
  // |--------------------------- AUDIO OPERATIONS ----------------------------|
  // |-------------------------------------------------------------------------|

  // TODO, refactor seed data to just use addAudio();
  Future<Audio?> addSeedAudio({
    String? title,
    String? description,
    List<String>? tags,
    required File audioFile,
    File? transcriptFile,
    String? summary,
  }) async {
    try {
      final audio = await AudioController.addSeedAudio(
        title: title,
        description: description,
        tags: tags,
        audioFile: audioFile,
        transcriptFile: transcriptFile,
        summary: summary,
      );
      if (audio != null) {
        await refreshMedia();
      }
      return audio;
    } catch (e) {
      appLogger.severe('Data Service -- Error adding audio: $e');
      return null;
    }
  }

  Future<Audio?> addAudio({
    String? title,
    String? description,
    List<String>? tags,
    required File audioFile,
    File? transcriptFile,
    String? summary,
  }) async {
    try {
      final audio = await AudioController.addAudio(
        title: title,
        description: description,
        tags: tags,
        audioFile: audioFile,
        transcriptFile: transcriptFile,
        summary: summary,
      );
      if (audio != null) {
        await refreshMedia();
      }
      return audio;
    } catch (e) {
      appLogger.severe('Data Service -- Error adding audio: $e');
      return null;
    }
  }

  Future<Audio?> updateAudio({
    required int id,
    String? title,
    String? description,
    List<String>? tags,
    bool? isFavorited,
    File? transcriptFile,
    String? summary,
  }) async {
    try {
      final audio = await AudioController.updateAudio(
        id: id,
        title: title,
        description: description,
        isFavorited: isFavorited,
        tags: tags,
        transcriptFile: transcriptFile,
        summary: summary,
      );
      if (audio != null) {
        await refreshMedia();
      }
      return audio;
    } catch (e) {
      appLogger.severe('Data Service -- Error updating audio: $e');
      return null;
    }
  }

  Future<Audio?> removeAudio(int id) async {
    try {
      final audio = await AudioController.removeAudio(id);
      if (audio != null) {
        await refreshMedia();
      }
      return audio;
    } catch (e) {
      appLogger.severe('Data Service -- Error removing audio: $e');
      return null;
    }
  }

  // |-------------------------------------------------------------------------|
  // |--------------------------- PHOTO OPERATIONS ----------------------------|
  // |-------------------------------------------------------------------------|

// TODO, refactor seed data to just use addPhoto();
  Future<Photo?> addSeedPhoto({
    String? title,
    String? description,
    List<String>? tags,
    required File photoFile,
  }) async {
    try {
      final photo = await PhotoController.addSeedPhoto(
        title: title,
        description: description,
        tags: tags,
        photoFile: photoFile,
      );
      if (photo != null) {
        await refreshMedia();
      }
      return photo;
    } catch (e) {
      appLogger.severe('Data Service -- Error adding photo: $e');
      return null;
    }
  }

  Future<Photo?> addPhoto({
    String? title,
    String? description,
    List<String>? tags,
    required File photoFile,
  }) async {
    try {
      final photo = await PhotoController.addPhoto(
        title: title,
        description: description,
        tags: tags,
        photoFile: photoFile,
      );
      if (photo != null) {
        await refreshMedia();
      }
      return photo;
    } catch (e) {
      appLogger.severe('Data Service -- Error adding photo: $e');
      return null;
    }
  }

  Future<Photo?> updatePhoto({
    required int id,
    String? title,
    String? description,
    bool? isFavorited,
    List<String>? tags,
  }) async {
    try {
      final photo = await PhotoController.updatePhoto(
        id: id,
        title: title,
        description: description,
        isFavorited: isFavorited,
        tags: tags,
      );
      if (photo != null) {
        await refreshMedia();
      }
      return photo;
    } catch (e) {
      appLogger.severe('Data Service -- Error updating photo: $e');
      return null;
    }
  }

  Future<Photo?> removePhoto(int id) async {
    try {
      final photo = await PhotoController.removePhoto(id);
      if (photo != null) {
        await refreshMedia();
      }
      return photo;
    } catch (e) {
      appLogger.severe('Data Service -- Error removing photo: $e');
      return null;
    }
  }

  // |-------------------------------------------------------------------------|
  // |--------------------------- OTHER OPERATIONS ----------------------------|
  // |-------------------------------------------------------------------------|

  Future<Media?> updateMediaIsFavorited(Media media, bool isFavorited) async {
    try {
      Media? updatedMedia;
      if (media is Audio) {
        updatedMedia = await updateAudio(
          id: media.id!,
          isFavorited: isFavorited,
        );
      } else if (media is Photo) {
        updatedMedia = await updatePhoto(
          id: media.id!,
          isFavorited: isFavorited,
        );
      }
      return updatedMedia;
    } catch (e) {
      appLogger.severe('Data Service -- Error updating media isFavorited: $e');
      return null;
    }
  }

  Future<Media?> updateMediaTags(Media media, List<String>? tags) async {
    try {
      Media? updatedMedia;
      if (media is Audio) {
        updatedMedia = await updateAudio(
          id: media.id!,
          tags: tags,
        );
      } else if (media is Photo) {
        updatedMedia = await updatePhoto(
          id: media.id!,
          tags: tags,
        );
      }
      return updatedMedia;
    } catch (e) {
      appLogger.severe('Data Service -- Error updating media tags: $e');
      return null;
    }
  }
}
