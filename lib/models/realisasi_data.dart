class RealisasiData {
  final int? id;
  final String pelayaran;
  final String kodeWS;
  final String namaKapal;
  final String periode; // Week 1, Week 2, etc.
  final String waktuArrival; // TA - ISO8601 format
  final String waktuBerthing; // TB - ISO8601 format
  final String waktuDeparture; // TD - ISO8601 format
  final String berthingTime; // BT - calculated HH:mm:ss
  final int realisasiBongkar;
  final int realisasiMuat;
  final String createdAt; // ISO8601 format

  RealisasiData({
    this.id,
    required this.pelayaran,
    required this.kodeWS,
    required this.namaKapal,
    required this.periode,
    required this.waktuArrival,
    required this.waktuBerthing,
    required this.waktuDeparture,
    required this.berthingTime,
    required this.realisasiBongkar,
    required this.realisasiMuat,
    required this.createdAt,
  });

  // Convert RealisasiData object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pelayaran': pelayaran,
      'kodeWS': kodeWS,
      'namaKapal': namaKapal,
      'periode': periode,
      'waktuArrival': waktuArrival,
      'waktuBerthing': waktuBerthing,
      'waktuDeparture': waktuDeparture,
      'berthingTime': berthingTime,
      'realisasiBongkar': realisasiBongkar,
      'realisasiMuat': realisasiMuat,
      'createdAt': createdAt,
    };
  }

  // Convert Map to RealisasiData object
  factory RealisasiData.fromMap(Map<String, dynamic> map) {
    return RealisasiData(
      id: map['id'],
      pelayaran: map['pelayaran'],
      kodeWS: map['kodeWS'],
      namaKapal: map['namaKapal'],
      periode: map['periode'],
      waktuArrival: map['waktuArrival'],
      waktuBerthing: map['waktuBerthing'],
      waktuDeparture: map['waktuDeparture'],
      berthingTime: map['berthingTime'],
      realisasiBongkar: map['realisasiBongkar'],
      realisasiMuat: map['realisasiMuat'],
      createdAt: map['createdAt'],
    );
  }

  // For JSON compatibility
  Map<String, dynamic> toJson() => toMap();
}
