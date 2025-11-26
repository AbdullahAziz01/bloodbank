/// Localization utility for English/Urdu language support
/// TODO: Integrate with flutter_localizations for proper i18n support
library;

class Localization {
  static String currentLanguage = 'en'; // 'en' or 'ur'

  static void setLanguage(String lang) {
    currentLanguage = lang;
  }

  static String get(String key) {
    if (currentLanguage == 'ur') {
      return ur[key] ?? en[key] ?? key;
    }
    return en[key] ?? key;
  }

  // English translations
  static final Map<String, String> en = {
    'appTitle': 'BloodBank',
    'tagline': 'Donate Blood, Save Lives',
    'donor': 'Donor',
    'recipient': 'Recipient',
    'donorDesc': 'Help save lives by donating blood',
    'recipientDesc': 'Find donors for your blood needs',
    'login': 'Login',
    'register': 'Register',
    'email': 'Email',
    'password': 'Password',
    'fullName': 'Full Name',
    'phoneNumber': 'Phone Number',
    'bloodGroup': 'Blood Group',
    'city': 'City',
    'selectBloodGroup': 'Select Blood Group',
    'welcome': 'Welcome',
    'requestsNearYou': 'Requests Near You',
    'findDonors': 'Find Donors Near You',
    'postRequest': 'Post Request',
    'contact': 'Contact',
    'profile': 'Profile',
    'logout': 'Logout',
    'editProfile': 'Edit Profile',
    'language': 'Language',
    'darkMode': 'Dark Mode',
    'english': 'English',
    'urdu': 'Urdu',
    'units': 'Units',
    'hospitalName': 'Hospital Name',
    'urgency': 'Urgency',
    'note': 'Note',
    'submit': 'Submit',
    'high': 'High',
    'medium': 'Medium',
    'low': 'Low',
    'available': 'Available',
    'notAvailable': 'Not Available',
    'km': 'km',
    'away': 'away',
    'lastDonation': 'Last Donation',
    'timeAgo': 'ago',
    'requestPosted': 'Request posted successfully!',
    'loginSuccess': 'Login successful!',
    'registerSuccess': 'Registration successful!',
    'invalidCredentials': 'Invalid email or password',
    'fillAllFields': 'Please fill all fields',
    'selectRole': 'Select Your Role',
  };

  // Urdu translations
  static final Map<String, String> ur = {
    'appTitle': 'بلڈ بینک',
    'tagline': 'خون دیں، زندگیاں بچائیں',
    'donor': 'دونر',
    'recipient': 'وصول کنندہ',
    'donorDesc': 'خون دے کر زندگیاں بچانے میں مدد کریں',
    'recipientDesc': 'اپنی خون کی ضروریات کے لیے دونر تلاش کریں',
    'login': 'لاگ ان',
    'register': 'رجسٹر',
    'email': 'ای میل',
    'password': 'پاس ورڈ',
    'fullName': 'پورا نام',
    'phoneNumber': 'فون نمبر',
    'bloodGroup': 'بلڈ گروپ',
    'city': 'شہر',
    'selectBloodGroup': 'بلڈ گروپ منتخب کریں',
    'welcome': 'خوش آمدید',
    'requestsNearYou': 'آپ کے قریب درخواستیں',
    'findDonors': 'آپ کے قریب دونر تلاش کریں',
    'postRequest': 'درخواست پوسٹ کریں',
    'contact': 'رابطہ',
    'profile': 'پروفائل',
    'logout': 'لاگ آؤٹ',
    'editProfile': 'پروفائل میں ترمیم کریں',
    'language': 'زبان',
    'darkMode': 'ڈارک موڈ',
    'english': 'انگریزی',
    'urdu': 'اردو',
    'units': 'یونٹس',
    'hospitalName': 'ہسپتال کا نام',
    'urgency': 'فوری',
    'note': 'نوٹ',
    'submit': 'جمع کروائیں',
    'high': 'زیادہ',
    'medium': 'درمیانی',
    'low': 'کم',
    'available': 'دستیاب',
    'notAvailable': 'دستیاب نہیں',
    'km': 'کلومیٹر',
    'away': 'دور',
    'lastDonation': 'آخری عطیہ',
    'timeAgo': 'پہلے',
    'requestPosted': 'درخواست کامیابی سے پوسٹ ہو گئی!',
    'loginSuccess': 'لاگ ان کامیاب!',
    'registerSuccess': 'رجسٹریشن کامیاب!',
    'invalidCredentials': 'غلط ای میل یا پاس ورڈ',
    'fillAllFields': 'براہ کرم تمام فیلڈز بھریں',
    'selectRole': 'اپنا کردار منتخب کریں',
  };
}

