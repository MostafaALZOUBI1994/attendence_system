// Adds copyWith to your non-Freezed TodayStatus entity without modifying it.
import 'today_status.dart';

extension TodayStatusX on TodayStatus {
  TodayStatus copyWith({
    String? checkInTime,
    String? delay,
    String? expectedOutTime,
    String? outTime,
    String? punchInOffice,
    List<int>? offSiteCheckIns,
  }) {
    return TodayStatus(
      checkInTime: checkInTime ?? this.checkInTime,
      delay: delay ?? this.delay,
      expectedOutTime: expectedOutTime ?? this.expectedOutTime,
      outTime: outTime ?? this.outTime,
      punchInOffice: punchInOffice ?? this.punchInOffice,
      offSiteCheckIns: offSiteCheckIns ?? this.offSiteCheckIns,
    );
  }
}