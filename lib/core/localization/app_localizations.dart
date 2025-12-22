import 'dart:async';
import 'package:flutter/material.dart';
import 'en.dart';
import 'am.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    if (locale.languageCode == 'am') {
      _localizedStrings = AppLocalizationsAm.translations;
    } else {
      _localizedStrings = AppLocalizationsEn.translations;
    }
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Convenience getters
  String get appName => translate('app_name');
  String get appNameAmharic => translate('app_name_amharic');
  
  // Auth
  String get welcomeBack => translate('welcome_back');
  String get loginToAccount => translate('login_to_account');
  String get createAccount => translate('create_account');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get fullName => translate('full_name');
  String get phoneNumber => translate('phone_number');
  String get login => translate('login');
  String get signup => translate('signup');
  String get forgotPassword => translate('forgot_password');
  String get dontHaveAccount => translate('dont_have_account');
  String get alreadyHaveAccount => translate('already_have_account');
  
  // Navigation
  String get home => translate('home');
  String get charts => translate('charts');
  String get settings => translate('settings');
  String get analytics => translate('analytics');
  String get dashboard => translate('dashboard');
  
  // Settings
  String get darkMode => translate('dark_mode');
  String get language => translate('language');
  String get english => translate('english');
  String get amharic => translate('amharic');
  String get exportData => translate('export_data');
  String get notifications => translate('notifications');
  String get about => translate('about');
  String get version => translate('version');
  String get developedBy => translate('developed_by');
  
  // Sensors
  String get soilMoisture => translate('soil_moisture');
  String get temperature => translate('temperature');
  String get humidity => translate('humidity');
  String get light => translate('light');
  String get battery => translate('battery');
  String get waterUsed => translate('water_used');
  
  // Analytics
  String get avgMoisture => translate('avg_moisture');
  String get avgTemperature => translate('avg_temperature');
  String get waterSaved => translate('water_saved');
  String get waterSavedAmount => translate('water_saved_amount');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'am'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
