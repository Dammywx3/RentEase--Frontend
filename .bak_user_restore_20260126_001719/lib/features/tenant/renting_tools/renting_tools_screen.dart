import "package:flutter/material.dart";

class RentingToolsScreen extends StatelessWidget {
  const RentingToolsScreen({super.key});

  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);
  static const _text = Color(0xFF1E2A3A);
  static const _muted = Color(0xFF6F7785);
  static const _blue = Color(0xFF2E5E9A);

  @override
  Widget build(BuildContext context) {
    final tools = <_Tool>[
      _Tool(
        icon: Icons.home_work_rounded,
        title: "Rent receipts",
        subtitle: "Download & share receipts",
      ),
      _Tool(
        icon: Icons.picture_as_pdf_rounded,
        title: "Lease documents",
        subtitle: "View agreement & addendum",
      ),
      _Tool(
        icon: Icons.report_rounded,
        title: "Report an issue",
        subtitle: "Raise complaints & track updates",
      ),
      _Tool(
        icon: Icons.build_rounded,
        title: "Request maintenance",
        subtitle: "Book repairs and services",
      ),
      _Tool(
        icon: Icons.support_agent_rounded,
        title: "Support",
        subtitle: "Chat with support",
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    Expanded(
                      child: Text(
                        "Renting Tools",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: _text,
                            ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                  itemCount: tools.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final t = tools[i];
                    return Material(
                      color: Colors.white.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFCFDBEA,
                                  ).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: Icon(t.icon, color: _blue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: _text,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      t.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: _muted,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tool {
  const _Tool({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
}
