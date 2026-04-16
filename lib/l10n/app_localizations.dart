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
