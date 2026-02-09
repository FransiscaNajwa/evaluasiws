class TargetData {
  final int? id;
  final String pelayaran;
  final String kodeWS;
  final String periode; // Week 1, Week 2, etc.
  final String waktuBerthing; // TB - ISO8601 format
  final String waktuDeparture; // TD - ISO8601 format
  final String berthingTime; // BT - calculated HH:mm:ss
  final int targetBongkar;
  final int targetMuat;
  final String createdAt; // ISO8601 format

  TargetData({
    this.id,
    required this.pelayaran,
    required this.kodeWS,
    required this.periode,
    required this.waktuBerthing,
    required this.waktuDeparture,
    required this.berthingTime,
    required this.targetBongkar,
    required this.targetMuat,
    required this.createdAt,
  });

  // Convert TargetData object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pelayaran': pelayaran,
      'kodeWS': kodeWS,
      'periode': periode,
      'waktuBerthing': waktuBerthing,
      'waktuDeparture': waktuDeparture,
      'berthingTime': berthingTime,
      'targetBongkar': targetBongkar,
      'targetMuat': targetMuat,
      'createdAt': createdAt,
    };
  }

  // Convert Map to TargetData object
  factory TargetData.fromMap(Map<String, dynamic> map) {
    return TargetData(
      id: map['id'],
      pelayaran: map['pelayaran'],
      kodeWS: map['kodeWS'],
      periode: map['periode'],
      waktuBerthing: map['waktuBerthing'],
      waktuDeparture: map['waktuDeparture'],
      berthingTime: map['berthingTime'],
      targetBongkar: map['targetBongkar'],
      targetMuat: map['targetMuat'],
      createdAt: map['createdAt'],
    );
  }

  // For JSON compatibility
  Map<String, dynamic> toJson() => toMap();
}
