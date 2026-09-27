/// Un point d'une courbe : une valeur à une date.
class ChartPoint {
  const ChartPoint(this.date, this.value);

  final DateTime date;
  final double value;

  @override
  String toString() => 'ChartPoint($date, $value)';
}
