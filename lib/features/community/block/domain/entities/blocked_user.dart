class BlockedUser {
  final String id;
  final String? displayName;
  final String? photoUrl;

  const BlockedUser({
    required this.id,
    this.displayName,
    this.photoUrl,
  });
}
