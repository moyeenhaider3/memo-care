import 'package:drift/drift.dart';

/// Converts [DateTime] to/from UTC epoch milliseconds (int).
///
/// All times in the database are stored as UTC epoch millis (P-10).
class DateTimeConverter extends TypeConverter<DateTime, int> {
  const DateTimeConverter();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}
