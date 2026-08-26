import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dube/models/customer_reliability.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en', ''));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('am', ''),
    Locale('om', ''),
  ];

  String get languageCode => locale.languageCode;

  // --- GENERAL & APP ---
  String get appTitle => _select(
        en: 'Dube',
        am: 'ድቤ',
        om: 'Dube',
      );

  String get appSubtitle => _select(
        en: 'Offline Credit Ledger',
        am: 'ከመስመር ውጭ የብድር መዝገብ',
        om: 'Galmee Liqii Toora Alaa',
      );

  String get language => _select(
        en: 'Language',
        am: 'ቋንቋ',
        om: 'Afaan',
      );

  String get selectLanguage => _select(
        en: 'Select Language',
        am: 'ቋንቋ ይምረጡ',
        om: 'Afaan Filadhaa',
      );

  String get continueBtn => _select(
        en: 'Continue',
        am: 'ቀጥል',
        om: 'Itti Fufi',
      );

  String get dashboard => _select(
        en: 'Credit Ledger Dashboard',
        am: 'የብድር መዝገብ ዳሽቦርድ',
        om: 'Daashboordii Galmee Liqii',
      );

  String get searchHint => _select(
        en: 'Search customer, phone, or item...',
        am: 'ደንበኛ፣ ስልክ ወይም ዕቃ ፈልግ...',
        om: 'Maamila, bilbila ykn meeshaa barbaadaa...',
      );

  // --- BUTTONS & COMMON ACTIONS ---
  String get save => _select(
        en: 'Save',
        am: 'መዝግብ',
        om: 'Galmeessi',
      );

  String get saving => _select(
        en: 'Saving...',
        am: 'በመመዝገብ ላይ...',
        om: 'Galmeessaa jira...',
      );

  String get cancel => _select(
        en: 'Cancel',
        am: 'ሰርዝ',
        om: 'Haqi',
      );

  String get delete => _select(
        en: 'Delete',
        am: 'አጥፋ',
        om: 'Balleessi',
      );

  String get confirm => _select(
        en: 'Confirm',
        am: 'አረጋግጥ',
        om: 'Mirkaneessi',
      );

  String get edit => _select(
        en: 'Edit',
        am: 'አስተካክል',
        om: 'Gulaali',
      );

  String get retry => _select(
        en: 'Retry',
        am: 'እንደገና ሞክር',
        om: 'Irra Deebi\'i',
      );

  String get close => _select(
        en: 'Close',
        am: 'ዝጋ',
        om: 'Cufi',
      );

  String get call => _select(
        en: 'Call',
        am: 'ደውል',
        om: 'Bilbili',
      );

  String get sendSms => _select(
        en: 'Send SMS',
        am: 'መልዕክት ላክ',
        om: 'Ergaa Ergi',
      );

  // --- DASHBOARD HEADERS & METRICS ---
  String get totalBalance => _select(
        en: 'Total Balance',
        am: 'ጠቅላላ ቀሪ',
        om: 'Haftee Waliigalaa',
      );

  String get totalDue => _select(
        en: 'Total Outstanding',
        am: 'ጠቅላላ ቀሪ',
        om: 'Haftee Waliigalaa',
      );

  String get overdueAccounts => _select(
        en: 'Overdue Debts',
        am: 'ቀነ-ገደብ ያለፈባቸው',
        om: 'Liqii Yeroon Darbe',
      );

  String get customers => _select(
        en: 'Customers',
        am: 'ደንበኞች',
        om: 'Maamiltoota',
      );

  String get debtors => _select(
        en: 'Debtors',
        am: 'ባለዕዳዎች',
        om: 'Liqeeffattoota',
      );

  String get totalPrefix => _select(
        en: 'Total:',
        am: 'ጠቅላላ፡',
        om: 'Waliigala:',
      );

  String get duePrefix => _select(
        en: 'Due',
        am: 'ቀጠሮ፡',
        om: 'Beellama:',
      );

  // --- FILTERS & STATUS CHIPS ---
  String get all => _select(
        en: 'All',
        am: 'ሁሉም',
        om: 'Hundaa',
      );

  String get active => _select(
        en: 'Active',
        am: 'ንቁ',
        om: 'Hojii Irra',
      );

  String get overdue => _select(
        en: 'Overdue',
        am: 'ያለፈበት',
        om: 'Yeroon Darbe',
      );

  String get paid => _select(
        en: 'Settled',
        am: 'የተከፈለ',
        om: 'Kaffalame',
      );

  String get settled => _select(
        en: 'Settled',
        am: 'የተከፈለ',
        om: 'Kaffalame',
      );

  String get unpaid => _select(
        en: 'Unpaid',
        am: 'ያልተከፈለ',
        om: 'Hin Kaffalamne',
      );

  // --- EMPTY STATES ---
  String get noRecordsYet => _select(
        en: 'No Dube records yet.\nTap Record Dube to add your first entry.',
        am: 'ምንም የድቤ መዝገብ የለም።\nየመጀመሪያውን ለማከል ዕዳ መዝግብ የሚለውን ይጫኑ።',
        om: 'Galmeen dube hin jiru.\nLiqii duraa galmeessuuf Liqii Galmeessi tuqaa.',
      );

  String get noPaidDebts => _select(
        en: 'No settled debts found.',
        am: 'ምንም የተከፈለ ዕዳ አልተገኘም።',
        om: 'Liqiin kaffalame hin argamne.',
      );

  String get noMatchingDebtors => _select(
        en: 'No matching customers found.',
        am: 'ምንም ተዛማጅ ደንበኛ አልተገኘም።',
        om: 'Maamilli walsimu hin argamne.',
      );

  String get noOpenDube => _select(
        en: 'No active open Dube for this customer.',
        am: 'ለዚህ ደንበኛ ምንም ያልተከፈለ ንቁ ድቤ የለም።',
        om: 'Maamila kanaaf liqiin banaa hin jiru.',
      );

  String get noDubeRecorded => _select(
        en: 'No Dube records exist for this customer.',
        am: 'ለዚህ ደንበኛ ምንም የድቤ መዝገብ የለም።',
        om: 'Maamila kanaaf galmeen dube hin jiru.',
      );

  String get noDubeForCustomerYet => _select(
        en: 'No Dube debts recorded for this customer yet.',
        am: 'ለዚህ ደንበኛ እስካሁን የተመዘገበ ዕዳ የለም።',
        om: 'Maamila kanaaf liqiin galmaa\'e hin jiru.',
      );

  String get noHistory => _select(
        en: 'No repayment history recorded yet.',
        am: 'ምንም የክፍያ ታሪክ እስካሁን አልተመዘገበም።',
        om: 'Seenaan kaffaltii hin galmoofne.',
      );

  // --- FORM FIELDS & LABELS ---
  String get recordDebt => _select(
        en: 'Record Debt',
        am: 'ዕዳ መዝግብ',
        om: 'Liqii Galmeessi',
      );

  String get customer => _select(
        en: 'Customer',
        am: 'ደንበኛ',
        om: 'Maamila',
      );

  String get name => _select(
        en: 'Customer Name',
        am: 'ስም',
        om: 'Maqaa',
      );

  String get nameHint => _select(
        en: 'e.g. Abebe Bikila',
        am: 'ምሳሌ፡ አበበ ቢቂላ',
        om: 'fkn. Tolasaa Caalaa',
      );

  String get phone => _select(
        en: 'Phone Number',
        am: 'ስልክ ቁጥር',
        om: 'Lakkoofsa Bilbilaa',
      );

  String get phoneHint => _select(
        en: '09xxxxxxxx',
        am: '09xxxxxxxx',
        om: '09xxxxxxxx',
      );

  String get nameRequired => _select(
        en: 'Please enter customer name',
        am: 'እባክዎ የደንበኛውን ስም ያስገቡ',
        om: 'Maaloo maqaa maamilaa galchaa',
      );

  String get phoneRequired => _select(
        en: 'Please enter phone number',
        am: 'እባክዎ ስልክ ቁጥር ያስገቡ',
        om: 'Maaloo lakkoofsa bilbilaa galchaa',
      );

  String get phoneTooShort => _select(
        en: 'Phone number is too short',
        am: 'ስልክ ቁጥሩ በጣም አጭር ነው',
        om: 'Lakkoofsi bilbilaa gabaabaa dha',
      );

  String existingCustomerNamed(String customerName) => _select(
        en: 'Existing customer: $customerName',
        am: 'ነባር ደንበኛ፡ $customerName',
        om: 'Maamila duraanii: $customerName',
      );

  String get dubeDetails => _select(
        en: 'Credit Details',
        am: 'የድቤ ዝርዝር',
        om: 'Ibsa Liqii',
      );

  String get itemDetails => _select(
        en: 'Items / Goods Description',
        am: 'የተወሰዱ ዕቃዎች',
        om: 'Meeshaalee Fudhataman',
      );

  String get itemHint => _select(
        en: 'e.g. 5kg Sugar, 2L Cooking Oil, Soap',
        am: 'ምሳሌ፡ 5 ኪሎ ስኳር፣ 2 ሊትር ዘይት፣ ሳሙና',
        om: 'fkn. Sukkaara kiiloo 5, Zayita liitira 2, Saamunaa',
      );

  String get itemsRequired => _select(
        en: 'Please describe the items purchased',
        am: 'እባክዎ የተወሰዱትን ዕቃዎች ይግለጹ',
        om: 'Maaloo meeshaalee fudhataman ibsaa',
      );

  String get amountEtb => _select(
        en: 'Total Amount (ETB)',
        am: 'መጠን (ብር)',
        om: 'Hamma Qarshii (ETB)',
      );

  String get amountHint => _select(
        en: '0.00',
        am: '0.00',
        om: '0.00',
      );

  String get amountInvalid => _select(
        en: 'Please enter a valid amount',
        am: 'እባክዎ ትክክለኛ መጠን ያስገቡ',
        om: 'Maaloo hamma qarshii sirrii galchaa',
      );

  String get amountMustBePositive => _select(
        en: 'Amount must be greater than 0',
        am: 'መጠኑ ከ0 በላይ መሆን አለበት',
        om: 'Hangi qarshii 0 ol ta\'uu qaba',
      );

  String get dueDate => _select(
        en: 'Due Date',
        am: 'የቀጠሮ ቀን',
        om: 'Guyyaa Beellamaa',
      );

  String get selectDueDate => _select(
        en: 'Select Due Date',
        am: 'የቀጠሮ ቀን ይምረጡ',
        om: 'Guyyaa Beellamaa Filadhaa',
      );

  String get notesOptional => _select(
        en: 'Notes (Optional)',
        am: 'ማስታወሻ (አማራጭ)',
        om: 'Yaada (Dirqama Miti)',
      );

  String get notesHint => _select(
        en: 'Additional remarks or payment arrangement',
        am: 'ተጨማሪ ዝርዝር ወይም የክፍያ ስምምነት',
        om: 'Ibsa dabalataa ykn walii galtee kaffaltii',
      );

  String couldNotSave(String error) => _select(
        en: 'Could not save Dube: $error',
        am: 'ድቤውን ማስቀመጥ አልተቻለም፡ $error',
        om: 'Dube galmeessuun hin danda\'amne: $error',
      );

  // --- CUSTOMER DETAILS & RELIABILITY ---
  String get openAndPastDube => _select(
        en: 'Debts History',
        am: 'የብድር ታሪክ',
        om: 'Seenaa Liqii',
      );

  String get repaymentTimeline => _select(
        en: 'Repayment Activity',
        am: 'የክፍያ እንቅስቃሴዎች',
        om: 'Sochiiwwan Kaffaltii',
      );

  String get repaymentTrackRecord => _select(
        en: 'Repayment Track Record',
        am: 'የክፍያ ታሪክና አስተማማኝነት',
        om: 'Seenaa Kaffaltii fi Amanamummaa',
      );

  String get settledActive => _select(
        en: 'Settled Debts',
        am: 'የተከፈሉ ዕዳዎች',
        om: 'Liqiiwwan Kaffalaman',
      );

  String overdueCountLabel(int count) => _select(
        en: '$count Overdue',
        am: '$count ቀነ-ገደብ ያለፈባቸው',
        om: '$count Yeroon Darbe',
      );

  String totalCountLabel(int count) => _select(
        en: '$count Total',
        am: '$count ጠቅላላ',
        om: '$count Waliigala',
      );

  String get onTimeSettlement => _select(
        en: 'On-Time Settlement',
        am: 'በወቅቱ የመክፈል ምጣኔ',
        om: 'Kaffaltii Yeroo Eeggate',
      );

  String get notAvailable => _select(
        en: 'N/A',
        am: 'የለም',
        om: 'Hin Jiru',
      );

  String onTimeFraction(int onTime, int total) => _select(
        en: '$onTime of $total on time',
        am: 'ከ$totalቱ $onTime በወቅቱ',
        om: '$total keessaa $onTime yeroon',
      );

  String get noHistoryShort => _select(
        en: 'No settled history',
        am: 'የተከፈለ ታሪክ የለም',
        om: 'Seenaan hin jiru',
      );

  String get totalBorrowed => _select(
        en: 'Lifetime Borrowed',
        am: 'ጠቅላላ የተወሰደ',
        om: 'Waliigala Kan Liqeeffame',
      );

  String get totalRepaid => _select(
        en: 'Lifetime Repaid',
        am: 'ጠቅላላ የተከፈለ',
        om: 'Waliigala Kan Kaffalame',
      );

  String get whichDubeExtend => _select(
        en: 'Select Dube to extend due date',
        am: 'የቀጠሮ ቀን የሚራዘምለትን ድቤ ይምረጡ',
        om: 'Guyyaan beellamaa kan dheeratuuf filadhaa',
      );

  String get newDueDateHelp => _select(
        en: 'Select new due date',
        am: 'አዲሱን የቀጠሮ ቀን ይምረጡ',
        om: 'Guyyaa beellamaa haaraa filadhaa',
      );

  String dueDateExtended(String dateStr) => _select(
        en: 'Due date extended to $dateStr',
        am: 'የቀጠሮ ቀን ወደ $dateStr ተራዝሟል',
        om: 'Guyyaan beellamaa gara $dateStr dheerateera',
      );

  String couldNotExtend(String error) => _select(
        en: 'Could not extend due date: $error',
        am: 'የቀጠሮ ቀኑን ማራዘም አልተቻለም፡ $error',
        om: 'Guyyaa beellamaa dheeressuun hin danda\'amne: $error',
      );

  String get noOutstanding => _select(
        en: 'Customer has no outstanding balance.',
        am: 'ደንበኛው ምንም ያልተከፈለ ቀሪ ዕዳ የለበትም።',
        om: 'Maamilichi haftee liqii hin qabu.',
      );

  String smsBody({
    required String name,
    required String amount,
    required String items,
    required String date,
  }) =>
      _select(
        en: 'Hello $name, this is a friendly reminder from your shop regarding your Dube balance of $amount ($items) due on $date. Thank you!',
        am: 'ጤና ይስጥልኝ $name፣ ከሱቃችን የወሰዱት $amount ($items) የድቤ ቀሪ ክፍያ የቀጠሮ ቀን $date መሆኑን በትህትና እናስታውሳለን። እናመሰግናለን!',
        om: 'Akkam $name, suuqii keenya irraa haftee liqii Dube keessan $amount ($items) guyyaa beellamaa $date ta\'uu kabajaan isin yaadachiifna. Galatoomaa!',
      );

  String get couldNotOpenSms => _select(
        en: 'Could not open SMS composer',
        am: 'የመልዕክት መተግበሪያውን መክፈት አልተቻለም',
        om: 'Ergaa banuun hin danda\'amne',
      );

  String couldNotOpenSmsError(String error) => _select(
        en: 'Could not open SMS: $error',
        am: 'መልዕክት መክፈት አልተቻለም፡ $error',
        om: 'Ergaa banuun hin danda\'amne: $error',
      );

  String settledAmount(String amount) => _select(
        en: 'Settled · $amount',
        am: 'የተከፈለ · $amount',
        om: 'Kaffalame · $amount',
      );

  String remainingDue(String remaining, String dueDate) => _select(
        en: 'Remaining: $remaining · Due $dueDate',
        am: 'ቀሪ፡ $remaining · ቀጠሮ $dueDate',
        om: 'Hafte: $remaining · Beellama $dueDate',
      );

  String remainingOf(String remaining, String total) => _select(
        en: '$remaining remaining of $total',
        am: 'ከ$totalቱ ቀሪ $remaining',
        om: '$total keessaa haftee $remaining',
      );

  String get whichDubePaid => _select(
        en: 'Select Dube to record payment',
        am: 'ክፍያ የሚመዘገብለትን ድቤ ይምረጡ',
        om: 'Liqii kaffaltiin galmaa\'uuf filadhaa',
      );

  String get paymentUpdated => _select(
        en: 'Payment recorded successfully',
        am: 'ክፍያው በተሳካ ሁኔታ ተመዝግቧል',
        om: 'Kaffaltiin milkaa\'inaan galmeeffameera',
      );

  String get whichDubeEdit => _select(
        en: 'Select Dube to edit',
        am: 'የሚስተካከለውን ድቤ ይምረጡ',
        om: 'Liqii gulaalamu filadhaa',
      );

  String get dubeUpdated => _select(
        en: 'Dube record updated successfully',
        am: 'የድቤ መዝገብ በተሳካ ሁኔታ ተስተካክሏል',
        om: 'Galmeen dube milkaa\'inaan gulaalameera',
      );

  String get recordPaymentMarkPaid => _select(
        en: 'Record Payment / Settle',
        am: 'ክፍያ መዝግብ / ጨርስ',
        om: 'Kaffaltii Galmeessi / Xumuri',
      );

  String get settleFullOrPartial => _select(
        en: 'Settle remaining balance or record partial payment',
        am: 'ቀሪውን ሙሉ በሙሉ ይክፈሉ ወይም ከፊል ክፍያ ይመዝግቡ',
        om: 'Haftee hunda kaffalaa ykn kaffaltii gar-tokkee galmeessaa',
      );

  String get extendDueDate => _select(
        en: 'Extend Due Date',
        am: 'የቀጠሮ ቀን አራዝም',
        om: 'Guyyaa Beellamaa Dheeressi',
      );

  String currentDue(String date) => _select(
        en: 'Current due date: $date',
        am: 'የአሁኑ የቀጠሮ ቀን፡ $date',
        om: 'Guyyaa beellamaa amma: $date',
      );

  String get editAdjustDube => _select(
        en: 'Edit / Adjust Dube',
        am: 'ዕዳ አስተካክል',
        om: 'Liqii Gulaali',
      );

  String get modifyItems => _select(
        en: 'Modify items description, total amount, or notes',
        am: 'የተወሰዱትን ዕቃዎች፣ መጠን ወይም ማስታወሻ ያስተካክሉ',
        om: 'Ibsa meeshaalee, hamma qarshii ykn yaada gulaalaa',
      );

  // --- RELIABILITY TRUST BADGES ---
  String trustLabelFor(CustomerReliabilityStats stats) {
    if (stats.overdueDebtsCount > 0) {
      return _select(
        en: 'Needs Attention',
        am: 'ትኩረት ያስፈልገዋል',
        om: 'Xiyyeeffannoo Barbaada',
      );
    }
    if (stats.settledDebtsCount >= 3 && stats.onTimeRate >= 0.8) {
      return _select(
        en: 'Highly Reliable',
        am: 'በጣም አስተማማኝ',
        om: 'Baay\'ee Amanamaa',
      );
    }
    if (stats.settledDebtsCount >= 1 && stats.onTimeRate >= 0.7) {
      return _select(
        en: 'Reliable',
        am: 'አስተማማኝ',
        om: 'Amanamaa',
      );
    }
    if (stats.totalDebtsCount == 0) {
      return _select(
        en: 'New Customer',
        am: 'አዲስ ደንበኛ',
        om: 'Maamila Haaraa',
      );
    }
    return _select(
      en: 'Good Standing',
      am: 'ጥሩ ደረጃ',
      om: 'Haala Gaarii',
    );
  }

  String quickSummaryFor(CustomerReliabilityStats stats) {
    final label = trustLabelFor(stats);
    if (stats.overdueDebtsCount > 0) {
      return _select(
        en: '⚠️ ${stats.overdueDebtsCount} overdue account(s) · $label',
        am: '⚠️ ${stats.overdueDebtsCount} ቀነ-ገደብ ያለፈባቸው · $label',
        om: '⚠️ ${stats.overdueDebtsCount} liqii yeroon darbe · $label',
      );
    }
    if (stats.settledDebtsCount > 0) {
      final pct = (stats.onTimeRate * 100).toStringAsFixed(0);
      return _select(
        en: '✓ ${stats.settledDebtsCount} settled ($pct% on time) · $label',
        am: '✓ ${stats.settledDebtsCount} የተከፈሉ ($pct% በወቅቱ) · $label',
        om: '✓ ${stats.settledDebtsCount} kaffalaman ($pct% yeroon) · $label',
      );
    }
    if (stats.openDebtsCount > 0) {
      return _select(
        en: '✓ ${stats.openDebtsCount} active Dube · $label',
        am: '✓ ${stats.openDebtsCount} ንቁ ድቤ · $label',
        om: '✓ ${stats.openDebtsCount} liqii hojii irra · $label',
      );
    }
    return _select(
      en: '✓ New Customer · $label',
      am: '✓ አዲስ ደንበኛ · $label',
      om: '✓ Maamila Haaraa · $label',
    );
  }

  // --- PAYMENTS & EDIT DIALOGS ---
  String get recordPayment => _select(
        en: 'Record Payment',
        am: 'ክፍያ መዝግብ',
        om: 'Kaffaltii Galmeessi',
      );

  String get fullSettlement => _select(
        en: 'Full Settlement',
        am: 'ሙሉ ክፍያ',
        om: 'Kaffaltii Guutuu',
      );

  String get partialPayment => _select(
        en: 'Partial Payment',
        am: 'ከፊል ክፍያ',
        om: 'Kaffaltii Gar-tokkee',
      );

  String get paymentAmount => _select(
        en: 'Payment Amount (ETB)',
        am: 'የክፍያ መጠን (ብር)',
        om: 'Hamma Kaffaltii (ETB)',
      );

  String get paymentNote => _select(
        en: 'Payment Note (Optional)',
        am: 'የክፍያ ማስታወሻ (አማራጭ)',
        om: 'Yaada Kaffaltii (Dirqama Miti)',
      );

  String get editDebt => _select(
        en: 'Edit / Adjust Debt',
        am: 'ዕዳ አስተካክል',
        om: 'Liqii Gulaali',
      );

  String get deleteCustomer => _select(
        en: 'Delete Customer',
        am: 'ደንበኛውን ሰርዝ',
        om: 'Maamila Balleessi',
      );

  String get deleteCustomerConfirm => _select(
        en: 'Are you sure you want to delete this customer and all their debt records? This cannot be undone.',
        am: 'ይህን ደንበኛ እና ሙሉ የዕዳ ታሪኩን መሰረዝ ይፈልጋሉ? ይህ ድርጊት አይመለስም።',
        om: 'Maamila kanaa fi seenaa liqii isaanii hunda balleessuu barbaadduu? Tarkaanfiin kun hin deebi\'u.',
      );

  String get deleteDebtConfirm => _select(
        en: 'Are you sure you want to delete this debt record?',
        am: 'ይህን የዕዳ መዝገብ መሰረዝ ይፈልጋሉ?',
        om: 'Galmee liqii kana balleessuu barbaadduu?',
      );

  // --- MONETIZATION & ADS ---
  String get sponsored => _select(
        en: 'Sponsored',
        am: 'የተደገፈ',
        om: 'Deeggarame',
      );

  String get callSponsor => _select(
        en: 'Call',
        am: 'ደውል',
        om: 'Bilbili',
      );

  // --- CURRENCY SETTINGS ---
  String get currency => _select(
        en: 'Currency',
        am: 'የገንዘብ ምልክት',
        om: 'Mallattoo Qarshii',
      );

  String get selectCurrency => _select(
        en: 'Select Currency',
        am: 'የገንዘብ ምልክት ይምረጡ',
        om: 'Mallattoo Qarshii Filadhaa',
      );

  String get customCurrency => _select(
        en: 'Custom Currency...',
        am: 'ብጁ የገንዘብ ምልክት...',
        om: 'Mallattoo Qarshii Addaa...',
      );

  String get enterCurrencyHint => _select(
        en: 'Enter currency symbol or code (e.g. USD, KSh, FCFA)',
        am: 'የገንዘብ ምልክት ወይም ምህፃረ ቃል ያስገቡ (ምሳሌ፡ USD, KSh, FCFA)',
        om: 'Mallattoo ykn koodii qarshii galchaa (fkn. USD, KSh, FCFA)',
      );

  // --- SHOPKEEPER DAILY NOTEPAD / SCRATCHPAD ---
  String get dailyNotes => _select(
        en: 'Daily Notes',
        am: 'የዕለት ማስታወሻ',
        om: 'Yaadannoo Guyyaa',
      );

  String get scratchpad => _select(
        en: 'Shop Scratchpad',
        am: 'ፈጣን ማስታወሻ',
        om: 'Yaadannoo Suuqii',
      );

  String get addNote => _select(
        en: 'Add Note',
        am: 'ማስታወሻ ጻፍ',
        om: 'Yaadannoo Galmeessi',
      );

  String get editNote => _select(
        en: 'Edit Note',
        am: 'ማስታወሻ አርም',
        om: 'Yaadannoo Gulaali',
      );

  String get noteTitle => _select(
        en: 'Title (Optional)',
        am: 'አርዕስት (አማራጭ)',
        om: 'Mata Duree (Filannoo)',
      );

  String get noteContent => _select(
        en: 'Note details, restock items, or cash tally...',
        am: 'የማስታወሻው ዝርዝር፣ የእቃ ማዘዣ ወይም የሂሳብ ማጠቃለያ...',
        om: 'Qabiyyee yaadannoo, meeshaalee barbaadaman ykn shallaggii...',
      );

  String get isTodoChecklist => _select(
        en: 'To-Do / Restock Checklist',
        am: 'የተግባር / የእቃ ዝርዝር',
        om: 'Tarree Hojii / Meeshaa',
      );

  String get pinToTop => _select(
        en: 'Pin to Top',
        am: 'ከላይ ሰካ',
        om: 'Gubbaatti Qabsiisi',
      );

  String get pinned => _select(
        en: 'Pinned',
        am: 'የተሰካ',
        om: 'Qabsiifame',
      );

  String get unpin => _select(
        en: 'Unpin',
        am: 'አውርድ',
        om: 'Qabsiisa Kaasi',
      );

  String get noNotesYet => _select(
        en: 'No notes yet.\nTap + to jot down supplier deliveries, restock lists, or daily tallies.',
        am: 'ምንም ማስታወሻ የለም።\nየአቅራቢ ዕቃዎችን፣ የሚያልቁ ሸቀጦችን ወይም የዕለት ሂሳብ ለመጻፍ + ይጫኑ።',
        om: 'Yaadannoon hin jiru.\nAjaja dhiyeessitootaa, meeshaalee dhumanii fi shallaggii guyyaa galmeessuuf + tuqaa.',
      );

  String get noteDeleted => _select(
        en: 'Note deleted',
        am: 'ማስታወሻው ተሰርዟል',
        om: 'Yaadannoon haqameera',
      );

  String get allNotes => _select(
        en: 'All Notes',
        am: 'ሁሉም',
        om: 'Hundaa',
      );

  String get pinnedNotes => _select(
        en: 'Pinned',
        am: 'የተሰኩ',
        om: 'Qabsiifaman',
      );

  String get todosOnly => _select(
        en: 'Checklists',
        am: 'የተግባር ዝርዝሮች',
        om: 'Tarree Hojii',
      );

  String get markDone => _select(
        en: 'Completed',
        am: 'የተጠናቀቀ',
        om: 'Xumurame',
      );

  String get ledgerTab => _select(
        en: 'Credit Ledger',
        am: 'የብድር መዝገብ',
        om: 'Galmee Liqii',
      );

  String get notesTab => _select(
        en: 'Daily Notes',
        am: 'የሱቅ ማስታወሻ',
        om: 'Yaadannoo Suuqii',
      );

  // --- HELPER METHOD ---
  String _select({
    required String en,
    required String am,
    required String om,
  }) {
    switch (locale.languageCode) {
      case 'am':
        return am;
      case 'om':
        return om;
      case 'en':
      default:
        return en;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'am', 'om'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
