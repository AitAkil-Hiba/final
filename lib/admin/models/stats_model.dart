
class AdminStats {
  final int totalUsers;
  final int totalMerchants;
  final int totalClients;
  final int suspendedClients;
  final int suspendedCommercants;
  final int suspendedAdmins;
  final int pendingDocuments;
  final int weeklyUsers;
  final int totalReservations;
  final int totalCancellations;
  final int pendingHelpRequests;
  final int newUsersThisWeek;
  final int totalAnnulations;

  AdminStats({
    required this.totalUsers,
    required this.totalMerchants,
    required this.totalClients,
    required this.suspendedClients,
    required this.suspendedCommercants,
    required this.suspendedAdmins,
    required this.pendingDocuments,
    required this.weeklyUsers,
    required this.totalReservations,
    required this.totalCancellations,
    this.pendingHelpRequests = 0,
    this.newUsersThisWeek = 0,
    this.totalAnnulations = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalMerchants: json['totalMerchants'] ?? 0,
      totalClients: json['totalClients'] ?? 0,
      suspendedClients: json['suspendedClients'] ?? 0,
      suspendedCommercants: json['suspendedCommercants'] ?? 0,
      suspendedAdmins: json['suspendedAdmins'] ?? 0,
      pendingDocuments: json['pendingDocuments'] ?? 0,
      weeklyUsers: json['weeklyUsers'] ?? 0,
      totalReservations: json['totalReservations'] ?? 0,
      totalCancellations: json['totalCancellations'] ?? 0,
      pendingHelpRequests: json['pendingHelpRequests'] ?? 0,
      newUsersThisWeek: json['newUsersThisWeek'] ?? json['weeklyUsers'] ?? 0,
      totalAnnulations: json['totalAnnulations'] ?? json['totalCancellations'] ?? 0,
    );
  }
}

class RegistrationStats {
  final List<DailyData> daily;
  final List<MonthlyData> monthly;

  RegistrationStats({
    required this.daily,
    required this.monthly,
  });

  factory RegistrationStats.fromJson(Map<String, dynamic> json) {
    return RegistrationStats(
      daily: (json['daily'] as List<dynamic>?)
          ?.map((e) => DailyData.fromJson(e))
          .toList() ?? [],
      monthly: (json['monthly'] as List<dynamic>?)
          ?.map((e) => MonthlyData.fromJson(e))
          .toList() ?? [],
    );
  }
}

class DailyData {
  final String date;
  final int count;

  DailyData({
    required this.date,
    required this.count,
  });

  factory DailyData.fromJson(Map<String, dynamic> json) {
    return DailyData(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class MonthlyData {
  final String month;
  final int count;

  MonthlyData({
    required this.month,
    required this.count,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class ReservationStats {
  final List<DailyData> daily;
  final MonthlyStats monthly;

  ReservationStats({
    required this.daily,
    required this.monthly,
  });

  factory ReservationStats.fromJson(Map<String, dynamic> json) {
    return ReservationStats(
      daily: (json['daily'] as List<dynamic>?)
          ?.map((e) => DailyData.fromJson(e))
          .toList() ?? [],
      monthly: MonthlyStats.fromJson(json['monthly'] ?? {}),
    );
  }
}

class MonthlyStats {
  final List<int> published;
  final List<int> reserved;

  MonthlyStats({
    required this.published,
    required this.reserved,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    try {
      final publishedList = json['published'] as List<dynamic>?;
      final reservedList = json['reserved'] as List<dynamic>?;
      
      final published = publishedList?.map((e) => (e is int ? e : int.tryParse(e.toString()) ?? 0)).toList() ?? [0];
      final reserved = reservedList?.map((e) => (e is int ? e : int.tryParse(e.toString()) ?? 0)).toList() ?? [0];
      
      return MonthlyStats(
        published: published,
        reserved: reserved,
      );
    } catch (e) {
      print('  MonthlyStats parsing error: $e');
      return MonthlyStats(published: [0], reserved: [0]);
    }
  }
}

class SuccessRateStats {
  final double current;
  final double previous;

  SuccessRateStats({
    required this.current,
    required this.previous,
  });

  factory SuccessRateStats.fromJson(Map<String, dynamic> json) {
    return SuccessRateStats(
      current: (json['current'] ?? 0).toDouble(),
      previous: (json['previous'] ?? 0).toDouble(),
    );
  }
}

class OfferStats {
  final WeeklyStats weekly;
  final MonthlyStats monthly;
  final SuccessRateStats successRate;

  OfferStats({
    required this.weekly,
    required this.monthly,
    required this.successRate,
  });

  factory OfferStats.fromJson(Map<String, dynamic> json) {
    return OfferStats(
      weekly: WeeklyStats.fromJson(json['weekly'] ?? {}),
      monthly: MonthlyStats.fromJson(json['monthly'] ?? {}),
      successRate: SuccessRateStats.fromJson(json['successRate'] ?? {}),
    );
  }
}

class WeeklyStats {
  final List<int> published;
  final List<int> reserved;

  WeeklyStats({
    required this.published,
    required this.reserved,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    try {
      final publishedList = json['published'] as List<dynamic>?;
      final reservedList = json['reserved'] as List<dynamic>?;
      
      final published = publishedList?.map((e) => (e is int ? e : int.tryParse(e.toString()) ?? 0)).toList() ?? [0];
      final reserved = reservedList?.map((e) => (e is int ? e : int.tryParse(e.toString()) ?? 0)).toList() ?? [0];
      
      return WeeklyStats(
        published: published,
        reserved: reserved,
      );
    } catch (e) {
      print('  WeeklyStats parsing error: $e');
      return WeeklyStats(published: [0], reserved: [0]);
    }
  }
}

class MerchantCategoryStats {
  final String category;
  final int count;

  MerchantCategoryStats({
    required this.category,
    required this.count,
  });

  factory MerchantCategoryStats.fromJson(Map<String, dynamic> json) {
    return MerchantCategoryStats(
      category: json['categorie'] ?? json['category'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
