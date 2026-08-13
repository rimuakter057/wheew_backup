
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:go_router/go_router.dart';
//
// import 'package:platchatapp/core/service/api_client.dart';
// import 'package:platchatapp/core/service/api_url.dart';
// import 'package:platchatapp/feature/profile/model/user_document.dart';
// import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
//
// class UploadDocumentController extends GetxController {
//   // ─────────────────────────────────────────────
//   // STATE MAPS (SCALABLE)
//   // ─────────────────────────────────────────────
//
//   final RxMap<String, UserDocument?> documents = <String, UserDocument?>{}.obs;
//   final RxMap<String, bool> loadingMap = <String, bool>{}.obs;
//
//   final RxBool isFetching = false.obs;
//
//   // ─────────────────────────────────────────────
//   // GET DOCUMENT
//   // ─────────────────────────────────────────────
//
//   UserDocument? getDoc(String type) {
//     return documents[type.toUpperCase()];
//   }
//
//   bool isLoading(String type) {
//     return loadingMap[type.toUpperCase()] ?? false;
//   }
//
//   // ─────────────────────────────────────────────
//   // FETCH ALL DOCUMENTS
//   // ─────────────────────────────────────────────
//
//   Future<void> fetchDocuments({required BuildContext context}) async {
//     try {
//       isFetching.value = true;
//
//       final response = await ApiClient.getData(
//         uri: ApiUrl.getDocument,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final decoded = jsonDecode(response.body);
//         final List<dynamic> docs = _documentsListFromBody(decoded);
//
//         documents.clear();
//
//         for (final d in docs) {
//           if (d is! Map) continue;
//
//           final doc = UserDocument.fromJson(
//             Map<String, dynamic>.from(d),
//           );
//
//           documents[doc.typeKey.toUpperCase()] = doc;
//         }
//       } else {
//         _showError(
//           context,
//           response.statusCode,
//           response.body,
//         );
//       }
//     } catch (e) {
//       CustomSnackbar.error(
//         context: context,
//         message: 'Failed to load documents',
//       );
//     } finally {
//       isFetching.value = false;
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   // UPLOAD DOCUMENT
//   // ─────────────────────────────────────────────
//
//   Future<void> uploadDocument({
//     required String documentType,
//     required String uniqueId,
//     required String expiryDate,
//     required String filePath,
//     required String fileName,
//     required BuildContext context,
//   }) async {
//     final type = documentType.toUpperCase();
//
//     try {
//       loadingMap[type] = true;
//
//       final multipartFile = await http.MultipartFile.fromPath(
//         'file',
//         filePath,
//         filename: fileName,
//       );
//
//       final response = await ApiClient.multipartRequest(
//         uri: ApiUrl.uploadDocument,
//         method: 'POST',
//         fields: {
//           'document_type': type,
//           'expiry_date': _toApiDate(expiryDate),
//           'unique_id': uniqueId,
//         },
//         files: [multipartFile],
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         await fetchDocuments(context: context);
//
//         CustomSnackbar.success(
//           context: context,
//           message: 'Document uploaded successfully',
//         );
//
//         context.pop();
//       } else {
//         _showError(
//           context,
//           response.statusCode,
//           response.body,
//         );
//       }
//     } catch (e) {
//       CustomSnackbar.error(
//         context: context,
//         message: 'Upload failed',
//       );
//     } finally {
//       loadingMap[type] = false;
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   // UPDATE DOCUMENT
//   // ─────────────────────────────────────────────
//
//   Future<void> updateDocument({
//     required String documentId,
//     required String documentType,
//     required String uniqueId,
//     required String expiryDate,
//     required String filePath,
//     required String fileName,
//     required BuildContext context,
//   }) async {
//     final type = documentType.toUpperCase();
//
//     try {
//       loadingMap[type] = true;
//
//       final multipartFile = await http.MultipartFile.fromPath(
//         'file',
//         filePath,
//         filename: fileName,
//       );
//
//       final response = await ApiClient.multipartRequest(
//         uri: ApiUrl.updateDocument(documentId: documentId),
//         method: 'PATCH',
//         fields: {
//           'document_type': type,
//           'expiry_date': _toApiDate(expiryDate),
//           'unique_id': uniqueId,
//         },
//         files: [multipartFile],
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         await fetchDocuments(context: context);
//
//         CustomSnackbar.success(
//           context: context,
//           message: 'Document updated successfully',
//         );
//
//         context.pop();
//       } else {
//         _showError(
//           context,
//           response.statusCode,
//           response.body,
//         );
//       }
//     } catch (e) {
//       CustomSnackbar.error(
//         context: context,
//         message: 'Update failed',
//       );
//     } finally {
//       loadingMap[type] = false;
//     }
//   }
//
//
//
//   // ─────────────────────────────────────────────
//   // DATE HELPERS
//   // ─────────────────────────────────────────────
//
//   String _toApiDate(String date) {
//     try {
//       final p = date.split('/');
//       if (p.length == 3) return '${p[2]}-${p[1]}-${p[0]}';
//     } catch (_) {}
//     return date;
//   }
//
//   String toDisplayDate(String apiDate) {
//     try {
//       final p = apiDate.split('-');
//       if (p.length == 3) return '${p[2]}/${p[1]}/${p[0]}';
//     } catch (_) {}
//     return apiDate;
//   }
//
//   // ─────────────────────────────────────────────
//   // RESPONSE PARSER
//   // ─────────────────────────────────────────────
//
//   static List<dynamic> _documentsListFromBody(dynamic decoded) {
//     if (decoded is List) return decoded;
//
//     if (decoded is Map) {
//       final m = Map<String, dynamic>.from(decoded);
//
//       final inner =
//           m['documents'] ??
//               m['data'] ??
//               m['items'] ??
//               m['user_documents'];
//
//       if (inner is List) return inner;
//     }
//
//     return const [];
//   }
//
//
//
//
//
//
//
//
//
//
//   void _showError(
//       BuildContext context,
//       int statusCode,
//       String body,
//       ) {
//     String message;
//
//     switch (statusCode) {
//       case 400:
//         try {
//           final decoded = jsonDecode(body);
//
//           if (decoded['message'] is List) {
//             message = (decoded['message'] as List).join('\n');
//           } else if (decoded['message'] is String &&
//               decoded['message'].toString().trim().isNotEmpty) {
//             message = decoded['message'];
//           } else {
//             message = 'Invalid request. Please check your information.';
//           }
//         } catch (_) {
//           message = 'Invalid request. Please check your information.';
//         }
//         break;
//
//       case 401:
//         message = 'Unauthorized. Please sign in again.';
//         break;
//
//       case 403:
//         message = 'You do not have permission to perform this action.';
//         break;
//
//       case 404:
//         message = 'The requested resource was not found.';
//         break;
//
//       case 409:
//         message = 'This document already exists.';
//         break;
//
//       case 422:
//         message = 'Please check the entered information and try again.';
//         break;
//
//       case 500:
//         message = 'Internal server error. Please try again later.';
//         break;
//
//       case 502:
//       case 503:
//       case 504:
//         message = 'Server is temporarily unavailable. Please try again later.';
//         break;
//
//       default:
//         message = 'Something went wrong. Please try again.';
//     }
//
//     CustomSnackbar.error(
//       context: context,
//       message: message,
//     );
//   }
//
// }



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:go_router/go_router.dart';
//
// import 'package:platchatapp/core/service/api_client.dart';
// import 'package:platchatapp/core/service/api_url.dart';
// import 'package:platchatapp/feature/profile/model/user_document.dart';
// import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';
//
// class UploadDocumentController extends GetxController {
//   // ─────────────────────────────────────────────
//   // STATE MAPS (SCALABLE)
//   // ─────────────────────────────────────────────
//
//   final RxMap<String, UserDocument?> documents = <String, UserDocument?>{}.obs;
//   final RxMap<String, bool> loadingMap = <String, bool>{}.obs;
//
//   final RxBool isFetching = false.obs;
//
//   // ─────────────────────────────────────────────
//   // GET DOCUMENT
//   // ─────────────────────────────────────────────
//
//   UserDocument? getDoc(String type) {
//     return documents[type.toUpperCase()];
//   }
//
//   bool isLoading(String type) {
//     return loadingMap[type.toUpperCase()] ?? false;
//   }
//
//   // ─────────────────────────────────────────────
//   // FETCH ALL DOCUMENTS
//   // ─────────────────────────────────────────────
//
//   Future<void> fetchDocuments({required BuildContext context}) async {
//     try {
//       isFetching.value = true;
//
//       final response = await ApiClient.getData(
//         uri: ApiUrl.getDocument,
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final decoded = jsonDecode(response.body);
//         final List<dynamic> docs = _documentsListFromBody(decoded);
//
//         documents.clear();
//
//         for (final d in docs) {
//           if (d is! Map) continue;
//
//           final doc = UserDocument.fromJson(
//             Map<String, dynamic>.from(d),
//           );
//
//           documents[doc.typeKey.toUpperCase()] = doc;
//         }
//       } else {
//         _showError(context, response.statusCode, response.body);
//       }
//     } catch (e) {
//       CustomSnackbar.error(
//         context: context,
//         message: 'Failed to load documents',
//       );
//     } finally {
//       isFetching.value = false;
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   // UPLOAD DOCUMENT
//   // ─────────────────────────────────────────────
//
//   Future<void> uploadDocument({
//     required String documentType,
//     required String uniqueId,
//     required String expiryDate,
//     required String filePath,
//     required String fileName,
//     required BuildContext context,
//     bool isOwner = false, // ✅ নতুন param
//   }) async {
//     final type = documentType.toUpperCase();
//
//     try {
//       loadingMap[type] = true;
//
//       final multipartFile = await http.MultipartFile.fromPath(
//         'file',
//         filePath,
//         filename: fileName,
//       );
//
//       // ✅ owner হলে শুধু expiry_date যাবে, বাকি field যাবে না
//       final fields = isOwner
//           ? <String, String>{
//         'expiry_date': _toApiDate(expiryDate),
//       }
//           : <String, String>{
//         'document_type': type,
//         'expiry_date': _toApiDate(expiryDate),
//         'unique_id': uniqueId,
//       };
//
//       final response = await ApiClient.multipartRequest(
//         uri: ApiUrl.uploadDocument,
//         method: 'POST',
//         fields: fields,
//         files: [multipartFile],
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         await fetchDocuments(context: context);
//
//         CustomSnackbar.success(
//           context: context,
//           message: 'Document uploaded successfully',
//         );
//
//         context.pop();
//       } else {
//         _showError(context, response.statusCode, response.body);
//       }
//     } catch (e) {
//       CustomSnackbar.error(
//         context: context,
//         message: 'Upload failed',
//       );
//     } finally {
//       loadingMap[type] = false;
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   // UPDATE DOCUMENT
//   // ─────────────────────────────────────────────
//
//   Future<void> updateDocument({
//     required String documentId,
//     required String documentType,
//     required String uniqueId,
//     required String expiryDate,
//     required String filePath,
//     required String fileName,
//     required BuildContext context,
//     bool isOwner = false, // ✅ নতুন param
//   }) async {
//     final type = documentType.toUpperCase();
//
//     try {
//       loadingMap[type] = true;
//
//       final multipartFile = await http.MultipartFile.fromPath(
//         'file',
//         filePath,
//         filename: fileName,
//       );
//
//       // ✅ owner হলে শুধু expiry_date যাবে, বাকি field যাবে না
//       final fields = isOwner
//           ? <String, String>{
//         'expiry_date': _toApiDate(expiryDate),
//       }
//           : <String, String>{
//         'document_type': type,
//         'expiry_date': _toApiDate(expiryDate),
//         'unique_id': uniqueId,
//       };
//
//       final response = await ApiClient.multipartRequest(
//         uri: ApiUrl.updateDocument(documentId: documentId),
//         method: 'PATCH',
//         fields: fields,
//         files: [multipartFile],
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         await fetchDocuments(context: context);
//
//         CustomSnackbar.success(
//           context: context,
//           message: 'Document updated successfully',
//         );
//
//         context.pop();
//       } else {
//         _showError(context, response.statusCode, response.body);
//       }
//     } catch (e) {
//       CustomSnackbar.error(
//         context: context,
//         message: 'Update failed',
//       );
//     } finally {
//       loadingMap[type] = false;
//     }
//   }
//
//   // ─────────────────────────────────────────────
//   // DATE HELPERS
//   // ─────────────────────────────────────────────
//
//   String _toApiDate(String date) {
//     try {
//       final p = date.split('/');
//       if (p.length == 3) return '${p[2]}-${p[1]}-${p[0]}';
//     } catch (_) {}
//     return date;
//   }
//
//   String toDisplayDate(String apiDate) {
//     try {
//       final p = apiDate.split('-');
//       if (p.length == 3) return '${p[2]}/${p[1]}/${p[0]}';
//     } catch (_) {}
//     return apiDate;
//   }
//
//   // ─────────────────────────────────────────────
//   // RESPONSE PARSER
//   // ─────────────────────────────────────────────
//
//   static List<dynamic> _documentsListFromBody(dynamic decoded) {
//     if (decoded is List) return decoded;
//
//     if (decoded is Map) {
//       final m = Map<String, dynamic>.from(decoded);
//
//       final inner =
//           m['documents'] ??
//               m['data'] ??
//               m['items'] ??
//               m['user_documents'];
//
//       if (inner is List) return inner;
//     }
//
//     return const [];
//   }
//
//   // ─────────────────────────────────────────────
//   // ERROR HANDLER (improved — সব ধরনের backend response format handle করে)
//   // ─────────────────────────────────────────────
//
//   void _showError(
//       BuildContext context,
//       int statusCode,
//       String body,
//       ) {
//     String message = _extractMessage(body) ?? _fallbackMessage(statusCode);
//
//     CustomSnackbar.error(
//       context: context,
//       message: message,
//     );
//   }
//
//   /// body থেকে actual error message বের করার চেষ্টা করে —
//   /// message: String / message: List / error: String / errors: [ {message: ...} ]
//   String? _extractMessage(String body) {
//     try {
//       final decoded = jsonDecode(body);
//       if (decoded is! Map) return null;
//
//       final m = Map<String, dynamic>.from(decoded);
//
//       // case 1: message is a String
//       if (m['message'] is String && (m['message'] as String).trim().isNotEmpty) {
//         return m['message'];
//       }
//
//       // case 2: message is a List<String>
//       if (m['message'] is List) {
//         final list = (m['message'] as List)
//             .map((e) => e.toString())
//             .where((e) => e.trim().isNotEmpty)
//             .toList();
//         if (list.isNotEmpty) return list.join('\n');
//       }
//
//       // case 3: top-level "error" key
//       if (m['error'] is String && (m['error'] as String).trim().isNotEmpty) {
//         return m['error'];
//       }
//
//       // case 4: "errors" is a List of objects like [{message: "..."}]
//       if (m['errors'] is List) {
//         final list = (m['errors'] as List)
//             .map((e) {
//           if (e is Map && e['message'] != null) return e['message'].toString();
//           return e.toString();
//         })
//             .where((e) => e.trim().isNotEmpty)
//             .toList();
//         if (list.isNotEmpty) return list.join('\n');
//       }
//
//       return null;
//     } catch (_) {
//       return null;
//     }
//   }
//
//   String _fallbackMessage(int statusCode) {
//     switch (statusCode) {
//       case 400:
//         return 'Invalid request. Please check your information.';
//       case 401:
//         return 'Unauthorized. Please sign in again.';
//       case 403:
//         return 'You do not have permission to perform this action.';
//       case 404:
//         return 'The requested resource was not found.';
//       case 409:
//         return 'This document already exists.';
//       case 422:
//         return 'Please check the entered information and try again.';
//       case 500:
//         return 'Internal server error. Please try again later.';
//       case 502:
//       case 503:
//       case 504:
//         return 'Server is temporarily unavailable. Please try again later.';
//       default:
//         return 'Something went wrong. Please try again.';
//     }
//   }
// }













import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'package:platchatapp/core/service/api_client.dart';
import 'package:platchatapp/core/service/api_url.dart';
import 'package:platchatapp/feature/profile/model/user_document.dart';
import 'package:platchatapp/helper/custom_snack_bar/custom_snack_bar.dart';

import '../../../utils/language/app_string.dart';

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
    final key = type.toUpperCase();

    debugPrint('📄 getDoc() called');
    debugPrint('➡️ Requested type: $type');
    debugPrint('➡️ Normalized key: $key');
    debugPrint('➡️ Available document keys: ${documents.keys.toList()}');

    final doc = documents[key];

    debugPrint('➡️ Document found: ${doc != null}');
    debugPrint('➡️ Document: $doc');

    return doc;
  }

  bool isLoading(String type) {
    final key = type.toUpperCase();
    final loading = loadingMap[key] ?? false;

    debugPrint('⏳ isLoading()');
    debugPrint('➡️ Type: $type');
    debugPrint('➡️ Key: $key');
    debugPrint('➡️ Loading: $loading');

    return loading;
  }

// ─────────────────────────────────────────────
// FETCH ALL DOCUMENTS
// ─────────────────────────────────────────────

  Future<void> fetchDocuments({required BuildContext context}) async {
    try {
      debugPrint('══════════════════════════════════════');
      debugPrint('📥 FETCH DOCUMENTS START');
      debugPrint('➡️ API URI: ${ApiUrl.getDocument}');

      isFetching.value = true;

      debugPrint('➡️ isFetching: ${isFetching.value}');

      final response = await ApiClient.getData(
        uri: ApiUrl.getDocument,
      );

      debugPrint('📡 FETCH RESPONSE');
      debugPrint('➡️ Status Code: ${response.statusCode}');
      debugPrint('➡️ Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Fetch successful');

        final decoded = jsonDecode(response.body);

        debugPrint('➡️ Decoded response: $decoded');
        debugPrint('➡️ Decoded type: ${decoded.runtimeType}');

        final List<dynamic> docs = _documentsListFromBody(decoded);

        debugPrint('➡️ Documents count: ${docs.length}');
        debugPrint('➡️ Documents list: $docs');

        documents.clear();

        debugPrint('🧹 Existing documents cleared');

        for (final d in docs) {
          debugPrint('────────────────────────────────');
          debugPrint('📄 Processing document');
          debugPrint('➡️ Raw document: $d');
          debugPrint('➡️ Raw type: ${d.runtimeType}');

          if (d is! Map) {
            debugPrint('⚠️ Skipped: document is not a Map');
            continue;
          }

          final doc = UserDocument.fromJson(
            Map<String, dynamic>.from(d),
          );

          debugPrint('✅ Parsed document');
          debugPrint('➡️ Document typeKey: ${doc.typeKey}');
          debugPrint('➡️ Normalized key: ${doc.typeKey.toUpperCase()}');
          debugPrint('➡️ Document: $doc');

          documents[doc.typeKey.toUpperCase()] = doc;

          debugPrint('➡️ Documents keys now: ${documents.keys.toList()}');
        }

        debugPrint('✅ FETCH DOCUMENTS COMPLETED');
        debugPrint('➡️ Total documents: ${documents.length}');
        debugPrint('➡️ Final keys: ${documents.keys.toList()}');
        debugPrint('➡️ Final documents: $documents');
      } else if (context.mounted) {
        debugPrint('❌ FETCH FAILED');
        debugPrint('➡️ Status Code: ${response.statusCode}');
        debugPrint('➡️ Response Body: ${response.body}');

        _showError(context, response.statusCode, response.body);
      }
    } catch (e, st) {
      debugPrint('❌ fetchDocuments error: $e');
      debugPrint('📍 StackTrace: $st');

      if (context.mounted) {
        CustomSnackbar.error(
          context: context,
          message: '${AppStrings.failedToLoadDocuments.tr}$e',
        );
      }
    } finally {
      isFetching.value = false;

      debugPrint('➡️ isFetching: ${isFetching.value}');
      debugPrint('📥 FETCH DOCUMENTS END');
      debugPrint('══════════════════════════════════════');
    }
  }

// ─────────────────────────────────────────────
// UPLOAD DOCUMENT (POST — নতুন document)
// ─────────────────────────────────────────────

  Future<void> uploadDocument({
    required String documentType,
    required String uniqueId,
    required String expiryDate,
    String? filePath,
    String? fileName,
    required BuildContext context,
    bool isOwner = false,
  }) async {
    final type = documentType.toUpperCase();

    try {
      debugPrint('══════════════════════════════════════');
      debugPrint('📤 UPLOAD DOCUMENT START');

      debugPrint('➡️ Original documentType: $documentType');
      debugPrint('➡️ Normalized type: $type');
      debugPrint('➡️ uniqueId: $uniqueId');
      debugPrint('➡️ expiryDate: $expiryDate');
      debugPrint('➡️ filePath: $filePath');
      debugPrint('➡️ fileName: $fileName');
      debugPrint('➡️ isOwner: $isOwner');

      loadingMap[type] = true;

      debugPrint('➡️ loadingMap[$type]: ${loadingMap[type]}');

      // Upload File is optional — only attach it if the user actually picked one.
      // contentType is set explicitly (mime-detected from the file itself) —
      // without it, http.MultipartFile.fromPath defaults to
      // application/octet-stream instead of e.g. image/jpeg, unlike Postman
      // which auto-detects it. The backend's file handling may behave
      // differently (or crash) on octet-stream vs a proper image mime type.
      final files = (filePath != null && fileName != null)
          ? [
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: fileName,
          contentType: MediaType.parse(
            lookupMimeType(filePath) ?? 'application/octet-stream',
          ),
        )
      ]
          : <http.MultipartFile>[];

      debugPrint('📎 FILE INFO');
      debugPrint('➡️ Files count: ${files.length}');
      debugPrint('➡️ File attached: ${files.isNotEmpty}');
      debugPrint('➡️ File contentType: ${files.isNotEmpty ? files.first.contentType : null}');

      // POST + owner হলে শুধু document_type + file — unique_id/expiry_date লাগবে না
      final fields = isOwner
          ? <String, String>{
        'document_type': type,
      }
          : <String, String>{
        'document_type': type,
        'expiry_date': _toApiDate(expiryDate),
        'unique_id': uniqueId,
      };

      debugPrint('📦 UPLOAD FIELDS');
      debugPrint('➡️ Fields: $fields');

      final response = await ApiClient.multipartRequest(
        uri: ApiUrl.uploadDocument,
        method: 'POST',
        fields: fields,
        files: files,
      );

      debugPrint('📡 UPLOAD RESPONSE');
      debugPrint('➡️ Status Code: ${response.statusCode}');
      debugPrint('➡️ Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ UPLOAD SUCCESS');

        if (context.mounted) {
          debugPrint('📥 Fetching documents after upload...');
          await fetchDocuments(context: context);
        }

        if (!context.mounted) {
          debugPrint('⚠️ Context is no longer mounted');
          return;
        }

        CustomSnackbar.success(
          context: context,
          message: AppStrings.documentUploadedSuccessfully.tr,
        );

        debugPrint('➡️ Navigating back after upload');

        context.pop();
      } else if (context.mounted) {
        debugPrint('❌ UPLOAD FAILED');
        debugPrint('➡️ Status Code: ${response.statusCode}');
        debugPrint('➡️ Response Body: ${response.body}');

        _showError(context, response.statusCode, response.body);
      }
    } catch (e, st) {
      debugPrint('❌ uploadDocument error: $e');
      debugPrint('📍 StackTrace: $st');

      if (context.mounted) {
        CustomSnackbar.error(
          context: context,
          message: '${AppStrings.uploadFailed.tr}$e',
        );
      }
    } finally {
      loadingMap[type] = false;

      debugPrint('➡️ loadingMap[$type]: ${loadingMap[type]}');
      debugPrint('📤 UPLOAD DOCUMENT END');
      debugPrint('══════════════════════════════════════');
    }
  }

// ─────────────────────────────────────────────
// UPDATE DOCUMENT (PATCH — existing document)
// ─────────────────────────────────────────────

  Future<void> updateDocument({
    required String documentId,
    required String documentType,
    required String uniqueId,
    required String expiryDate,
    String? filePath,
    String? fileName,
    required BuildContext context,
    bool isOwner = false,
  }) async {
    final type = documentType.toUpperCase();

    try {
      debugPrint('══════════════════════════════════════');
      debugPrint('🔄 UPDATE DOCUMENT START');

      debugPrint('➡️ documentId: $documentId');
      debugPrint('➡️ Original documentType: $documentType');
      debugPrint('➡️ Normalized type: $type');
      debugPrint('➡️ uniqueId: $uniqueId');
      debugPrint('➡️ expiryDate: $expiryDate');
      debugPrint('➡️ filePath: $filePath');
      debugPrint('➡️ fileName: $fileName');
      debugPrint('➡️ isOwner: $isOwner');

      loadingMap[type] = true;

      debugPrint('➡️ loadingMap[$type]: ${loadingMap[type]}');

      // Upload File is optional — only attach it if the user actually picked one.
      // contentType set explicitly — see uploadDocument for why (defaults
      // to application/octet-stream otherwise, unlike Postman's auto-detect).
      final files = (filePath != null && fileName != null)
          ? [
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: fileName,
          contentType: MediaType.parse(
            lookupMimeType(filePath) ?? 'application/octet-stream',
          ),
        )
      ]
          : <http.MultipartFile>[];

      debugPrint('📎 FILE INFO');
      debugPrint('➡️ Files count: ${files.length}');
      debugPrint('➡️ File attached: ${files.isNotEmpty}');
      debugPrint('➡️ File contentType: ${files.isNotEmpty ? files.first.contentType : null}');

      // PATCH + owner হলে কোনো field লাগবে না, শুধু file।
      // unique_id ইচ্ছাকৃতভাবে বাদ — backend PATCH-এ এটা reject করে
      // ("property unique_id should not exist", Postman-এ confirmed):
      // এটা শুধু creation (POST)-এর সময় একবারই সেট করা যায়, পরে আর
      // বদলানো যায় না। এটা পাঠালেই update request fail করত (400/500)।
      final fields = isOwner
          ? <String, String>{}
          : <String, String>{
        'document_type': type,
        'expiry_date': _toApiDate(expiryDate),
      };

      debugPrint('📦 UPDATE FIELDS');
      debugPrint('➡️ Fields: $fields');

      final uri = ApiUrl.updateDocument(documentId: documentId);

      debugPrint('🌐 UPDATE REQUEST');
      debugPrint('➡️ URI: $uri');
      debugPrint('➡️ Method: PATCH');

      final response = await ApiClient.multipartRequest(
        uri: uri,
        method: 'PATCH',
        fields: fields,
        files: files,
      );

      debugPrint('📡 UPDATE RESPONSE');
      debugPrint('➡️ Status Code: ${response.statusCode}');
      debugPrint('➡️ Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ UPDATE SUCCESS');

        if (context.mounted) {
          debugPrint('📥 Fetching documents after update...');
          await fetchDocuments(context: context);
        }

        if (!context.mounted) {
          debugPrint('⚠️ Context is no longer mounted');
          return;
        }

        CustomSnackbar.success(
          context: context,
          message: AppStrings.documentUpdatedSuccessfully.tr,
        );

        debugPrint('➡️ Navigating back after update');

        context.pop();
      } else if (context.mounted) {
        debugPrint('❌ UPDATE FAILED');
        debugPrint('➡️ Status Code: ${response.statusCode}');
        debugPrint('➡️ Response Body: ${response.body}');

        _showError(context, response.statusCode, response.body);
      }
    } catch (e, st) {
      debugPrint('❌ updateDocument error: $e');
      debugPrint('📍 StackTrace: $st');

      if (context.mounted) {
        CustomSnackbar.error(
          context: context,
          message: '${AppStrings.uploadFailed.tr}$e',
        );
      }
    } finally {
      loadingMap[type] = false;

      debugPrint('➡️ loadingMap[$type]: ${loadingMap[type]}');
      debugPrint('🔄 UPDATE DOCUMENT END');
      debugPrint('══════════════════════════════════════');
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

  // ─────────────────────────────────────────────
  // ERROR HANDLER (সব ধরনের backend response format handle করে)
  // ─────────────────────────────────────────────

  void _showError(
      BuildContext context,
      int statusCode,
      String body,
      ) {
    String message = _extractMessage(body) ?? _fallbackMessage(statusCode);

    CustomSnackbar.error(
      context: context,
      message: message,
    );
  }

  /// body থেকে actual error message বের করার চেষ্টা করে —
  /// message: String / message: List / error: String / errors: [ {message: ...} ]
  String? _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) return null;

      final m = Map<String, dynamic>.from(decoded);

      if (m['message'] is String && (m['message'] as String).trim().isNotEmpty) {
        return m['message'];
      }

      if (m['message'] is List) {
        final list = (m['message'] as List)
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
        if (list.isNotEmpty) return list.join('\n');
      }

      if (m['error'] is String && (m['error'] as String).trim().isNotEmpty) {
        return m['error'];
      }

      if (m['errors'] is List) {
        final list = (m['errors'] as List)
            .map((e) {
          if (e is Map && e['message'] != null) return e['message'].toString();
          return e.toString();
        })
            .where((e) => e.trim().isNotEmpty)
            .toList();
        if (list.isNotEmpty) return list.join('\n');
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  String _fallbackMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return AppStrings.invalidRequest.tr;
      case 401:
        return AppStrings.unauthorizedPleaseSignInAgain.tr;
      case 403:
        return AppStrings.noPermissionToPerformAction.tr;
      case 404:
        return AppStrings.requestedResourceNotFound.tr;
      case 409:
        return AppStrings.documentAlreadyExists.tr;
      case 422:
        return AppStrings.checkInformationAndTryAgain.tr;
      case 500:
        return AppStrings.internalServerError.tr;
      case 502:
      case 503:
      case 504:
        return AppStrings.serverTemporarilyUnavailable.tr;
      default:
        return AppStrings.somethingWentWrong.tr;
    }
  }
}