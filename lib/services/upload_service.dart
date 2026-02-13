import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'api_client.dart';

final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService(ref);
});

class UploadService {
  final Ref _ref;

  UploadService(this._ref);

  Future<String> uploadFile(XFile file) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      
      final bytes = await file.readAsBytes();
      final String fileName = file.name;

      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      var response = await apiClient.client.post("/uploads/", data: formData);
      return response.data['url'];
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }
}
