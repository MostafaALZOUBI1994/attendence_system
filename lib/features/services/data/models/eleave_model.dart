class EleaveModel {
  final String noOfHrsAllowed;
  final String noOfHrsAvailable;
  final String noOfHrsUtilized;
  final String noOfHrsPending;

  EleaveModel({
    required this.noOfHrsAllowed,
    required this.noOfHrsAvailable,
    required this.noOfHrsUtilized,
    required this.noOfHrsPending,
  });

  factory EleaveModel.fromJson(Map<String, dynamic> json) {
    return EleaveModel(
      noOfHrsAllowed: json['NoOfHrsAllowed'],
      noOfHrsAvailable: json['NoOfHrsAvailable'],
      noOfHrsUtilized: json['NoOfHrsUtilized'],
      noOfHrsPending: json['NoOfHrsPending'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NoOfHrsAllowed': noOfHrsAllowed,
      'NoOfHrsAvailable': noOfHrsAvailable,
      'NoOfHrsUtilized': noOfHrsUtilized,
      'NoOfHrsPending': noOfHrsPending,
    };
  }
}