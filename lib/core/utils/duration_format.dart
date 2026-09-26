/// Durée en secondes au format « m:ss » : 90 → `'1:30'`, 45 → `'0:45'`.
/// Au-delà d'une heure : « h:mm:ss ».
String formatDuration(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
  }
  return '$minutes:$seconds';
}
