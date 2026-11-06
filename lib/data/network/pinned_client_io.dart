import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Client HTTPS che si fida SOLO del certificato self-signed del server quiz
/// (assets/certs/server.crt). Nessuna CA di sistema è accettata per questo
/// client, quindi un certificato diverso (es. man-in-the-middle) viene rifiutato.
Future<http.Client> createQuizHttpClient() async {
  final cert = await rootBundle.load('assets/certs/server.crt');
  final context = SecurityContext(withTrustedRoots: false)
    ..setTrustedCertificatesBytes(cert.buffer.asUint8List());
  return IOClient(HttpClient(context: context));
}
