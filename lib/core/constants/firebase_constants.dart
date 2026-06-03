class FirebaseConstants {
  FirebaseConstants._();

  // Firestore collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String ordersCollection = 'orders';
  static const String notificationsCollection = 'notifications';
  static const String reviewsCollection = 'reviews';

  // Storage buckets/paths
  static const String profileImagesPath = 'profile_images';
  static const String productImagesPath = 'product_images';

  // FCM Topics
  static const String offersTopicKey = 'offers';
  static const String newProductsTopicKey = 'new_products';
  static const String promotionsTopicKey = 'promotions';

  // SharedPreferences keys
  static const String onboardingDoneKey = 'onboarding_done';
  static const String cartItemsKey = 'cart_items';
  static const String cachedProductsKey = 'cached_products';
  static const String themeModeKey = 'theme_mode';
}