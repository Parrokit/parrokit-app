class PaymentArgs {
  final String merchantUid;
  final int amount;
  final int coins;
  final String productName;
  final String buyerEmail;

  PaymentArgs({
    required this.merchantUid,
    required this.amount,
    required this.coins,
    required this.productName,
    required this.buyerEmail,
  });
}