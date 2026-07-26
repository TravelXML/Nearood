import 'package:flutter/material.dart';
import '../../data/host_repository.dart';
import '../../models/event.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

const _categories = [
  'Weekend Dinner',
  'Tea & Conversation',
  'Senior Assistance',
  'Shopping Help',
  'Local Travel',
  'Walking Group',
  'Games',
  'Cultural Events',
  'Learning and Mentoring',
  'Family Activities',
  'Fitness',
  'Volunteering',
];

const _eligibilityOptions = [
  'Senior-friendly',
  'Women-only',
  'Family-friendly',
  'Accessibility support',
];

/// Create-event form (a single-screen take on spec item 10's multi-step
/// flow). Publishes straight to the `events` table.
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController(text: '10');

  String _category = _categories.first;
  DateTime? _dateTime;
  bool _isFree = true;
  bool _publishing = false;
  final Set<String> _eligibilityTags = {};

  @override
  void initState() {
    super.initState();
    _locationController.text = AppSession.instance.neighbourhood ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 3)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a date and time for the event.')),
      );
      return;
    }
    setState(() => _publishing = true);
    try {
      await HostRepository.instance.createEvent(
        title: _titleController.text.trim(),
        category: _category,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        eventTime: _dateTime!,
        isFree: _isFree,
        priceLabel: _isFree ? 'Free' : '₹${_priceController.text.trim()}',
        seatsAvailable: int.tryParse(_seatsController.text.trim()) ?? 10,
        latitude: AppSession.instance.latitude,
        longitude: AppSession.instance.longitude,
        coverImageUrl: categoryStyle(_category).imageUrl.replaceFirst('400/400', '800/600'),
        eligibilityTags: _eligibilityTags.toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _publishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't publish the event — try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text('Category', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: AppSpacing.base + 4),
              Text('Title', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'e.g. Sunday Home-Cooked Dinner'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: AppSpacing.base + 4),
              Text('Description', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'What should neighbours expect?'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Add a short description' : null,
              ),
              const SizedBox(height: AppSpacing.base + 4),
              Text('Location', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(hintText: 'Neighbourhood or area'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a location' : null,
              ),
              const SizedBox(height: AppSpacing.base + 4),
              Text('Date & time', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: InputDecorator(
                  decoration: const InputDecoration(),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 18, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.base),
                      Text(
                        _dateTime == null ? 'Select date & time' : _formatDateTime(_dateTime!),
                        style: AppTextStyles.bodyMd,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base + 4),
              Row(
                children: [
                  Expanded(child: Text('Free event', style: AppTextStyles.labelMd)),
                  Switch(
                    value: _isFree,
                    onChanged: (v) => setState(() => _isFree = v),
                  ),
                ],
              ),
              if (!_isFree) ...[
                const SizedBox(height: AppSpacing.base),
                Text('Price per person (₹)', style: AppTextStyles.labelMd),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'e.g. 200'),
                  validator: (v) {
                    if (_isFree) return null;
                    return (v == null || v.trim().isEmpty) ? 'Enter a price' : null;
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.base + 4),
              Text('Seats available', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _seatsController,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || int.tryParse(v.trim()) == null) ? 'Enter a number' : null,
              ),
              const SizedBox(height: AppSpacing.base + 4),
              Text('Who is this for? (optional)', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              Wrap(
                spacing: AppSpacing.base,
                runSpacing: AppSpacing.base,
                children: _eligibilityOptions.map((tag) {
                  final selected = _eligibilityTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _eligibilityTags.add(tag);
                        } else {
                          _eligibilityTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryFixed,
                    checkmarkColor: AppColors.primary,
                    labelStyle: AppTextStyles.labelSm.copyWith(
                      color: selected ? AppColors.primary : AppColors.onSurface,
                    ),
                    backgroundColor: AppColors.surfaceContainer,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: _publishing ? null : _publish,
                child: _publishing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Publish Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDateTime(DateTime dt) {
  final weekday = _weekdays[dt.weekday - 1];
  final month = _months[dt.month - 1];
  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$weekday, ${dt.day} $month · $hour12:$minute $period';
}
