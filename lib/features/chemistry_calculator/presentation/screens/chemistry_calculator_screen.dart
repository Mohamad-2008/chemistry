import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class ChemistryCalculatorScreen extends StatefulWidget {
  const ChemistryCalculatorScreen({super.key});

  @override
  State<ChemistryCalculatorScreen> createState() => _ChemistryCalculatorScreenState();
}

class _ChemistryCalculatorScreenState extends State<ChemistryCalculatorScreen> {
  final TextEditingController _massController = TextEditingController();
  final TextEditingController _molarMassController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _concentrationController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _densityController = TextEditingController();
  final TextEditingController _manualMolesController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _pressureController = TextEditingController();
  final TextEditingController _volumeGasController = TextEditingController();
  final TextEditingController _molesGasController = TextEditingController();
  final TextEditingController _temperatureGasController = TextEditingController();

  double _moles = 0;
  double _molarity = 0;
  double _pOH = 0;
  double _hConcentration = 0;
  double _ohConcentration = 0;
  double _mass = 0;
  double _pressure = 0;
  bool _useManualMoles = false;
  String _selectedTemperatureType = 'celsius';
  String _celsiusResult = '';
  String _kelvinResult = '';
  String _fahrenheitResult = '';

  @override
  void dispose() {
    _massController.dispose();
    _molarMassController.dispose();
    _volumeController.dispose();
    _concentrationController.dispose();
    _phController.dispose();
    _densityController.dispose();
    _manualMolesController.dispose();
    _temperatureController.dispose();
    _pressureController.dispose();
    _volumeGasController.dispose();
    _molesGasController.dispose();
    _temperatureGasController.dispose();
    super.dispose();
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

  void _calculateMoles() {
    if (_massController.text.isNotEmpty && _molarMassController.text.isNotEmpty) {
      try {
        final mass = double.parse(_massController.text);
        final molarMass = double.parse(_molarMassController.text);
        if (mass <= 0 || molarMass <= 0) {
          _showError('جرم و جرم مولی باید بزرگ‌تر از صفر باشند.');
          return;
        }
        setState(() {
          _moles = mass / molarMass;
        });
      } catch (e) {
        _showError('لطفاً مقادیر معتبر وارد کنید.');
      }
    } else {
      setState(() {
        _moles = 0;
      });
    }
  }

  void _calculateMolarity() {
    if (_volumeController.text.isNotEmpty) {
      try {
        final volume = double.parse(_volumeController.text);
        if (volume <= 0) {
          _showError('حجم باید بزرگ‌تر از صفر باشد.');
          return;
        }
        double moles = _useManualMoles
            ? (double.tryParse(_manualMolesController.text) ?? 0)
            : _moles;
        if (_useManualMoles && moles <= 0) {
          _showError('تعداد مول دلخواه باید بزرگ‌تر از صفر باشد.');
          return;
        }
        setState(() {
          _molarity = moles / volume;
        });
      } catch (e) {
        _showError('لطفاً مقادیر معتبر وارد کنید.');
      }
    } else {
      setState(() {
        _molarity = 0;
      });
    }
  }

  void _calculatePH() {
    if (_phController.text.isNotEmpty) {
      try {
        final ph = double.parse(_phController.text);
        if (ph < 0 || ph > 14) {
          _showError('pH باید بین 0 تا 14 باشد.');
          return;
        }
        setState(() {
          _hConcentration = pow(10, -ph).toDouble();
          _pOH = 14 - ph;
          _ohConcentration = pow(10, -_pOH).toDouble();
        });
      } catch (e) {
        _showError('لطفاً مقدار معتبر برای pH وارد کنید.');
      }
    } else {
      setState(() {
        _hConcentration = 0;
        _pOH = 0;
        _ohConcentration = 0;
      });
    }
  }

  void _calculateMass() {
    if (_densityController.text.isNotEmpty && _volumeController.text.isNotEmpty) {
      try {
        final density = double.parse(_densityController.text);
        final volume = double.parse(_volumeController.text);
        if (density <= 0 || volume <= 0) {
          _showError('چگالی و حجم باید بزرگ‌تر از صفر باشند.');
          return;
        }
        setState(() {
          _mass = density * volume;
        });
      } catch (e) {
        _showError('لطفاً مقادیر معتبر وارد کنید.');
      }
    } else {
      setState(() {
        _mass = 0;
      });
    }
  }

  void _calculateTemperature() {
    if (_temperatureController.text.isEmpty) {
      setState(() {
        _celsiusResult = '';
        _kelvinResult = '';
        _fahrenheitResult = '';
      });
      return;
    }

    try {
      final inputTemp = double.parse(_temperatureController.text);
      setState(() {
        switch (_selectedTemperatureType) {
          case 'celsius':
            _celsiusResult = inputTemp.toStringAsFixed(2);
            _kelvinResult = (inputTemp + 273.15).toStringAsFixed(2);
            _fahrenheitResult = ((inputTemp * 9 / 5) + 32).toStringAsFixed(2);
            break;
          case 'kelvin':
            _celsiusResult = (inputTemp - 273.15).toStringAsFixed(2);
            _kelvinResult = inputTemp.toStringAsFixed(2);
            _fahrenheitResult = ((inputTemp - 273.15) * 9 / 5 + 32).toStringAsFixed(2);
            break;
          case 'fahrenheit':
            _celsiusResult = ((inputTemp - 32) * 5 / 9).toStringAsFixed(2);
            _kelvinResult = ((inputTemp - 32) * 5 / 9 + 273.15).toStringAsFixed(2);
            _fahrenheitResult = inputTemp.toStringAsFixed(2);
            break;
        }
      });
    } catch (e) {
      _showError('لطفاً مقدار معتبر برای دما وارد کنید.');
    }
  }

  void _calculateGasLaw() {
    if (_volumeGasController.text.isNotEmpty &&
        _molesGasController.text.isNotEmpty &&
        _temperatureGasController.text.isNotEmpty) {
      try {
        final volume = double.parse(_volumeGasController.text);
        final moles = double.parse(_molesGasController.text);
        final temperature = double.parse(_temperatureGasController.text);
        if (volume <= 0 || moles <= 0 || temperature <= 0) {
          _showError('حجم، تعداد مول و دما باید بزرگ‌تر از صفر باشند.');
          return;
        }
        const R = 0.0821; // L.atm/mol.K
        setState(() {
          _pressure = (moles * R * temperature) / volume;
        });
      } catch (e) {
        _showError('لطفاً مقادیر معتبر وارد کنید.');
      }
    } else {
      setState(() {
        _pressure = 0;
      });
    }
  }

  void _resetFields() {
    setState(() {
      _massController.clear();
      _molarMassController.clear();
      _volumeController.clear();
      _concentrationController.clear();
      _phController.clear();
      _densityController.clear();
      _manualMolesController.clear();
      _temperatureController.clear();
      _pressureController.clear();
      _volumeGasController.clear();
      _molesGasController.clear();
      _temperatureGasController.clear();
      _moles = 0;
      _molarity = 0;
      _pOH = 0;
      _hConcentration = 0;
      _ohConcentration = 0;
      _mass = 0;
      _pressure = 0;
      _useManualMoles = false;
      _celsiusResult = '';
      _kelvinResult = '';
      _fahrenheitResult = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ماشین حساب شیمی',
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
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildCalculatorCard(
                title: 'محاسبه تعداد مول',
                subtitle: 'با استفاده از جرم و جرم مولی',
                children: [
                  _buildInputField(
                    controller: _massController,
                    label: 'جرم (گرم)',
                    onChanged: (_) => _calculateMoles(),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _molarMassController,
                    label: 'جرم مولی (گرم بر مول)',
                    onChanged: (_) => _calculateMoles(),
                  ),
                  const SizedBox(height: 12),
                  _buildResultField(
                    label: 'تعداد مول',
                    value: _moles.toStringAsFixed(4),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCalculatorCard(
                title: 'محاسبه مولاریته',
                subtitle: 'با استفاده از تعداد مول و حجم',
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    textDirection: TextDirection.rtl,
                    children: [
                      Switch(
                        value: _useManualMoles,
                        onChanged: (value) {
                          setState(() {
                            _useManualMoles = value;
                            if (!value) {
                              _manualMolesController.clear();
                            }
                            _calculateMolarity();
                          });
                        },
                        activeColor: Colors.amber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildResultField(
                          label: 'تعداد مول محاسبه شده',
                          value: _moles.toStringAsFixed(4),
                        ),
                      ),
                    ],
                  ),
                  if (_useManualMoles) ...[
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _manualMolesController,
                      label: 'تعداد مول دلخواه',
                      onChanged: (_) => _calculateMolarity(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _volumeController,
                    label: 'حجم (لیتر)',
                    onChanged: (_) => _calculateMolarity(),
                  ),
                  const SizedBox(height: 12),
                  _buildResultField(
                    label: 'مولاریته (مول بر لیتر)',
                    value: _molarity.toStringAsFixed(4),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCalculatorCard(
                title: 'محاسبات pH و pOH',
                subtitle: 'محاسبه غلظت یون‌های H⁺ و OH⁻',
                children: [
                  _buildInputField(
                    controller: _phController,
                    label: 'pH',
                    onChanged: (_) => _calculatePH(),
                  ),
                  const SizedBox(height: 12),
                  _buildResultField(
                    label: 'غلظت یون H⁺ (مول بر لیتر)',
                    value: _hConcentration.toStringAsExponential(4),
                  ),
                  const SizedBox(height: 8),
                  _buildResultField(
                    label: 'pOH',
                    value: _pOH.toStringAsFixed(4),
                  ),
                  const SizedBox(height: 8),
                  _buildResultField(
                    label: 'غلظت یون OH⁻ (مول بر لیتر)',
                    value: _ohConcentration.toStringAsExponential(4),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCalculatorCard(
                title: 'محاسبه جرم',
                subtitle: 'با استفاده از چگالی و حجم',
                children: [
                  _buildInputField(
                    controller: _densityController,
                    label: 'چگالی (گرم بر میلی‌لیتر)',
                    onChanged: (_) => _calculateMass(),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _volumeController,
                    label: 'حجم (میلی‌لیتر)',
                    onChanged: (_) => _calculateMass(),
                  ),
                  const SizedBox(height: 12),
                  _buildResultField(
                    label: 'جرم (گرم)',
                    value: _mass.toStringAsFixed(4),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTemperatureSection(),
              const SizedBox(height: 16),
              _buildCalculatorCard(
                title: 'قانون گازها',
                subtitle: 'محاسبه فشار با استفاده از قانون گاز ایده‌آل',
                children: [
                  _buildInputField(
                    controller: _volumeGasController,
                    label: 'حجم (لیتر)',
                    onChanged: (_) => _calculateGasLaw(),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _molesGasController,
                    label: 'تعداد مول',
                    onChanged: (_) => _calculateGasLaw(),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    controller: _temperatureGasController,
                    label: 'دما (کلوین)',
                    onChanged: (_) => _calculateGasLaw(),
                  ),
                  const SizedBox(height: 12),
                  _buildResultField(
                    label: 'فشار (اتمسفر)',
                    value: _pressure.toStringAsFixed(4),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _resetFields,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    minimumSize: const Size(120, 48),
                  ),
                  child: const Text(
                    'بازنشانی',
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
      ),
    );
  }

  Widget _buildCalculatorCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Vazir',
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Vazir',
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?[0-9]*\.?[0-9]*$')),
      ],
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'Vazir',
        color: Colors.white,
        fontSize: 16,
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
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
    );
  }

  Widget _buildResultField({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Vazir',
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Vazir',
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureSection() {
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
              'تبدیل دما',
              style: TextStyle(
                fontFamily: 'Vazir',
                color: Colors.amber,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedTemperatureType,
                items: const [
                  DropdownMenuItem(value: 'celsius', child: Text('سلسیوس (°C)')),
                  DropdownMenuItem(value: 'kelvin', child: Text('کلوین (K)')),
                  DropdownMenuItem(value: 'fahrenheit', child: Text('فارنهایت (°F)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTemperatureType = value;
                      _calculateTemperature();
                    });
                  }
                },
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  color: Colors.white,
                  fontSize: 16,
                ),
                dropdownColor: Colors.grey[800],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                isExpanded: true,
                alignment: Alignment.centerRight,
              ),
            ),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _temperatureController,
              label: _getTemperatureLabel(),
              onChanged: (_) => _calculateTemperature(),
            ),
            const SizedBox(height: 12),
            _buildResultField(label: 'سلسیوس (°C)', value: _celsiusResult),
            const SizedBox(height: 8),
            _buildResultField(label: 'کلوین (K)', value: _kelvinResult),
            const SizedBox(height: 8),
            _buildResultField(label: 'فارنهایت (°F)', value: _fahrenheitResult),
          ],
        ),
      ),
    );
  }

  String _getTemperatureLabel() {
    switch (_selectedTemperatureType) {
      case 'celsius':
        return 'دما به سلسیوس (°C)';
      case 'kelvin':
        return 'دما به کلوین (K)';
      case 'fahrenheit':
        return 'دما به فارنهایت (°F)';
      default:
        return 'دما';
    }
  }
}