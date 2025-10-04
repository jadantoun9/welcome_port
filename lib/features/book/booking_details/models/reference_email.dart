class ReferenceEmail {
  final String reference;
  final String email;

  ReferenceEmail({required this.reference, required this.email});

  factory ReferenceEmail.fromJson(Map<String, dynamic> json) {
    return ReferenceEmail(
      reference: json['reference'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
