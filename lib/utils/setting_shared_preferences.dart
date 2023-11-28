import 'package:shared_preferences/shared_preferences.dart';

class SettingSharedPreferences {
  static SharedPreferences? _preferences;

  static const String urlServer = 'url_server';
  static const String namaWarung = 'nama_warung';
  static const String alamatWarung = 'alamat_warung';
  static const String lastIdKas = 'last_id_kas';

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setSetting({
    required String urlStr,
    required String namaWarungStr,
    required String alamatWarungStr,
  }) async {
    await _preferences!.setString(urlServer, urlStr);
    await _preferences!.setString(namaWarung, namaWarungStr);
    await _preferences!.setString(alamatWarung, alamatWarungStr);
  }

  static Future setLastIdKas(int id) async {
    await _preferences!.setInt(lastIdKas, id);
  }

  static String? getUrlServer() => _preferences!.getString(urlServer);

  static String? getNamaWarung() => _preferences!.getString(namaWarung);

  static String? getAlamatWarung() => _preferences!.getString(alamatWarung);

  static int? getLastIdKas() => _preferences!.getInt(lastIdKas);
}
