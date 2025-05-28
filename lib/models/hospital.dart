import 'evaluation_report.dart';

class Hospital{
  int id;
  String name;
  double latitude;
  double longitude;
  String address;
  int phoneNumber;
  String? email;
  String district;
  bool hasEmergency;
  List<EvaluationReport> reports = [];
  Hospital({required this.id, required this.name, required this.latitude,required this.longitude,required this.address,
    required this.phoneNumber,required this.email,required this.district,required this.hasEmergency ,required this.reports});

  factory Hospital.fromMap(Map<String,dynamic> map){
    
    return Hospital(
        id: map["Id"],
        name:map["Name"],
        latitude: map["Latitude"],
        longitude: map["Longitude"],
        address: map["Address"],
        phoneNumber: map["Phone"],
        email: map["Email"],
        district: map["District"],
        hasEmergency: map["HasEmergency"],
        reports: []);
    
  }
  factory Hospital.fromDB(Map<String, dynamic> db) {
    return Hospital(
      id: db["id"],
      name: db["name"],
      latitude: db["latitude"] * 1.0,
      longitude: db["longitude"] * 1.0,
      address: db["address"],
      phoneNumber: db["phoneNumber"],
      email: db["email"],
      district: db["district"],
      hasEmergency: db["hasEmergency"] == 1, // <-- FIXED
      reports: [],
    );
  }




}