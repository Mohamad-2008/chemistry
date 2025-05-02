import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _educationalGoalController = TextEditingController();
  String? _fieldOfStudy;
  String? _educationLevel;
  String? _chemistryKnowledgeLevel;
  List<String> _scientificInterests = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _fieldOptions = [
    'شیمی',
    'فیزیک',
    'زیست‌شناسی',
    'ریاضی',
    'فنی حرفه ای',
    'سایر'
  ];
  final List<String> _educationLevelOptions = [
    'دبستان',
    'دبیرستان',
    'کارشناسی',
    'کارشناسی ارشد',
    'دکتری'
  ];
  final List<String> _knowledgeLevelOptions = ['مبتدی', 'متوسط', 'پیشرفته'];
  final List<Map<String, String>> _interestOptions = [
    {'key': 'organic_chemistry', 'display': 'شیمی آلی'},
    {'key': 'electrochemistry', 'display': 'الکتروشیمی'},
    {'key': 'thermodynamics', 'display': 'ترمودینامیک'},
    {'key': 'analytical_chemistry', 'display': 'شیمی تجزیه'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _educationalGoalController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _fieldOfStudy = prefs.getString('field_of_study');
      _educationLevel = prefs.getString('education_level');
      _chemistryKnowledgeLevel = prefs.getString('chemistry_knowledge_level');
      _scientificInterests = prefs.getStringList('scientific_interests') ?? [];
      _educationalGoalController.text = prefs.getString('educational_goal') ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final userName = _nameController.text.trim();
      await prefs.setString('user_name', userName);
      if (_fieldOfStudy != null) {
        await prefs.setString('field_of_study', _fieldOfStudy!);
      }
      if (_educationLevel != null) {
        await prefs.setString('education_level', _educationLevel!);
      }
      if (_chemistryKnowledgeLevel != null) {
        await prefs.setString('chemistry_knowledge_level', _chemistryKnowledgeLevel!);
      }
      await prefs.setStringList('scientific_interests', _scientificInterests);
      await prefs.setString('educational_goal', _educationalGoalController.text.trim());

      // به‌روزرسانی تمام اطلاعات پروفایل در Provider
      Provider.of<PeriodicTableProvider>(context, listen: false).updateUserProfile(
        userName: userName,
        fieldOfStudy: _fieldOfStudy,
        educationLevel: _educationLevel,
        chemistryKnowledgeLevel: _chemistryKnowledgeLevel,
        scientificInterests: _scientificInterests,
        educationalGoal: _educationalGoalController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'پروفایل با موفقیت ذخیره شد',
            style: TextStyle(fontFamily: 'Vazir', color: Colors.white),
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey[900]!.withOpacity(0.9),
              Colors.black.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'تنظیم پروفایل کاربری',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Vazir',
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لطفاً اطلاعات خود را وارد کنید تا تجربه آموزشی بهتری داشته باشید',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'Vazir',
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _nameController,
                      label: 'نام و نام خانوادگی',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'لطفاً نام خود را وارد کنید';
                        }
                        if (value.trim().length < 2) {
                          return 'نام باید حداقل 2 کاراکتر باشد';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'رشته تحصیلی',
                      value: _fieldOfStudy,
                      items: _fieldOptions,
                      onChanged: (value) {
                        setState(() {
                          _fieldOfStudy = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'مقطع تحصیلی',
                      value: _educationLevel,
                      items: _educationLevelOptions,
                      onChanged: (value) {
                        setState(() {
                          _educationLevel = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'سطح دانش شیمی',
                      value: _chemistryKnowledgeLevel,
                      items: _knowledgeLevelOptions,
                      onChanged: (value) {
                        setState(() {
                          _chemistryKnowledgeLevel = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMultiSelectField(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _educationalGoalController,
                      label: 'هدف آموزشی',
                      hint: 'مثلاً آمادگی برای کنکور یا یادگیری شیمی آلی',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Vazir',
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Vazir',
          ),
          hintStyle: const TextStyle(
            color: Colors.white38,
            fontFamily: 'Vazir',
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          alignLabelWithHint: true,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DropdownButtonFormField2<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Vazir',
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
        isExpanded: true,
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          width: MediaQuery.of(context).size.width - 48,
          offset: const Offset(0, 8), // منو از پایین فیلد باز می‌شود
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.blueGrey[900]!.withOpacity(0.9),
                Colors.blueGrey[800]!.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          elevation: 0, // سایه توسط boxShadow مدیریت می‌شود
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(6),
            thumbVisibility: MaterialStateProperty.all(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
          iconSize: 24,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Vazir',
                fontSize: 16,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMultiSelectField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'علاقه‌مندی‌های علمی',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontFamily: 'Vazir',
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: _interestOptions.map((interest) {
              return CheckboxListTile(
                title: Text(
                  interest['display']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Vazir',
                    fontSize: 16,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                value: _scientificInterests.contains(interest['key']),
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _scientificInterests.add(interest['key']!);
                    } else {
                      _scientificInterests.remove(interest['key']);
                    }
                  });
                },
                activeColor: Colors.blueAccent,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
        ),
      ),
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.save, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'ذخیره پروفایل',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
            ),
          ],
        ),
      ),
    );
  }
}