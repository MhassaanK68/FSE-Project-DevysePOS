import 'package:uuid/uuid.dart';

class UUIDGenerator {
  static const Uuid _uuid = Uuid();

  static String generate() => _uuid.v4();
}
