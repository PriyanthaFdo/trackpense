// Downloads the files Drift needs to run on the web into web/:
//   - web/drift_worker.js  from the drift release matching pubspec.lock
//   - web/sqlite3.wasm     from the sqlite3 release matching pubspec.lock
//
// Run from the project root:
//   fvm dart run tool/setup_web_db.dart          download or update the files
//   fvm dart run tool/setup_web_db.dart --check  only verify them (exit code 1 if out of date)
//
// Run it after recreating web/ (flutter create --platforms=web .) and after
// upgrading drift or sqlite3. Commit the updated files.
import 'dart:io';
import 'dart:typed_data';

Future<void> main(List<String> args) async {
  final checkOnly = args.contains('--check');

  final lockFile = File('pubspec.lock');
  if (!lockFile.existsSync()) {
    _fail('pubspec.lock not found. Run this from the project root after `flutter pub get`.');
  }
  final lock = lockFile.readAsStringSync().replaceAll('\r\n', '\n');
  final driftVersion = _lockedVersion(lock, 'drift');
  final sqlite3Version = _lockedVersion(lock, 'sqlite3');

  final files = [
    _WebDbFile(
      path: 'web/drift_worker.js',
      source: 'drift $driftVersion',
      url: 'https://github.com/simolus3/drift/releases/download/drift-$driftVersion/drift_worker.js',
      isValid: (bytes) => bytes.length > 1000 && bytes.first != '<'.codeUnitAt(0),
    ),
    _WebDbFile(
      path: 'web/sqlite3.wasm',
      source: 'sqlite3 $sqlite3Version',
      url: 'https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-$sqlite3Version/sqlite3.wasm',
      // Every WebAssembly module starts with the magic bytes "\0asm".
      isValid: (bytes) => bytes.length > 4 && bytes[0] == 0x00 && bytes[1] == 0x61 && bytes[2] == 0x73 && bytes[3] == 0x6d,
    ),
  ];

  var outOfDate = 0;
  final client = HttpClient();
  try {
    for (final file in files) {
      final expected = await _download(client, file.url);
      if (!file.isValid(expected)) {
        _fail('Downloaded ${file.url} but it does not look like a valid ${file.path}.');
      }

      final target = File(file.path);
      if (target.existsSync() && _sameBytes(target.readAsBytesSync(), expected)) {
        stdout.writeln('OK       ${file.path} matches ${file.source}');
      } else if (checkOnly) {
        stdout.writeln('OUTDATED ${file.path} does not match ${file.source}');
        outOfDate++;
      } else {
        target.writeAsBytesSync(expected);
        stdout.writeln('UPDATED  ${file.path} -> ${file.source}');
      }
    }
  } finally {
    client.close();
  }

  if (outOfDate > 0) {
    stderr.writeln('\n$outOfDate file(s) out of date. Run `fvm dart run tool/setup_web_db.dart` and commit the result.');
    exit(1);
  }
}

class _WebDbFile {
  const _WebDbFile({
    required this.path,
    required this.source,
    required this.url,
    required this.isValid,
  });

  final String path;
  final String source;
  final String url;
  final bool Function(Uint8List bytes) isValid;
}

/// Reads the resolved version of [package] from the contents of pubspec.lock.
String _lockedVersion(String lock, String package) {
  final match = RegExp('^  $package:\\n(?:    .*\\n)*?    version: "([^"]+)"', multiLine: true).firstMatch(lock);
  if (match == null) {
    _fail('Could not find the version of `$package` in pubspec.lock.');
  }
  return match.group(1)!;
}

Future<Uint8List> _download(HttpClient client, String url) async {
  final request = await client.getUrl(Uri.parse(url));
  final response = await request.close();
  if (response.statusCode != HttpStatus.ok) {
    _fail('Download failed (HTTP ${response.statusCode}): $url');
  }
  final builder = BytesBuilder(copy: false);
  await response.forEach(builder.add);
  return builder.takeBytes();
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

Never _fail(String message) {
  stderr.writeln('ERROR: $message');
  exit(1);
}
