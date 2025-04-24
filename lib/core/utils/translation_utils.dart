class TranslationUtils {
  static final Map<String, String> _translations = {
    // خواص فیزیکی
    'atomicMass': 'جرم اتمی',
    'phase': 'فاز',
    'appearance': 'ظاهر',
    'density': 'چگالی',
    'melt': 'نقطه ذوب',
    'boil': 'نقطه جوش',
    
    // خواص شیمیایی
    'electronegativity': 'الکترونگاتیوی',
    'ionizationEnergy': 'انرژی یونش',
    'oxidationStates': 'حالت اکسایش',
    
    // خواص اتمی
    'electronConfiguration': 'پیکربندی الکترونی',
    'atomicRadius': 'شعاع اتمی',
    'covalentRadius': 'شعاع کووالانسی',
    'halfLife': 'نیمه‌عمر',
    
    // اطلاعات تاریخی
    'discoveredBy': 'کاشف',
    'namedBy': 'نام‌گذاری شده توسط',
    'source': 'منبع',
    
    // مقادیر خاص
    'g/L': 'گرم بر لیتر',
    'K': 'کلوین',
    'kJ/mol': 'کیلوژول بر مول',
    'pm': 'پیکومتر',
    
    // فازها
    'Gas': 'گاز',
    'Liquid': 'مایع',
    'Solid': 'جامد',
    'Unknown': 'نامشخص',
  };

  static String translate(String text) {
    return _translations[text] ?? text;
  }

  static String translateValue(String value) {
    if (value.contains('K')) {
      return value.replaceAll('K', ' کلوین');
    }
    if (value.contains('g/L')) {
      return value.replaceAll('g/L', ' گرم بر لیتر');
    }
    if (value.contains('kJ/mol')) {
      return value.replaceAll('kJ/mol', ' کیلوژول بر مول');
    }
    if (value.contains('pm')) {
      return value.replaceAll('pm', ' پیکومتر');
    }
    return translate(value);
  }
} 