import 'package:hive/hive.dart';

class FavoritesManager
{
  static Box _box;

  static List<dynamic> getAll() => _box.get("list");

  static Future<void> add(dynamic value) => _box.put("list", [ ...getAll(), value ]);

  static Future<void> delete(dynamic value) async {
    final List<dynamic> favorites = getAll();

    favorites.remove(value);

    await _box.put("list", getAll());
  }

  static Future<void> empty() async {
    await _box.deleteFromDisk();

    await FavoritesManager.initialize();
  }

  static Future<void> initialize() async => _box = await Hive.openBox("favorites");
}