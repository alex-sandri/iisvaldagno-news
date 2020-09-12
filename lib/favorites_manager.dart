import 'package:hive/hive.dart';
import 'package:iisvaldagno_news/serializable_news.dart';

class FavoritesManager
{
  static Box _box;

  static List<SerializableNews> getAll() => _box.get("list");

  static Future<void> add(SerializableNews value) => _box.put("list", [ ...getAll(), value ]);

  static Future<void> delete(SerializableNews value) async {
    final List<SerializableNews> favorites = getAll();

    favorites.remove(value);

    await _box.put("list", getAll());
  }

  static Future<void> empty() async {
    await _box.deleteFromDisk();

    await FavoritesManager.initialize();
  }

  static Future<void> initialize() async => _box = await Hive.openBox("favorites");
}