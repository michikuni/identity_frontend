/// Format date/datetime helpers — parse on display only, never mutate
/// data sent to/from backend.
///
/// All user-facing timestamps in TrustID use:
///   dd-MM-yyyy - HH:mm:ss   (full)
///   dd-MM-yyyy              (date only)
///   HH:mm:ss                (time only)
library;

/// Parses [iso] (any DateTime.parse-compatible string) and returns
/// "dd-MM-yyyy - HH:mm:ss" in the device's local time zone.
/// Returns empty string when [iso] is null/empty, or the original
/// string when it cannot be parsed.
String formatDateTime(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return formatDateTimeOf(dt);
}

/// Same as [formatDateTime] but for an already-parsed [DateTime].
String formatDateTimeOf(DateTime dt) {
  final local = dt.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final m = local.month.toString().padLeft(2, '0');
  final y = local.year.toString().padLeft(4, '0');
  final h = local.hour.toString().padLeft(2, '0');
  final min = local.minute.toString().padLeft(2, '0');
  final s = local.second.toString().padLeft(2, '0');
  return '$d-$m-$y - $h:$min:$s';
}

/// "dd-MM-yyyy" — for fields where only the date matters (e.g. start
/// date of contract, day on a calendar cell).
String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return formatDateOf(dt);
}

String formatDateOf(DateTime dt) {
  final local = dt.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final m = local.month.toString().padLeft(2, '0');
  final y = local.year.toString().padLeft(4, '0');
  return '$d-$m-$y';
}

/// "HH:mm:ss" — clock-only display (e.g. live current time).
String formatTimeOf(DateTime dt) {
  final local = dt.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  final s = local.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}

/// "HH:mm" — used by attendance rows where seconds add noise.
String formatHm(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  final local = dt.toLocal();
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
