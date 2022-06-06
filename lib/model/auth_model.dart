// Login Request
class LoginRequestModel {
  String email;
  String password;
  String deviceName;

  LoginRequestModel(
      {required this.email, required this.password, required this.deviceName});

  Map<String, dynamic> toJson() {
    final map = {
      'email': email.trim(),
      'password': password.trim(),
      'device_name': deviceName.trim(),
    };
    return map;
  }
}

// Get Email Token Request
class GetEmailTokenRequestModel {
  String email;

  GetEmailTokenRequestModel({required this.email});

  Map<String, dynamic> toJson() {
    final map = {
      'email': email.trim(),
    };
    return map;
  }
}

// Verify Email Request
class VerifyEmailRequestModel {
  String email;
  String token;

  VerifyEmailRequestModel({required this.email, required this.token});

  Map<String, dynamic> toJson() {
    final map = {
      'email': email.trim(),
      'token': token.trim(),
    };
    return map;
  }
}

// Register Request
class RegisterRequestModel {
  String fullName;
  String username;
  String email;
  String country;
  String password;
  String deviceName;

  RegisterRequestModel({
    required this.fullName,
    required this.username,
    required this.email,
    required this.country,
    required this.password,
    required this.deviceName,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'full_name': fullName.trim(),
      'username': username.trim(),
      'email': email.trim(),
      'country': country.trim(),
      'password': password.trim(),
      'device_name': deviceName.trim(),
    };
    return map;
  }
}
