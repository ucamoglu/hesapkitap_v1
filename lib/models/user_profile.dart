import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  // Uygulama genelinde kullanilan temel profil bilgileri.
  late String firstName;
  late String lastName;

  DateTime? birthDate;
  String? email;
  String? phone;
  // Profil fotografi su an veritabani icinde byte olarak tutulur.
  List<int>? photoBytes;

  late DateTime createdAt;
  DateTime? updatedAt;
}
