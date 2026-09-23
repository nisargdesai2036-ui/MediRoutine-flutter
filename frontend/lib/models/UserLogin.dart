class Userlogin
{
  final String email;
  final String password;

  Userlogin({required this.email,required this.password});

  Map<String,dynamic>toJson()
  {
    return{
      'email':email,
      'password':password
    };
  }

}