class Translations {
  static String t(String key, String lang) {
    if (_dict[lang] != null && _dict[lang]![key] != null) {
      return _dict[lang]![key]!;
    }
    return key; // Fallback to English (the key itself)
  }

  static const Map<String, Map<String, String>> _dict = {
    'Sinhala': {
      'My Profile': 'මගේ පැතිකඩ',
      'Driver': 'රියදුරු',
      'Truck': 'ට්‍රක් රථය',
      'Zone': 'කලාපය',
      'Not assigned': 'පවරා නැත',
      'TODAY\'S ROUTE DETAILS': 'අද මාර්ග විස්තර',
      'ACTIVE': 'සක්‍රිය',
      'No routes assigned for today.': 'අද සඳහා මාර්ග පවරා නැත.',
      'APP PREFERENCES': 'යෙදුම් මනාප',
      'Language': 'භාෂාව',
      'Preferred interface language': 'කැමති අතුරු මුහුණත් භාෂාව',
      'App Theme': 'යෙදුම් තේමාව',
      'Switch between light and dark': 'ආලෝකය සහ අඳුර අතර මාරු වන්න',
      'Sign Out from EcoTrack': 'ඉවත්වන්න',
    },
    'Tamil': {
      'My Profile': 'என் சுயவிவரம்',
      'Driver': 'ஓட்டுநர்',
      'Truck': 'சுமையுந்து',
      'Zone': 'மண்டலம்',
      'Not assigned': 'ஒதுக்கப்படவில்லை',
      'TODAY\'S ROUTE DETAILS': 'இன்றைய வழி விவரங்கள்',
      'ACTIVE': 'செயலில்',
      'No routes assigned for today.': 'இன்று வழிகள் எதுவும் ஒதுக்கப்படவில்லை.',
      'APP PREFERENCES': 'பயன்பாட்டு விருப்பங்கள்',
      'Language': 'மொழி',
      'Preferred interface language': 'விருப்பமான மொழி',
      'App Theme': 'பயன்பாட்டு தீம்',
      'Switch between light and dark': 'வெளிச்சம் மற்றும் இருளுக்கு இடையில் மாறவும்',
      'Sign Out from EcoTrack': 'வெளியேறு',
    },
  };
}
