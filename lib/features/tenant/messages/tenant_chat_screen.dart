// lib/features/tenant/messages/tenant_chat_screen.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import 'messages_screen.dart';

/* ---------------------------------------------------------
   Chat Screen (Tenant)
---------------------------------------------------------- */

class TenantChatScreen extends StatefulWidget {
  const TenantChatScreen({
    super.key,
    required this.conversation,
    required this.initialMessages,
    this.onOpenListing,
    this.onCall,
  });

  final ConversationVM conversation;
  final List<ChatMessageVM> initialMessages;

  final VoidCallback? onOpenListing;
  final VoidCallback? onCall;

  @override
  State<TenantChatScreen> createState() => _TenantChatScreenState();
}

class _TenantChatScreenState extends State<TenantChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _sc = ScrollController();

  late List<ChatMessageVM> _messages = List.of(widget.initialMessages);

  @override
  void dispose() {
    _ctrl.dispose();
    _sc.dispose();
    super.dispose();
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages = [
        ..._messages,
        ChatMessageVM.user(
          id: 'm_${DateTime.now().microsecondsSinceEpoch}',
          text: trimmed,
          at: DateTime.now(),
        ),
      ];
      _ctrl.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_sc.hasClients) return;
      _sc.animateTo(
        _sc.position.maxScrollExtent + AppSpacing.xxxl,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _dayLabel(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatFullDate(DateTime(dt.year, dt.month, dt.day));
  }

  String _timeLabel(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(dt),
      alwaysUse24HourFormat: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;

    return AppScaffold(
      backgroundColor: Colors.transparent,

      // ✅ important: let our gradient reach the top (we handle SafeArea ourselves)
      safeAreaTop: false,
      safeAreaBottom: false,

      // ✅ remove topBar slot so it doesn't paint outside the gradient
      topBar: null,

      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
        child: Column(
          children: [
            // ✅ AppTopBar is now INSIDE the gradient
            SafeArea(
              bottom: false,
              child: AppTopBar(
                title: c.displayName,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.screenH),
                    child: InkWell(
                      onTap: widget.onCall,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: Container(
                        height: AppSizes.iconButtonBox,
                        width: AppSizes.iconButtonBox,
                        decoration: BoxDecoration(
                          color: AppColors.surface(
                            context,
                          ).withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.overlay(context, 0.06),
                          ),
                          boxShadow: AppShadows.soft(
                            context,
                            blur: AppSpacing.xxxl,
                            y: AppSpacing.lg,
                            alpha: 0.10,
                          ),
                        ),
                        child: Icon(
                          Icons.call_rounded,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // verified badge line under topbar (like mock)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenV,
                AppSpacing.s2,
                AppSpacing.screenV,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.s6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context).withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: AppColors.overlay(context, 0.06),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          c.isVerified
                              ? Icons.verified_rounded
                              : Icons.info_outline_rounded,
                          size: 18,
                          color: c.isVerified
                              ? AppColors.brandGreenDeep
                              : AppColors.textMutedLight,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          c.isVerified
                              ? 'Verified ${c.subtitleLabel()}'
                              : c.subtitleLabel(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.navy,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // pinned listing mini card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenV,
              ),
              child: _ListingMiniCard(
                title: c.listingTitle,
                priceText: c.listingPriceText,
                thumbAsset: c.listingThumbAsset,
                onTap: widget.onOpenListing,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // messages
            Expanded(
              child: ListView.builder(
                controller: _sc,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenV,
                  AppSpacing.sm,
                  AppSpacing.screenV,
                  AppSpacing.md,
                ),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final m = _messages[i];

                  final showDay =
                      i == 0 ||
                      (_messages[i - 1].at.year != m.at.year ||
                          _messages[i - 1].at.month != m.at.month ||
                          _messages[i - 1].at.day != m.at.day);

                  return Column(
                    children: [
                      if (showDay) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _DatePill(text: _dayLabel(context, m.at)),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      if (m.type == ChatMessageType.system)
                        _SystemMsg(text: m.text)
                      else
                        _Bubble(
                          text: m.text,
                          isMe: m.type == ChatMessageType.user,
                          time: _timeLabel(context, m.at),
                        ),
                      const SizedBox(height: AppSpacing.s10),
                    ],
                  );
                },
              ),
            ),

            // quick actions
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenV,
                0,
                AppSpacing.screenV,
                AppSpacing.sm,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickChip(
                      text: 'Schedule viewing',
                      onTap: () => _send('Can we schedule a viewing?'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _QuickChip(
                      text: 'Ask about rent',
                      onTap: () => _send('Please confirm the rent terms.'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _QuickChip(
                      text: 'Request documents',
                      onTap: () =>
                          _send('Can you share the required documents?'),
                    ),
                  ],
                ),
              ),
            ),

            // composer
            _Composer(
              controller: _ctrl,
              onAttach: () {},
              onSend: () => _send(_ctrl.text),
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------- VMs ----------------------------- */

enum ChatMessageType { user, other, system }

class ChatMessageVM {
  const ChatMessageVM._({
    required this.id,
    required this.type,
    required this.text,
    required this.at,
  });

  final String id;
  final ChatMessageType type;
  final String text;
  final DateTime at;

  factory ChatMessageVM.user({
    required String id,
    required String text,
    required DateTime at,
  }) => ChatMessageVM._(id: id, type: ChatMessageType.user, text: text, at: at);

  factory ChatMessageVM.other({
    required String id,
    required String text,
    required DateTime at,
  }) =>
      ChatMessageVM._(id: id, type: ChatMessageType.other, text: text, at: at);

  factory ChatMessageVM.system({
    required String id,
    required String text,
    required DateTime at,
  }) =>
      ChatMessageVM._(id: id, type: ChatMessageType.system, text: text, at: at);
}

/* ----------------------------- UI ----------------------------- */

class _ListingMiniCard extends StatelessWidget {
  const _ListingMiniCard({
    required this.title,
    required this.priceText,
    required this.thumbAsset,
    required this.onTap,
  });

  final String title;
  final String priceText;
  final String thumbAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: Container(
                  height: AppSizes.listThumbSize,
                  width: AppSizes.listThumbSize + AppSpacing.md,
                  color: AppColors.tenantPanel.withValues(alpha: 0.85),
                  child: thumbAsset.trim().isEmpty
                      ? const Icon(
                          Icons.photo_rounded,
                          color: AppColors.textMutedLight,
                        )
                      : Image.asset(
                          thumbAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.photo_rounded,
                              color: AppColors.textMutedLight,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      priceText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMutedLight.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemMsg extends StatelessWidget {
  const _SystemMsg({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.05),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.overlay(context, 0.08)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.textMutedLight.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.textMutedLight.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.isMe, required this.time});

  final String text;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
    final bg = isMe
        ? AppColors.brandBlueSoft.withValues(alpha: 0.45)
        : AppColors.surface(context).withValues(alpha: 0.58);

    final border = isMe
        ? AppColors.brandBlueSoft.withValues(alpha: 0.35)
        : AppColors.overlay(context, 0.06);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMutedLight.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.60),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onAttach,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.screenV,
        0,
        AppSpacing.screenV,
        AppSpacing.md,
      ),
      child: _FrostCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.s10,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onAttach,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s6),
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type a message…',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMutedLight.withValues(alpha: 0.85),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Material(
                color: AppColors.brandGreenDeep.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: InkWell(
                  onTap: onSend,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: SizedBox(
                    height: AppSizes.iconButtonBox,
                    width: AppSizes.iconButtonBox,
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
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
}

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: AppColors.surface(context).withValues(alpha: 0.55),
          ),
          boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: child,
        ),
      ),
    );
  }
}
