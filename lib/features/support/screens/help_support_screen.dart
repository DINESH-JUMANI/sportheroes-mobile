import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/widgets/app_loading_overlay.dart';
import 'package:sportheroes_mobile/core/widgets/app_logo_loader.dart';
import 'package:sportheroes_mobile/features/support/models/support_models.dart';
import 'package:sportheroes_mobile/features/support/providers/support_provider.dart';
import 'package:sportheroes_mobile/routes/app_routes.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _otherController = TextEditingController();
  final _picker = ImagePicker();

  SupportConcern? _selectedConcern;
  final List<File> _images = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportProvider.notifier).loadConcerns();
      ref.read(supportProvider.notifier).loadMyTickets();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) {
      AppSnackbar.warning(context, 'You can attach up to 5 images');
      return;
    }
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;

    for (final file in files) {
      if (_images.length >= 5) break;
      final local = File(file.path);
      final length = await local.length();
      if (length > 5 * 1024 * 1024) {
        if (!mounted) return;
        AppSnackbar.warning(context, 'Each image must be under 5MB');
        continue;
      }
      setState(() => _images.add(local));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final concern = _selectedConcern;
    if (concern == null) {
      AppSnackbar.error(context, 'Select a concern');
      return;
    }
    if (concern.isOther && _otherController.text.trim().length < 3) {
      AppSnackbar.error(context, 'Please describe your concern');
      return;
    }

    final ticket = await AppLoader.during(
      context,
      () => ref.read(supportProvider.notifier).createTicket(
            CreateSupportTicketRequest(
              concernId: concern.id,
              description: _descriptionController.text.trim(),
              otherConcernText:
                  concern.isOther ? _otherController.text.trim() : null,
            ),
            imageFiles: List<File>.from(_images),
          ),
      message: 'Submitting…',
    );

    if (!mounted) return;
    final state = ref.read(supportProvider);
    if (ticket != null) {
      final msg = state.actionState.dataOrNull ?? 'Support ticket created';
      AppSnackbar.success(
        context,
        '$msg\nTicket: ${ticket.ticketNumber}',
      );
      _descriptionController.clear();
      _otherController.clear();
      setState(() {
        _selectedConcern = null;
        _images.clear();
      });
    } else {
      final err = state.actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportProvider);
    final concerns = state.concerns;
    final tickets = state.tickets;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Help & Support'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.mySupportTickets),
            child: const Text(
              'My tickets',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: state.concernsState.isLoading && concerns.isEmpty
          ? const Center(
              child: AppLogoLoader(size: 48, message: 'Loading…'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a concern, describe the issue, and optionally attach screenshots.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedConcern?.id,
                        decoration: const InputDecoration(
                          labelText: 'Concern',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: concerns
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.label),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          setState(() {
                            _selectedConcern = concerns
                                .where((c) => c.id == id)
                                .firstOrNull;
                          });
                        },
                        validator: (v) =>
                            v == null ? 'Select a concern' : null,
                      ),
                      if (_selectedConcern?.isOther == true) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _otherController,
                          decoration: const InputDecoration(
                            labelText: 'Describe your concern',
                            prefixIcon: Icon(Icons.edit_note_rounded),
                          ),
                          maxLines: 2,
                          validator: (v) {
                            if (_selectedConcern?.isOther == true &&
                                (v == null || v.trim().length < 3)) {
                              return 'Required for Other';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 5,
                        minLines: 4,
                        validator: (v) {
                          if (v == null || v.trim().length < 10) {
                            return 'Please write at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Attachments (${_images.length}/5)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add_photo_alternate_outlined),
                            label: const Text('Add photos'),
                          ),
                        ],
                      ),
                      if (_images.isNotEmpty)
                        SizedBox(
                          height: 84,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final img = _images[i];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      img,
                                      width: 84,
                                      height: 84,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () =>
                                          setState(() => _images.removeAt(i)),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: state.actionState.isLoading
                              ? null
                              : _submit,
                          child: const Text('Submit ticket'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (tickets.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recent tickets',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.mySupportTickets,
                        ),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  ...tickets.take(3).map(_ticketTile),
                ],
              ],
            ),
    );
  }

  Widget _ticketTile(SupportTicket t) {
    final color = switch (t.status) {
      'resolved' || 'closed' => AppColors.success,
      'in_progress' => AppColors.warning700,
      _ => AppColors.primary,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          t.ticketNumber,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          t.concern?.label ?? t.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            t.statusLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
