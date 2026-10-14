// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_share.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseShareAdapter extends TypeAdapter<ExpenseShare> {
  @override
  final int typeId = 3;

  @override
  ExpenseShare read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseShare(
      id: fields[0] as String,
      expenseId: fields[1] as String,
      memberId: fields[2] as String,
      shareAmount: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseShare obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.expenseId)
      ..writeByte(2)
      ..write(obj.memberId)
      ..writeByte(3)
      ..write(obj.shareAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseShareAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
