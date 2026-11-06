import 'package:http/http.dart' as http;

Future<http.Client> createQuizHttpClient() async => http.Client();
