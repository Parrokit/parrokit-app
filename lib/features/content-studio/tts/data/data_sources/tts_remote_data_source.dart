import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:path_provider/path_provider.dart';

class TtsRemoteDataSource {
  Future<String> generateTts({
    required String text,
    required String voiceType,
    String? language,
  }) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('generateElevenLabsTts');

    final response = await callable.call({
      'text': text,
      'voiceId': voiceType,
      if (language != null) 'language': language,
    });

    // Base64 문자열을 디코딩하여 임시 파일로 저장
    final String base64Audio = response.data['audioBase64'];
    final bytes = base64Decode(base64Audio);

    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3');
    await file.writeAsBytes(bytes);

    return file.path;
  }
}
