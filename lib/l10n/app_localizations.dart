import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TrustID'**
  String get appTitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get appVersion;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signinWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signinWelcomeBack;

  /// No description provided for @signinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your identity'**
  String get signinSubtitle;

  String get signinPendingApproval;
  String get signinRejected;
  String get signinFailed;

  /// No description provided for @signupGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signupGetStarted;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join TrustID to manage your identity'**
  String get signupSubtitle;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get hasAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get navContract;

  /// No description provided for @navPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get navPayroll;

  /// No description provided for @navLedger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get navLedger;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your identity overview'**
  String get homeSubtitle;

  /// No description provided for @homeEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get homeEmployee;

  /// No description provided for @homeDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get homeDepartment;

  /// No description provided for @homePosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get homePosition;

  /// No description provided for @homeStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get homeStatus;

  /// No description provided for @homeWorkingType.
  ///
  /// In en, this message translates to:
  /// **'Working Type'**
  String get homeWorkingType;

  /// No description provided for @homeJoinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get homeJoinedDate;

  /// No description provided for @homeNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get homeNote;

  /// No description provided for @homeQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get homeQuickAccess;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileName;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileDOB.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get profileDOB;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhone;

  /// No description provided for @profileIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get profileIdentity;

  /// No description provided for @profileIdentityType.
  ///
  /// In en, this message translates to:
  /// **'Identity Type'**
  String get profileIdentityType;

  /// No description provided for @profileIdentityNumber.
  ///
  /// In en, this message translates to:
  /// **'Identity Number'**
  String get profileIdentityNumber;

  /// No description provided for @profileIdentityIssueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get profileIdentityIssueDate;

  /// No description provided for @profileIdentityIssuePlace.
  ///
  /// In en, this message translates to:
  /// **'Issue Place'**
  String get profileIdentityIssuePlace;

  /// No description provided for @profileEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get profileEmergency;

  /// No description provided for @profileEmergencyName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get profileEmergencyName;

  /// No description provided for @profileEmergencyPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get profileEmergencyPhone;

  /// No description provided for @profileEmergencyRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get profileEmergencyRelationship;

  /// No description provided for @profileHealth.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get profileHealth;

  /// No description provided for @profileMarried.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get profileMarried;

  /// No description provided for @profileResidence.
  ///
  /// In en, this message translates to:
  /// **'Residence'**
  String get profileResidence;

  /// No description provided for @profilePermanentResidence.
  ///
  /// In en, this message translates to:
  /// **'Permanent Address'**
  String get profilePermanentResidence;

  /// No description provided for @profileNowResidence.
  ///
  /// In en, this message translates to:
  /// **'Current Address'**
  String get profileNowResidence;

  /// No description provided for @profileEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get profileEducation;

  /// No description provided for @profileEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education Level'**
  String get profileEducationLevel;

  /// No description provided for @profileMajor.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get profileMajor;

  /// No description provided for @profileCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get profileCertificate;

  /// No description provided for @profileSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get profileSkills;

  /// No description provided for @profileExpYears.
  ///
  /// In en, this message translates to:
  /// **'Experience (years)'**
  String get profileExpYears;

  /// No description provided for @profileNoData.
  ///
  /// In en, this message translates to:
  /// **'Profile not set up yet'**
  String get profileNoData;

  /// No description provided for @contractTitle.
  ///
  /// In en, this message translates to:
  /// **'My Contract'**
  String get contractTitle;

  /// No description provided for @contractType.
  ///
  /// In en, this message translates to:
  /// **'Contract Type'**
  String get contractType;

  /// No description provided for @contractStart.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get contractStart;

  /// No description provided for @contractEnd.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get contractEnd;

  /// No description provided for @contractExpire.
  ///
  /// In en, this message translates to:
  /// **'Expire Date'**
  String get contractExpire;

  /// No description provided for @contractProbationStart.
  ///
  /// In en, this message translates to:
  /// **'Probation Start'**
  String get contractProbationStart;

  /// No description provided for @contractProbationEnd.
  ///
  /// In en, this message translates to:
  /// **'Probation End'**
  String get contractProbationEnd;

  /// No description provided for @contractTaxCode.
  ///
  /// In en, this message translates to:
  /// **'Tax Code'**
  String get contractTaxCode;

  /// No description provided for @contractSocialInsurance.
  ///
  /// In en, this message translates to:
  /// **'Social Insurance'**
  String get contractSocialInsurance;

  /// No description provided for @contractHealthInsurance.
  ///
  /// In en, this message translates to:
  /// **'Health Insurance'**
  String get contractHealthInsurance;

  /// No description provided for @contractNoData.
  ///
  /// In en, this message translates to:
  /// **'No contract found'**
  String get contractNoData;

  /// No description provided for @payrollTitle.
  ///
  /// In en, this message translates to:
  /// **'My Payroll'**
  String get payrollTitle;

  /// No description provided for @payrollSalaryType.
  ///
  /// In en, this message translates to:
  /// **'Salary Type'**
  String get payrollSalaryType;

  /// No description provided for @payrollBaseSalary.
  ///
  /// In en, this message translates to:
  /// **'Base Salary'**
  String get payrollBaseSalary;

  /// No description provided for @payrollBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get payrollBonus;

  /// No description provided for @payrollOvertime.
  ///
  /// In en, this message translates to:
  /// **'Overtime Rate'**
  String get payrollOvertime;

  /// No description provided for @payrollTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get payrollTotal;

  /// No description provided for @payrollCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get payrollCurrency;

  /// No description provided for @payrollPayDay.
  ///
  /// In en, this message translates to:
  /// **'Pay Day'**
  String get payrollPayDay;

  /// No description provided for @payrollBank.
  ///
  /// In en, this message translates to:
  /// **'Bank Information'**
  String get payrollBank;

  /// No description provided for @payrollBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get payrollBankAccount;

  /// No description provided for @payrollBankName_label.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get payrollBankName_label;

  /// No description provided for @payrollBankNameInst.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get payrollBankNameInst;

  /// No description provided for @payrollBankBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get payrollBankBranch;

  /// No description provided for @payrollNoData.
  ///
  /// In en, this message translates to:
  /// **'No payroll information found'**
  String get payrollNoData;

  /// No description provided for @ledgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Blockchain Ledger'**
  String get ledgerTitle;

  /// No description provided for @ledgerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tamper-proof identity records'**
  String get ledgerSubtitle;

  /// No description provided for @ledgerRecords.
  ///
  /// In en, this message translates to:
  /// **'Identity Records'**
  String get ledgerRecords;

  /// No description provided for @ledgerHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get ledgerHistory;

  /// No description provided for @ledgerVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get ledgerVerify;

  /// No description provided for @ledgerStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get ledgerStatus;

  /// No description provided for @ledgerRecordType.
  ///
  /// In en, this message translates to:
  /// **'Record Type'**
  String get ledgerRecordType;

  /// No description provided for @ledgerAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get ledgerAction;

  /// No description provided for @ledgerTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Timestamp'**
  String get ledgerTimestamp;

  /// No description provided for @ledgerHash.
  ///
  /// In en, this message translates to:
  /// **'Data Hash'**
  String get ledgerHash;

  /// No description provided for @ledgerNoData.
  ///
  /// In en, this message translates to:
  /// **'No ledger records found'**
  String get ledgerNoData;

  /// No description provided for @ledgerActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ledgerActive;

  /// No description provided for @ledgerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get ledgerDeleted;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @statusFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full Time'**
  String get statusFullTime;

  /// No description provided for @statusPartTime.
  ///
  /// In en, this message translates to:
  /// **'Part Time'**
  String get statusPartTime;

  /// No description provided for @statusPermanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get statusPermanent;

  /// No description provided for @statusFixedTerm.
  ///
  /// In en, this message translates to:
  /// **'Fixed Term'**
  String get statusFixedTerm;

  /// No description provided for @statusProbation.
  ///
  /// In en, this message translates to:
  /// **'Probation'**
  String get statusProbation;

  /// No description provided for @statusMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get statusMale;

  /// No description provided for @statusFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get statusFemale;

  /// No description provided for @statusSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get statusSingle;

  /// No description provided for @statusMarried.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get statusMarried;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// No description provided for @kycTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get kycTitle;

  /// No description provided for @kycStepDocument.
  ///
  /// In en, this message translates to:
  /// **'1. Capture your document'**
  String get kycStepDocument;

  /// No description provided for @kycStepFace.
  ///
  /// In en, this message translates to:
  /// **'2. Scan your face'**
  String get kycStepFace;

  /// No description provided for @kycStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'3. Confirm'**
  String get kycStepConfirm;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your work profile'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details to complete registration'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get onboardingDepartment;

  /// No description provided for @onboardingDepartmentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Engineering'**
  String get onboardingDepartmentHint;

  /// No description provided for @onboardingPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get onboardingPosition;

  /// No description provided for @onboardingPositionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Software Engineer'**
  String get onboardingPositionHint;

  /// No description provided for @onboardingWorkingType.
  ///
  /// In en, this message translates to:
  /// **'Working Type'**
  String get onboardingWorkingType;

  /// No description provided for @onboardingNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get onboardingNote;

  /// No description provided for @onboardingNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Additional info...'**
  String get onboardingNoteHint;

  /// No description provided for @onboardingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get onboardingSubmit;

  /// No description provided for @onboardingError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please try again'**
  String get onboardingError;

  /// No description provided for @roleEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get roleEmployee;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleChief.
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get roleChief;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @homeLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading your profile...'**
  String get homeLoadingProfile;

  /// No description provided for @homeLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get homeLoadFailed;

  /// No description provided for @homeApproveAccounts.
  ///
  /// In en, this message translates to:
  /// **'Approve Accounts'**
  String get homeApproveAccounts;

  /// No description provided for @homeStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get homeStaff;

  /// No description provided for @navAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get navAttendance;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navDirectory.
  ///
  /// In en, this message translates to:
  /// **'Directory'**
  String get navDirectory;

  /// No description provided for @navWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get navWallet;

  /// No description provided for @navVerifier.
  ///
  /// In en, this message translates to:
  /// **'Verifier'**
  String get navVerifier;

  /// No description provided for @navApproveRequests.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get navApproveRequests;

  /// No description provided for @navTimesheet.
  ///
  /// In en, this message translates to:
  /// **'Timesheet'**
  String get navTimesheet;

  /// No description provided for @navApproveAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navApproveAccounts;

  /// No description provided for @navStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get navStaff;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Control Panel'**
  String get adminDashboardTitle;

  /// No description provided for @adminRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get adminRefresh;

  /// No description provided for @adminLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get adminLoadFailed;

  /// No description provided for @adminSystemOverview.
  ///
  /// In en, this message translates to:
  /// **'System Overview'**
  String get adminSystemOverview;

  /// No description provided for @adminRealTimeData.
  ///
  /// In en, this message translates to:
  /// **'Real-time data'**
  String get adminRealTimeData;

  /// No description provided for @adminPendingAccountsBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} accounts pending approval'**
  String adminPendingAccountsBanner(int count);

  /// No description provided for @adminStatTotalEmployees.
  ///
  /// In en, this message translates to:
  /// **'Total Staff'**
  String get adminStatTotalEmployees;

  /// No description provided for @adminStatActiveEmployees.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get adminStatActiveEmployees;

  /// No description provided for @adminStatTodayAttendance.
  ///
  /// In en, this message translates to:
  /// **'Today Check-in'**
  String get adminStatTodayAttendance;

  /// No description provided for @adminStatPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get adminStatPendingRequests;

  /// No description provided for @adminManageStaff.
  ///
  /// In en, this message translates to:
  /// **'Manage Staff'**
  String get adminManageStaff;

  /// No description provided for @adminIssueSalaryVc.
  ///
  /// In en, this message translates to:
  /// **'Issue Salary VC'**
  String get adminIssueSalaryVc;

  /// No description provided for @adminVerifierScanner.
  ///
  /// In en, this message translates to:
  /// **'Verifier Scanner'**
  String get adminVerifierScanner;

  /// No description provided for @adminIssueSalaryVcTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Salary Range VC'**
  String get adminIssueSalaryVcTitle;

  /// No description provided for @adminIssueSalaryVcDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter Employee ID to issue SalaryRangeVC.\nEmployee must have a payroll assigned.'**
  String get adminIssueSalaryVcDesc;

  /// No description provided for @adminEmployeeId.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get adminEmployeeId;

  /// No description provided for @adminEmployeeIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5'**
  String get adminEmployeeIdHint;

  /// No description provided for @adminSalaryVcIssued.
  ///
  /// In en, this message translates to:
  /// **'SalaryRangeVC has been issued'**
  String get adminSalaryVcIssued;

  /// No description provided for @adminErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String adminErrorPrefix(String message);

  /// No description provided for @adminIssueVc.
  ///
  /// In en, this message translates to:
  /// **'Issue VC'**
  String get adminIssueVc;

  /// No description provided for @pendingApproved.
  ///
  /// In en, this message translates to:
  /// **'Account approved'**
  String get pendingApproved;

  /// No description provided for @pendingRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Account'**
  String get pendingRejectTitle;

  /// No description provided for @pendingRejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reject account "$email"?\nThis account will not be able to sign in.'**
  String pendingRejectConfirm(String email);

  /// No description provided for @pendingReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get pendingReject;

  /// No description provided for @pendingRejected.
  ///
  /// In en, this message translates to:
  /// **'Account rejected'**
  String get pendingRejected;

  /// No description provided for @pendingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No accounts pending approval'**
  String get pendingEmpty;

  /// No description provided for @pendingApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get pendingApprove;

  /// No description provided for @requestTypeLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get requestTypeLeave;

  /// No description provided for @requestTypeAttendanceCorrection.
  ///
  /// In en, this message translates to:
  /// **'Attendance Fix'**
  String get requestTypeAttendanceCorrection;

  /// No description provided for @requestTypeWfh.
  ///
  /// In en, this message translates to:
  /// **'Work From Home'**
  String get requestTypeWfh;

  /// No description provided for @requestTypeBusinessTrip.
  ///
  /// In en, this message translates to:
  /// **'Business Trip'**
  String get requestTypeBusinessTrip;

  /// No description provided for @requestSessionFullDay.
  ///
  /// In en, this message translates to:
  /// **'Full Day'**
  String get requestSessionFullDay;

  /// No description provided for @requestSessionMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get requestSessionMorning;

  /// No description provided for @requestSessionAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get requestSessionAfternoon;

  /// No description provided for @requestSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get requestSelectDate;

  /// No description provided for @requestCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request created successfully'**
  String get requestCreateSuccess;

  /// No description provided for @requestCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get requestCreate;

  /// No description provided for @requestType.
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get requestType;

  /// No description provided for @requestDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get requestDate;

  /// No description provided for @requestFromDate.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get requestFromDate;

  /// No description provided for @requestToDate.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get requestToDate;

  /// No description provided for @requestSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get requestSession;

  /// No description provided for @requestReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get requestReason;

  /// No description provided for @requestReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter reason...'**
  String get requestReasonHint;

  /// No description provided for @requestReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get requestReasonRequired;

  /// No description provided for @requestSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get requestSubmit;

  /// No description provided for @requestTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get requestTabAll;

  /// No description provided for @requestTabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get requestTabPending;

  /// No description provided for @requestTabDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get requestTabDone;

  /// No description provided for @requestEmpty.
  ///
  /// In en, this message translates to:
  /// **'No requests'**
  String get requestEmpty;

  /// No description provided for @requestStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get requestStatusApproved;

  /// No description provided for @requestStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get requestStatusRejected;

  /// No description provided for @requestStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get requestStatusPending;

  /// No description provided for @requestApprover.
  ///
  /// In en, this message translates to:
  /// **'Approver: $name'**
  String requestApprover(String name);

  /// No description provided for @requestRejectedReason.
  ///
  /// In en, this message translates to:
  /// **'Reject reason: $reason'**
  String requestRejectedReason(String reason);

  /// No description provided for @managerRequestProcessed.
  ///
  /// In en, this message translates to:
  /// **'Request processed'**
  String get managerRequestProcessed;

  /// No description provided for @managerRequestEmpty.
  ///
  /// In en, this message translates to:
  /// **'No requests'**
  String get managerRequestEmpty;

  /// No description provided for @managerRejectReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Reason'**
  String get managerRejectReasonTitle;

  /// No description provided for @managerRequestTypeLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave Request'**
  String get managerRequestTypeLeave;

  /// No description provided for @managerTimesheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff Timesheet'**
  String get managerTimesheetTitle;

  /// No description provided for @attendanceMonth.
  ///
  /// In en, this message translates to:
  /// **'Month $month/$year'**
  String attendanceMonth(int month, int year);

  /// No description provided for @attendancePresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attendancePresent;

  /// No description provided for @attendanceLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceLate;

  /// No description provided for @attendanceAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attendanceAbsent;

  /// No description provided for @attendanceWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get attendanceWeekend;

  /// No description provided for @attendanceDetail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get attendanceDetail;

  /// No description provided for @managerNoSubordinates.
  ///
  /// In en, this message translates to:
  /// **'No subordinate employees'**
  String get managerNoSubordinates;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @attendanceToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get attendanceToday;

  /// No description provided for @attendanceCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get attendanceCheckIn;

  /// No description provided for @attendanceCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get attendanceCheckOut;

  /// No description provided for @attendanceCheckInBtn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get attendanceCheckInBtn;

  /// No description provided for @attendanceCheckOutBtn.
  ///
  /// In en, this message translates to:
  /// **'Check Out'**
  String get attendanceCheckOutBtn;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get attendanceHistory;

  /// No description provided for @weekdayFullSun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdayFullSun;

  /// No description provided for @weekdayFullMon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayFullMon;

  /// No description provided for @weekdayFullTue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayFullTue;

  /// No description provided for @weekdayFullWed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayFullWed;

  /// No description provided for @weekdayFullThu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayFullThu;

  /// No description provided for @weekdayFullFri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFullFri;

  /// No description provided for @weekdayFullSat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdayFullSat;

  /// No description provided for @attendanceHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance History'**
  String get attendanceHistoryTitle;

  /// No description provided for @attendanceNoDataMonth.
  ///
  /// In en, this message translates to:
  /// **'No data for this month'**
  String get attendanceNoDataMonth;

  /// No description provided for @attendanceWorkdays.
  ///
  /// In en, this message translates to:
  /// **'Workdays'**
  String get attendanceWorkdays;

  // ── Company ────────────────────────────────────────────────────────────────

  /// No description provided for @companyTitle.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get companyTitle;

  /// No description provided for @companyTaxCode.
  ///
  /// In en, this message translates to:
  /// **'Tax ID: $code'**
  String companyTaxCode(String code);

  /// No description provided for @companyLegalInfo.
  ///
  /// In en, this message translates to:
  /// **'Legal Entity'**
  String get companyLegalInfo;

  /// No description provided for @companyLegalRep.
  ///
  /// In en, this message translates to:
  /// **'Legal Representative'**
  String get companyLegalRep;

  /// No description provided for @companyLegalRepTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get companyLegalRepTitle;

  /// No description provided for @companyLegalRepId.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get companyLegalRepId;

  /// No description provided for @companyRegisteredAt.
  ///
  /// In en, this message translates to:
  /// **'Registration Date'**
  String get companyRegisteredAt;

  /// No description provided for @companyContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get companyContact;

  /// No description provided for @companyPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get companyPhone;

  /// No description provided for @companyEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get companyEmail;

  /// No description provided for @companyAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get companyAddress;

  /// No description provided for @companyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No company information'**
  String get companyEmpty;

  /// No description provided for @companyEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'The director can register the legal entity'**
  String get companyEmptyHint;

  // ── Directory ──────────────────────────────────────────────────────────────

  /// No description provided for @directoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee Directory'**
  String get directoryTitle;

  /// No description provided for @directorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, department, position...'**
  String get directorySearchHint;

  /// No description provided for @directoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get directoryNotFound;

  // ── Contract extras ────────────────────────────────────────────────────────

  /// No description provided for @contractLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading contract...'**
  String get contractLoading;

  /// No description provided for @contractNoDataRetry.
  ///
  /// In en, this message translates to:
  /// **'No contract data.\nPlease try again.'**
  String get contractNoDataRetry;

  /// No description provided for @contractDatesSection.
  ///
  /// In en, this message translates to:
  /// **'Contract Dates'**
  String get contractDatesSection;

  /// No description provided for @contractInsuranceTax.
  ///
  /// In en, this message translates to:
  /// **'Insurance & Tax'**
  String get contractInsuranceTax;

  // ── Payroll extras ─────────────────────────────────────────────────────────

  /// No description provided for @payrollLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading payroll...'**
  String get payrollLoading;

  /// No description provided for @payrollNoDataRetry.
  ///
  /// In en, this message translates to:
  /// **'No payroll data.\nPlease try again.'**
  String get payrollNoDataRetry;

  /// No description provided for @payrollBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Salary Breakdown'**
  String get payrollBreakdown;

  // ── Ledger extras ──────────────────────────────────────────────────────────

  /// No description provided for @ledgerLoading.
  ///
  /// In en, this message translates to:
  /// **'Fetching ledger records...'**
  String get ledgerLoading;

  /// No description provided for @ledgerLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch ledger'**
  String get ledgerLoadFailed;

  // ── Chief ──────────────────────────────────────────────────────────────────

  /// No description provided for @chiefTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff Management'**
  String get chiefTitle;

  /// No description provided for @chiefApproveAccounts.
  ///
  /// In en, this message translates to:
  /// **'Approve Accounts'**
  String get chiefApproveAccounts;

  /// No description provided for @chiefAddStaff.
  ///
  /// In en, this message translates to:
  /// **'Add Staff'**
  String get chiefAddStaff;

  /// No description provided for @chiefSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search employees...'**
  String get chiefSearchHint;

  /// No description provided for @chiefFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chiefFilterAll;

  /// No description provided for @chiefFilterEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get chiefFilterEmployee;

  /// No description provided for @chiefFilterManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get chiefFilterManager;

  /// No description provided for @chiefFilterChief.
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get chiefFilterChief;

  /// No description provided for @chiefFilterAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get chiefFilterAdmin;

  /// No description provided for @chiefFilterTerminated.
  ///
  /// In en, this message translates to:
  /// **'Terminated'**
  String get chiefFilterTerminated;

  /// No description provided for @chiefPendingBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} accounts pending approval — tap to review'**
  String chiefPendingBanner(int count);

  /// No description provided for @chiefNoEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees found'**
  String get chiefNoEmployees;

  /// No description provided for @chiefTerminated.
  ///
  /// In en, this message translates to:
  /// **'Terminated'**
  String get chiefTerminated;

  /// No description provided for @chiefPromoteAdmin.
  ///
  /// In en, this message translates to:
  /// **'Promote to Admin'**
  String get chiefPromoteAdmin;

  /// No description provided for @chiefPromoteChief.
  ///
  /// In en, this message translates to:
  /// **'Promote to Director'**
  String get chiefPromoteChief;

  /// No description provided for @chiefPromoteManager.
  ///
  /// In en, this message translates to:
  /// **'Promote to Manager'**
  String get chiefPromoteManager;

  /// No description provided for @chiefDemoteEmployee.
  ///
  /// In en, this message translates to:
  /// **'Demote to Employee'**
  String get chiefDemoteEmployee;

  /// No description provided for @chiefAssignManager.
  ///
  /// In en, this message translates to:
  /// **'Assign Manager'**
  String get chiefAssignManager;

  /// No description provided for @chiefCreateContract.
  ///
  /// In en, this message translates to:
  /// **'Create / Update Contract'**
  String get chiefCreateContract;

  /// No description provided for @chiefCreatePayroll.
  ///
  /// In en, this message translates to:
  /// **'Create / Update Payroll'**
  String get chiefCreatePayroll;

  /// No description provided for @chiefIssueSalaryVc.
  ///
  /// In en, this message translates to:
  /// **'Issue Salary VC'**
  String get chiefIssueSalaryVc;

  /// No description provided for @chiefTerminateContract.
  ///
  /// In en, this message translates to:
  /// **'Terminate Contract'**
  String get chiefTerminateContract;

  /// No description provided for @chiefTerminateTitle.
  ///
  /// In en, this message translates to:
  /// **'Terminate Contract'**
  String get chiefTerminateTitle;

  /// No description provided for @chiefTerminateReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason...'**
  String get chiefTerminateReasonHint;

  /// No description provided for @chiefChangeRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get chiefChangeRoleTitle;

  /// No description provided for @chiefNewRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'New role: {role}'**
  String chiefNewRoleLabel(String role);

  /// No description provided for @chiefNewPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'New position (optional)'**
  String get chiefNewPositionLabel;

  /// No description provided for @chiefNewPositionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Senior Engineer'**
  String get chiefNewPositionHint;

  /// No description provided for @chiefPromotionVcNote.
  ///
  /// In en, this message translates to:
  /// **'If a new position is entered, a PromotionVC will be issued automatically.'**
  String get chiefPromotionVcNote;

  /// No description provided for @chiefUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get chiefUpdateSuccess;

  /// No description provided for @chiefCreateStaffTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Staff'**
  String get chiefCreateStaffTitle;

  /// No description provided for @chiefSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get chiefSectionAccount;

  /// No description provided for @chiefSectionWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get chiefSectionWork;

  /// No description provided for @chiefEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email *'**
  String get chiefEmailLabel;

  /// No description provided for @chiefEmailHint.
  ///
  /// In en, this message translates to:
  /// **'employee@company.com'**
  String get chiefEmailHint;

  /// No description provided for @chiefPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone *'**
  String get chiefPhoneLabel;

  /// No description provided for @chiefPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get chiefPasswordLabel;

  /// No description provided for @chiefPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get chiefPasswordHint;

  /// No description provided for @chiefDepartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Department *'**
  String get chiefDepartmentLabel;

  /// No description provided for @chiefDepartmentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Engineering'**
  String get chiefDepartmentHint;

  /// No description provided for @chiefPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position *'**
  String get chiefPositionLabel;

  /// No description provided for @chiefPositionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Software Engineer'**
  String get chiefPositionHint;

  /// No description provided for @chiefRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get chiefRoleLabel;

  /// No description provided for @chiefWorkingTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Working Type'**
  String get chiefWorkingTypeLabel;

  /// No description provided for @chiefFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full Time'**
  String get chiefFullTime;

  /// No description provided for @chiefPartTime.
  ///
  /// In en, this message translates to:
  /// **'Part Time'**
  String get chiefPartTime;

  /// No description provided for @chiefNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get chiefNoteLabel;

  /// No description provided for @chiefNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Additional info...'**
  String get chiefNoteHint;

  /// No description provided for @chiefCreateBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Staff'**
  String get chiefCreateBtn;

  /// No description provided for @chiefCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Staff created successfully'**
  String get chiefCreateSuccess;

  /// No description provided for @chiefContractTitle.
  ///
  /// In en, this message translates to:
  /// **'Create / Update Contract'**
  String get chiefContractTitle;

  /// No description provided for @chiefContractType.
  ///
  /// In en, this message translates to:
  /// **'Contract Type'**
  String get chiefContractType;

  /// No description provided for @chiefContractFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full Time'**
  String get chiefContractFullTime;

  /// No description provided for @chiefContractPartTime.
  ///
  /// In en, this message translates to:
  /// **'Part Time'**
  String get chiefContractPartTime;

  /// No description provided for @chiefContractProbation.
  ///
  /// In en, this message translates to:
  /// **'Probation'**
  String get chiefContractProbation;

  /// No description provided for @chiefContractInternship.
  ///
  /// In en, this message translates to:
  /// **'Internship'**
  String get chiefContractInternship;

  /// No description provided for @chiefContractStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date *'**
  String get chiefContractStartDate;

  /// No description provided for @chiefContractEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get chiefContractEndDate;

  /// No description provided for @chiefContractProbationStart.
  ///
  /// In en, this message translates to:
  /// **'Probation Start'**
  String get chiefContractProbationStart;

  /// No description provided for @chiefContractProbationEnd.
  ///
  /// In en, this message translates to:
  /// **'Probation End'**
  String get chiefContractProbationEnd;

  /// No description provided for @chiefContractTaxCode.
  ///
  /// In en, this message translates to:
  /// **'Tax Code'**
  String get chiefContractTaxCode;

  /// No description provided for @chiefContractSocialInsurance.
  ///
  /// In en, this message translates to:
  /// **'Social Insurance No.'**
  String get chiefContractSocialInsurance;

  /// No description provided for @chiefContractHealthInsurance.
  ///
  /// In en, this message translates to:
  /// **'Health Insurance No.'**
  String get chiefContractHealthInsurance;

  /// No description provided for @chiefContractSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Contract'**
  String get chiefContractSaveBtn;

  /// No description provided for @chiefContractSaved.
  ///
  /// In en, this message translates to:
  /// **'Contract saved'**
  String get chiefContractSaved;

  /// No description provided for @chiefContractStartRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a start date'**
  String get chiefContractStartRequired;

  /// No description provided for @chiefPickDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get chiefPickDate;

  /// No description provided for @chiefPayrollTitle.
  ///
  /// In en, this message translates to:
  /// **'Create / Update Payroll'**
  String get chiefPayrollTitle;

  /// No description provided for @chiefPayrollSalaryType.
  ///
  /// In en, this message translates to:
  /// **'Salary Type'**
  String get chiefPayrollSalaryType;

  /// No description provided for @chiefPayrollMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get chiefPayrollMonthly;

  /// No description provided for @chiefPayrollHourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get chiefPayrollHourly;

  /// No description provided for @chiefPayrollByContract.
  ///
  /// In en, this message translates to:
  /// **'By Contract'**
  String get chiefPayrollByContract;

  /// No description provided for @chiefPayrollCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get chiefPayrollCurrency;

  /// No description provided for @chiefPayrollBaseSalary.
  ///
  /// In en, this message translates to:
  /// **'Base Salary *'**
  String get chiefPayrollBaseSalary;

  /// No description provided for @chiefPayrollTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get chiefPayrollTotalIncome;

  /// No description provided for @chiefPayrollTotalHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to use base salary'**
  String get chiefPayrollTotalHint;

  /// No description provided for @chiefPayrollBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get chiefPayrollBonus;

  /// No description provided for @chiefPayrollOtRate.
  ///
  /// In en, this message translates to:
  /// **'Overtime Rate (per hour)'**
  String get chiefPayrollOtRate;

  /// No description provided for @chiefPayrollPayDay.
  ///
  /// In en, this message translates to:
  /// **'Pay Day'**
  String get chiefPayrollPayDay;

  /// No description provided for @chiefPayrollBankSection.
  ///
  /// In en, this message translates to:
  /// **'Bank Information'**
  String get chiefPayrollBankSection;

  /// No description provided for @chiefPayrollBankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get chiefPayrollBankName;

  /// No description provided for @chiefPayrollBankAccNum.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get chiefPayrollBankAccNum;

  /// No description provided for @chiefPayrollBankAccName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get chiefPayrollBankAccName;

  /// No description provided for @chiefPayrollBankBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get chiefPayrollBankBranch;

  /// No description provided for @chiefPayrollSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Payroll'**
  String get chiefPayrollSaveBtn;

  /// No description provided for @chiefPayrollSaved.
  ///
  /// In en, this message translates to:
  /// **'Payroll saved'**
  String get chiefPayrollSaved;

  /// No description provided for @chiefAssignManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Manager'**
  String get chiefAssignManagerTitle;

  /// No description provided for @chiefCurrentManager.
  ///
  /// In en, this message translates to:
  /// **'Current Manager: {name}'**
  String chiefCurrentManager(String name);

  /// No description provided for @chiefNoManager.
  ///
  /// In en, this message translates to:
  /// **'No manager'**
  String get chiefNoManager;

  /// No description provided for @chiefNoManagerAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Manager or Director in system.\nPlease promote a user to Manager first.'**
  String get chiefNoManagerAvailable;

  /// No description provided for @chiefSaveAssign.
  ///
  /// In en, this message translates to:
  /// **'Save Assignment'**
  String get chiefSaveAssign;

  /// No description provided for @chiefAssignSuccess.
  ///
  /// In en, this message translates to:
  /// **'Manager assigned successfully'**
  String get chiefAssignSuccess;

  /// No description provided for @chiefIssueSalaryVcTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Salary Range VC'**
  String get chiefIssueSalaryVcTitle;

  /// No description provided for @chiefIssueSalaryVcContent.
  ///
  /// In en, this message translates to:
  /// **'Issue SalaryRangeVC for {name}?\n\nEmployee must have a payroll assigned.'**
  String chiefIssueSalaryVcContent(String name);

  // ── Wallet ─────────────────────────────────────────────────────────────────

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity Wallet'**
  String get walletTitle;

  /// No description provided for @walletRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get walletRefresh;

  /// No description provided for @walletDisclosedInfo.
  ///
  /// In en, this message translates to:
  /// **'Disclosed Information'**
  String get walletDisclosedInfo;

  /// No description provided for @walletVerifiedReady.
  ///
  /// In en, this message translates to:
  /// **'Verified — ready to use'**
  String get walletVerifiedReady;

  /// No description provided for @walletKeypairPending.
  ///
  /// In en, this message translates to:
  /// **'Keypair created — awaiting Admin approval'**
  String get walletKeypairPending;

  /// No description provided for @walletNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Wallet not initialized'**
  String get walletNotInitialized;

  /// No description provided for @walletDidPending.
  ///
  /// In en, this message translates to:
  /// **'DID pending Admin approval.\n\nAdmin must approve in "Approve Accounts" screen. After approval, DID and Employment VC will be issued automatically.'**
  String get walletDidPending;

  /// No description provided for @walletDidNotInit.
  ///
  /// In en, this message translates to:
  /// **'DID Wallet not initialized.\n\nCommon causes:\n• You have not completed Onboarding\n• Account not yet approved by Admin\n\nSolution:\n1. Complete department and position in Onboarding\n2. Contact Admin for approval\n3. After Admin approves, Wallet and Employment VC will be created\n4. Tap Refresh (↺) to check again'**
  String get walletDidNotInit;

  /// No description provided for @walletVcPending.
  ///
  /// In en, this message translates to:
  /// **'Employment VC not yet issued — will appear automatically after Admin approves.'**
  String get walletVcPending;

  /// No description provided for @walletVerifierScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan VP Request QR'**
  String get walletVerifierScanTitle;

  /// No description provided for @walletVerifierScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point camera at QR on Verifier screen\n(tab "Create VP Request")'**
  String get walletVerifierScanSubtitle;

  /// No description provided for @walletShareInfo.
  ///
  /// In en, this message translates to:
  /// **'Select information to share'**
  String get walletShareInfo;

  /// No description provided for @walletShareInfoHint.
  ///
  /// In en, this message translates to:
  /// **'You are proactively sharing VP with Verifier.\nSelect fields to disclose — Verifier will scan this QR.'**
  String get walletShareInfoHint;

  /// No description provided for @walletRequestShareInfo.
  ///
  /// In en, this message translates to:
  /// **'Information sharing request'**
  String get walletRequestShareInfo;

  /// No description provided for @walletVerifierRequestHint.
  ///
  /// In en, this message translates to:
  /// **'Verifier is requesting the following information. Only confirm if you trust the requester.'**
  String get walletVerifierRequestHint;

  /// No description provided for @walletRequestedFields.
  ///
  /// In en, this message translates to:
  /// **'Requested information:'**
  String get walletRequestedFields;

  /// No description provided for @walletReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get walletReject;

  /// No description provided for @walletConfirmShare.
  ///
  /// In en, this message translates to:
  /// **'Confirm Share'**
  String get walletConfirmShare;

  /// No description provided for @walletVpSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'VP sent successfully — Verifier can view the result ✓'**
  String get walletVpSentSuccess;

  /// No description provided for @walletVpSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send VP: {error}'**
  String walletVpSendFailed(String error);

  /// No description provided for @walletVpSessionFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot create VP session: {error}'**
  String walletVpSessionFailed(String error);

  /// No description provided for @walletCreateVcQr.
  ///
  /// In en, this message translates to:
  /// **'Create VC QR'**
  String get walletCreateVcQr;

  /// No description provided for @walletScanVpRequest.
  ///
  /// In en, this message translates to:
  /// **'Scan VP Request QR'**
  String get walletScanVpRequest;

  /// No description provided for @walletQrForVerifier.
  ///
  /// In en, this message translates to:
  /// **'Show QR to Verifier to verify'**
  String get walletQrForVerifier;

  /// No description provided for @walletCopyVcJson.
  ///
  /// In en, this message translates to:
  /// **'Copy VC JSON'**
  String get walletCopyVcJson;

  /// No description provided for @walletCopied.
  ///
  /// In en, this message translates to:
  /// **'VC JSON copied'**
  String get walletCopied;

  /// No description provided for @walletCopiedPublicKey.
  ///
  /// In en, this message translates to:
  /// **'Public key copied'**
  String get walletCopiedPublicKey;

  /// No description provided for @walletCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get walletCopy;

  /// No description provided for @walletCopiedSnack.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get walletCopiedSnack;

  /// No description provided for @walletIssuedAt.
  ///
  /// In en, this message translates to:
  /// **'Issued at: {time}'**
  String walletIssuedAt(String time);

  /// No description provided for @walletQrSelectFields.
  ///
  /// In en, this message translates to:
  /// **'Select fields to include in the QR.'**
  String get walletQrSelectFields;

  /// No description provided for @walletQrCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get walletQrCancel;

  /// No description provided for @walletQrCreate.
  ///
  /// In en, this message translates to:
  /// **'Create QR'**
  String get walletQrCreate;

  /// No description provided for @walletVpAccepted.
  ///
  /// In en, this message translates to:
  /// **'VP accepted by Verifier ✓'**
  String get walletVpAccepted;

  /// No description provided for @walletVpRejected.
  ///
  /// In en, this message translates to:
  /// **'VP rejected: {reason}'**
  String walletVpRejected(String reason);

  /// No description provided for @walletClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get walletClose;

  // ── CCCD ───────────────────────────────────────────────────────────────────

  /// No description provided for @cccdBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get cccdBack;

  /// No description provided for @cccdSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get cccdSkip;

  /// No description provided for @cccdTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan CCCD QR Code'**
  String get cccdTitle;

  /// No description provided for @cccdInstruction.
  ///
  /// In en, this message translates to:
  /// **'Point camera at the QR code on the back of your chip CCCD to auto-fill information'**
  String get cccdInstruction;

  /// No description provided for @cccdManualInput.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get cccdManualInput;

  // ── Verifier ───────────────────────────────────────────────────────────────

  /// No description provided for @verifierTitle.
  ///
  /// In en, this message translates to:
  /// **'Verifier'**
  String get verifierTitle;

  /// No description provided for @verifierVerifyVc.
  ///
  /// In en, this message translates to:
  /// **'Verify VC'**
  String get verifierVerifyVc;

  /// No description provided for @verifierRequestVp.
  ///
  /// In en, this message translates to:
  /// **'Request VP'**
  String get verifierRequestVp;

  /// No description provided for @verifierScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get verifierScanAgain;

  /// No description provided for @verifierScanInstruction.
  ///
  /// In en, this message translates to:
  /// **'Point camera at QR Code on employee\'s app'**
  String get verifierScanInstruction;

  /// No description provided for @verifierScanDescription.
  ///
  /// In en, this message translates to:
  /// **'Accepts 2 QR types:\n• QR from "Export QR" button — verify VC directly\n• QR from "Present VP" button — verify VP Token signed by Employee'**
  String get verifierScanDescription;

  /// No description provided for @verifierHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get verifierHowItWorks;

  /// No description provided for @verifierHowItWorksSteps.
  ///
  /// In en, this message translates to:
  /// **'1. Select information you want Employee to provide\n2. Tap "Create VP Request QR" → QR is generated\n3. Have Employee scan this QR with their app\n4. Employee reviews and sends Verifiable Presentation\n5. Tap "Check Result" to view the shared information'**
  String get verifierHowItWorksSteps;

  /// No description provided for @verifierSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 1 field in 1 VC'**
  String get verifierSelectAtLeastOne;

  /// No description provided for @verifierCreateQrBtn.
  ///
  /// In en, this message translates to:
  /// **'Step 2 — Create QR for Employee to scan'**
  String get verifierCreateQrBtn;

  /// No description provided for @verifierQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Step 3 — Have Employee scan this QR'**
  String get verifierQrTitle;

  /// No description provided for @verifierCheckResult.
  ///
  /// In en, this message translates to:
  /// **'Step 5 — Check Result'**
  String get verifierCheckResult;

  /// No description provided for @verifierCreateVpRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create VP Request: {error}'**
  String verifierCreateVpRequestFailed(String error);

  /// No description provided for @verifierPollIdle.
  ///
  /// In en, this message translates to:
  /// **'No request yet'**
  String get verifierPollIdle;

  /// No description provided for @verifierPollPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Employee to scan QR and send VP...'**
  String get verifierPollPending;

  /// No description provided for @verifierPollAccepted.
  ///
  /// In en, this message translates to:
  /// **'Employee sent VP — Verified successfully'**
  String get verifierPollAccepted;

  /// No description provided for @verifierPollRejected.
  ///
  /// In en, this message translates to:
  /// **'VP invalid or rejected'**
  String get verifierPollRejected;

  /// No description provided for @verifierPollStillPending.
  ///
  /// In en, this message translates to:
  /// **'Employee has not scanned QR or confirmed sharing yet'**
  String get verifierPollStillPending;

  /// No description provided for @verifierSharedInfo.
  ///
  /// In en, this message translates to:
  /// **'Employee shared information'**
  String get verifierSharedInfo;

  /// No description provided for @verifierResultValid.
  ///
  /// In en, this message translates to:
  /// **'VALID'**
  String get verifierResultValid;

  /// No description provided for @verifierResultInvalid.
  ///
  /// In en, this message translates to:
  /// **'INVALID'**
  String get verifierResultInvalid;

  /// No description provided for @verifierDisclosedInfo.
  ///
  /// In en, this message translates to:
  /// **'Disclosed Information'**
  String get verifierDisclosedInfo;

  /// No description provided for @verifierVpRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'VP Rejected'**
  String get verifierVpRejectedTitle;

  /// No description provided for @verifierVpSharedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared Information'**
  String get verifierVpSharedTitle;

  /// No description provided for @verifierVpInvalidDefault.
  ///
  /// In en, this message translates to:
  /// **'VP invalid or rejected'**
  String get verifierVpInvalidDefault;

  /// No description provided for @verifierEmployeeConfirmedNoFields.
  ///
  /// In en, this message translates to:
  /// **'Employee confirmed but no fields were shared.'**
  String get verifierEmployeeConfirmedNoFields;

  /// No description provided for @verifierEmployeeSharedInfo.
  ///
  /// In en, this message translates to:
  /// **'Employee confirmed and shared the following:'**
  String get verifierEmployeeSharedInfo;

  /// No description provided for @verifierClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get verifierClose;

  /// No description provided for @verifierQrInvalidMissingStateNonce.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR: missing state/nonce'**
  String get verifierQrInvalidMissingStateNonce;

  /// No description provided for @verifierShareRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Information sharing request'**
  String get verifierShareRequestTitle;

  /// No description provided for @verifierShareRequestWarning.
  ///
  /// In en, this message translates to:
  /// **'Verifier is requesting the following information. Only confirm if you trust the requester.'**
  String get verifierShareRequestWarning;

  /// No description provided for @verifierRequestedInfo.
  ///
  /// In en, this message translates to:
  /// **'Requested information:'**
  String get verifierRequestedInfo;

  /// No description provided for @verifierDenyShare.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get verifierDenyShare;

  /// No description provided for @verifierConfirmShare.
  ///
  /// In en, this message translates to:
  /// **'Confirm Share'**
  String get verifierConfirmShare;

  // ── Profile screen extras ──────────────────────────────────────────────────

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get profileLoading;

  /// No description provided for @profileSetupHint.
  ///
  /// In en, this message translates to:
  /// **'Set up your profile to use all features'**
  String get profileSetupHint;

  /// No description provided for @profileSetup.
  ///
  /// In en, this message translates to:
  /// **'Set Up Profile'**
  String get profileSetup;

  /// No description provided for @profileCreated.
  ///
  /// In en, this message translates to:
  /// **'Profile created successfully'**
  String get profileCreated;

  /// No description provided for @profileStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1/2 — Work Information'**
  String get profileStep1;

  /// No description provided for @profileStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2/2 — Personal Information'**
  String get profileStep2;

  /// No description provided for @profileDepartmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Department *'**
  String get profileDepartmentLabel;

  /// No description provided for @profileDepartmentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Board of Directors'**
  String get profileDepartmentHint;

  /// No description provided for @profilePositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position *'**
  String get profilePositionLabel;

  /// No description provided for @profilePositionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chief Executive Officer'**
  String get profilePositionHint;

  /// No description provided for @profileWorkingTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Working Type'**
  String get profileWorkingTypeLabel;

  /// No description provided for @profileFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get profileFullNameLabel;

  /// No description provided for @profileFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Nguyen Van A'**
  String get profileFullNameHint;

  /// No description provided for @profileDobLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth *'**
  String get profileDobLabel;

  /// No description provided for @profileSelectDob.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get profileSelectDob;

  /// No description provided for @profileIdentityDocLabel.
  ///
  /// In en, this message translates to:
  /// **'Identity Document'**
  String get profileIdentityDocLabel;

  /// No description provided for @profileIdentityDocNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Document Number *'**
  String get profileIdentityDocNumberLabel;

  /// No description provided for @profileIdentityIssueYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue Year *'**
  String get profileIdentityIssueYearLabel;

  /// No description provided for @profileIdentityIssuePlaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue Place *'**
  String get profileIdentityIssuePlaceLabel;

  /// No description provided for @profileIdentityIssuePlaceHint.
  ///
  /// In en, this message translates to:
  /// **'Department of Police'**
  String get profileIdentityIssuePlaceHint;

  /// No description provided for @profileEmergencySection.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get profileEmergencySection;

  /// No description provided for @profileEmergencyFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Nguyen Thi B'**
  String get profileEmergencyFullNameHint;

  /// No description provided for @profileEmergencyPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get profileEmergencyPhoneLabel;

  /// No description provided for @profileEmergencyRelLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship *'**
  String get profileEmergencyRelLabel;

  /// No description provided for @profileEmergencyRelHint.
  ///
  /// In en, this message translates to:
  /// **'Father/Mother, Husband/Wife'**
  String get profileEmergencyRelHint;

  /// No description provided for @profileResidenceHealthSection.
  ///
  /// In en, this message translates to:
  /// **'Residence & Health'**
  String get profileResidenceHealthSection;

  /// No description provided for @profilePermanentAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Permanent Address *'**
  String get profilePermanentAddressLabel;

  /// No description provided for @profileAddressHint.
  ///
  /// In en, this message translates to:
  /// **'House number, street, ward, district, province'**
  String get profileAddressHint;

  /// No description provided for @profileCurrentAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Address *'**
  String get profileCurrentAddressLabel;

  /// No description provided for @profileHealthLabel.
  ///
  /// In en, this message translates to:
  /// **'Health Status *'**
  String get profileHealthLabel;

  /// No description provided for @profileHealthHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Good'**
  String get profileHealthHint;

  /// No description provided for @profileMaritalLabel.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get profileMaritalLabel;

  /// No description provided for @profileEducationSkillsSection.
  ///
  /// In en, this message translates to:
  /// **'Education & Skills'**
  String get profileEducationSkillsSection;

  /// No description provided for @profileEducationLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Education Level *'**
  String get profileEducationLevelLabel;

  /// No description provided for @profileEducationLevelHint.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get profileEducationLevelHint;

  /// No description provided for @profileMajorLabel.
  ///
  /// In en, this message translates to:
  /// **'Major *'**
  String get profileMajorLabel;

  /// No description provided for @profileMajorHint.
  ///
  /// In en, this message translates to:
  /// **'Information Technology'**
  String get profileMajorHint;

  /// No description provided for @profileExpYearsLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience (years) *'**
  String get profileExpYearsLabel;

  /// No description provided for @profileSkillsLabel.
  ///
  /// In en, this message translates to:
  /// **'Skills *'**
  String get profileSkillsLabel;

  /// No description provided for @profileSkillsHint.
  ///
  /// In en, this message translates to:
  /// **'Flutter, Kotlin (comma separated)'**
  String get profileSkillsHint;

  /// No description provided for @profileNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get profileNext;

  /// No description provided for @profileSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get profileSaveProfile;

  /// No description provided for @profileRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get profileRequired;

  /// No description provided for @profileError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get profileError;

  // ── Onboarding personal screen extras ─────────────────────────────────────

  /// No description provided for @onboardingProvince.
  ///
  /// In en, this message translates to:
  /// **'Province / City'**
  String get onboardingProvince;

  /// No description provided for @onboardingDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get onboardingDistrict;

  /// No description provided for @onboardingWard.
  ///
  /// In en, this message translates to:
  /// **'Ward'**
  String get onboardingWard;

  /// No description provided for @onboardingPersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get onboardingPersonalTitle;

  /// No description provided for @onboardingPersonalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile for admin approval'**
  String get onboardingPersonalSubtitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip, complete later'**
  String get onboardingSkip;

  /// No description provided for @onboardingSelectYear.
  ///
  /// In en, this message translates to:
  /// **'Select year'**
  String get onboardingSelectYear;

  /// No description provided for @onboardingFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get onboardingFullNameLabel;

  /// No description provided for @onboardingGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender *'**
  String get onboardingGenderLabel;

  /// No description provided for @onboardingDobLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth *'**
  String get onboardingDobLabel;

  /// No description provided for @onboardingSelectDob.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get onboardingSelectDob;

  /// No description provided for @onboardingIdentityDocSection.
  ///
  /// In en, this message translates to:
  /// **'Identity Document'**
  String get onboardingIdentityDocSection;

  /// No description provided for @onboardingIdentityDocTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Document Type *'**
  String get onboardingIdentityDocTypeLabel;

  /// No description provided for @onboardingIdentityDocNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Document Number *'**
  String get onboardingIdentityDocNumberLabel;

  /// No description provided for @onboardingIssueYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue Year *'**
  String get onboardingIssueYearLabel;

  /// No description provided for @onboardingIssuePlaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Issue Place *'**
  String get onboardingIssuePlaceLabel;

  /// No description provided for @onboardingEmergencySection.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get onboardingEmergencySection;

  /// No description provided for @onboardingEmergencyFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Nguyen Thi B'**
  String get onboardingEmergencyFullNameHint;

  /// No description provided for @onboardingEmergencyPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number *'**
  String get onboardingEmergencyPhoneLabel;

  /// No description provided for @onboardingEmergencyRelLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship *'**
  String get onboardingEmergencyRelLabel;

  /// No description provided for @onboardingResidenceHealthSection.
  ///
  /// In en, this message translates to:
  /// **'Residence & Health'**
  String get onboardingResidenceHealthSection;

  /// No description provided for @onboardingPermanentAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Permanent Address *'**
  String get onboardingPermanentAddressLabel;

  /// No description provided for @onboardingCurrentAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Address *'**
  String get onboardingCurrentAddressLabel;

  /// No description provided for @onboardingHealthStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Health Status *'**
  String get onboardingHealthStatusLabel;

  /// No description provided for @onboardingMaritalStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Marital Status *'**
  String get onboardingMaritalStatusLabel;

  /// No description provided for @onboardingEducationSkillsSection.
  ///
  /// In en, this message translates to:
  /// **'Education & Skills'**
  String get onboardingEducationSkillsSection;

  /// No description provided for @onboardingEducationLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Education Level *'**
  String get onboardingEducationLevelLabel;

  /// No description provided for @onboardingMajorLabel.
  ///
  /// In en, this message translates to:
  /// **'Major *'**
  String get onboardingMajorLabel;

  /// No description provided for @onboardingMajorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Information Technology'**
  String get onboardingMajorHint;

  /// No description provided for @onboardingExpYearsLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience (years) *'**
  String get onboardingExpYearsLabel;

  /// No description provided for @onboardingExpYearsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3'**
  String get onboardingExpYearsHint;

  /// No description provided for @onboardingSkillsLabel.
  ///
  /// In en, this message translates to:
  /// **'Skills *'**
  String get onboardingSkillsLabel;

  /// No description provided for @onboardingSkillsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Flutter, Kotlin, Spring Boot (comma separated)'**
  String get onboardingSkillsHint;

  /// No description provided for @onboardingCertificateLabel.
  ///
  /// In en, this message translates to:
  /// **'Certificates (optional)'**
  String get onboardingCertificateLabel;

  /// No description provided for @onboardingCertificateHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. AWS, PMP (comma separated)'**
  String get onboardingCertificateHint;

  /// No description provided for @onboardingCompleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get onboardingCompleteBtn;

  /// No description provided for @onboardingValidateFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get onboardingValidateFullName;

  /// No description provided for @onboardingValidateDob.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get onboardingValidateDob;

  /// No description provided for @onboardingValidateDocNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter document number'**
  String get onboardingValidateDocNumber;

  /// No description provided for @onboardingValidateIssueYear.
  ///
  /// In en, this message translates to:
  /// **'Please select issue year'**
  String get onboardingValidateIssueYear;

  /// No description provided for @onboardingValidatePhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get onboardingValidatePhone;

  /// No description provided for @onboardingValidatePhoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get onboardingValidatePhoneFormat;

  /// No description provided for @onboardingValidatePermanentAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select permanent address'**
  String get onboardingValidatePermanentAddress;

  /// No description provided for @onboardingValidateCurrentAddress.
  ///
  /// In en, this message translates to:
  /// **'Please select current address'**
  String get onboardingValidateCurrentAddress;

  /// No description provided for @onboardingValidateMajor.
  ///
  /// In en, this message translates to:
  /// **'Please enter major'**
  String get onboardingValidateMajor;

  /// No description provided for @onboardingValidateExpYears.
  ///
  /// In en, this message translates to:
  /// **'Please enter experience years'**
  String get onboardingValidateExpYears;

  /// No description provided for @onboardingValidateSkills.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 1 skill'**
  String get onboardingValidateSkills;

  /// No description provided for @onboardingGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get onboardingGenericError;

  // ── Auth screen extras ─────────────────────────────────────────────────────

  /// No description provided for @authSignInPending.
  ///
  /// In en, this message translates to:
  /// **'Account is pending admin approval. Please try again later.'**
  String get authSignInPending;

  /// No description provided for @authSignInRejected.
  ///
  /// In en, this message translates to:
  /// **'Account has been rejected. Please contact Admin.'**
  String get authSignInRejected;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please check your credentials.'**
  String get authSignInFailed;

  /// No description provided for @authSignUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed'**
  String get authSignUpFailed;

  // ── Gender / Marital helpers ───────────────────────────────────────────────

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @marriedSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get marriedSingle;

  /// No description provided for @marriedMarried.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get marriedMarried;

  /// No description provided for @marriedDivorced.
  ///
  /// In en, this message translates to:
  /// **'Divorced'**
  String get marriedDivorced;

  /// No description provided for @marriedWidowed.
  ///
  /// In en, this message translates to:
  /// **'Widowed'**
  String get marriedWidowed;

  /// No description provided for @marriedSeparated.
  ///
  /// In en, this message translates to:
  /// **'Separated'**
  String get marriedSeparated;

  /// No description provided for @marriedEngaged.
  ///
  /// In en, this message translates to:
  /// **'Engaged'**
  String get marriedEngaged;

  /// No description provided for @marriedRemarried.
  ///
  /// In en, this message translates to:
  /// **'Remarried'**
  String get marriedRemarried;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
