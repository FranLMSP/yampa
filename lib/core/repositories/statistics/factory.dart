import 'package:yampa/core/repositories/statistics/statistics.dart';
import 'package:yampa/core/repositories/statistics/statistics_sqlite.dart';

StatisticsRepository getStatisticsRepository() {
  return StatisticsSqlite();
}
