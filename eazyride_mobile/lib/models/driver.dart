class Driver {
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String countryCode;

  Driver({
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.countryCode,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'gender': gender,
    'countryCode': countryCode,
  };
}
