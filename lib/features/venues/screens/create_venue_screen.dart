import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/models/device_location_data.dart';
import 'package:sportheroes_mobile/core/providers/providers.dart';
import 'package:sportheroes_mobile/core/services/device_location_service.dart';
import 'package:sportheroes_mobile/core/widgets/app_loading_overlay.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';
import 'package:sportheroes_mobile/features/venues/models/venue_model.dart';
import 'package:sportheroes_mobile/features/venues/providers/venues_provider.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';
import 'package:sportheroes_mobile/utils/validators.dart';

class CreateVenueScreen extends ConsumerStatefulWidget {
  const CreateVenueScreen({super.key});

  @override
  ConsumerState<CreateVenueScreen> createState() => _CreateVenueScreenState();
}

class _CreateVenueScreenState extends ConsumerState<CreateVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  DeviceLocationData? _location;
  bool _locating = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureLocation());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });

    try {
      final service = ref.read(deviceLocationServiceProvider);
      final status = await service.checkAvailability(
        requestPermissionIfDenied: true,
      );

      if (!mounted) return;

      if (status == LocationAvailabilityStatus.serviceDisabled) {
        setState(() {
          _locationError = 'Location services are turned off';
        });
        return;
      }
      if (status == LocationAvailabilityStatus.permissionDenied ||
          status == LocationAvailabilityStatus.permissionDeniedForever) {
        setState(() {
          _locationError = 'Location permission is required to pin this venue';
        });
        return;
      }

      final data = await service.collectData();
      if (!mounted) return;

      setState(() {
        _location = data;
        if (!data.hasLocation) {
          _locationError = 'Could not get GPS coordinates. Try again.';
        } else {
          if ((_addressController.text.isEmpty) &&
              (data.street?.isNotEmpty == true ||
                  data.address?.isNotEmpty == true)) {
            _addressController.text = data.street?.isNotEmpty == true
                ? data.street!
                : data.address!;
          }
          if (_cityController.text.isEmpty && data.city != null) {
            _cityController.text = data.city!;
          }
          if (_stateController.text.isEmpty && data.state != null) {
            _stateController.text = data.state!;
          }
          if (_countryController.text.isEmpty && data.country != null) {
            _countryController.text = data.country!;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError =
            'Could not capture location. Check GPS permission and try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  Future<void> _handleLocationErrorAction() async {
    final service = ref.read(deviceLocationServiceProvider);
    final status = await service.checkAvailability();
    if (status == LocationAvailabilityStatus.serviceDisabled) {
      await service.openLocationSettings();
    } else if (status == LocationAvailabilityStatus.permissionDeniedForever) {
      await service.openAppSettings();
    } else {
      await _captureLocation();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final loc = _location;
    if (loc == null || !loc.hasLocation) {
      AppSnackbar.error(context, 'Capture your location first');
      return;
    }

    final venue = await AppLoader.during(
      context,
      () => ref.read(venuesProvider.notifier).createVenue(
            CreateVenueRequest(
              name: _nameController.text.trim(),
              latitude: loc.latitude!,
              longitude: loc.longitude!,
              address: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
              city: _cityController.text.trim().isEmpty
                  ? null
                  : _cityController.text.trim(),
              state: _stateController.text.trim().isEmpty
                  ? null
                  : _stateController.text.trim(),
              country: _countryController.text.trim().isEmpty
                  ? null
                  : _countryController.text.trim(),
            ),
          ),
      message: 'Creating venue…',
    );

    if (!mounted) return;
    if (venue != null) {
      AppSnackbar.success(
        context,
        ref.read(venuesProvider).actionState.dataOrNull ?? 'Venue created',
      );
      Navigator.pop(context, venue);
    } else {
      final err = ref.read(venuesProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(title: const Text('Create Venue')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.my_location_rounded, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Location',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_locating)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: AppLogoLoader(
                          size: 40,
                          message: 'Getting GPS…',
                        ),
                      ),
                    )
                  else if (_location?.hasLocation == true) ...[
                    Text(
                      _location!.gpsCoordinates,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (_location!.formattedAddress.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _location!.formattedAddress,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ] else
                    Text(
                      _locationError ?? 'No location yet',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _locating
                        ? null
                        : (_locationError != null
                            ? _handleLocationErrorAction
                            : _captureLocation),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      _locationError != null ? 'Fix & retry' : 'Refresh GPS',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Venue name',
                hintText: 'e.g. Club Court 1',
                prefixIcon: Icon(Icons.stadium_outlined),
              ),
              validator: (v) {
                final required = Validators.required(v, fieldName: 'Name');
                if (required != null) return required;
                if (v!.trim().length < 2) return 'Name must be at least 2 chars';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'City (optional)',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stateController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'State (optional)',
                prefixIcon: Icon(Icons.map_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _countryController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Country (optional)',
                prefixIcon: Icon(Icons.public_outlined),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _locating ? null : _submit,
                child: const Text('Create Venue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
