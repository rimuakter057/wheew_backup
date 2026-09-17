class AppConst {
  static const String token = "auth_token";
  static const String userID = "userID";
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';
  static const String rememberMe = "remember_me";
  static const String avatar = 'avatar'; // ✅ add this

  /// Last Find/Stop Parking choice ('SEARCHING' or 'IDLE'), cached so
  /// re-entering the Parking tab restores the button from local state
  /// instead of waiting on GET /parking-mode/me.
  static const String parkingSearchStatus = 'parking_search_status';

  /// Last selected radius filter for parking spots / handoffs in meters.
  static const String selectedParkingRadius = 'selected_parking_radius';

  /// Last resolved GPS fix as "lat,lng". Lets the map open on the user's own
  /// location right away instead of a loading state (or a hardcoded default)
  /// every time the Parking tab is opened.
  static const String lastKnownLocation = 'last_known_location';

  /// First page of the saved-parking history, cached as JSON so the Save
  /// Parking screen can render its list instantly on open and refresh in the
  /// background, instead of showing a shimmer on every single visit.
  static const String savedParkingHistoryCache = 'saved_parking_history_cache';

  /// Id of the account the locally cached chat/parking data belongs to.
  /// Compared on every login/signup so another account's cache is never
  /// shown — the caches themselves use global keys, not per-user ones.
  static const String cacheOwnerUserId = 'cache_owner_user_id';

  static String unknown =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/500px-Unknown_person.jpg';

  static const String licenceId = "licence_id";
  static const String nickName = "nick_name";
  static const String loginUser = "login_user";
  static const String loginPass = "login_pass";
  static const String licenseNoVerified = "license_no_verified";
  static const String group = "https://cdn-icons-png.flaticon.com/512/2352/2352167.png";
  static const String groupTest = "https://www.google.com/search?q=groupe+icon+transparent&sca_esv=ec2bff8bd1e2ef21&udm=2&biw=1745&bih=859&sxsrf=ANbL-n5kVb3fCc9vZKVzzi2OyQCIb-7PlQ%3A1781585649750&ei=8dYwapjfLNuf4-EP5q-NyAw&ved=0ahUKEwjYm6je-4qVAxXbzzgGHeZXA8kQ4dUDCBE&uact=5&oq=groupe+icon+transparent&gs_lp=Egtnd3Mtd2l6LWltZyIXZ3JvdXBlIGljb24gdHJhbnNwYXJlbnRI9yFQkgFY4B5wAXgAkAEAmAHjAqAB7A-qAQcwLjkuMS4yuAEDyAEA-AEBmAIFoALEBcICBhAAGAcYHsICCRAAGIAEGAoYC8ICBhAAGB4YCsICBhAAGAUYHsICBhAAGAgYHpgDAIgGAZIHBzEuMy4wLjGgB7YIsgcHMC4zLjAuMbgHuwXCBwUwLjMuMsgHEYAIAQ&sclient=gws-wiz-img#sv=CAMSURoyKhBlLTc0clJ3Tm40aU4xdWJNMg43NHJSd05uNGlOMXViTToOTzg0dzdlU1VYb0d3Tk0gBCoXCgFzEhBlLTc0clJ3Tm40aU4xdWJNGAEwARgHIOfchtYPSggQARgBIAEoAQ";

  // final String licenceId=data["licence_id"];
  // final String nickName=data["nick_name"];
}
