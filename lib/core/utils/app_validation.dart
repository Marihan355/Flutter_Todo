class AppValidation{
  AppValidation._();

  static String? validateEmail(String? value){
    if(value == null || value.isEmpty){
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if(!emailRegex.hasMatch(value)){
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value){
    if(value == null || value.isEmpty){
      return 'Password is required';
    }
    if(value.length < 6){
      return 'Password must be at least 6 characters';
    }
    // must contain at least one number
    // if (!RegExp(r'[0-9]').hasMatch(value)) {
    //   return 'Password must contain at least one number';
    // }

    // // must contain at least one special character
    // if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
    //   return 'Password must contain at least one special character';
    // }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? originalPassword){
    if(value == null || value.isEmpty){
      return 'Confirm Password is required';
    }
    if(value != originalPassword){
      return 'Passwords do not match';
    }
    return null;
  }

  // static String? validateUsername(String? value){
  //   if(value == null || value.isEmpty){
  //     return 'Username is required';
  //   }
  //   if(value.length < 3){
  //     return 'Username must be at least 3 characters';
  //   }
  //   return null;
  // }
  //
  //
  // static String? validatePhoneNumber(String? value){
  //   if(value == null || value.isEmpty){
  //     return 'Phone number is required';
  //   }
  //   final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
  //   if(!phoneRegex.hasMatch(value)){
  //     return 'Enter a valid phone number';
  //   }
  //   return null;
  // }
  //
  //
  // static String? validateNotEmpty(String? value, String fieldName){
  //   if(value == null || value.isEmpty){
  //     return '$fieldName is required';
  //   }
  //   return null;
  // }
}