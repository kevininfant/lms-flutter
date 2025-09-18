class User {
  final String id;
  final String email;
  final String? token;
  final String? name;
  final int? imagecode;
  final int? age;
  final String? gender;
  final String? type;
  final String? dob;
  final String? mobile;
  final String? address;

  User({
    required this.id,
    required this.email,
    this.token,
    this.name,
    this.imagecode,
    this.age,
    this.gender,
    this.type,
    this.dob,
    this.mobile,
    this.address,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      token: json['token'],
      name: json['name'],
      imagecode: json['imagecode'],
      age: json['age'],
      gender: json['gender'],
      type: json['type'],
      dob: json['dob'],
      mobile: json['mobile'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'token': token,
      'name': name,
      'imagecode': imagecode,
      'age': age,
      'gender': gender,
      'type': type,
      'dob': dob,
      'mobile': mobile,
      'address': address,
    };
  }
}