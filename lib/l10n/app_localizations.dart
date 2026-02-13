import 'package:flutter/material.dart';
import 'app_en.dart';
import 'app_hi.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'hi':
        return hiStrings;
      case 'en':
      default:
        return enStrings;
    }
  }

  String get appName => _strings['appName']!;
  String get hello => _strings['hello']!;
  String get searchServices => _strings['searchServices']!;
  String get whatLookingFor => _strings['whatLookingFor']!;
  String get popularNearYou => _strings['popularNearYou']!;
  String get home => _strings['home']!;
  String get bookings => _strings['bookings']!;
  String get profile => _strings['profile']!;
  String get signIn => _strings['signIn']!;
  String get signUp => _strings['signUp']!;
  String get createAccount => _strings['createAccount']!;
  String get email => _strings['email']!;
  String get password => _strings['password']!;
  String get fullName => _strings['fullName']!;
  String get phone => _strings['phone']!;
  String get logout => _strings['logout']!;
  String get settings => _strings['settings']!;
  String get language => _strings['language']!;
  String get cleaning => _strings['cleaning']!;
  String get plumbing => _strings['plumbing']!;
  String get electrician => _strings['electrician']!;
  String get painting => _strings['painting']!;
  String get acRepair => _strings['acRepair']!;
  String get salon => _strings['salon']!;
  String get pestControl => _strings['pestControl']!;
  String get carpentry => _strings['carpentry']!;
  String get describeIssue => _strings['describeIssue']!;
  String get submitRequest => _strings['submitRequest']!;
  String get findProfessionals => _strings['findProfessionals']!;
  String get matchedPros => _strings['matchedPros']!;
  String get bestMatch => _strings['bestMatch']!;
  String get startChat => _strings['startChat']!;
  String get sendMessage => _strings['sendMessage']!;
  String get typeMessage => _strings['typeMessage']!;
  String get proposePrice => _strings['proposePrice']!;
  String get acceptPrice => _strings['acceptPrice']!;
  String get payment => _strings['payment']!;
  String get totalAmount => _strings['totalAmount']!;
  String get paymentMethod => _strings['paymentMethod']!;
  String get creditCard => _strings['creditCard']!;
  String get upi => _strings['upi']!;
  String get cash => _strings['cash']!;
  String get payAfterService => _strings['payAfterService']!;
  String get payNow => _strings['payNow']!;
  String get bookingHistory => _strings['bookingHistory']!;
  String get noBookings => _strings['noBookings']!;
  String get completed => _strings['completed']!;
  String get inProgress => _strings['inProgress']!;
  String get pending => _strings['pending']!;
  String get review => _strings['review']!;
  String get submitReview => _strings['submitReview']!;
  String get writeReview => _strings['writeReview']!;
  String get availableNow => _strings['availableNow']!;
  String get jobsDone => _strings['jobsDone']!;
  String get setLocation => _strings['setLocation']!;
  String get iNeedService => _strings['iNeedService']!;
  String get iOfferService => _strings['iOfferService']!;
  String get alreadyAccount => _strings['alreadyAccount']!;
  String get enterUpiId => _strings['enterUpiId']!;
  String get chatNow => _strings['chatNow']!;
  String get priceNegotiation => _strings['priceNegotiation']!;
  String get aiMatch => _strings['aiMatch']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
