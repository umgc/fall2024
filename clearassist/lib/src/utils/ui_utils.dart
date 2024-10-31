import 'package:clearassistapp/src/database/model/media_type.dart';
import 'package:clearassistapp/src/utils/permission_manager.dart';
import 'package:clearassistapp/ui/assistant_screen.dart';
import 'package:clearassistapp/ui/home_screen.dart';
import 'package:clearassistapp/ui/settings_screen.dart';
import 'package:clearassistapp/ui/video_screen.dart';
import 'package:flutter/material.dart';

import '../../ui/global_settings.dart';

class UiUtils {
  static IconData getMediaIconData(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.audio:
        return Icons.chat;
      case MediaType.photo:
        return Icons.photo;
      case MediaType.video:
        return Icons.video_camera_back;
      default:
        throw Exception('Unsupported media type: $mediaType');
    }
  }
}
