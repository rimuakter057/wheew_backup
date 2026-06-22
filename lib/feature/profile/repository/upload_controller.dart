// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:http/http.dart' as http;
// import 'package:platchatapp/core/service/api_client.dart';
// import 'package:platchatapp/core/service/api_url.dart';
// import 'package:platchatapp/feature/profile/model/user_document.dart';
// import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
//
//
// class UploadDocumentController extends GetxController {
//   // ── State ──────────────────────────────────────────────────────────────
//   final RxBool isFetching = false.obs;
//
//   final RxBool isLicenseLoading   = false.obs;
//   final RxBool isInsuranceLoading = false.obs;
//   final RxBool isTaxLoading       = false.obs;
//   final RxBool isVehicleOwner      = false.obs;
//   final RxBool isCarInspection    = false.obs;
//
//   final Rxn<UserDocument> licenseDoc   = Rxn<UserDocument>();
//   final Rxn<UserDocument> insuranceDoc = Rxn<UserDocument>();
//   final Rxn<UserDocument> taxDoc       = Rxn<UserDocument>();
//   final Rxn<UserDocument> vehicleOwner      = Rxn<UserDocument>();
//   final Rxn<UserDocument> carInspection       = Rxn<UserDocument>(); //, VEHICLE_OWNERSHIP, CAR_INSPECTION
//
//   // ── Helpers ────────────────────────────────────────────────────────────
//
//   Rxn<UserDocument> docObs(String type) {
//     switch (type.toUpperCase()) {
//       case 'LICENSE':   return licenseDoc;
//       case 'INSURANCE': return insuranceDoc;
//       case 'TAX':       return taxDoc;
//       case "VEHICLE_OWNERSHIP": return vehicleOwner;
//       case "CAR_INSPECTION": return carInspection;
//
//       default:          return licenseDoc;
//     }
//   }
//
//   RxBool loadingObs(String type) {
//     switch (type.toUpperCase()) {
//       case 'LICENSE':   return isLicenseLoading;
//       case 'INSURANCE': return isInsuranceLoading;
//       case 'TAX':       return isTaxLoading;
//       case 'VEHICLE_OWNERSHIP':       return isVehicleOwner;
//       case 'CAR_INSPECTION':       return isCarInspection;
//
//       default:          return isLicenseLoading;
//     }
//   }
//
//   // ── GET /user-documents ────────────────────────────────────────────────
//   Future<void> fetchDocuments({required BuildContext context}) async {
//     try {
//       isFetching.value = true;
//       final response = await ApiClient.getData(uri: ApiUrl.getDocument);
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final decoded = jsonDecode(response.body);
//         final List<dynamic> docs = _documentsListFromBody(decoded);
//
//         licenseDoc.value   = null;
//         insuranceDoc.value = null;
//         taxDoc.value       = null;
//
//         for (final d in docs) {
//           if (d is! Map) continue;
//           final doc = UserDocument.fromJson(Map<String, dynamic>.from(d));
//           docObs(doc.typeKey).value = doc;
//         }
//       }if(response.statusCode == 400){
//
//         final decoded = jsonDecode(response.body);
//
//         String msg = 'Something went wrong';
//
//         if (decoded['message'] is List) {
//           msg = (decoded['message'] as List).join('\n');
//         } else if (decoded['message'] is String) {
//           msg = decoded['message'];
//         }
//
//         CustomSnackbar.error(
//           context: context,
//           message: msg,
//         );
//
//
//       }
//     }
//
//     catch (e) {
//
//       CustomSnackbar.error(context: context, message:'Failed to load documents');
//     } finally {
//       isFetching.value = false;
//     }
//   }
//
//   /// ── POST /user-documents ───────────────────────────────────────────────
//   Future<void> uploadDocument({
//     required String documentType,
//     required String uniqueId,
//     required String expiryDate,   // dd/MM/yyyy
//     required String filePath,
//     required String fileName,
//     required BuildContext context
//   }) async
//   {
//     final loading = loadingObs(documentType);
//     try {
//       loading.value = true;
//
//       final multipartFile = await http.MultipartFile.fromPath(
//         'file', filePath, filename: fileName,
//       );
//
//       final response = await ApiClient.multipartRequest(
//         uri: ApiUrl.uploadDocument,
//         method: 'POST',
//         fields: {
//           'document_type': documentType.toUpperCase(),
//           'expiry_date':   _toApiDate(expiryDate),
//           'unique_id':     uniqueId,
//         },
//         files: [multipartFile],
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         await fetchDocuments(context: context);
//
//         CustomSnackbar.success(context: context, message: 'Document uploaded successfully');
//         context.pop();
//       } else {
//
//         CustomSnackbar.error(context: context, message:response.body);
//       }
//     } catch (e) {
//
//       CustomSnackbar.error(context: context, message:'Upload failed: $e');
//     } finally {
//       loading.value = false;
//     }
//   }
//
//   /// ── PATCH /user-documents/:id ──────────────────────────────────────────
//   Future<void> updateDocument({
//     required String documentId,
//     required String documentType,
//     required String uniqueId,
//     required String expiryDate,   // dd/MM/yyyy
//     required String filePath,
//     required String fileName,
//     required BuildContext context,
//   }) async
//   {
//     final loading = loadingObs(documentType);
//     try {
//       loading.value = true;
//
//       final multipartFile = await http.MultipartFile.fromPath(
//         'file', filePath, filename: fileName,
//       );
//
//       final response = await ApiClient.multipartRequest(
//         uri: ApiUrl.updateDocument(documentId: documentId),
//         method: 'PATCH',
//         fields: {
//           'document_type': documentType.toUpperCase(),
//           'expiry_date':   _toApiDate(expiryDate),
//           'unique_id':     uniqueId,
//         },
//         files: [multipartFile],
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         await fetchDocuments(context: context);
//
//         CustomSnackbar.success(context: context, message:'Document updated successfully');
//         context.pop();
//       } else {
//
//         CustomSnackbar.error(context: context, message:response.body);
//       }
//     } catch (e) {
//
//
//       CustomSnackbar.error(context: context, message: 'Update failed: $e');
//     } finally {
//       loading.value = false;
//     }
//   }
//
//   // ── Date helpers ───────────────────────────────────────────────────────
//   /// dd/MM/yyyy → yyyy-MM-dd
//   String _toApiDate(String date) {
//     try {
//       final p = date.split('/');
//       if (p.length == 3) return '${p[2]}-${p[1]}-${p[0]}';
//     } catch (_) {}
//     return date;
//   }
//
//   /// yyyy-MM-dd → dd/MM/yyyy  (for pre-filling the edit sheet)
//   String toDisplayDate(String apiDate) {
//     try {
//       final p = apiDate.split('-');
//       if (p.length == 3) return '${p[2]}/${p[1]}/${p[0]}';
//     } catch (_) {}
//     return apiDate;
//   }
//
//   String _parseMessage(String body) {
//     try {
//       return jsonDecode(body)['message'] ?? 'Something went wrong';
//     } catch (_) {
//       return 'Something went wrong';
//     }
//   }
//
//
//
//
//   static List<dynamic> _documentsListFromBody(dynamic decoded) {
//     if (decoded is List) return decoded;
//     if (decoded is Map) {
//       final m = Map<String, dynamic>.from(decoded);
//       final inner = m['documents'] ??
//           m['data'] ??
//           m['items'] ??
//           m['user_documents'];
//       if (inner is List) return inner;
//     }
//     return const [];
//   }
// }








import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/profile/model/user_document.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';

class UploadDocumentController extends GetxController {
  // ─────────────────────────────────────────────
  // STATE MAPS (SCALABLE)
  // ─────────────────────────────────────────────

  final RxMap<String, UserDocument?> documents = <String, UserDocument?>{}.obs;
  final RxMap<String, bool> loadingMap = <String, bool>{}.obs;

  final RxBool isFetching = false.obs;

  // ─────────────────────────────────────────────
  // GET DOCUMENT
  // ─────────────────────────────────────────────

  UserDocument? getDoc(String type) {
    return documents[type.toUpperCase()];
  }

  bool isLoading(String type) {
    return loadingMap[type.toUpperCase()] ?? false;
  }

  // ─────────────────────────────────────────────
  // FETCH ALL DOCUMENTS
  // ─────────────────────────────────────────────

  Future<void> fetchDocuments({required BuildContext context}) async {
    try {
      isFetching.value = true;

      final response = await ApiClient.getData(
        uri: ApiUrl.getDocument,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> docs = _documentsListFromBody(decoded);

        documents.clear();

        for (final d in docs) {
          if (d is! Map) continue;

          final doc = UserDocument.fromJson(
            Map<String, dynamic>.from(d),
          );

          documents[doc.typeKey.toUpperCase()] = doc;
        }
      } else {
        _showError(context, response.body);
      }
    } catch (e) {
      CustomSnackbar.error(
        context: context,
        message: 'Failed to load documents',
      );
    } finally {
      isFetching.value = false;
    }
  }

  // ─────────────────────────────────────────────
  // UPLOAD DOCUMENT
  // ─────────────────────────────────────────────

  Future<void> uploadDocument({
    required String documentType,
    required String uniqueId,
    required String expiryDate,
    required String filePath,
    required String fileName,
    required BuildContext context,
  }) async {
    final type = documentType.toUpperCase();

    try {
      loadingMap[type] = true;

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: fileName,
      );

      final response = await ApiClient.multipartRequest(
        uri: ApiUrl.uploadDocument,
        method: 'POST',
        fields: {
          'document_type': type,
          'expiry_date': _toApiDate(expiryDate),
          'unique_id': uniqueId,
        },
        files: [multipartFile],
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchDocuments(context: context);

        CustomSnackbar.success(
          context: context,
          message: 'Document uploaded successfully',
        );

        context.pop();
      } else {
        _showError(context, response.body);
      }
    } catch (e) {
      CustomSnackbar.error(
        context: context,
        message: 'Upload failed',
      );
    } finally {
      loadingMap[type] = false;
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE DOCUMENT
  // ─────────────────────────────────────────────

  Future<void> updateDocument({
    required String documentId,
    required String documentType,
    required String uniqueId,
    required String expiryDate,
    required String filePath,
    required String fileName,
    required BuildContext context,
  }) async {
    final type = documentType.toUpperCase();

    try {
      loadingMap[type] = true;

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: fileName,
      );

      final response = await ApiClient.multipartRequest(
        uri: ApiUrl.updateDocument(documentId: documentId),
        method: 'PATCH',
        fields: {
          'document_type': type,
          'expiry_date': _toApiDate(expiryDate),
          'unique_id': uniqueId,
        },
        files: [multipartFile],
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchDocuments(context: context);

        CustomSnackbar.success(
          context: context,
          message: 'Document updated successfully',
        );

        context.pop();
      } else {
        _showError(context, response.body);
      }
    } catch (e) {
      CustomSnackbar.error(
        context: context,
        message: 'Update failed',
      );
    } finally {
      loadingMap[type] = false;
    }
  }

  // ─────────────────────────────────────────────
  // ERROR HANDLER (IMPORTANT)
  // ─────────────────────────────────────────────

  void _showError(BuildContext context, String body) {
    try {
      final decoded = jsonDecode(body);

      String msg = 'Something went wrong';

      if (decoded['message'] is List) {
        msg = (decoded['message'] as List).join('\n');
      } else if (decoded['message'] is String) {
        msg = decoded['message'];
      }

      CustomSnackbar.error(
        context: context,
        message: msg,
      );
    } catch (_) {
      CustomSnackbar.error(
        context: context,
        message: 'Something went wrong',
      );
    }
  }

  // ─────────────────────────────────────────────
  // DATE HELPERS
  // ─────────────────────────────────────────────

  String _toApiDate(String date) {
    try {
      final p = date.split('/');
      if (p.length == 3) return '${p[2]}-${p[1]}-${p[0]}';
    } catch (_) {}
    return date;
  }

  String toDisplayDate(String apiDate) {
    try {
      final p = apiDate.split('-');
      if (p.length == 3) return '${p[2]}/${p[1]}/${p[0]}';
    } catch (_) {}
    return apiDate;
  }

  // ─────────────────────────────────────────────
  // RESPONSE PARSER
  // ─────────────────────────────────────────────

  static List<dynamic> _documentsListFromBody(dynamic decoded) {
    if (decoded is List) return decoded;

    if (decoded is Map) {
      final m = Map<String, dynamic>.from(decoded);

      final inner =
          m['documents'] ??
              m['data'] ??
              m['items'] ??
              m['user_documents'];

      if (inner is List) return inner;
    }

    return const [];
  }
}