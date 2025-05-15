class TodayStatus {
  final List<int> offSiteCheckIns;
  final String   checkInTime;
  final String   delay;
  final String   expectedOutTime;
  final String   outTime;
  final String   punchInOffice;

  const TodayStatus({
    this.offSiteCheckIns   = const [],
    this.checkInTime        = '--:--',
    this.delay              = '--:--',
    this.expectedOutTime    = '--:--',
    this.outTime    = '--:--',
    this.punchInOffice    = '--:--',
  });
}