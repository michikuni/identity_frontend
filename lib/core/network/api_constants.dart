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
  static const String adminIssuerStats = '/admin/issuer-stats';
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

  // Status List 2021 (W3C — public, no auth)
  static String statusList(String listId) => '/status-list/$listId';
  static String statusListEntry(String listId) => '/status-list/$listId/entry';

  // SD-JWT (issue = ADMIN/CHIEF; sync/verify/present = public)
  static String sdJwtIssueSkill(String employeeId) => '/sd-jwt/issue/skill/$employeeId';
  static String sdJwtIssueEducation(String employeeId) => '/sd-jwt/issue/education/$employeeId';
  static String sdJwtGetSkill(String employeeId) => '/sd-jwt/$employeeId/skill';
  static String sdJwtGetEducation(String employeeId) => '/sd-jwt/$employeeId/education';
  static const String sdJwtPresent = '/sd-jwt/present';
  static const String sdJwtVerify  = '/sd-jwt/verify';

  // DIF Universal Resolver (public)
  static String resolveDidUniversal(String did) => '/1.0/identifiers/${Uri.encodeComponent(did)}';

  // Trust Registry (list/check = public; register/revoke = CHIEF/ADMIN)
  static const String trustRegistryIssuers = '/trust-registry/issuers';
  static String trustRegistryIssuerTrusted(String did) =>
      '/trust-registry/issuers/${Uri.encodeComponent(did)}/trusted';

  // Contract e-signing
  static String contractSign(String contractId) => '/contracts/$contractId/sign';
  static String contractSignatures(String contractId) => '/contracts/$contractId/signatures';
  static const String contractHash = '/contracts/hash';

  // Admin — new VC types
  static String adminIssueTrainingVc(String employeeId) =>
      '/admin/employees/$employeeId/issue-training-vc';
  static String adminIssueNdaVc(String employeeId) =>
      '/admin/employees/$employeeId/issue-nda-vc';

  // TOTP MFA (setup/disable = ADMIN/CHIEF; validate = public)
  static const String mfaSetup        = '/mfa/setup';
  static const String mfaVerifySetup  = '/mfa/verify-setup';
  static const String mfaDisable      = '/mfa/disable';
  static const String mfaValidate     = '/mfa/validate';
  static String mfaStatus(String userId) => '/mfa/status/$userId';

  // Audit Log (ADMIN/CHIEF)
  static String auditEmployeeHistory(String employeeId, String type) =>
      '/audit/employees/$employeeId/history/$type';
  static String auditEmployeeAll(String employeeId) =>
      '/audit/employees/$employeeId/history';
  static const String auditRecords = '/audit/records';

  // Sessions / Device Binding
  static const String sessionsRegister = '/sessions/register';
  static const String sessions         = '/sessions';
  static String sessionsDevice(String deviceId) => '/sessions/$deviceId';

  // GDPR
  static const String gdprExport = '/me/export-data';
  static const String gdprDelete = '/me/data';

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
