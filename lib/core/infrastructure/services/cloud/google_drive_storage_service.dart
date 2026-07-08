import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parrokit/core/shared/utils/app_logger.dart';

typedef GoogleDriveProgressCallback = void Function(
  int current,
  int total,
  String message,
);

class GoogleDriveUploadResult {
  GoogleDriveUploadResult({
    required this.fileId,
    required this.fileName,
    required this.folderId,
    required this.accountKey,
    this.webViewLink,
    this.webContentLink,
  });

  final String fileId;
  final String fileName;
  final String folderId;
  final String accountKey;
  final String? webViewLink;
  final String? webContentLink;
}

class GoogleDriveStorageQuota {
  GoogleDriveStorageQuota({
    required this.usedBytes,
    this.limitBytes,
  });

  final int usedBytes;
  final int? limitBytes;
}

class GoogleDriveStorageService {
  static const String _driveScope =
      'https://www.googleapis.com/auth/drive.file';
  static const String _folderName = 'Parrokit';
  static const String _folderCacheKeyPrefix = 'google_drive_folder_id';

  GoogleDriveStorageService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const [_driveScope],
            );

  final GoogleSignIn _googleSignIn;

  Future<GoogleSignInAccount?> connect() async {
    final current = await _googleSignIn.signInSilently(suppressErrors: true);
    if (current != null) return current;
    return _googleSignIn.signIn();
  }

  Future<bool> hasConnectedAccount() async {
    final current = await _googleSignIn.signInSilently(suppressErrors: true);
    return current != null;
  }

  Future<void> disconnect() async {
    await _googleSignIn.signOut();
  }

  Future<String?> currentAccountKey() async {
    final account = await _googleSignIn.signInSilently(suppressErrors: true);
    return account == null ? null : _accountKey(account);
  }

  Future<GoogleDriveStorageQuota?> fetchStorageQuota() async {
    final account = await _googleSignIn.signInSilently(suppressErrors: true);
    if (account == null) {
      return null;
    }

    final headers = await _authorizationHeaders(account);
    final client = HttpClient();
    try {
      final uri = Uri.https(
        'www.googleapis.com',
        '/drive/v3/about',
        const {'fields': 'storageQuota'},
      );
      final request = await client.getUrl(uri);
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await utf8.decodeStream(response);
        throw StateError(
          'Google Drive 저장 용량 조회 실패: ${response.statusCode} $body',
        );
      }

      final body = await utf8.decodeStream(response);
      final data = _asMap(body);
      final quota = data['storageQuota'];
      if (quota is! Map<String, dynamic>) return null;

      final usedBytes = int.tryParse('${quota['usageInDrive'] ?? 0}') ?? 0;
      final limitRaw = quota['limit'];
      final limitBytes = limitRaw == null ? null : int.tryParse('$limitRaw');
      return GoogleDriveStorageQuota(
        usedBytes: usedBytes,
        limitBytes: limitBytes,
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<GoogleDriveUploadResult> uploadClipFile({
    required File file,
    required String fileName,
    required String clipId,
    required String storagePath,
    required String title,
    required int storageBytes,
    required int durationMs,
    required String remoteDocId,
    required String ownerScope,
    GoogleDriveProgressCallback? onProgress,
  }) async {
    AppLogger.i(
        '[GoogleDrive][Upload] connect-start file=${_maskFileName(fileName)}');
    final account = await connect();
    if (account == null) {
      throw StateError('Google Drive 연결이 필요합니다.');
    }
    AppLogger.i(
      '[GoogleDrive][Upload] connect-done account=${_maskAccount(account)}',
    );

    AppLogger.d('[GoogleDrive][Upload] auth-start');
    final headers = await _authorizationHeaders(account);
    final accountKey = _accountKey(account);
    AppLogger.d('[GoogleDrive][Upload] auth-done');
    AppLogger.d('[GoogleDrive][Upload] folder-ensure-start');
    final folderSegments = _folderSegmentsForStoragePath(storagePath);
    final folderId = await _ensureFolderPath(
      account,
      headers,
      folderSegments,
    );
    AppLogger.d('[GoogleDrive][Upload] folder-ensure-done folderId=$folderId');
    onProgress?.call(0, 0, 'Google Drive 연결 확인 중');

    final uploadUri = Uri.https(
      'www.googleapis.com',
      '/upload/drive/v3/files',
      const {
        'uploadType': 'multipart',
        'fields': 'id,name,webViewLink,webContentLink,parents',
      },
    );
    final boundary =
        'parrokit-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final totalBytes = await file.length();

    final metadata = <String, dynamic>{
      'name': fileName,
      'parents': [folderId],
      'appProperties': <String, String>{
        'clipId': clipId,
        'remoteDocId': remoteDocId,
        'title': title,
        'storageMode': 'gdrive',
        'provider': 'gdrive',
        'ownerScope': ownerScope,
        'ownerKey': accountKey,
        'storageBytes': storageBytes.toString(),
        'durationMs': durationMs.toString(),
        'storagePath': storagePath,
      },
    };

    final client = HttpClient();
    try {
      AppLogger.i(
        '[GoogleDrive][Upload] start file=${_maskFileName(fileName)} folderId=$folderId',
      );
      onProgress?.call(0, totalBytes, 'Google Drive에 저장하는 중');
      AppLogger.d('[GoogleDrive][Upload] request-open-start');
      final request = await client.postUrl(uploadUri);
      AppLogger.d('[GoogleDrive][Upload] request-open-done');
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/related; boundary="$boundary"',
      );
      AppLogger.d('[GoogleDrive][Upload] request-body-write-start');
      request.add(_utf8Bytes('--$boundary\r\n'));
      request.add(
        _utf8Bytes('Content-Type: application/json; charset=UTF-8\r\n\r\n'),
      );
      request.add(_utf8Bytes('${jsonEncode(metadata)}\r\n'));
      request.add(_utf8Bytes('--$boundary\r\n'));
      request.add(_utf8Bytes('Content-Type: $mimeType\r\n\r\n'));
      AppLogger.d(
        '[GoogleDrive][Upload] file-stream-start totalBytes=$totalBytes',
      );
      var sentBytes = 0;
      var lastLoggedPercent = -1;
      await for (final chunk in file.openRead()) {
        request.add(chunk);
        sentBytes += chunk.length;
        final percent =
            totalBytes == 0 ? 100 : ((sentBytes / totalBytes) * 100).floor();
        if (percent != lastLoggedPercent && percent % 10 == 0) {
          lastLoggedPercent = percent;
          AppLogger.d(
            '[GoogleDrive][Upload] file-stream-progress sent=$sentBytes total=$totalBytes percent=$percent',
          );
        }
        onProgress?.call(sentBytes, totalBytes, 'Google Drive에 올리는 중');
      }
      AppLogger.d(
        '[GoogleDrive][Upload] file-stream-done sentBytes=$sentBytes',
      );
      request.add(_utf8Bytes('\r\n--$boundary--'));
      AppLogger.d('[GoogleDrive][Upload] request-close-start');
      final response = await request.close();
      AppLogger.d(
        '[GoogleDrive][Upload] request-close-done status=${response.statusCode}',
      );
      final responseBody = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Google Drive 업로드 실패: ${response.statusCode} $responseBody',
        );
      }

      final data = _asMap(responseBody);
      final result = GoogleDriveUploadResult(
        fileId: data['id'] as String? ?? '',
        fileName: data['name'] as String? ?? fileName,
        folderId: folderId,
        accountKey: accountKey,
        webViewLink: data['webViewLink'] as String?,
        webContentLink: data['webContentLink'] as String?,
      );

      if (result.fileId.isEmpty) {
        throw StateError('Google Drive 파일 ID를 받지 못했습니다.');
      }

      onProgress?.call(1, 1, 'Google Drive 저장 완료');
      AppLogger.i(
        '[GoogleDrive][Upload] success fileId=${result.fileId} folderId=$folderId',
      );
      return result;
    } finally {
      client.close(force: true);
    }
  }

  Future<File> downloadClipFile({
    required String fileId,
    required File destination,
    GoogleDriveProgressCallback? onProgress,
  }) async {
    AppLogger.i('[GoogleDrive][Download] connect-start fileId=$fileId');
    final account = await connect();
    if (account == null) {
      throw StateError('Google Drive 연결이 필요합니다.');
    }
    AppLogger.i(
      '[GoogleDrive][Download] connect-done account=${_maskAccount(account)}',
    );

    AppLogger.d('[GoogleDrive][Download] auth-start');
    final headers = await _authorizationHeaders(account);
    AppLogger.d('[GoogleDrive][Download] auth-done');
    final client = http.Client();
    try {
      final downloadUri = Uri.https(
        'www.googleapis.com',
        '/drive/v3/files/$fileId',
        const {'alt': 'media'},
      );
      final request = http.Request('GET', downloadUri);
      request.headers.addAll(headers);

      onProgress?.call(0, 0, 'Google Drive에서 내려받는 중');
      final response = await client.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await response.stream.bytesToString();
        throw StateError(
          'Google Drive 다운로드 실패: ${response.statusCode} $body',
        );
      }

      await destination.parent.create(recursive: true);
      final sink = destination.openWrite();
      try {
        await response.stream.pipe(sink);
      } finally {
        await sink.close();
      }
      onProgress?.call(1, 1, 'Google Drive 다운로드 완료');
      return destination;
    } finally {
      client.close();
    }
  }

  Future<void> deleteFile(String fileId) async {
    AppLogger.i('[GoogleDrive][Delete] connect-start fileId=$fileId');
    final account = await connect();
    if (account == null) {
      throw StateError('Google Drive 연결이 필요합니다.');
    }
    AppLogger.i(
      '[GoogleDrive][Delete] connect-done account=${_maskAccount(account)}',
    );

    AppLogger.d('[GoogleDrive][Delete] auth-start');
    final headers = await _authorizationHeaders(account);
    AppLogger.d('[GoogleDrive][Delete] auth-done');
    final client = http.Client();
    try {
      final deleteUri = Uri.https(
        'www.googleapis.com',
        '/drive/v3/files/$fileId',
      );
      final request = http.Request('DELETE', deleteUri);
      request.headers.addAll(headers);

      final response = await client.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await response.stream.bytesToString();
        if (response.statusCode == 404) {
          AppLogger.w(
            '[GoogleDrive][Delete] not-found fileId=$fileId body=$body',
          );
          return;
        }
        throw StateError(
          'Google Drive 삭제 실패: ${response.statusCode} $body',
        );
      }
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>?> fetchFileMetadata(String fileId) async {
    AppLogger.d('[GoogleDrive][Meta] connect-start fileId=$fileId');
    final account = await connect();
    if (account == null) {
      throw StateError('Google Drive 연결이 필요합니다.');
    }
    AppLogger.d(
        '[GoogleDrive][Meta] connect-done account=${_maskAccount(account)}');

    AppLogger.d('[GoogleDrive][Meta] auth-start');
    final headers = await _authorizationHeaders(account);
    AppLogger.d('[GoogleDrive][Meta] auth-done');
    final client = http.Client();
    try {
      final uri = Uri.https(
        'www.googleapis.com',
        '/drive/v3/files/$fileId',
        const {
          'fields': 'id,name,mimeType,trashed,parents',
        },
      );
      final response = await client.get(uri, headers: headers);
      if (response.statusCode == 404) return null;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Google Drive 메타데이터 조회 실패: ${response.statusCode} ${response.body}',
        );
      }
      return _asMap(response.body);
    } finally {
      client.close();
    }
  }

  Future<String> _ensureFolderPath(
    GoogleSignInAccount account,
    Map<String, String> headers,
    List<String> folderSegments,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    var currentParentId = await _ensureRootFolder(account, headers, prefs);
    if (folderSegments.isEmpty) {
      return currentParentId;
    }

    var currentPath = <String>[_folderName];
    for (final segment in folderSegments) {
      currentPath = [...currentPath, segment];
      currentParentId = await _ensureChildFolder(
        account: account,
        headers: headers,
        prefs: prefs,
        parentId: currentParentId,
        folderName: segment,
        folderPath: currentPath,
      );
    }
    return currentParentId;
  }

  List<String> _folderSegmentsForStoragePath(String storagePath) {
    final segments =
        storagePath.split('/').where((segment) => segment.isNotEmpty).toList();
    if (segments.length <= 1) {
      return const [];
    }
    return segments.sublist(0, segments.length - 1);
  }

  Future<String> _ensureRootFolder(
    GoogleSignInAccount account,
    Map<String, String> headers,
    SharedPreferences prefs,
  ) async {
    final cacheKey = '${_folderCacheKeyPrefix}_${_accountKey(account)}_root';
    final cachedFolderId = prefs.getString(cacheKey);
    if (cachedFolderId != null && cachedFolderId.isNotEmpty) {
      AppLogger.d(
        '[GoogleDrive][Folder] cache-hit account=${_maskAccount(account)} folderId=$cachedFolderId',
      );
      final metadata = await fetchFileMetadata(cachedFolderId);
      if (metadata != null &&
          metadata['mimeType'] == 'application/vnd.google-apps.folder' &&
          metadata['trashed'] != true) {
        return cachedFolderId;
      }
    }

    final folderId = await _findOrCreateFolder(
      account: account,
      headers: headers,
      prefs: prefs,
      parentId: 'root',
      folderName: _folderName,
      folderPath: const ['Parrokit'],
    );
    await prefs.setString(cacheKey, folderId);
    return folderId;
  }

  Future<String> _ensureChildFolder({
    required GoogleSignInAccount account,
    required Map<String, String> headers,
    required SharedPreferences prefs,
    required String parentId,
    required String folderName,
    required List<String> folderPath,
  }) async {
    final cacheKey =
        '${_folderCacheKeyPrefix}_${_accountKey(account)}_${folderPath.join('__')}';
    final cachedFolderId = prefs.getString(cacheKey);
    if (cachedFolderId != null && cachedFolderId.isNotEmpty) {
      AppLogger.d(
        '[GoogleDrive][Folder] cache-hit account=${_maskAccount(account)} folderId=$cachedFolderId',
      );
      final metadata = await fetchFileMetadata(cachedFolderId);
      if (metadata != null &&
          metadata['mimeType'] == 'application/vnd.google-apps.folder' &&
          metadata['trashed'] != true) {
        return cachedFolderId;
      }
    }

    final folderId = await _findOrCreateFolder(
      account: account,
      headers: headers,
      prefs: prefs,
      parentId: parentId,
      folderName: folderName,
      folderPath: folderPath,
    );
    await prefs.setString(cacheKey, folderId);
    return folderId;
  }

  Future<String> _findOrCreateFolder({
    required GoogleSignInAccount account,
    required Map<String, String> headers,
    required SharedPreferences prefs,
    required String parentId,
    required String folderName,
    required List<String> folderPath,
  }) async {
    final existing = await _findFolderByName(
      parentId: parentId,
      folderName: folderName,
      headers: headers,
    );
    if (existing != null) {
      AppLogger.d(
        '[GoogleDrive][Folder] reuse account=${_maskAccount(account)} path=${folderPath.join('/')} folderId=$existing',
      );
      return existing;
    }

    final client = http.Client();
    try {
      AppLogger.d(
        '[GoogleDrive][Folder] create-start account=${_maskAccount(account)} path=${folderPath.join('/')}',
      );
      final createUri = Uri.https(
        'www.googleapis.com',
        '/drive/v3/files',
        const {'fields': 'id,name'},
      );
      final request = http.Request('POST', createUri);
      request.headers.addAll(headers);
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.body = jsonEncode({
        'name': folderName,
        'mimeType': 'application/vnd.google-apps.folder',
        'parents': [parentId],
      });

      final response = await client.send(request);
      final body = await response.stream.bytesToString();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Google Drive 폴더 생성 실패: ${response.statusCode} $body',
        );
      }

      final data = _asMap(body);
      final folderId = data['id'] as String? ?? '';
      if (folderId.isEmpty) {
        throw StateError('Google Drive 폴더 ID를 받지 못했습니다.');
      }

      await prefs.setString(
        '${_folderCacheKeyPrefix}_${_accountKey(account)}_${folderPath.join('__')}',
        folderId,
      );
      AppLogger.i(
        '[GoogleDrive][Folder] ready account=${_maskAccount(account)} path=${folderPath.join('/')} folderId=$folderId',
      );
      return folderId;
    } finally {
      client.close();
    }
  }

  Future<String?> _findFolderByName({
    required String parentId,
    required String folderName,
    required Map<String, String> headers,
  }) async {
    final client = http.Client();
    try {
      final query = [
        "mimeType = 'application/vnd.google-apps.folder'",
        "trashed = false",
        "name = '${_escapeDriveQuery(folderName)}'",
        "'$parentId' in parents",
      ].join(' and ');
      final uri = Uri.https(
        'www.googleapis.com',
        '/drive/v3/files',
        const {'fields': 'files(id,name,parents)'},
      ).replace(queryParameters: {
        'q': query,
        'fields': 'files(id,name,parents)',
        'pageSize': '1',
      });
      final response = await client.get(uri, headers: headers);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final data = _asMap(response.body);
      final files = data['files'];
      if (files is! List || files.isEmpty) return null;
      final first = files.first;
      if (first is! Map<String, dynamic>) return null;
      return first['id'] as String?;
    } finally {
      client.close();
    }
  }

  Future<Map<String, String>> _authorizationHeaders(
    GoogleSignInAccount account,
  ) async {
    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Google Drive access token을 받을 수 없습니다.');
    }

    return {
      'Authorization': 'Bearer $accessToken',
    };
  }

  Map<String, dynamic> _asMap(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }

  Uint8List _utf8Bytes(String value) => Uint8List.fromList(utf8.encode(value));

  String _accountKey(GoogleSignInAccount account) {
    if (account.email.isNotEmpty) return account.email;
    return 'unknown';
  }

  String _escapeDriveQuery(String value) {
    return value.replaceAll('\\', r'\\').replaceAll("'", r"\'");
  }

  String _maskAccount(GoogleSignInAccount account) {
    final email = account.email;
    if (email.isEmpty) return 'unknown';
    final atIndex = email.indexOf('@');
    if (atIndex <= 1) return email;
    return '${email.substring(0, 2)}***${email.substring(atIndex)}';
  }

  String _maskFileName(String fileName) {
    if (fileName.length <= 12) return fileName;
    return '${fileName.substring(0, 8)}...${fileName.substring(fileName.length - 4)}';
  }
}
