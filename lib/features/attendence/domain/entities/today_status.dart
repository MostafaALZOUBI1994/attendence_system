class TodayStatus {
  final List<int> offSiteCheckIns;
  final String   checkInTime;
  final String   delay;
  final String   expectedOutTime;
  final String   outTime;
  final String   punchInOffice;

  const TodayStatus({
    this.offSiteCheckIns   = const [],
    this.checkInTime        = '00:00',
    this.delay              = '00:00',
    this.expectedOutTime    = '00:00',
    this.outTime    = '00:00',
    this.punchInOffice    = '00:00',
  });
}