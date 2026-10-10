import 'package:eagle_eye/eagle_eye_launcher.dart';

void main(List<String> args) {
  final updateBaseline = args.contains('--baseline') ||
      args.contains('--update-baseline');

  EagleEyeLauncher().launchEagleEye(updateBaseline: updateBaseline);
}
