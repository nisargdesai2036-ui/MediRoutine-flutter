class UserUpdateRequest {
  final String? name;
  final String? email;
  final String? password;

  UserUpdateRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
    };
  }

  factory UserUpdateRequest.fromJson(Map<String,dynamic> json)
  {
    return UserUpdateRequest(name: json['name'],email: json['email'],password: json['password']);
  }
}