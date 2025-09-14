
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class Authservice{
  final LocalAuthentication localauth = LocalAuthentication();
  Future<bool> authenticatelocally()async{
    bool isAuthenticated = false;
    try{
      isAuthenticated=await localauth.authenticate(localizedReason: "We are trying to authenticate you",
      options: AuthenticationOptions(
        // biometricOnly: true,
        sensitiveTransaction:true,
        stickyAuth: true,
        useErrorDialogs: true,
      ),
      );
    }
    on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        // ...
      } else {
        // ...
      }
    }



    catch(e){
      isAuthenticated = false;
      print("error:$e");
    }
  return isAuthenticated;
  }
}