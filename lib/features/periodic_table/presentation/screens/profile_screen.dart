import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:periodic_table_app/features/periodic_table/providers/periodic_table_provider.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Map<int, double> _podmanProgress = {};

  final List<Map<String, dynamic>> _podmans = [
    {
      'id': 1,
      'title': 'پودمان یک',
      'subtitle': 'ساختار اتم و مفاهیم پایه شیمی',
      'route': '/chemistry_book',
    },
    {
      'id': 2,
      'title': 'پودمان دو',
      'subtitle': 'فرایندهای شیمیایی',
      'route': '/chemistry_book',
    },
    {
      'id': 3,
      'title': 'پودمان سه',
      'subtitle': 'محلول و کلوئید',
      'route': '/chemistry_book',
    },
    {
      'id': 4,
      'title': 'پودمان چهار',
      'subtitle': 'الکتروشیمی',
      'route': '/chemistry_book',
    },
    {
      'id': 5,
      'title': 'پودمان پنج',
      'subtitle': 'ترکیب‌های کربن‌دار',
      'route': '/chemistry_book',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadProgress();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var podman in _podmans) {
        final progress =
            prefs.getDouble('podman_${podman['id']}_progress') ?? 0.0;
        _podmanProgress[podman['id']] = progress;
      }
    });
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
          child: Consumer<PeriodicTableProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _animationController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Header
                      _buildHeader(provider),
                      const SizedBox(height: 24),
                      // User Info Card
                      _buildUserInfoCard(provider),
                      const SizedBox(height: 24),
                      // Progress Section
                      _buildProgressSection(),
                      const SizedBox(height: 24),
                      // Learning Suggestions
                      _buildLearningSuggestions(provider),
                      const SizedBox(height: 24),
                      // Tools and Settings
                      _buildToolsSection(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PeriodicTableProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Text(
            'پروفایل کاربری${provider.userName != null ? ': ${provider.userName}' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Vazir',
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ),
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blueAccent.withOpacity(0.3),
          child: const Icon(
            Icons.person,
            size: 40,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(PeriodicTableProvider provider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey[800]!.withOpacity(0.9),
              Colors.blueGrey[900]!.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'اطلاعات کاربر',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
              textDirection: TextDirection.rtl,
            ),
            const Divider(color: Colors.white54),
            _buildInfoRow('نام', provider.userName ?? 'وارد نشده'),
            _buildInfoRow('رشته تحصیلی', provider.fieldOfStudy ?? 'وارد نشده'),
            _buildInfoRow('مقطع تحصیلی', provider.educationLevel ?? 'وارد نشده'),
            _buildInfoRow('سطح دانش شیمی', provider.chemistryKnowledgeLevel ?? 'وارد نشده'),
            _buildInfoRow('هدف آموزشی', provider.educationalGoal ?? 'وارد نشده'),
            const SizedBox(height: 16),
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile_setup');
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'ویرایش پروفایل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Vazir',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'Vazir',
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Vazir',
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueGrey[900]!.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'پیشرفت آموزشی',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
              textDirection: TextDirection.rtl,
            ),
            const Divider(color: Colors.white54),
            ..._podmans.map((podman) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, podman['route'], arguments: podman['id']);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              podman['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Vazir',
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              podman['subtitle'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontFamily: 'Vazir',
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: _podmanProgress[podman['id']] ?? 0.0,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              color: Colors.blueAccent,
                              strokeWidth: 6,
                            ),
                          ),
                          Text(
                            '${((_podmanProgress[podman['id']] ?? 0.0) * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Vazir',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningSuggestions(PeriodicTableProvider provider) {
    final interests = provider.scientificInterests;
    final suggestions = {
      'organic_chemistry': 'دوره شیمی آلی پیشرفته را شروع کنید.',
      'electrochemistry': 'آزمایش‌های الکتروشیمی را در پودمان ۴ کاوش کنید.',
      'thermodynamics': 'مفاهیم ترمودینامیک را در منابع پیشنهادی مطالعه کنید.',
      'analytical_chemistry': 'تکنیک‌های شیمی تجزیه را در پودمان ۳ بیاموزید.',
    };

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueGrey[900]!.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'پیشنهادات آموزشی',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
              textDirection: TextDirection.rtl,
            ),
            const Divider(color: Colors.white54),
            if (interests.isEmpty)
              const Text(
                'علاقه‌مندی‌های علمی را در پروفایل خود تنظیم کنید.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Vazir',
                ),
                textDirection: TextDirection.rtl,
              )
            else
              ...interests.map((interest) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          suggestions[interest] ?? 'منبع آموزشی مرتبط را کاوش کنید.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'Vazir',
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.yellowAccent,
                        size: 24,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsSection(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueGrey[900]!.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'ابزارها و تنظیمات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Vazir',
              ),
              textDirection: TextDirection.rtl,
            ),
            const Divider(color: Colors.white54),
            _buildToolButton(
              icon: Icons.book,
              label: 'دسترسی به پودمان‌ها',
              onTap: () {
                Navigator.pushNamed(context, '/chemistry_book');
              },
            ),
            _buildToolButton(
              icon: Icons.notifications,
              label: 'تنظیم اعلان‌ها',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تنظیم اعلان‌ها در حال توسعه است.',
                      style: TextStyle(fontFamily: 'Vazir'),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                );
              },
            ),
            _buildToolButton(
              icon: Icons.brightness_6,
              label: 'تغییر تم (روشن/تاریک)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تغییر تم در حال توسعه است.',
                      style: TextStyle(fontFamily: 'Vazir'),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Vazir',
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(width: 16),
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 0.95).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.3),
                child: Icon(icon, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}