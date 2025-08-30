import 'package:todoapp/util/share_message_handler.dart';

class FakeShareMessageHandler extends ShareMessageHandler {
  @override
  Future<bool> share({required String text, required String title}) {
    return Future.value(true);
  }
}
