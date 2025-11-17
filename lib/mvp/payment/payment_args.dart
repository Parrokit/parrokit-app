class PaymentArgs {
  final String merchantUid;
  final int amount;
  final String productName;
  final String buyerEmail;

  PaymentArgs({
    required this.merchantUid,
    required this.amount,
    required this.productName,
    required this.buyerEmail,
  });
}