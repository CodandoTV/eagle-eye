import 'dart:io';

import 'package:eagle_eye/data/file_helper.dart';
import 'package:eagle_eye/data/json_converter.dart';
import 'package:eagle_eye/model/eagle_eye_config.dart';

abstract class EagleEyeRepository {
  Future<EagleEyeConfig?> getAndCheckIfConfigFileExists();
  List<File>? allDartFiles();
  String? getApplicationName();
}

class EagleEyeRepositoryImpl extends EagleEyeRepository {
  static const configFileName = 'eagle_eye_config.json';
  static const libsFolderName = 'lib';

  FileHelper fileHelper;
  JsonConverter jsonConverter;

  EagleEyeRepositoryImpl({
    required this.fileHelper,
    required this.jsonConverter,
  });

  @override
  List<File>? allDartFiles() {
    try {
      Directory libsDir = fileHelper.getAndCheckIfLibsDirectoryExists(
        libsFolderName,
      );
      return fileHelper.allDartFiles(libsDir);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<EagleEyeConfig?> getAndCheckIfConfigFileExists() async {
    try {
      final String configFileContent =
          await fileHelper.getAndCheckIfConfigFileExists(configFileName);

      return jsonConverter.convert(configFileContent);
    } catch (e) {
      return null;
    }
  }

  @override
  String? getApplicationName() {
    try {
      return fileHelper.getApplicationName();
    } catch (e) {
      return null;
    }
  }
}
