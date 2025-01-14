import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class FileUtils {
  static Future<String> exportData(Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.json');
    final jsonData = jsonEncode(data);
    await file.writeAsString(jsonData);
    return file.path;
  }

  static Future<Map<String, dynamic>?> importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final jsonData = await file.readAsString();
      return jsonDecode(jsonData) as Map<String, dynamic>;
    }

    return null;
  }
}
