import "package:flutter/material.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_spacing.dart";
import "../../../core/theme/app_sizes.dart";

import "../../../shared/models/application_form_models.dart";
import "../../../shared/models/application_model.dart";


/// ------------------------------------------------------------
/// Application Apply Flow (Precheck -> Step1 -> Step2 -> Step3 -> Review -> Success)
/// ✅ Uses ONLY shared models from lib/shared/models/...
/// ✅ Uses ExploreScreen pattern: page gradient outside + transparent AppScaffold
/// ------------------------------------------------------------

class ApplyPreCheckScreen extends StatelessWidget {
  const ApplyPreCheckScreen({
    super.key,
    required this.listing,
    required this.guarantorRequiredThresholdNgn,
  });

  final ApplyListingVM listing;

  /// Rule: for RENT only, if rent > threshold => guarantor required
  final int guarantorRequiredThresholdNgn;

  bool get _guarantorRequired =>
      listing.rentPerMonthNgn > guarantorRequiredThresholdNgn;

  @override
  Widget build(BuildContext context) {
    final reqs = <String>[
      "Valid ID",
      "Selfie verification",
      _guarantorRequired
          ? "Guarantor details (required)"
          : "Guarantor details (optional)",
    ];

    return _PageGradient(
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: const AppTopBar(title: "Application"),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.sm,
            AppSpacing.screenV,
            AppSizes.screenBottomPad,
          ),
          children: [
            const _StepDots(active: 1),
            const SizedBox(height: AppSpacing.md),
            _ListingRowCard(listing: listing),
            const SizedBox(height: AppSpacing.lg),

            const _SectionTitle("Requirements"),
            const SizedBox(height: AppSpacing.sm),
            _FrostCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: reqs
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.brandGreenDeep,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  t,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary(context),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _PrimaryPillButton(
              text: "Continue Application",
              onTap: () {
                final draft = _initialDraft(listing, _guarantorRequired);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ApplicationStep1Screen(draft: draft),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _SecondaryPillButton(
              text: "Schedule Viewing instead",
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }

  ApplicationDraftVM _initialDraft(
    ApplyListingVM listing,
    bool guarantorRequired,
  ) {
    return ApplicationDraftVM(
      listing: listing,
      guarantorRequired: guarantorRequired,
      applicant: const ApplicantVM(
        fullName: "",
        email: "",
        phone: "",
        address: "",
      ),
      guarantors: const [
        GuarantorVM(
          fullName: "",
          relationship: RelationshipKind.parent,
          email: "",
          phone: "",
          address: "",
          sameAddressAsApplicant: false,
        ),
      ],
      employment: const EmploymentIncomeVM(
        status: EmploymentStatus.employed,
        monthlyIncomeNgn: 0,
        employerName: "",
        jobTitle: "",
      ),
      docs: const DocumentsVM(
        applicantIdUploaded: false,
        selfieUploaded: false,
        guarantorIdUploaded: false,
        guarantorPassportUploaded: false,
        proofOfAddressUploaded: false,
      ),
      acceptTerms: false,

      // ✅ shared model supports these (optional)
      message: null,
      moveInDate: null,
    );
  }
}

/// ---------------- Screen 2: Step 1 (Personal + Guarantor) ----------------

class ApplicationStep1Screen extends StatefulWidget {
  const ApplicationStep1Screen({super.key, required this.draft});
  final ApplicationDraftVM draft;

  @override
  State<ApplicationStep1Screen> createState() => _ApplicationStep1ScreenState();
}

class _ApplicationStep1ScreenState extends State<ApplicationStep1Screen> {
  late ApplicationDraftVM _draft;

  // Applicant
  final _aName = TextEditingController();
  final _aEmail = TextEditingController();
  final _aPhone = TextEditingController();
  final _aAddress = TextEditingController();

  // Guarantors (max 2)
  final List<_GuarantorControllers> _guarantorCtrls = [];

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;

    _aName.text = _draft.applicant.fullName;
    _aEmail.text = _draft.applicant.email;
    _aPhone.text = _draft.applicant.phone;
    _aAddress.text = _draft.applicant.address;

    for (final g in _draft.guarantors) {
      _guarantorCtrls.add(_GuarantorControllers.from(g));
    }
  }

  @override
  void dispose() {
    _aName.dispose();
    _aEmail.dispose();
    _aPhone.dispose();
    _aAddress.dispose();
    for (final c in _guarantorCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _guarantorRequired => _draft.guarantorRequired;

  void _syncDraftFromFields() {
    final applicant = ApplicantVM(
      fullName: _aName.text.trim(),
      email: _aEmail.text.trim(),
      phone: _aPhone.text.trim(),
      address: _aAddress.text.trim(),
    );

    final guarantors = _guarantorCtrls
        .map((c) => c.toVM(applicantAddress: applicant.address))
        .toList();

    _draft = _draft.copyWith(applicant: applicant, guarantors: guarantors);
  }

  String? _validate() {
    _syncDraftFromFields();

    if (_draft.applicant.fullName.trim().isEmpty) {
      return "Please enter your full name.";
    }
    if (_draft.applicant.email.trim().isEmpty) {
      return "Please enter your email.";
    }
    if (_draft.applicant.address.trim().isEmpty) {
      return "Please enter your current address.";
    }

    if (_guarantorRequired) {
      final g = _draft.guarantors.first;
      if (g.fullName.trim().isEmpty) return "Guarantor full name is required.";
      if (g.email.trim().isEmpty) return "Guarantor email is required.";
      if (g.phone.trim().isEmpty) return "Guarantor phone is required.";
      if (g.address.trim().isEmpty) return "Guarantor address is required.";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _PageGradient(
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: const AppTopBar(title: "Application"),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.sm,
            AppSpacing.screenV,
            AppSizes.screenBottomPad,
          ),
          children: [
            const _StepDots(active: 2),
            const SizedBox(height: AppSpacing.md),
            _ListingRowCard(listing: _draft.listing),
            const SizedBox(height: AppSpacing.lg),

            const _SectionTitle("Step 1 of 3 | Personal + Guarantor"),
            const SizedBox(height: AppSpacing.md),

            const _SubTitle("Applicant (You)"),
            const SizedBox(height: AppSpacing.sm),
            _FrostCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _LabeledField(
                      label: "Full name *",
                      child: _TextField(
                        ctrl: _aName,
                        hint: "Your full name",
                        keyboardType: TextInputType.name,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LabeledField(
                      label: "Email *",
                      child: _TextField(
                        ctrl: _aEmail,
                        hint: "you@email.com",
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LabeledField(
                      label: "Phone *",
                      child: _TextField(
                        ctrl: _aPhone,
                        hint: "+234 80X XXXX",
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LabeledField(
                      label: "Current address *",
                      child: _TextField(
                        ctrl: _aAddress,
                        hint: "Current address",
                        keyboardType: TextInputType.streetAddress,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _SubTitle(
              _guarantorRequired
                  ? "Guarantor Details (Required)"
                  : "Guarantor Details (Optional)",
            ),
            const SizedBox(height: AppSpacing.sm),

            ...List.generate(_guarantorCtrls.length, (i) {
              final c = _guarantorCtrls[i];
              final isSecond = i == 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isSecond ? 0 : AppSpacing.md),
                child: _FrostCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_guarantorCtrls.length > 1)
                          Text(
                            "Guarantor ${i + 1}",
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary(context),
                                ),
                          ),
                        if (_guarantorCtrls.length > 1)
                          const SizedBox(height: AppSpacing.sm),

                        _LabeledField(
                          label: "Guarantor full name",
                          child: _TextField(
                            ctrl: c.name,
                            hint: "Full name",
                            keyboardType: TextInputType.name,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        _LabeledField(
                          label: "Relationship",
                          child: _Dropdown<RelationshipKind>(
                            value: c.relationship,
                            items: RelationshipKind.values,
                            label: (v) => v.label,
                            onChanged: (v) =>
                                setState(() => c.relationship = v),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        _LabeledField(
                          label: "Guarantor email",
                          child: _TextField(
                            ctrl: c.email,
                            hint: "guarantor@email.com",
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _LabeledField(
                          label: "Guarantor phone",
                          child: _TextField(
                            ctrl: c.phone,
                            hint: "+234 80X XXXX",
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        _LabeledField(
                          label: "Guarantor address",
                          child: _TextField(
                            ctrl: c.address,
                            hint: "Address",
                            keyboardType: TextInputType.streetAddress,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),
                        _CheckRow(
                          value: c.sameAddress,
                          label: "Same address as applicant",
                          onChanged: (v) {
                            setState(() {
                              c.sameAddress = v;
                              if (v) c.address.text = _aAddress.text;
                            });
                          },
                        ),

                        const SizedBox(height: AppSpacing.sm),
                        _LabeledField(
                          label: "Employment status (optional)",
                          child: _Dropdown<EmploymentStatus>(
                            value: c.empStatus,
                            items: EmploymentStatus.values,
                            label: (v) => v.label,
                            onChanged: (v) => setState(() => c.empStatus = v),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _LabeledField(
                          label: "Monthly income (optional)",
                          child: _TextField(
                            ctrl: c.income,
                            hint: "e.g ₦250000",
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        if (_guarantorCtrls.length > 1) ...[
                          const SizedBox(height: AppSpacing.md),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _guarantorCtrls.removeAt(i).dispose();
                                });
                              },
                              child: const Text("Remove guarantor"),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: AppSpacing.sm),

            if (_guarantorCtrls.length < 2)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _guarantorCtrls.add(_GuarantorControllers.empty());
                    });
                  },
                  child: const Text("+ Add another guarantor"),
                ),
              ),

            const SizedBox(height: AppSpacing.lg),

            _PrimaryPillButton(
              text: "Next",
              onTap: () {
                final err = _validate();
                if (err != null) {
                  _toast(context, err);
                  return;
                }
                _syncDraftFromFields();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ApplicationStep2Screen(draft: _draft),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Screen 3: Step 2 (Employment & Income) ----------------

class ApplicationStep2Screen extends StatefulWidget {
  const ApplicationStep2Screen({super.key, required this.draft});
  final ApplicationDraftVM draft;

  @override
  State<ApplicationStep2Screen> createState() => _ApplicationStep2ScreenState();
}

class _ApplicationStep2ScreenState extends State<ApplicationStep2Screen> {
  late ApplicationDraftVM _draft;

  EmploymentStatus _status = EmploymentStatus.employed;
  final _income = TextEditingController();
  final _employer = TextEditingController();
  final _jobTitle = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _status = _draft.employment.status;
    _income.text = _draft.employment.monthlyIncomeNgn == 0
        ? ""
        : _draft.employment.monthlyIncomeNgn.toString();
    _employer.text = _draft.employment.employerName;
    _jobTitle.text = _draft.employment.jobTitle;
  }

  @override
  void dispose() {
    _income.dispose();
    _employer.dispose();
    _jobTitle.dispose();
    super.dispose();
  }

  int _parseInt(String s) =>
      int.tryParse(s.replaceAll(RegExp(r"[^0-9]"), "")) ?? 0;

  @override
  Widget build(BuildContext context) {
    return _PageGradient(
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: const AppTopBar(title: "Application"),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.sm,
            AppSpacing.screenV,
            AppSizes.screenBottomPad,
          ),
          children: [
            const _StepDots(active: 3),
            const SizedBox(height: AppSpacing.md),
            _ListingRowCard(listing: _draft.listing),
            const SizedBox(height: AppSpacing.lg),

            const _SectionTitle("Step 2 of 3 | Employment & Income"),
            const SizedBox(height: AppSpacing.md),

            _FrostCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _LabeledField(
                      label: "Employment status",
                      child: _Dropdown<EmploymentStatus>(
                        value: _status,
                        items: EmploymentStatus.values,
                        label: (v) => v.label,
                        onChanged: (v) => setState(() => _status = v),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LabeledField(
                      label: "Monthly income",
                      child: _TextField(
                        ctrl: _income,
                        hint: "e.g ₦300000",
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LabeledField(
                      label: "Employer name (optional)",
                      child: _TextField(ctrl: _employer, hint: "Employer"),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LabeledField(
                      label: "Job title (optional)",
                      child: _TextField(ctrl: _jobTitle, hint: "Job title"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _PrimaryPillButton(
              text: "Next (Documents)",
              onTap: () {
                final income = _parseInt(_income.text);
                if (income <= 0) {
                  _toast(context, "Please enter your monthly income.");
                  return;
                }

                final emp = EmploymentIncomeVM(
                  status: _status,
                  monthlyIncomeNgn: income,
                  employerName: _employer.text.trim(),
                  jobTitle: _jobTitle.text.trim(),
                );

                final next = _draft.copyWith(employment: emp);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ApplicationStep3DocumentsScreen(draft: next),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Screen 4: Step 3 (Documents) ----------------

class ApplicationStep3DocumentsScreen extends StatefulWidget {
  const ApplicationStep3DocumentsScreen({super.key, required this.draft});
  final ApplicationDraftVM draft;

  @override
  State<ApplicationStep3DocumentsScreen> createState() =>
      _ApplicationStep3DocumentsScreenState();
}

class _ApplicationStep3DocumentsScreenState
    extends State<ApplicationStep3DocumentsScreen> {
  late ApplicationDraftVM _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  void _toggle(String key) {
    final d = _draft.docs;
    DocumentsVM next;
    switch (key) {
      case "applicantId":
        next = d.copyWith(applicantIdUploaded: !d.applicantIdUploaded);
        break;
      case "selfie":
        next = d.copyWith(selfieUploaded: !d.selfieUploaded);
        break;
      case "guarantorId":
        next = d.copyWith(guarantorIdUploaded: !d.guarantorIdUploaded);
        break;
      case "guarantorPassport":
        next = d.copyWith(
          guarantorPassportUploaded: !d.guarantorPassportUploaded,
        );
        break;
      case "proof":
        next = d.copyWith(proofOfAddressUploaded: !d.proofOfAddressUploaded);
        break;
      default:
        next = d;
    }
    setState(() => _draft = _draft.copyWith(docs: next));
  }

  bool get _guarantorRequired => _draft.guarantorRequired;

  bool get _canProceed {
    if (!_draft.docs.applicantIdUploaded) return false;
    if (!_draft.docs.selfieUploaded) return false;
    if (_guarantorRequired && !_draft.docs.guarantorIdUploaded) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return _PageGradient(
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: const AppTopBar(title: "Application"),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.sm,
            AppSpacing.screenV,
            AppSizes.screenBottomPad,
          ),
          children: [
            const _StepDots(active: 3),
            const SizedBox(height: AppSpacing.md),
            _ListingRowCard(listing: _draft.listing),
            const SizedBox(height: AppSpacing.lg),

            const _SectionTitle("Step 3 of 3 | Documents"),
            const SizedBox(height: AppSpacing.md),

            _DocTile(
              title: "Applicant ID (required)",
              subtitle: "Upload government ID",
              uploaded: _draft.docs.applicantIdUploaded,
              onTap: () => _toggle("applicantId"),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DocTile(
              title: "Selfie (required)",
              subtitle: "Face verification selfie",
              uploaded: _draft.docs.selfieUploaded,
              onTap: () => _toggle("selfie"),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DocTile(
              title:
                  "Guarantor ID (${_guarantorRequired ? "required" : "optional"})",
              subtitle: "Upload guarantor ID",
              uploaded: _draft.docs.guarantorIdUploaded,
              onTap: () => _toggle("guarantorId"),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DocTile(
              title: "Guarantor passport (optional)",
              subtitle: "Optional passport upload",
              uploaded: _draft.docs.guarantorPassportUploaded,
              onTap: () => _toggle("guarantorPassport"),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DocTile(
              title: "Proof of address (optional)",
              subtitle: "Utility bill / statement",
              uploaded: _draft.docs.proofOfAddressUploaded,
              onTap: () => _toggle("proof"),
            ),

            const SizedBox(height: AppSpacing.lg),

            _PrimaryPillButton(
              text: "Next (Review)",
              enabled: _canProceed,
              onTap: _canProceed
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ApplicationReviewScreen(draft: _draft),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Screen 5: Review & Submit ----------------

class ApplicationReviewScreen extends StatefulWidget {
  const ApplicationReviewScreen({super.key, required this.draft});
  final ApplicationDraftVM draft;

  @override
  State<ApplicationReviewScreen> createState() =>
      _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  late ApplicationDraftVM _draft;
  bool _submitting = false;

  final _message = TextEditingController();
  final _moveInDate = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _message.text = _draft.message ?? "";
    _moveInDate.text = _draft.moveInDate ?? "";
  }

  @override
  void dispose() {
    _message.dispose();
    _moveInDate.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final next = _draft.copyWith(
      message: _message.text.trim().isEmpty ? null : _message.text.trim(),
      moveInDate:
          _moveInDate.text.trim().isEmpty ? null : _moveInDate.text.trim(),
    );

    if (!next.acceptTerms) {
      _toast(context, "Please accept the terms to continue.");
      return;
    }

    // ✅ Build backend payload using your shared model -> CreateApplicationInput
    // (status should be omitted for tenant)
    final createInput = next.toCreateInput(status: null);

    setState(() => _submitting = true);

    try {
      // ✅ Plug your API client here:
      // await _client.post(ApiEndpoints.applications, data: createInput.toJson());
      await Future.delayed(const Duration(milliseconds: 650));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ApplicationSuccessScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _toast(context, "Failed to submit. Please try again.");
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = _draft.guarantors;

    return _PageGradient(
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: const AppTopBar(title: "Review & Submit"),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.sm,
            AppSpacing.screenV,
            AppSizes.screenBottomPad,
          ),
          children: [
            _ListingRowCard(listing: _draft.listing),
            const SizedBox(height: AppSpacing.lg),

            _FrostCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle("Applicant"),
                    const SizedBox(height: AppSpacing.sm),
                    _kv(context, "Full name", _draft.applicant.fullName),
                    _kv(context, "Email", _draft.applicant.email),
                    _kv(context, "Phone", _draft.applicant.phone),
                    _kv(context, "Address", _draft.applicant.address),

                    const SizedBox(height: AppSpacing.lg),

                    _SectionTitle("Guarantor${g.length > 1 ? "s" : ""}"),
                    const SizedBox(height: AppSpacing.sm),
                    ...g.map(
                      (x) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _FrostInner(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _kv(
                                context,
                                "Name",
                                x.fullName.isEmpty ? "—" : x.fullName,
                              ),
                              _kv(context, "Relationship", x.relationship.label),
                              _kv(
                                context,
                                "Email",
                                x.email.isEmpty ? "—" : x.email,
                              ),
                              _kv(
                                context,
                                "Phone",
                                x.phone.isEmpty ? "—" : x.phone,
                              ),
                              _kv(
                                context,
                                "Address",
                                x.address.isEmpty ? "—" : x.address,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    const _SectionTitle("Employment"),
                    const SizedBox(height: AppSpacing.sm),
                    _kv(context, "Status", _draft.employment.status.label),
                    _kv(
                      context,
                      "Monthly income",
                      "₦${_draft.employment.monthlyIncomeNgn}",
                    ),
                    _kv(
                      context,
                      "Employer",
                      _draft.employment.employerName.isEmpty
                          ? "—"
                          : _draft.employment.employerName,
                    ),
                    _kv(
                      context,
                      "Job title",
                      _draft.employment.jobTitle.isEmpty
                          ? "—"
                          : _draft.employment.jobTitle,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    const _SectionTitle("Optional"),
                    const SizedBox(height: AppSpacing.sm),
                    _LabeledField(
                      label: "Message to landlord (optional)",
                      child: _TextField(
                        ctrl: _message,
                        hint: "Write a short note...",
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LabeledField(
                      label: "Preferred move-in date (YYYY-MM-DD)",
                      child: _TextField(
                        ctrl: _moveInDate,
                        hint: "2026-03-01",
                        keyboardType: TextInputType.datetime,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _CheckRow(
                      value: _draft.acceptTerms,
                      label: "I agree to the terms and conditions",
                      onChanged: (v) => setState(
                        () => _draft = _draft.copyWith(acceptTerms: v),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _PrimaryPillButton(
              text: _submitting ? "Submitting..." : "Submit Application",
              enabled: !_submitting,
              onTap: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------- Success ----------------

class ApplicationSuccessScreen extends StatelessWidget {
  const ApplicationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PageGradient(
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: AppTopBar(
          title: "Application Submitted",
          leadingIcon: Icons.close_rounded,
          onLeadingTap: () => Navigator.of(context).pop(),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenV,
              AppSpacing.lg,
              AppSpacing.screenV,
              AppSizes.screenBottomPad,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 86,
                        width: 86,
                        decoration: BoxDecoration(
                          color: AppColors.brandGreenDeep.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 44,
                          color: AppColors.brandGreenDeep,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        "Success",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Your application has been submitted. We'll notify you when it's reviewed.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted(context)
                                  .withValues(alpha: 0.92),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _PrimaryPillButton(
                        text: "Back",
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------- Gradient wrapper (ExploreScreen pattern) ----------------

class _PageGradient extends StatelessWidget {
  const _PageGradient({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.pageBgGradient(context),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// ---------------- UI Helpers ----------------

class _ListingRowCard extends StatelessWidget {
  const _ListingRowCard({required this.listing});
  final ApplyListingVM listing;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: Container(
                height: AppSizes.listThumbSize,
                width: AppSizes.listThumbSize + AppSpacing.sm,
                color: AppColors.overlay(context, 0.06),
                child: listing.photoAssetPath != null &&
                        listing.photoAssetPath!.startsWith("assets/")
                    ? Image.asset(listing.photoAssetPath!, fit: BoxFit.cover)
                    : const Icon(
                        Icons.home_rounded,
                        color: AppColors.brandBlueSoft,
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    listing.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted(context),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    listing.priceText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandGreenDeep,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.active});
  final int active; // 1..3

  @override
  Widget build(BuildContext context) {
    Widget dot(int i) {
      final sel = i == active;
      return Container(
        height: 22,
        width: 22,
        decoration: BoxDecoration(
          color: sel
              ? AppColors.brandGreenDeep.withValues(alpha: 0.85)
              : AppColors.overlay(context, 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.overlay(context, 0.06)),
        ),
        child: Center(
          child: Text(
            "$i",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: sel ? AppColors.white : AppColors.textMuted(context),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(1),
        const SizedBox(width: AppSpacing.sm),
        dot(2),
        const SizedBox(width: AppSpacing.sm),
        dot(3),
      ],
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.title,
    required this.subtitle,
    required this.uploaded,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: uploaded
                      ? AppColors.brandGreenDeep.withValues(alpha: 0.18)
                      : AppColors.overlay(context, 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  uploaded ? Icons.check_rounded : Icons.upload_file_rounded,
                  color: uploaded
                      ? AppColors.brandGreenDeep
                      : AppColors.textMuted(context),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted(context),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted(context),
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
      color: AppColors.surface(context).withValues(alpha: 0.70),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: AppColors.surface(context).withValues(alpha: 0.55),
          ),
          boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
        ),
        child: child,
      ),
    );
  }
}

class _FrostInner extends StatelessWidget {
  const _FrostInner({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.03),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: child,
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({
    required this.text,
    this.enabled = true,
    required this.onTap,
  });

  final String text;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = !enabled || onTap == null;

    final disabledBg = AppColors.overlay(context, 0.06);
    final disabledText = AppColors.textMuted(context);

    return Material(
      color: disabled
          ? disabledBg
          : AppColors.brandGreenDeep.withValues(alpha: 0.80),
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: SizedBox(
          height: AppSizes.pillButtonHeight,
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: disabled ? disabledText : AppColors.white,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryPillButton extends StatelessWidget {
  const _SecondaryPillButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: SizedBox(
          height: AppSizes.pillButtonHeight,
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary(context),
          ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary(context),
          ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted(context),
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({required this.ctrl, required this.hint, this.keyboardType});

  final TextEditingController ctrl;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.03),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ).copyWith(hintText: hint),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.03),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (x) => DropdownMenuItem<T>(
                  value: x,
                  child: Text(
                    label(x),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(context),
                        ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                color: value
                    ? AppColors.brandGreenDeep.withValues(alpha: 0.85)
                    : AppColors.overlay(context, 0.08),
                borderRadius: BorderRadius.circular(AppRadii.xxs),
                border: Border.all(color: AppColors.overlay(context, 0.06)),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.white,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Guarantor controllers ----------------

class _GuarantorControllers {
  _GuarantorControllers({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.income,
    required this.relationship,
    required this.empStatus,
    required this.sameAddress,
  });

  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController address;
  final TextEditingController income;

  RelationshipKind relationship;
  EmploymentStatus empStatus;
  bool sameAddress;

  static _GuarantorControllers empty() {
    return _GuarantorControllers(
      name: TextEditingController(),
      email: TextEditingController(),
      phone: TextEditingController(),
      address: TextEditingController(),
      income: TextEditingController(),
      relationship: RelationshipKind.parent,
      empStatus: EmploymentStatus.employed,
      sameAddress: false,
    );
  }

  static _GuarantorControllers from(GuarantorVM g) {
    return _GuarantorControllers(
      name: TextEditingController(text: g.fullName),
      email: TextEditingController(text: g.email),
      phone: TextEditingController(text: g.phone),
      address: TextEditingController(text: g.address),
      income: TextEditingController(text: g.monthlyIncomeNgn?.toString() ?? ""),
      relationship: g.relationship,
      empStatus: g.employmentStatus ?? EmploymentStatus.employed,
      sameAddress: g.sameAddressAsApplicant,
    );
  }

  int _parseIncome(String s) =>
      int.tryParse(s.replaceAll(RegExp(r"[^0-9]"), "")) ?? 0;

  GuarantorVM toVM({required String applicantAddress}) {
    final addr = sameAddress ? applicantAddress : address.text.trim();
    return GuarantorVM(
      fullName: name.text.trim(),
      relationship: relationship,
      email: email.text.trim(),
      phone: phone.text.trim(),
      address: addr,
      sameAddressAsApplicant: sameAddress,
      employmentStatus: empStatus,
      monthlyIncomeNgn:
          income.text.trim().isEmpty ? null : _parseIncome(income.text),
    );
  }

  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    address.dispose();
    income.dispose();
  }
}

void _toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}