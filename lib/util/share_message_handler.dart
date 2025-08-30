import 'package:injectable/injectable.dart';
import 'package:share_plus/share_plus.dart';

abstract class ShareMessageHandler {
  Future<bool> share({
    required String text,
    required String title,
  });
}

@Injectable(as: ShareMessageHandler)
class SharePlusWrapper implements ShareMessageHandler {
  @override
  Future<bool> share({required String text, required String title}) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        text: text,
        title: title,
      ),
    );

    if (result.status == ShareResultStatus.success) {
      return true;
    } else {
      return false;
    }
  }
}
