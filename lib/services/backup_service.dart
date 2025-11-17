import 'dart:convert';
import 'dart:io' show File, Directory, Platform;
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive.dart' as a;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:restart_app/restart_app.dart';

class BackupService {
  BackupService._internal();

  static final BackupService instance = BackupService._internal();
  final String dbRelativePath = 'paro.db';
  final String mediaRelativeDir = '';

  Future<Directory> _appDocDir() async =>
      await getApplicationDocumentsDirectory();

  /// DB 파일 경로 및 생성
  Future<File> _dbFile() async {
    final dir = await _appDocDir();
    final f = File(p.join(dir.path, dbRelativePath));
    await f.parent.create(recursive: true);
    return f;
  }

  /// Media 디렉터리 및 경로 생성
  Future<Directory> _mediaDir() async {
    final dir = await _appDocDir();
    final d = Directory(p.join(dir.path, mediaRelativeDir));
    await d.create(recursive: true);
    return d;
  }

  /// 파일 백업 시 무결성 검증
  Future<String> _sha256OfFile(File f) async {
    if (!await f.exists()) return '';
    final digest = await sha256.bind(f.openRead()).first;
    return digest.toString();
  }

  /// 백업 파일 생성
  Future<File> createBackup() async {
    final appDir = await _appDocDir();
    final db = await _dbFile();
    final media = await _mediaDir();

    final ts = DateTime.now();

    // 기존 backup_*.zip 정리
    await for (final ent in appDir.list(recursive: false, followLinks: false)) {
      if (ent is File && p.basename(ent.path).startsWith('backup_')) {
        try {
          await ent.delete();
        } catch (_) {}
      }
    }

    final name =
        'backup_${ts.year}${_2(ts.month)}${_2(ts.day)}_${_2(ts.hour)}${_2(ts.minute)}${_2(ts.second)}.zip';
    final backupZip = File(p.join(appDir.path, name));

    final encoder = ZipFileEncoder();
    encoder.create(backupZip.path);

    // 1) DB 추가 — zip 내부 경로를 명시
    if (await db.exists()) {
      encoder.addFile(db, dbRelativePath); // << 변경
    }

    // 2) media 재귀 추가 — 자기 자신(zip)과 manifest.json 제외 (중요)
    if (await media.exists()) {
      await for (final ent in media.list(recursive: true, followLinks: false)) {
        if (ent is! File) continue;

        final base = p.basename(ent.path);
        // 자기 자신(zip) 또는 manifest 제외
        if (base == name ||
            base == 'manifest.json' ||
            base.startsWith('backup_')) {
          continue;
        }

        final rel =
            p.relative(ent.path, from: media.path).replaceAll('\\', '/');
        final inZip = p.join(mediaRelativeDir, rel).replaceAll('\\', '/');
        encoder.addFile(ent, inZip);
      }
    }

    // 3) manifest entries
    final entries = <Map<String, dynamic>>[];

    // DB 엔트리
    if (await db.exists()) {
      entries.add({
        'path': dbRelativePath,
        'sha256': await _sha256OfFile(db),
        'bytes': await db.length(),
      });
    }

    // media 엔트리 — 위와 동일한 제외 규칙 적용 (중요)
    if (await media.exists()) {
      await for (final ent in media.list(recursive: true, followLinks: false)) {
        if (ent is! File) continue;

        final base = p.basename(ent.path);
        if (base == name ||
            base == 'manifest.json' ||
            base.startsWith('backup_')) {
          continue;
        }

        final inZipPath = p.joinAll([
          mediaRelativeDir,
          p.relative(ent.path, from: media.path)
        ]).replaceAll('\\', '/');

        entries.add({
          'path': inZipPath,
          'sha256': await _sha256OfFile(ent),
          'bytes': await ent.length(),
        });
      }
    }

    // 4) manifest.json 추가
    final manifest = {
      'createdAt': ts.toIso8601String(),
      'db': dbRelativePath,
      'mediaDir': mediaRelativeDir,
      'entries': entries,
      'version': 1,
    };

    final manifestBytes =
        utf8.encode(const JsonEncoder.withIndent('  ').convert(manifest));

    encoder.addArchiveFile(
        a.ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));

    encoder.close();

    final saved = await _save(backupZip, name);

    // ⚠️ 외부 저장 성공 시 내부 zip 삭제는 호출부에서 하는 걸 권장
    if (saved) {
      try {
        await backupZip.delete();
      } catch (_) {}
    }

    return backupZip;
  }

  Future<bool> _save(File backupZip, String suggestedName) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final params = SaveFileDialogParams(
          sourceFilePath: backupZip.path,
          fileName: suggestedName,
        );
        final savedPath = await FlutterFileDialog.saveFile(params: params);
        return savedPath != null;
      } else {
        final bytes = await backupZip.readAsBytes();
        await FileSaver.instance.saveFile(
          name: suggestedName,
          bytes: bytes,
          mimeType: MimeType.zip,
        );
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> restoreBackup() async {
    // 1) Let user pick a .zip
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (res == null || res.files.isEmpty) return;

    final appDir = await _appDocDir();
    final zipPath = res.files.single.path!;
    final ts = DateTime.now().millisecondsSinceEpoch;

    // (옵션) 이전 임시 폴더 정리
    try {
      await for (final ent
          in appDir.list(recursive: false, followLinks: false)) {
        if (ent is Directory &&
            p.basename(ent.path).startsWith('.restore_tmp_')) {
          try {
            await ent.delete(recursive: true);
          } catch (_) {}
        }
      }
    } catch (_) {}

    // 2) Extract to temporary folder inside app directory
    final tmpDir = Directory(p.join(appDir.path, '.restore_tmp_$ts'));
    await tmpDir.create(recursive: true);

    Archive archive;
    try {
      final inputStream = InputFileStream(zipPath);
      archive = ZipDecoder().decodeStream(inputStream); // 스트리밍 파싱(메모리 절약)
      await inputStream.close();
    } catch (e) {
      try {
        await _deleteDir(tmpDir);
      } catch (_) {}
      rethrow;
    }

    // 3) 디스크로 임시 추출 (스트리밍)
    try {
      for (final file in archive) {
        final outPath = p.join(tmpDir.path, file.name);
        if (file.isFile) {
          await File(outPath).parent.create(recursive: true);
          final out = OutputFileStream(outPath);
          file.writeContent(out);
          await out.close();
        } else {
          await Directory(outPath).create(recursive: true);
        }
      }
    } catch (e) {
      try {
        await _deleteDir(tmpDir);
      } catch (_) {}
      rethrow;
    }

    // 4) manifest.json 로드 (루트 우선, 실패 시 유연 탐색)
    Future<File?> _findManifestIn(Directory root) async {
      final exact = File(p.join(root.path, 'manifest.json'));
      if (await exact.exists()) return exact;
      await for (final ent in root.list(recursive: true, followLinks: false)) {
        if (ent is File &&
            p.basename(ent.path).trim().toLowerCase() == 'manifest.json') {
          return ent;
        }
      }
      return null;
    }

    final tmpManifest = await _findManifestIn(tmpDir);
    if (tmpManifest == null) {
      try {
        await _deleteDir(tmpDir);
      } catch (_) {}
      throw StateError('Backup manifest.json not found in archive.');
    }

    Map<String, dynamic> manifestMap;
    try {
      manifestMap =
          jsonDecode(await tmpManifest.readAsString()) as Map<String, dynamic>;
    } catch (e) {
      try {
        await _deleteDir(tmpDir);
      } catch (_) {}
      throw StateError('Invalid manifest.json.');
    }

    // 5) 엔트리 해시 검증 + 경로 검사 (경로 traversal 방지)
    final List entries = manifestMap['entries'] ?? [];
    for (final e in entries) {
      final rel = (e['path'] as String?) ?? '';
      if (rel.isEmpty || p.isAbsolute(rel) || rel.contains('..')) {
        try {
          await _deleteDir(tmpDir);
        } catch (_) {}
        throw StateError('Unsafe path in manifest: $rel');
      }
      final tmpFile = File(p.join(tmpDir.path, rel));
      if (!await tmpFile.exists()) {
        try {
          await _deleteDir(tmpDir);
        } catch (_) {}
        throw StateError('Missing file from archive: $rel');
      }
      final expectedSha = (e['sha256'] as String?) ?? '';
      if (expectedSha.isNotEmpty) {
        final sha = await _sha256OfFile(tmpFile);
        if (sha != expectedSha) {
          try {
            await _deleteDir(tmpDir);
          } catch (_) {}
          throw StateError('Hash mismatch for $rel');
        }
      }
    }

    // 6) 현재 DB 백업 (있으면)
    try {
      final dbFile = await _dbFile(); // e.g., appDir/paro.db
      if (await dbFile.exists()) {
        final bakPath = '${dbFile.path}.bak_$ts';
        await dbFile.copy(bakPath);
      }
    } catch (_) {
      try {
        await _deleteDir(tmpDir);
      } catch (_) {}
      rethrow;
    }

    // 7) 임시 폴더의 파일들을 앱 디렉토리로 원자적 교체 (entries + manifest.json)
    try {
      // entries 이동/복사 (이번 tmp에 실제 존재하는 것만)
      for (final e in entries) {
        final rel = e['path'] as String;
        final src = File(p.join(tmpDir.path, rel));
        final dst = File(p.join(appDir.path, rel));

        if (!await src.exists()) {
          // 이번 tmp에 없으면 건너뜀 (구버전/누락 대비)
          continue;
        }

        await dst.parent.create(recursive: true);
        try {
          await src.rename(dst.path);
        } catch (_) {
          await src.copy(dst.path);
          try {
            await src.delete();
          } catch (_) {}
        }
      }

      // manifest.json 이동
      final dstManifest = File(p.join(appDir.path, 'manifest.json'));
      await dstManifest.parent.create(recursive: true);
      try {
        await tmpManifest.rename(dstManifest.path);
      } catch (_) {
        await tmpManifest.copy(dstManifest.path);
        try {
          await tmpManifest.delete();
        } catch (_) {}
      }

      // ✅ paro.db 보장: tmp에 없으면 archive에서 직접 추출해 복구
      final dbRel = dbRelativePath; // 예: 'paro.db'
      final dbSrc = File(p.join(tmpDir.path, dbRel));
      final dbDst = File(p.join(appDir.path, dbRel));
      if (!await dbSrc.exists()) {
        ArchiveFile? dbEntry = archive.files.firstWhere(
              (f) => f.isFile && f.name.replaceAll('\\', '/') == dbRel,
          orElse: () => null as ArchiveFile, // 강제 캐스팅
        );

        if (dbEntry != null) {
          await dbDst.parent.create(recursive: true);
          final out = OutputFileStream(dbDst.path);
          dbEntry.writeContent(out);
          await out.close();
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      // 8) 임시 폴더 정리
      try {
        await _deleteDir(tmpDir);
      } catch (_) {}
      Restart.restartApp();
    }
  }

  Future<void> _deleteDir(Directory dir) async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  String _2(int n) => n.toString().padLeft(2, '0');
}
