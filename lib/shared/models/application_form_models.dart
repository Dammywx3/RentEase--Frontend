// lib/shared/models/application_form_models.dart
import 'package:flutter/foundation.dart';

import 'application_model.dart';

@immutable
class ApplyListingVM {
  const ApplyListingVM({
    required this.listingId,
    required this.propertyId,
    required this.title,
    required this.location,
    required this.rentPerMonthNgn,
    required this.priceText,
    this.photoAssetPath,
  });

  final String listingId;
  final String propertyId;

  final String title;
  final String location;
  final int rentPerMonthNgn;
  final String priceText;
  final String? photoAssetPath;

  /// ✅ Backward compatibility for old code that expects listing.id
  @Deprecated("Use listingId")
  String get id => listingId;
}

enum RelationshipKind { parent, sibling, friend, employer, other }

extension RelationshipKindX on RelationshipKind {
  String get label {
    switch (this) {
      case RelationshipKind.parent:
        return "Parent";
      case RelationshipKind.sibling:
        return "Sibling";
      case RelationshipKind.friend:
        return "Friend";
      case RelationshipKind.employer:
        return "Employer";
      case RelationshipKind.other:
        return "Other";
    }
  }
}

enum EmploymentStatus { employed, selfEmployed, unemployed, student, other }

extension EmploymentStatusX on EmploymentStatus {
  String get label {
    switch (this) {
      case EmploymentStatus.employed:
        return "Employed";
      case EmploymentStatus.selfEmployed:
        return "Self-employed";
      case EmploymentStatus.unemployed:
        return "Unemployed";
      case EmploymentStatus.student:
        return "Student";
      case EmploymentStatus.other:
        return "Other";
    }
  }
}

@immutable
class ApplicantVM {
  const ApplicantVM({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
  });

  final String fullName;
  final String email;
  final String phone;
  final String address;
}

@immutable
class GuarantorVM {
  const GuarantorVM({
    required this.fullName,
    required this.relationship,
    required this.email,
    required this.phone,
    required this.address,
    required this.sameAddressAsApplicant,
    this.employmentStatus,
    this.monthlyIncomeNgn,
  });

  final String fullName;
  final RelationshipKind relationship;
  final String email;
  final String phone;
  final String address;
  final bool sameAddressAsApplicant;

  final EmploymentStatus? employmentStatus;
  final int? monthlyIncomeNgn;
}

@immutable
class EmploymentIncomeVM {
  const EmploymentIncomeVM({
    required this.status,
    required this.monthlyIncomeNgn,
    required this.employerName,
    required this.jobTitle,
  });

  final EmploymentStatus status;
  final int monthlyIncomeNgn;
  final String employerName;
  final String jobTitle;
}

@immutable
class DocumentsVM {
  const DocumentsVM({
    required this.applicantIdUploaded,
    required this.selfieUploaded,
    required this.guarantorIdUploaded,
    required this.guarantorPassportUploaded,
    required this.proofOfAddressUploaded,
  });

  final bool applicantIdUploaded;
  final bool selfieUploaded;
  final bool guarantorIdUploaded;
  final bool guarantorPassportUploaded;
  final bool proofOfAddressUploaded;

  DocumentsVM copyWith({
    bool? applicantIdUploaded,
    bool? selfieUploaded,
    bool? guarantorIdUploaded,
    bool? guarantorPassportUploaded,
    bool? proofOfAddressUploaded,
  }) {
    return DocumentsVM(
      applicantIdUploaded: applicantIdUploaded ?? this.applicantIdUploaded,
      selfieUploaded: selfieUploaded ?? this.selfieUploaded,
      guarantorIdUploaded: guarantorIdUploaded ?? this.guarantorIdUploaded,
      guarantorPassportUploaded:
          guarantorPassportUploaded ?? this.guarantorPassportUploaded,
      proofOfAddressUploaded:
          proofOfAddressUploaded ?? this.proofOfAddressUploaded,
    );
  }
}

@immutable
class ApplicationDraftVM {
  const ApplicationDraftVM({
    required this.listing,
    required this.guarantorRequired,
    required this.applicant,
    required this.guarantors,
    required this.employment,
    required this.docs,
    required this.acceptTerms,
    this.message,
    this.moveInDate, // YYYY-MM-DD
  });

  final ApplyListingVM listing;
  final bool guarantorRequired;

  final ApplicantVM applicant;
  final List<GuarantorVM> guarantors;

  final EmploymentIncomeVM employment;
  final DocumentsVM docs;

  final bool acceptTerms;

  /// ✅ These are the ONLY extra fields that backend supports.
  final String? message;
  final String? moveInDate;

  ApplicationDraftVM copyWith({
    ApplyListingVM? listing,
    bool? guarantorRequired,
    ApplicantVM? applicant,
    List<GuarantorVM>? guarantors,
    EmploymentIncomeVM? employment,
    DocumentsVM? docs,
    bool? acceptTerms,
    String? message,
    String? moveInDate,
  }) {
    return ApplicationDraftVM(
      listing: listing ?? this.listing,
      guarantorRequired: guarantorRequired ?? this.guarantorRequired,
      applicant: applicant ?? this.applicant,
      guarantors: guarantors ?? this.guarantors,
      employment: employment ?? this.employment,
      docs: docs ?? this.docs,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      message: message ?? this.message,
      moveInDate: moveInDate ?? this.moveInDate,
    );
  }

  /// ✅ Convert UI draft into backend create input (matches Zod)
  CreateApplicationInput toCreateInput({ApplicationStatus? status}) {
    return CreateApplicationInput(
      listingId: listing.listingId,
      propertyId: listing.propertyId,
      message: message,
      monthlyIncome: employment.monthlyIncomeNgn > 0 ? employment.monthlyIncomeNgn : null,
      moveInDate: moveInDate,
      status: status,
    );
  }
}