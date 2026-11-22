import 'dart:convert';

String parseApiError(String error) {
  try {
    // Ambil JSON dari Exception
    final jsonStart = error.indexOf('{');

    if (jsonStart == -1) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }

    final jsonString = error.substring(jsonStart);
    final data = jsonDecode(jsonString);

    final detail = data['detail'];

    if (detail is List && detail.isNotEmpty) {
      return detail.map((item) => item['msg'].toString()).join('\n');
    }

    if (detail is String) {
      return detail;
    }

    return 'Terjadi kesalahan. Silakan coba lagi.';
  } catch (_) {
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
