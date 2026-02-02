// lib/features/tenant/messages/messages_screen.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import 'tenant_chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.conversations,
    this.initialFilter = MessagesFilter.all,
    this.onExploreHomes,
  });

  final List<ConversationVM> conversations;
  final MessagesFilter initialFilter;
  final VoidCallback? onExploreHomes;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late MessagesFilter _filter = widget.initialFilter;
  final TextEditingController _searchCtrl = TextEditingController();

  // ---------- Explore-style alpha helpers ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ConversationVM> _applyFilters(List<ConversationVM> all) {
    final q = _searchCtrl.text.trim().toLowerCase();

    Iterable<ConversationVM> out = all;

    switch (_filter) {
      case MessagesFilter.all:
        break;
      case MessagesFilter.agents:
        out = out.where((c) => c.kind == ConversationKind.agent);
        break;
      case MessagesFilter.landlords:
        out = out.where((c) => c.kind == ConversationKind.landlord);
        break;
      case MessagesFilter.support:
        out = out.where((c) => c.kind == ConversationKind.support);
        break;
    }

    if (q.isNotEmpty) {
      out = out.where((c) {
        return c.displayName.toLowerCase().contains(q) ||
            c.listingTitle.toLowerCase().contains(q) ||
            c.lastMessagePreview.toLowerCase().contains(q);
      });
    }

    final list = out.toList()
      ..sort((a, b) {
        final au = a.unreadCount > 0 ? 0 : 1;
        final bu = b.unreadCount > 0 ? 0 : 1;
        if (au != bu) return au.compareTo(bu);
        return b.lastMessageAt.compareTo(a.lastMessageAt);
      });

    return list;
  }

  void _openChat(ConversationVM c) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            TenantChatScreen(conversation: c, initialMessages: c.messages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applyFilters(widget.conversations);

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: AppTopBar(
          title: 'Messages',
          subtitle: 'Chats with agents & landlords',
          actions: [
            // Standard Explore-style Icon Button
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.screenH),
              child: Container(
                height: AppSizes.iconButtonBox,
                width: AppSizes.iconButtonBox,
                decoration: BoxDecoration(
                  color: AppColors.surface(context)
                      .withValues(alpha: _alphaSurfaceStrong),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.overlay(context, _alphaBorderSoft)),
                  boxShadow: AppShadows.soft(
                    context,
                    blur: AppSpacing.xxxl,
                    y: AppSpacing.lg,
                    alpha: _alphaShadowSoft,
                  ),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.textMuted(context),
                ),
              ),
            ),
          ],
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH, // ✅ Fixed: Horizontal spacing
            AppSpacing.sm,
            AppSpacing.screenH, // ✅ Fixed: Horizontal spacing
            AppSizes.screenBottomPad,
          ),
          children: [
            _SearchBar(
              controller: _searchCtrl,
              hint: 'Search messages...',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            _FilterChips(
              value: _filter,
              onChanged: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: AppSpacing.md),
            if (filtered.isEmpty)
              _EmptyState(
                title: 'No messages found',
                buttonText: 'Explore homes',
                onTap: widget.onExploreHomes,
              )
            else
              ...filtered.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ConversationRow(convo: c, onTap: () => _openChat(c)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------- VMs ---------------------------- */

enum ConversationKind { agent, landlord, support }

enum MessagesFilter { all, agents, landlords, support }

class ConversationVM {
  const ConversationVM({
    required this.id,
    required this.kind,
    required this.displayName,
    required this.isVerified,
    required this.listingTitle,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.listingPriceText,
    required this.listingThumbAsset,
    required this.messages,
  });

  final String id;
  final ConversationKind kind;

  final String displayName;
  final bool isVerified;

  final String listingTitle;
  final String listingPriceText;
  final String listingThumbAsset;

  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final int unreadCount;

  final List<ChatMessageVM> messages;

  String subtitleLabel() {
    switch (kind) {
      case ConversationKind.agent:
        return 'Verified Agent';
      case ConversationKind.landlord:
        return 'Landlord';
      case ConversationKind.support:
        return 'Support';
    }
  }
}

/* ------------------------- UI Components ------------------------- */

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.s10,
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: AppColors.textMuted(context).withValues(alpha: 0.9),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted(context)
                            .withValues(alpha: 0.85),
                      ),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(context),
                    ),
              ),
            ),
            if (controller.text.trim().isNotEmpty)
              InkWell(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s6),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.value, required this.onChanged});

  final MessagesFilter value;
  final ValueChanged<MessagesFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    // Matches Explore filters logic
    return SizedBox(
      height: AppSizes.pillButtonHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _ChipBtn(
            text: 'All',
            active: value == MessagesFilter.all,
            onTap: () => onChanged(MessagesFilter.all),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ChipBtn(
            text: 'Agents',
            active: value == MessagesFilter.agents,
            onTap: () => onChanged(MessagesFilter.agents),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ChipBtn(
            text: 'Landlords',
            active: value == MessagesFilter.landlords,
            onTap: () => onChanged(MessagesFilter.landlords),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ChipBtn(
            text: 'Support',
            active: value == MessagesFilter.support,
            onTap: () => onChanged(MessagesFilter.support),
          ),
        ],
      ),
    );
  }
}

class _ChipBtn extends StatelessWidget {
  const _ChipBtn({
    required this.text,
    required this.active,
    required this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    // Matches Explore ChipRow logic
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: active ? AppColors.brandGradient : null,
          color: active
              ? null
              : AppColors.surface(context).withValues(alpha: alphaSurface),
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(color: AppColors.overlay(context, alphaBorder)),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: active
                    ? AppColors.white
                    : AppColors.textPrimary(context),
              ),
        ),
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.convo, required this.onTap});

  final ConversationVM convo;
  final VoidCallback onTap;

  String _timeLabel(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _timeLabel(context, convo.lastMessageAt);

    return _FrostCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(kind: convo.kind, verified: convo.isVerified),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              convo.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary(context),
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            t,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted(context)
                                      .withValues(alpha: 0.9),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        '${convo.subtitleLabel()} • ${convo.listingTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted(context)
                                  .withValues(alpha: 0.92),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              convo.lastMessagePreview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    // Make unread messages slightly bolder/darker
                                    color: convo.unreadCount > 0
                                        ? AppColors.textPrimary(context)
                                        : AppColors.textSecondary(context),
                                  ),
                            ),
                          ),
                          if (convo.unreadCount > 0) ...[
                            const SizedBox(width: AppSpacing.sm),
                            _UnreadBadge(count: convo.unreadCount),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.kind, required this.verified});

  final ConversationKind kind;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final base = AppColors.surface(context).withValues(alpha: 0.65);
    final ring = AppColors.overlay(context, 0.06);

    IconData icon;
    Color tone;

    switch (kind) {
      case ConversationKind.agent:
        icon = Icons.person_rounded;
        tone = AppColors.brandGreenDeep;
        break;
      case ConversationKind.landlord:
        icon = Icons.home_rounded;
        tone = AppColors.brandBlueSoft;
        break;
      case ConversationKind.support:
        icon = Icons.support_agent_rounded;
        // Fallback safely if brandOrange doesn't exist
        tone = Colors.orange;
        break;
    }

    return SizedBox(
      width: AppSizes.iconButtonBox, // Standardized size
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: AppSizes.iconButtonBox,
            width: AppSizes.iconButtonBox,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(color: ring),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: tone),
          ),
          if (verified)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                height: AppSpacing.lg,
                width: AppSpacing.lg,
                decoration: BoxDecoration(
                  color: AppColors.brandGreenDeep.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(
                    width: 2,
                    color: AppColors.surface(context),
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 10,
                  color: AppColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 10, // Slightly smaller for dense layouts
              color: AppColors.white,
            ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.buttonText,
    required this.onTap,
  });

  final String title;
  final String buttonText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxl,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.mark_chat_unread_rounded,
                size: AppSpacing.xxxl + AppSpacing.lg,
                color: AppColors.textMuted(context).withValues(alpha: 0.3),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(context),
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (onTap != null) _PrimaryButton(text: buttonText, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Material(
      color: disabled
          ? AppColors.textMuted(context).withValues(alpha: 0.1)
          : AppColors.brandBlueSoft.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(AppRadii.pill), // Pill style
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: disabled
                      ? AppColors.textMuted(context)
                      : AppColors.white,
                ),
          ),
        ),
      ),
    );
  }
}

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  // Standard Explore/More/Tools alpha logic
  double get _alphaSurface =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _alphaBorder => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaShadow => AppSpacing.xs / AppSpacing.xxxl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: _alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, _alphaBorder)),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: _alphaShadow,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: child,
        ),
      ),
    );
  }
}