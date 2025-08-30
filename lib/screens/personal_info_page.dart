import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  int? _age;
  double? _weight;
  int? _heightFeet;
  int? _heightInches;
  String? _gender;

  final List<String> _genderOptions = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];

  bool get _canContinue =>
      _age != null && _weight != null && _heightFeet != null && _heightInches != null && _gender != null;

  void _submitForm() {
    if (_formKey.currentState!.validate() && _canContinue) {
      Navigator.pushReplacementNamed(context, '/fitnessgoals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tell us about yourself', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder(), suffixText: 'years'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your age';
                  final age = int.tryParse(value);
                  if (age == null || age < 10 || age > 100) return 'Please enter a valid age between 10 and 100';
                  return null;
                },
                onChanged: (value) => setState(() => _age = int.tryParse(value)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight', border: OutlineInputBorder(), suffixText: 'LBS'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter your weight';
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 30 || weight > 300) return 'Please enter a valid weight between 30 and 300 lbs';
                  return null;
                },
                onChanged: (value) => setState(() => _weight = double.tryParse(value)),
              ),
              const SizedBox(height: 16),
              const Text('Height', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Feet', border: OutlineInputBorder(), suffixText: 'ft'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter feet';
                        final feet = int.tryParse(value);
                        if (feet == null || feet < 3 || feet > 8) return 'Valid: 3-8';
                        return null;
                      },
                      onChanged: (value) => setState(() => _heightFeet = int.tryParse(value)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Inches', border: OutlineInputBorder(), suffixText: 'in'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter inches';
                        final inches = int.tryParse(value);
                        if (inches == null || inches < 0 || inches > 11) return 'Valid: 0-11';
                        return null;
                      },
                      onChanged: (value) => setState(() => _heightInches = int.tryParse(value)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _genderOptions.map((gender) {
                  return ChoiceChip(
                    label: Text(gender),
                    selected: _gender == gender,
                    onSelected: (selected) => setState(() => _gender = selected ? gender : null),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
              Center(
                child: ElevatedButton(
                  onPressed: _canContinue ? _submitForm : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}