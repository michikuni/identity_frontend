class ApiConstants {
  ApiConstants._();

  // Dùng IP Windows host khi backend chạy trên WSL2/Ubuntu
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
  static const String attendanceTeam = '/attendance/team';

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
  static const String chiefRequests = '/chief/requests';
  static String chiefChangeRole(String id) => '/chief/employees/$id/role';
  static String chiefTerminate(String id) => '/chief/employees/$id/terminate';
  static String chiefAssignManager(String id) => '/chief/employees/$id/manager';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminPendingAccounts = '/admin/pending-accounts';
  static String adminApproveAccount(String id) => '/admin/accounts/$id/approve';
  static String adminRejectAccount(String id) => '/admin/accounts/$id/reject';
  static String adminEmployeePayroll(String id) => '/admin/employees/$id/payroll';
  static String adminEmployeeContract(String id) => '/admin/employees/$id/contract';
  static String adminIssueSalaryVC(String id) => '/admin/employees/$id/issue-salary-vc';

  // Ledger (CHIEF + ADMIN only)
  static const String ledger = '/ledger';
  static const String ledgerInit = '/ledger/init';
  static const String ledgerRecords = '/ledger/records';

  // DID + VC Identity (public — no auth required)
  static String resolveDid(String did) => '/identity/did/${Uri.encodeComponent(did)}';
  static String getEmploymentVC(String employeeId) => '/identity/vc/employment/$employeeId';
  static String getTerminationVC(String employeeId) => '/identity/vc/termination/$employeeId';
  static String getSalaryRangeVC(String employeeId) => '/identity/vc/salary/$employeeId';
  static String getPromotionVC(String employeeId)   => '/identity/vc/promotion/$employeeId';
  static const String verifyVC = '/identity/vc/verify';
  static String verifyVCById(String vcId) => '/identity/vc/verify-by-id?vcId=${Uri.encodeComponent(vcId)}';

  // OID4VP — Verifiable Presentation flow
  static const String oidcVpRequest = '/oidc/vp/request';
  static const String oidcVpSubmit  = '/oidc/vp/submit';
  static String oidcVpResult(String state) => '/oidc/vp/result/$state';

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
