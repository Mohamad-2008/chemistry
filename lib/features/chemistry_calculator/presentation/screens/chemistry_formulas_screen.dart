import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ChemistryToolsScreen extends StatefulWidget {
  const ChemistryToolsScreen({super.key});

  @override
  State<ChemistryToolsScreen> createState() => _ChemistryToolsScreenState();
}

class _ChemistryToolsScreenState extends State<ChemistryToolsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _equationController = TextEditingController();
  final TextEditingController _massController = TextEditingController();
  String _balancedEquation = '';
  String _selectedOperation = 'balance';
  String _selectedReactant = '';
  double _inputMass = 0;
  late TabController _tabController;
  Map<String, dynamic> _elementsData = {};

  // نمونه معادلات پیش‌فرض
  final List<String> _sampleEquations = [
    'H2 + O2 = H2O',
    'Fe + O2 = Fe2O3',
    'CH4 + O2 = CO2 + H2O',
    'Na + Cl2 = NaCl',
    'Al + HCl = AlCl3 + H2'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadElementsData();
  }

  Future<void> _loadElementsData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/periodic_table.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      setState(() {
        _elementsData = data;
      });
    } catch (e) {
      _showError('خطا در بارگذاری داده‌های عناصر');
    }
  }

  // تبدیل فرمول‌های ساده به فرمت استاندارد
  String _formatEquation(String equation) {
    return equation
        .replaceAll('=', '→')
        .replaceAllMapped(RegExp(r'(\d+)([A-Za-z])'), (match) => '${match[1]}${match[2]}')
        .replaceAllMapped(RegExp(r'([A-Za-z])(\d+)'), (match) => '${match[1]}${match[2]}');
  }

  // تجزیه و تحلیل فرمول شیمیایی
  Map<String, int> _parseFormula(String formula) {
    Map<String, int> elements = {};
    RegExp elementPattern = RegExp(r'([A-Z][a-z]?)(\d*)');
    
    for (var match in elementPattern.allMatches(formula)) {
      String element = match.group(1)!;
      int count = match.group(2)?.isEmpty ?? true ? 1 : int.parse(match.group(2)!);
      elements[element] = (elements[element] ?? 0) + count;
    }
    
    return elements;
  }

  // محاسبه جرم مولی ترکیب
  double _calculateMolarMass(String compound) {
    Map<String, int> elements = _parseFormula(compound);
    double molarMass = 0;
    
    elements.forEach((element, count) {
      if (_elementsData.containsKey(element)) {
        molarMass += (_elementsData[element]['atomic_mass'] as num) * count;
      }
    });
    
    return molarMass;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontFamily: 'Vazir'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _balanceEquation() {
    if (_equationController.text.isEmpty) {
      _showError('لطفاً معادله را وارد کنید.');
      return;
    }

    String equation = _equationController.text;
    equation = _formatEquation(equation);

    List<String> sides = equation.split('→');
    if (sides.length != 2) {
      _showError('فرمت معادله نامعتبر است.');
      return;
    }

    List<String> reactants = sides[0].split('+').map((e) => e.trim()).toList();
    List<String> products = sides[1].split('+').map((e) => e.trim()).toList();

    // محاسبه ضرایب موازنه با استفاده از الگوریتم هوشمند
    Map<String, int> balancedCoefficients = _calculateBalancedCoefficients(reactants, products);
    
    // ساخت معادله موازنه شده
    String balancedEquation = _buildBalancedEquation(reactants, products, balancedCoefficients);
    
    setState(() {
      _balancedEquation = balancedEquation;
    });
  }

  Map<String, int> _calculateBalancedCoefficients(List<String> reactants, List<String> products) {
    Map<String, int> coefficients = {};
    Map<String, int> leftElements = {};
    Map<String, int> rightElements = {};

    // جمع‌آوری عناصر در هر طرف
    for (var reactant in reactants) {
      Map<String, int> elements = _parseFormula(reactant);
      elements.forEach((element, count) {
        leftElements[element] = (leftElements[element] ?? 0) + count;
      });
    }

    for (var product in products) {
      Map<String, int> elements = _parseFormula(product);
      elements.forEach((element, count) {
        rightElements[element] = (rightElements[element] ?? 0) + count;
      });
    }

    // محاسبه ضرایب اولیه
    for (var element in leftElements.keys) {
      if (rightElements.containsKey(element)) {
        int leftCount = leftElements[element]!;
        int rightCount = rightElements[element]!;
        
        if (leftCount != rightCount) {
          // محاسبه ضریب مورد نیاز برای موازنه
          int coefficient = (leftCount / rightCount).ceil();
          coefficients[element] = coefficient;
        }
      }
    }

    return coefficients;
  }

  String _buildBalancedEquation(List<String> reactants, List<String> products, Map<String, int> coefficients) {
    String result = '';
    
    // اضافه کردن واکنش‌دهنده‌ها
    for (int i = 0; i < reactants.length; i++) {
      if (i > 0) result += ' + ';
      String reactant = reactants[i];
      int coefficient = coefficients[reactant] ?? 1;
      if (coefficient > 1) result += '$coefficient';
      result += _formatSubscripts(reactant);
    }
    
    result += ' → ';
    
    // اضافه کردن محصولات
    for (int i = 0; i < products.length; i++) {
      if (i > 0) result += ' + ';
      String product = products[i];
      int coefficient = coefficients[product] ?? 1;
      if (coefficient > 1) result += '$coefficient';
      result += _formatSubscripts(product);
    }
    
    return result;
  }

  String _formatSubscripts(String formula) {
    return formula.replaceAllMapped(RegExp(r'(\d+)'), (match) {
      String num = match.group(1)!;
      return num.replaceAll('0', '₀')
               .replaceAll('1', '₁')
               .replaceAll('2', '₂')
               .replaceAll('3', '₃')
               .replaceAll('4', '₄')
               .replaceAll('5', '₅')
               .replaceAll('6', '₆')
               .replaceAll('7', '₇')
               .replaceAll('8', '₈')
               .replaceAll('9', '₉');
    });
  }

  void _calculateMoles() {
    if (_equationController.text.isEmpty || _selectedReactant.isEmpty || _massController.text.isEmpty) {
      _showError('لطفاً معادله، ماده واکنش‌دهنده و جرم را وارد کنید.');
      return;
    }

    try {
      double mass = double.parse(_massController.text);
      if (mass <= 0) {
        _showError('جرم باید بزرگ‌تر از صفر باشد.');
        return;
      }

      double molarMass = _calculateMolarMass(_selectedReactant);
      if (molarMass == 0) {
        _showError('خطا در محاسبه جرم مولی');
        return;
      }

      double moles = mass / molarMass;
      setState(() {
        _balancedEquation = '${mass.toStringAsFixed(2)} g $_selectedReactant = ${moles.toStringAsFixed(4)} mol';
      });
    } catch (e) {
      _showError('لطفاً مقادیر معتبر وارد کنید.');
    }
  }

  void _calculateMass() {
    if (_equationController.text.isEmpty || _selectedReactant.isEmpty || _massController.text.isEmpty) {
      _showError('لطفاً معادله، ماده واکنش‌دهنده و تعداد مول را وارد کنید.');
      return;
    }

    try {
      double moles = double.parse(_massController.text);
      if (moles <= 0) {
        _showError('تعداد مول باید بزرگ‌تر از صفر باشد.');
        return;
      }

      double molarMass = _calculateMolarMass(_selectedReactant);
      if (molarMass == 0) {
        _showError('خطا در محاسبه جرم مولی');
        return;
      }

      double mass = moles * molarMass;
      setState(() {
        _balancedEquation = '${moles.toStringAsFixed(4)} mol $_selectedReactant = ${mass.toStringAsFixed(2)} g';
      });
    } catch (e) {
      _showError('لطفاً مقادیر معتبر وارد کنید.');
    }
  }

  @override
  void dispose() {
    _equationController.dispose();
    _massController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ابزارهای شیمی',
          style: TextStyle(
            fontFamily: 'Vazir',
            color: Colors.amber,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 16,
          ),
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey[400],
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'معادلات'),
            Tab(text: 'فرمول‌ها'),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildEquationsTab(),
            _buildFormulasTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildEquationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    textDirection: TextDirection.rtl,
                    'این بخش در حال توسعه است و به زودی با قابلیت‌های جدید به‌روزرسانی خواهد شد.',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      color: Colors.amber,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildOperationSelector(),
          const SizedBox(height: 16),
          _buildEquationInput(),
          const SizedBox(height: 16),
          _buildResultCard(),
          const SizedBox(height: 16),
          _buildRulesCard(),
        ],
      ),
    );
  }

  Widget _buildFormulasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    textDirection: TextDirection.rtl,
                    'این بخش در حال توسعه است و به زودی با قابلیت‌های جدید به‌روزرسانی خواهد شد.',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      color: Colors.amber,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFormulaCard(
            title: 'محاسبه تعداد مول',
            formula: 'n = m/M',
            description: 'n: تعداد مول\nm: جرم (گرم)\nM: جرم مولی (گرم بر مول)',
          ),
          const SizedBox(height: 16),
          _buildFormulaCard(
            title: 'محاسبه مولاریته',
            formula: 'C = n/V',
            description: 'C: مولاریته (مول بر لیتر)\nn: تعداد مول\nV: حجم (لیتر)',
          ),
          const SizedBox(height: 16),
          _buildFormulaCard(
            title: 'محاسبه pH و pOH',
            formula: 'pH = -log[H⁺]\npOH = -log[OH⁻]\npH + pOH = 14',
            description: '[H⁺]: غلظت یون هیدروژن\n[OH⁻]: غلظت یون هیدروکسید',
          ),
          const SizedBox(height: 16),
          _buildFormulaCard(
            title: 'محاسبه جرم',
            formula: 'm = ρ × V',
            description: 'm: جرم (گرم)\nρ: چگالی (گرم بر میلی‌لیتر)\nV: حجم (میلی‌لیتر)',
          ),
          const SizedBox(height: 16),
          _buildFormulaCard(
            title: 'تبدیل دما',
            formula: 'K = °C + 273.15\n°F = (°C × 9/5) + 32',
            description: 'K: کلوین\n°C: سلسیوس\n°F: فارنهایت',
          ),
          const SizedBox(height: 16),
          _buildFormulaCard(
            title: 'قانون گاز ایده‌آل',
            formula: 'PV = nRT',
            description: 'P: فشار (اتمسفر)\nV: حجم (لیتر)\nn: تعداد مول\nR: ثابت گازها (0.0821 L.atm/mol.K)\nT: دما (کلوین)',
          ),
        ],
      ),
    );
  }

  Widget _buildOperationSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'عملیات مورد نظر را انتخاب کنید:',
              style: TextStyle(
                fontFamily: 'Vazir',
                color: Colors.amber,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: [
                _buildOperationChip('موازنه معادله', 'balance'),
                _buildOperationChip('محاسبه تعداد مول', 'moles'),
                _buildOperationChip('محاسبه جرم', 'mass'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationChip(String label, String value) {
    final isSelected = _selectedOperation == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Vazir',
          color: isSelected ? Colors.black : Colors.white,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedOperation = value;
        });
      },
      backgroundColor: Colors.grey[800],
      selectedColor: Colors.amber,
      checkmarkColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildEquationInput() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'معادله شیمیایی را وارد کنید:',
              style: TextStyle(
                fontFamily: 'Vazir',
                color: Colors.amber,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: _sampleEquations.map((eq) => _buildSampleEquationChip(eq)).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _equationController,
              style: const TextStyle(
                fontFamily: 'Vazir',
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'مثال: H2 + O2 = H2O',
                hintStyle: TextStyle(
                  fontFamily: 'Vazir',
                  color: Colors.grey[400],
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber, width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            if (_selectedOperation != 'balance') ...[
              const SizedBox(height: 16),
              const Text(
                'ماده واکنش‌دهنده را انتخاب کنید:',
                style: TextStyle(
                  fontFamily: 'Vazir',
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              _buildReactantSelector(),
              const SizedBox(height: 16),
              TextField(
                controller: _massController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: _selectedOperation == 'moles' ? 'جرم (گرم)' : 'تعداد مول',
                  hintStyle: TextStyle(
                    fontFamily: 'Vazir',
                    color: Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.amber, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  switch (_selectedOperation) {
                    case 'balance':
                      _balanceEquation();
                      break;
                    case 'moles':
                      _calculateMoles();
                      break;
                    case 'mass':
                      _calculateMass();
                      break;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text(
                  'محاسبه',
                  style: TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleEquationChip(String equation) {
    return ActionChip(
      label: Text(
        equation,
        style: const TextStyle(
          fontFamily: 'Vazir',
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      onPressed: () {
        setState(() {
          _equationController.text = equation;
        });
      },
      backgroundColor: Colors.grey[800],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildReactantSelector() {
    if (_equationController.text.isEmpty) return const SizedBox.shrink();

    List<String> reactants = _equationController.text
        .split('→')[0]
        .split('+')
        .map((e) => e.trim())
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: reactants.map((reactant) {
        final isSelected = _selectedReactant == reactant;
        return FilterChip(
          label: Text(
            reactant,
            style: TextStyle(
              fontFamily: 'Vazir',
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 14,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedReactant = selected ? reactant : '';
            });
          },
          backgroundColor: Colors.grey[800],
          selectedColor: Colors.amber,
          checkmarkColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      }).toList(),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'نتیجه:',
              style: TextStyle(
                fontFamily: 'Vazir',
                color: Colors.amber,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Text(
                _balancedEquation.isEmpty ? 'لطفاً معادله را وارد کنید' : _balancedEquation,
                style: TextStyle(
                  fontFamily: 'Vazir',
                  color: _balancedEquation.isEmpty ? Colors.grey[400] : Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'قوانین و نکات مهم:',
              style: TextStyle(
                fontFamily: 'Vazir',
                color: Colors.amber,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            _buildRuleItem('1. برای وارد کردن معادله از نمادهای شیمیایی استاندارد استفاده کنید'),
            _buildRuleItem('2. برای نمایش زیرنویس از _ استفاده کنید (مثال: H_2)'),
            _buildRuleItem('3. برای نمایش بالانویس از ^ استفاده کنید (مثال: SO_4^2-)'),
            _buildRuleItem('4. از فلش (→) برای نشان دادن واکنش استفاده کنید'),
            _buildRuleItem('5. اعداد را به صورت عادی وارد کنید'),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Vazir',
          color: Colors.grey[400],
          fontSize: 14,
          height: 1.5,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildFormulaCard({
    required String title,
    required String formula,
    required String description,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Vazir',
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Text(
                formula,
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontFamily: 'Vazir',
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}