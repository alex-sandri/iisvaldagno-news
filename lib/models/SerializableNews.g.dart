// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SerializableNews.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SerializableNewsAdapter extends TypeAdapter<SerializableNews> {
  @override
  final int typeId = 0;

  @override
  SerializableNews read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SerializableNews(
      title: fields[0] as String,
      link: fields[1] as String,
      content: fields[2] as String,
      categories: (fields[3] as List)?.cast<String>(),
      creator: fields[4] as String,
      pubDate: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SerializableNews obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.link)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.categories)
      ..writeByte(4)
      ..write(obj.creator)
      ..writeByte(5)
      ..write(obj.pubDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SerializableNewsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
