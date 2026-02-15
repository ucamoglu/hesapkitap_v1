import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  late String firstName;
  late String lastName;

  DateTime? birthDate;
  String? email;
  String? phone;
  List<int>? photoBytes;

  late DateTime createdAt;
  DateTime? updatedAt;
}
