class TodayStatus {
  final List<int> offSiteCheckIns;
  final String   checkInTime;
  final String   delay;
  final String   expectedOutTime;

  const TodayStatus({
    this.offSiteCheckIns   = const [],
    this.checkInTime        = '--:--',
    this.delay              = '--:--',
    this.expectedOutTime    = '--:--',
  });
}