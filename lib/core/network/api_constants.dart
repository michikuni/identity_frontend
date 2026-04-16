class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://188.122.1.106:8080/api/v1';

  // Auth
  static const String signIn = '/auth/sign-in';
  static const String signUp = '/auth/sign-up';

  // Employee (self)
  static const String employee = '/employee';
  static const String profile = '/profile';
  static const String contracts = '/contracts';
  static const String payroll = '/payroll';

  // Attendance
  static const String attendanceCheckIn = '/attendance/check-in';
  static const String attendanceCheckOut = '/attendance/check-out';
  static const String attendanceToday = '/attendance/today';
  static const String attendance = '/attendance';

  // Requests
  static const String requests = '/requests';

  // Directory
  static const String directory = '/directory';

  // Company
  static const String company = '/company';

  // Manager
  static const String managerRequests = '/manager/requests';

  // Chief
  static const String chiefEmployees = '/chief/employees';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminPendingAccounts = '/admin/pending-accounts';
  static String adminApproveAccount(String id) => '/admin/accounts/$id/approve';
  static String adminRejectAccount(String id) => '/admin/accounts/$id/reject';

  // Ledger (CHIEF + ADMIN only)
  static const String ledger = '/ledger';
  static const String ledgerInit = '/ledger/init';
  static const String ledgerRecords = '/ledger/records';

  // Headers
  static const String authHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
