import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  static const String defaultThemeKey = 'classic';
  static const String defaultFanTeamKey = 'galatasaray';

  Id id = Isar.autoIncrement;

  // Uygulama genelinde kullanilan temel profil bilgileri.
  late String firstName;
  late String lastName;

  DateTime? birthDate;
  String? email;
  String fanTeamKey = defaultFanTeamKey;
  String? phone;
  String themeKey = defaultThemeKey;
  // Profil fotografi su an veritabani icinde byte olarak tutulur.
  List<int>? photoBytes;

  late DateTime createdAt;
  DateTime? updatedAt;
}
