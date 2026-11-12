import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/data/indian_cities.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/birth_profile.dart';
import '../../../core/services/profile_store.dart';

class BirthDetailsScreen extends StatefulWidget {
  const BirthDetailsScreen({super.key});

  @override
  State<BirthDetailsScreen> createState() => _BirthDetailsScreenState();
}

class _BirthDetailsScreenState extends State<BirthDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  DateTime? _dateOfBirth;
  TimeOfDay? _timeOfBirth;
  String _placeOfBirth = '';
  String? _selectedCity;
  bool _manualPlace = false;
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _utcOffsetHours = 5.5; // IST by default
  String _timezoneLabel = 'IST (UTC+5:30)';
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New KP Chart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              // Save draft
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameField(),
              const SizedBox(height: 16),
              _buildDateOfBirthField(),
              const SizedBox(height: 16),
              _buildTimeOfBirthField(),
              const SizedBox(height: 16),
              _buildPlaceSelector(),
              if (_manualPlace) ...[
                const SizedBox(height: 16),
                _buildPlaceOfBirthField(),
              ],
              const SizedBox(height: 16),
              _buildCoordinatesFields(),
              const SizedBox(height: 16),
              _buildTimezoneField(),
              const SizedBox(height: 24),
              _buildAdvancedOptions(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter full name',
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Name cannot be empty';
        }
        return null;
      },
      onChanged: (value) => _fullName = value,
    );
  }

  Widget _buildDateOfBirthField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Date of Birth',
        hintText: _dateOfBirth != null
            ? _formatDate(_dateOfBirth!)
            : 'Select date of birth',
        prefixIcon: const Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _dateOfBirth = picked);
        }
      },
      validator: (value) {
        if (_dateOfBirth == null) {
          return 'Date of birth is required';
        }
        return null;
      },
    );
  }

  Widget _buildTimeOfBirthField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Time of Birth',
        hintText: _timeOfBirth != null
            ? _timeOfBirth!.format(context)
            : 'Select time of birth',
        prefixIcon: const Icon(Icons.access_time),
      ),
      readOnly: true,
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() => _timeOfBirth = picked);
        }
      },
      validator: (value) {
        if (_timeOfBirth == null) {
          return 'Time of birth is required';
        }
        return null;
      },
    );
  }

  Widget _buildPlaceOfBirthField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Place of Birth',
        hintText: 'Search city...',
        prefixIcon: Icon(Icons.place),
        suffixIcon: Icon(Icons.search),
      ),
      onChanged: (value) => _placeOfBirth = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Place of birth is required';
        }
        return null;
      },
    );
  }

  Widget _buildCoordinatesFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Latitude',
              prefixIcon: Icon(Icons.location_on),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _latitude = double.tryParse(value) ?? 0.0;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Longitude',
              prefixIcon: Icon(Icons.location_on),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _longitude = double.tryParse(value) ?? 0.0;
            },
          ),
        ),
      ],
    );
  }

  static const Map<String, double> _timezones = {
    'UTC (UTC+0)': 0.0,
    'GMT (UTC+0)': 0.0,
    'IST (UTC+5:30)': 5.5,
    'CET (UTC+1)': 1.0,
    'EET (UTC+2)': 2.0,
    'BST (UTC+1)': 1.0,
    'SGT (UTC+8)': 8.0,
    'HKT (UTC+8)': 8.0,
    'AWST (UTC+8)': 8.0,
    'JST (UTC+9)': 9.0,
    'KST (UTC+9)': 9.0,
    'AEST (UTC+10)': 10.0,
    'NZST (UTC+12)': 12.0,
    'EST (UTC-5)': -5.0,
    'CST (UTC-6)': -6.0,
    'MST (UTC-7)': -7.0,
    'PST (UTC-8)': -8.0,
    'AKST (UTC-9)': -9.0,
    'HST (UTC-10)': -10.0,
  };

  Widget _buildPlaceSelector() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Place of Birth',
        prefixIcon: Icon(Icons.place),
      ),
      initialValue: _selectedCity,
      items: [
        const DropdownMenuItem(
          value: '__other__',
          child: Text('Other / manual entry'),
        ),
        ...kIndianCities.map(
          (city) => DropdownMenuItem(
            value: city.name,
            child: Text('${city.name}, ${city.state}'),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          if (value == '__other__') {
            _manualPlace = true;
            _selectedCity = null;
          } else {
            _manualPlace = false;
            _selectedCity = value;
            final city = kIndianCities.firstWhere((c) => c.name == value);
            _placeOfBirth = city.name;
            _latitude = city.latitude;
            _longitude = city.longitude;
            // Indian cities default to IST
            _utcOffsetHours = 5.5;
            _timezoneLabel = 'IST (UTC+5:30)';
          }
        });
      },
      validator: (value) {
        if (!_manualPlace && (value == null || value.isEmpty)) {
          return 'Please select your place of birth';
        }
        return null;
      },
    );
  }

  Widget _buildTimezoneField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Timezone',
        prefixIcon: Icon(Icons.language),
      ),
      initialValue: _timezoneLabel,
      items: _timezones.keys
          .map((tz) => DropdownMenuItem(value: tz, child: Text(tz)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _timezoneLabel = value!;
          _utcOffsetHours = _timezones[value] ?? 0.0;
        });
      },
    );
  }

  Widget _buildAdvancedOptions() {
    return ExpansionPanelList(
      expansionCallback: (panelIndex, isExpanded) {
        setState(() => _isExpanded = !_isExpanded);
      },
      children: [
        ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Advanced Options'),
            );
          },
          isExpanded: _isExpanded,
          body: Column(
            children: [
              const ListTile(
                title: Text('KP Ayanamsa'),
                subtitle: Text('Select ayanamsa type'),
              ),
              const ListTile(
                title: Text('House System'),
                subtitle: Text('Placidus (default)'),
              ),
              const ListTile(
                title: Text('Node Type'),
                subtitle: Text('Mean / True'),
              ),
              const ListTile(
                title: Text('Birth-time Precision'),
                subtitle: Text('Accurate / Approximate'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              _formKey.currentState?.reset();
              setState(() {
                _fullName = '';
                _dateOfBirth = null;
                _timeOfBirth = null;
                _placeOfBirth = '';
                _selectedCity = null;
                _manualPlace = false;
                _latitude = 0.0;
                _longitude = 0.0;
                _utcOffsetHours = 5.5;
                _timezoneLabel = 'IST (UTC+5:30)';
              });
            },
            child: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _generateChart,
            child: const Text('Generate KP Chart'),
          ),
        ),
      ],
    );
  }

  Future<void> _generateChart() async {
    if (!_formKey.currentState!.validate()) return;

    final birthDateTime = DateTime(
      _dateOfBirth!.year,
      _dateOfBirth!.month,
      _dateOfBirth!.day,
      _timeOfBirth!.hour,
      _timeOfBirth!.minute,
    );
    final now = DateTime.now();

    final profile = BirthProfile(
      id: const Uuid().v4(),
      name: _fullName.trim(),
      dateOfBirth: _dateOfBirth!,
      timeOfBirth: birthDateTime,
      birthplaceName: _placeOfBirth.trim(),
      latitude: _latitude,
      longitude: _longitude,
      timezoneId: _formatUtcOffset(_utcOffsetHours),
      utcBirthTimestamp: birthDateTime.subtract(
        Duration(minutes: (_utcOffsetHours * 60).round()),
      ),
      createdAt: now,
      updatedAt: now,
    );

    // Persist offline and expose to downstream screens
    await DatabaseHelper().insertBirthProfile(profile);
    ProfileStore.instance.currentProfile = profile;

    if (mounted) context.go('/kp-chart');
  }

  String _formatUtcOffset(double hours) {
    final sign = hours < 0 ? '-' : '+';
    final absHours = hours.abs();
    final h = absHours.floor();
    final m = ((absHours - h) * 60).round();
    return 'UTC$sign$h:${m.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
