class UserSession {

  static int ? userid;
  static String ? name;
  static String ? email;


  static void setUser({int? Userid, String? Name, String? Email})
  {
    UserSession.userid = Userid;
    UserSession.name = Name;
    UserSession.email = Email;
  }

  static void unrestUser()
  {
    userid = null;
    name = null;
    email = null;
  }


}