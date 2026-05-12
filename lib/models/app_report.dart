enum AppReportStatus { open, closed }

class AppReport {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  final String description;
  final DateTime createdAt;
  final AppReportStatus status;

  const AppReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.description,
    required this.createdAt,
    required this.status,
  });

  factory AppReport.fromJson(Map<String, dynamic> json) {
    return AppReport(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userName: (json['userName'] ?? 'Utilisateur inconnu').toString(),
      subject: (json['subject'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      status: AppReportStatusX.fromApiValue((json['status'] ?? '').toString()),
    );
  }
}

extension AppReportStatusX on AppReportStatus {
  String get apiValue => this == AppReportStatus.open ? 'OPEN' : 'CLOSED';

  String get displayValue => this == AppReportStatus.open ? 'Ouvert' : 'Fermé';

  static AppReportStatus fromApiValue(String raw) {
    return raw.toUpperCase() == 'CLOSED'
        ? AppReportStatus.closed
        : AppReportStatus.open;
  }
}
