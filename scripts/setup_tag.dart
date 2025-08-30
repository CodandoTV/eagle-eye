import 'dart:io';

void main() {
  final githubRef = Platform.environment['GITHUB_REF'];
  if (githubRef == null) {
    stderr.writeln('Error: GITHUB_REF not found');
    exit(1);
  }

  var tag = _formatTag(githubRef);
  print('Using tag $tag');

  _replaceTagInPubspec(tag);
  print('pubspec.yaml updated successfully.');
}

String _formatTag(String githubRef) {
  return githubRef.replaceFirst('refs/tags/', '').replaceAll('v', '');
}

void _replaceTagInPubspec(String version) {
  final pubspecFile = File('pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    stderr.writeln('Error: pubspec.yaml not found');
    exit(1);
  }

  var content = pubspecFile.readAsStringSync();

  final updated = content.replaceFirst(
    RegExp(
      r'^version:.*',
      multiLine: true,
    ),
    'version: $version+1',
  );

  pubspecFile.writeAsStringSync(updated);
}
