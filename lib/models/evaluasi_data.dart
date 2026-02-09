class EvaluasiData {
  final int? id;
  final String tanggal;
  final String shift;
  final String kapal;
  final String pelayaran;
  final int targetBongkar;
  final int realisasiBongkar;
  final int targetMuat;
  final int realisasiMuat;
  final double persenBongkar;
  final double persenMuat;
  final String keterangan;

  EvaluasiData({
    this.id,
    required this.tanggal,
    required this.shift,
    required this.kapal,
    required this.pelayaran,
    required this.targetBongkar,
    required this.realisasiBongkar,
    required this.targetMuat,
    required this.realisasiMuat,
    required this.persenBongkar,
    required this.persenMuat,
    required this.keterangan,
  });

  // Convert EvaluasiData object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'shift': shift,
      'kapal': kapal,
      'pelayaran': pelayaran,
      'targetBongkar': targetBongkar,
      'realisasiBongkar': realisasiBongkar,
      'targetMuat': targetMuat,
      'realisasiMuat': realisasiMuat,
      'persenBongkar': persenBongkar,
      'persenMuat': persenMuat,
      'keterangan': keterangan,
    };
  }

  // Convert Map to EvaluasiData object
  factory EvaluasiData.fromMap(Map<String, dynamic> map) {
    return EvaluasiData(
      id: map['id'],
      tanggal: map['tanggal'],
      shift: map['shift'],
      kapal: map['kapal'],
      pelayaran: map['pelayaran'],
      targetBongkar: map['targetBongkar'],
      realisasiBongkar: map['realisasiBongkar'],
      targetMuat: map['targetMuat'],
      realisasiMuat: map['realisasiMuat'],
      persenBongkar: map['persenBongkar'],
      persenMuat: map['persenMuat'],
      keterangan: map['keterangan'],
    );
  }

  // For backward compatibility with existing code
  Map<String, dynamic> toJson() => toMap();
}
