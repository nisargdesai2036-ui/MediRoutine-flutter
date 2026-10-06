class Userlogin
{
  final String email;
  final String password;

  Userlogin({required this.email, required this.password});

  factory Userlogin.fromJson(Map<String, dynamic> json) {
    return Userlogin(
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

typedef UserLogin = Userlogin;