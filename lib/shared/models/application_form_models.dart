// lib/shared/models/application_form_models.dart
import 'application_model.dart';

enum RelationshipKind { parent, sibling, spouse, friend, colleague, other }
extension RelationshipKindX on RelationshipKind {
  String get label {
    switch (this) {
      case RelationshipKind.parent:
        return "Parent";
      case RelationshipKind.sibling:
        return "Sibling";
      case RelationshipKind.spouse:
        return "Spouse";
      case RelationshipKind.friend:
        return "Friend";
      case RelationshipKind.colleague:
        return "Colleague";
      case RelationshipKind.other:
        return "Other";
    }
  }
}

enum EmploymentStatus { employed, selfEmployed, unemployed, student, retired }
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
      case EmploymentStatus.retired:
        return "Retired";
    }
  }
}

/// ✅ IMPORTANT: Apply flow must carry listingId AND propertyId
class ApplyListingVM {
  const ApplyListingVM({
    required this.listingId,
    required this.propertyId,
    required this.title,
    required this.location,
    required this.priceText,
    required this.rentPerMonthNgn,
    this.photoAssetPath,
  });

  final String listingId;
  final String propertyId;

  final String title;
  final String location;
  final String priceText;

  /// used for guarantor rule
  final int rentPerMonthNgn;

  final String? photoAssetPath;

  ApplyListingVM copyWith({
    String? listingId,
    String? propertyId,
    String? title,
    String? location,
    String? priceText,
    int? rentPerMonthNgn,
    String? photoAssetPath,
  }) {
    return ApplyListingVM(
      listingId: listingId ?? this.listingId,
      propertyId: propertyId ?? this.propertyId,
      title: title ?? this.title,
      location: location ?? this.location,
      priceText: priceText ?? this.priceText,
      rentPerMonthNgn: rentPerMonthNgn ?? this.rentPerMonthNgn,
      photoAssetPath: photoAssetPath ?? this.photoAssetPath,
    );
  }
}

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

  ApplicantVM copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? address,
  }) {
    return ApplicantVM(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

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

  GuarantorVM copyWith({
    String? fullName,
    RelationshipKind? relationship,
    String? email,
    String? phone,
    String? address,
    bool? sameAddressAsApplicant,
    EmploymentStatus? employmentStatus,
    int? monthlyIncomeNgn,
  }) {
    return GuarantorVM(
      fullName: fullName ?? this.fullName,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      sameAddressAsApplicant: sameAddressAsApplicant ?? this.sameAddressAsApplicant,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      monthlyIncomeNgn: monthlyIncomeNgn ?? this.monthlyIncomeNgn,
    );
  }
}

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

  EmploymentIncomeVM copyWith({
    EmploymentStatus? status,
    int? monthlyIncomeNgn,
    String? employerName,
    String? jobTitle,
  }) {
    return EmploymentIncomeVM(
      status: status ?? this.status,
      monthlyIncomeNgn: monthlyIncomeNgn ?? this.monthlyIncomeNgn,
      employerName: employerName ?? this.employerName,
      jobTitle: jobTitle ?? this.jobTitle,
    );
  }
}

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
      proofOfAddressUploaded: proofOfAddressUploaded ?? this.proofOfAddressUploaded,
    );
  }
}

class ApplicationDraftVM {
  const ApplicationDraftVM({
    required this.listing,
    required this.guarantorRequired,
    required this.applicant,
    required this.guarantors,
    required this.employment,
    required this.docs,
    required this.acceptTerms,
    required this.message,
    required this.moveInDate,
  });

  final ApplyListingVM listing;
  final bool guarantorRequired;

  final ApplicantVM applicant;
  final List<GuarantorVM> guarantors;
  final EmploymentIncomeVM employment;
  final DocumentsVM docs;

  final bool acceptTerms;

  /// Optional fields sent to backend
  final String? message;
  final String? moveInDate; // YYYY-MM-DD

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

  /// ✅ The important part: use listing.listingId and listing.propertyId
  CreateApplicationInput toCreateInput({ApplicationStatus? status}) {
    return CreateApplicationInput(
      listingId: listing.listingId,
      propertyId: listing.propertyId,
      message: message,
      monthlyIncome: employment.monthlyIncomeNgn,
      moveInDate: moveInDate,
      status: status,
    );
  }
}