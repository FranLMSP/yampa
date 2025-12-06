import 'package:yampa/core/repositories/statistics/statistics.dart';
import 'package:yampa/core/repositories/statistics/statistics_sqlite.dart';

StatisticsRepository? _statisticsRepository;

Future<StatisticsRepository> getStatisticsRepository() async {
  _statisticsRepository ??= StatisticsSqlite();
  return _statisticsRepository!;
}
