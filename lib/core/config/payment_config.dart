class PaymentConfig {
  PaymentConfig._();

  /// Paystack
  static const String publicKey =
      "pk_test_69cf95e52fd204069cca94f7b621f7a96a39f872";

  /// NEVER ship this in production.
  /// It is only for local development.
  static const String secretKey =
      "sk_test_294fd20eb9849e80a3fe22427de804a24d61ea7d";

  /// Currency
  static const String currency = "NGN";

  /// Callback URL configured in your Paystack dashboard
  static const String callbackUrl = "https://paystack.com";
}
