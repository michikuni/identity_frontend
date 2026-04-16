class DirectoryEntity {
  final int id;
  final String name;
  final String email;
  final String department;
  final String position;
  final String role;
  final String status;

  const DirectoryEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.role,
    required this.status,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
