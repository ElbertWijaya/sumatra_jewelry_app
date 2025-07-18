class Account {
  final String accountsId;
  final String accountsUsername;
  final String accountsRole;
  final String accountsName;
  final String? accountsLastActive;
  final String? accountsCreatedAt;

  Account({
    required this.accountsId,
    required this.accountsUsername,
    required this.accountsRole,
    required this.accountsName,
    this.accountsLastActive,
    this.accountsCreatedAt,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountsId: json['accounts_id'] ?? '',
      accountsUsername: json['accounts_username'] ?? '',
      accountsRole: json['accounts_role'] ?? '',
      accountsName: json['accounts_name'] ?? '',
      accountsLastActive: json['accounts_last_active'],
      accountsCreatedAt: json['accounts_created_at'],
    );
  }
}
