import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appwrite_service.dart';

final appwriteProvider = Provider<AppwriteService>((ref) {
  return AppwriteService();
});
