import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportheroes_mobile/core/constants/app_colors.dart';
import 'package:sportheroes_mobile/core/utils/image_picker_helper.dart';
import 'package:sportheroes_mobile/core/widgets/api_state_view.dart';
import 'package:sportheroes_mobile/core/widgets/app_loading_overlay.dart';
import 'package:sportheroes_mobile/features/auth/providers/auth_provider.dart';
import 'package:sportheroes_mobile/features/teams/models/team_model.dart';
import 'package:sportheroes_mobile/features/teams/providers/teams_provider.dart';
import 'package:sportheroes_mobile/features/teams/widgets/add_member_sheet.dart';
import 'package:sportheroes_mobile/features/teams/widgets/team_logo_avatar.dart';
import 'package:sportheroes_mobile/utils/app_snackbar.dart';

class TeamDetailScreen extends ConsumerStatefulWidget {
  const TeamDetailScreen({super.key, required this.teamId});

  final String teamId;

  @override
  ConsumerState<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends ConsumerState<TeamDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamsProvider.notifier).loadTeam(widget.teamId);
    });
  }

  Future<void> _editTeam(TeamModel team) async {
    final nameController = TextEditingController(text: team.name);
    final shortController = TextEditingController(text: team.shortName ?? '');
    final descController = TextEditingController(text: team.description ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit team'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: shortController,
                decoration: const InputDecoration(labelText: 'Short name'),
                maxLength: 10,
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final updated = await AppLoader.during(
      context,
      () => ref.read(teamsProvider.notifier).updateTeam(
            widget.teamId,
            UpdateTeamRequest(
              name: nameController.text.trim(),
              shortName: shortController.text.trim().isEmpty
                  ? null
                  : shortController.text.trim(),
              description: descController.text.trim(),
            ),
          ),
      message: 'Saving…',
    );
    nameController.dispose();
    shortController.dispose();
    descController.dispose();

    if (!mounted) return;
    if (updated != null) {
      AppSnackbar.success(context, ref.read(teamsProvider).actionState.dataOrNull ?? 'Team updated');
    } else {
      final err = ref.read(teamsProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  Future<void> _deleteTeam() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete team?'),
        content: const Text('This will deactivate the team. You can undo from admin tools if needed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final ok = await AppLoader.during(
      context,
      () => ref.read(teamsProvider.notifier).deleteTeam(widget.teamId),
      message: 'Deleting…',
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, ref.read(teamsProvider).actionState.dataOrNull ?? 'Team deleted');
      Navigator.pop(context);
    } else {
      final err = ref.read(teamsProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  Future<void> _uploadLogo() async {
    final picked = await ImagePickerHelper.pickLogo();
    if (picked == null || !mounted) return;

    final ok = await AppLoader.during(
      context,
      () => ref.read(teamsProvider.notifier).uploadLogo(
            widget.teamId,
            UploadTeamLogoRequest(
              logoBase64: picked.base64,
              logoMimeType: picked.mimeType,
            ),
          ),
      message: 'Uploading logo…',
    );
    if (!mounted) return;
    if (ok) {
      ref.invalidate(teamLogoProvider(widget.teamId));
      AppSnackbar.success(context, ref.read(teamsProvider).actionState.dataOrNull ?? 'Logo updated');
    } else {
      final err = ref.read(teamsProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  Future<void> _changeRole(TeamMember member) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Change role',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            ...TeamModel.assignableRoles.map(
              (r) => ListTile(
                leading: Icon(
                  r == member.role
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primary,
                ),
                title: Text(r.replaceAll('_', ' ')),
                onTap: () => Navigator.pop(ctx, r),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null || selected == member.role || !mounted) return;

    final ok = await AppLoader.during(
      context,
      () => ref.read(teamsProvider.notifier).updateMemberRole(
            widget.teamId,
            member.id,
            selected,
          ),
      message: 'Updating role…',
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, ref.read(teamsProvider).actionState.dataOrNull ?? 'Role updated');
    } else {
      final err = ref.read(teamsProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  Future<void> _removeMember(TeamMember member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text(
          'Remove ${member.user?.displayLabel ?? 'this player'} from the team?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final ok = await AppLoader.during(
      context,
      () => ref.read(teamsProvider.notifier).removeMember(
            widget.teamId,
            member.id,
          ),
      message: 'Removing…',
    );
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, ref.read(teamsProvider).actionState.dataOrNull ?? 'Member removed');
    } else {
      final err = ref.read(teamsProvider).actionState.errorOrNull;
      if (err != null) AppSnackbar.error(context, err);
    }
  }

  Color _roleColor(String role) => switch (role) {
        'admin' => AppColors.primary,
        'captain' => AppColors.warning600,
        'vice_captain' => AppColors.info600,
        _ => AppColors.grey500,
      };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamsProvider);
    final team = state.detailState.dataOrNull;
    final me = ref.watch(authProvider).user;

    final myRole = me != null && team != null ? team.roleForUser(me.id) : null;
    final canManage = me != null && team != null && team.canManageTeam(me.id);
    final canAdd = me != null && team != null && team.canAddMember(me.id);
    final canRemove = me != null && team != null && team.canRemoveMember(me.id);
    final canAssign = me != null && team != null && team.canAssignRoles(me.id);
    final members = team?.members.where((m) => m.isActive).toList() ?? const [];

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(team?.name ?? 'Team'),
        actions: [
          if (canManage)
            PopupMenuButton<String>(
              onSelected: (v) {
                switch (v) {
                  case 'edit':
                    _editTeam(team);
                  case 'logo':
                    _uploadLogo();
                  case 'delete':
                    _deleteTeam();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit team')),
                PopupMenuItem(value: 'logo', child: Text('Change logo')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete team',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (_) => AddMemberSheet(teamId: widget.teamId),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add member'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            )
          : null,
      body: ApiStateView(
        isLoading: state.detailState.isLoading && team == null,
        loadingMessage: 'Loading team…',
        error: state.detailState.isError && team == null
            ? state.detailState.errorOrNull
            : null,
        onRetry: () =>
            ref.read(teamsProvider.notifier).loadTeam(widget.teamId),
        child: team == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      children: [
                        TeamLogoAvatar(
                          teamId: team.id,
                          name: team.name,
                          hasLogo: team.hasLogo,
                          radius: 44,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          team.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (team.shortName != null &&
                            team.shortName!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            team.shortName!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (myRole != null) ...[
                          const SizedBox(height: 12),
                          Chip(
                            backgroundColor: AppColors.primary50,
                            label: Text(
                              'Your role · ${myRole.replaceAll('_', ' ')}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        if (team.description != null &&
                            team.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            team.description!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Members (${members.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (members.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: const Text(
                        'No active members yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ...members.map((m) {
                      final isMe = me != null && m.userId == me.id;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary50,
                            child: Text(
                              (m.user?.displayLabel.isNotEmpty == true
                                      ? m.user!.displayLabel[0]
                                      : '?')
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          title: Text(
                            m.user?.displayLabel ?? 'Player',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            [
                              m.roleLabel,
                              if (m.user?.phoneNumber != null)
                                m.user!.phoneNumber!,
                              if (isMe) 'You',
                            ].join(' · '),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _roleColor(m.role).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  m.roleLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _roleColor(m.role),
                                  ),
                                ),
                              ),
                              if (canAssign || (canRemove && !isMe))
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'role') _changeRole(m);
                                    if (v == 'remove') _removeMember(m);
                                  },
                                  itemBuilder: (_) => [
                                    if (canAssign)
                                      const PopupMenuItem(
                                        value: 'role',
                                        child: Text('Change role'),
                                      ),
                                    if (canRemove && !isMe)
                                      const PopupMenuItem(
                                        value: 'remove',
                                        child: Text(
                                          'Remove',
                                          style: TextStyle(color: AppColors.error),
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
}
