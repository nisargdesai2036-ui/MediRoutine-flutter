class UserRegister {
  late final String name;
  late final String email;
  late final String password;

  UserRegister({required this.name,required this.email,required this.password});

    //  from springboot to flutter
  factory UserRegister.fromJson(Map<String,dynamic> json)
  {
      return UserRegister(name: json['name'],email: json['email'],password: json['password']);
  }

  // job is send data from flutter to springboot
  Map<String,dynamic>toJson()
  {
    return{
      'name':name,
      'email':email,
      'password':password,
    };
  }
}