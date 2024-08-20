import 'dart:convert';
import 'dart:io';

import 'package:alice/alice.dart';
import 'package:alice/core/alice_http_client_extensions.dart';
import 'package:alice/core/alice_http_extensions.dart';
import 'package:alice_example/posts_service.dart';
import 'package:chopper/chopper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Alice _alice;
  late Dio _dio;
  late HttpClient _httpClient;
  ChopperClient? _chopper;
  late PostsService _postsService;
  final Color _primaryColor = const Color(0xffff5e57);
  final Color _accentColor = const Color(0xffff3f34);
  final Color _buttonColor = const Color(0xff008000);

  @override
  void initState() {
    _alice = Alice(
      showInspectorOnShake: true,
    );
    _dio = Dio(
      BaseOptions(
        followRedirects: false,
      ),
    );
    _dio.interceptors.add(_alice.getDioInterceptor());
    _httpClient = HttpClient();
    _chopper = ChopperClient(
      interceptors: [_alice.getChopperInterceptor()],
    );
    _postsService = PostsService.create(_chopper);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(_buttonColor),
    );
    return MaterialApp(
      theme: ThemeData(
        primaryColor: _primaryColor,
        colorScheme: ColorScheme.light(secondary: _accentColor),
      ),
      navigatorKey: _alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alice HTTP Inspector - Example'),
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              _getTextWidget(
                'Welcome to example of Alice Http Inspector. Click buttons '
                'below to generate sample data.',
              ),
              ElevatedButton(
                onPressed: _runDioRequests,
                style: buttonStyle,
                child: const Text('Run Dio HTTP Requests'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _runHttpHttpRequests,
                style: buttonStyle,
                child: const Text('Run http/http HTTP Requests'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _runHttpHttpClientRequests,
                style: buttonStyle,
                child: const Text('Run HttpClient Requests'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _runChopperHttpRequests,
                style: buttonStyle,
                child: const Text('Run Chopper HTTP Requests'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _logExampleData,
                style: buttonStyle,
                child: const Text('Log example data'),
              ),
              const SizedBox(height: 24),
              _getTextWidget(
                  'After clicking on buttons above, you should receive '
                  'notification.'
                  ' Click on it to show inspector. You can also shake your '
                  'device or click button below.'),
              ElevatedButton(
                onPressed: _runHttpInspector,
                style: buttonStyle,
                child: const Text('Run HTTP Inspector'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTextWidget(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
    );
  }

  void _logExampleData() {
    final logs = [
      AliceLog(
        timestamp: DateTime.now(),
        message: 'Info log',
      ),
      AliceLog(
        level: DiagnosticLevel.debug,
        timestamp: DateTime.now(),
        message: 'Debug log',
      ),
      AliceLog(
        level: DiagnosticLevel.warning,
        timestamp: DateTime.now(),
        message: 'Warning log',
      ),
    ];
    const notNumber = 'afs';
    try {
      int.parse(notNumber);
    } catch (e, stacktrace) {
      logs.add(
        AliceLog(
          level: DiagnosticLevel.error,
          timestamp: DateTime.now(),
          message: 'Error log',
          error: e,
          stackTrace: stacktrace,
        ),
      );
    }
    _alice.addLogs(logs);
  }

  Future<void> _runChopperHttpRequests() async {
    final body = jsonEncode(
      <String, dynamic>{'title': 'foo', 'body': 'bar', 'userId': '1'},
    );
    await _postsService.getPost('1');
    await _postsService.postPost(body);
    await _postsService.putPost('1', body);
    await _postsService.putPost('1231923', body);
    await _postsService.putPost('1', null);
    await _postsService.postPost(null);
    await _postsService.getPost('123456');
  }

  Future<void> _runDioRequests() async {
    final body = <String, dynamic>{
      'title': 'foo',
      'body': 'bar',
      'userId': '1',
    };
    await _dio.get<void>(
      'https://httpbin.org/redirect-to?url=https%3A%2F%2Fhttpbin.org',
    );
    await _dio.delete<void>('https://httpbin.org/status/500');
    await _dio.delete<void>('https://httpbin.org/status/400');
    await _dio.delete<void>('https://httpbin.org/status/300');
    await _dio.delete<void>('https://httpbin.org/status/200');
    await _dio.delete<void>('https://httpbin.org/status/100');
    await _dio.post<void>(
      'https://jsonplaceholder.typicode.com/posts',
      data: body,
    );
    await _dio.get<void>(
      'https://jsonplaceholder.typicode.com/posts',
      queryParameters: <String, dynamic>{'test': 1},
    );
    await _dio.put<void>(
      'https://jsonplaceholder.typicode.com/posts/1',
      data: body,
    );
    await _dio.put<void>(
      'https://jsonplaceholder.typicode.com/posts/1',
      data: body,
    );
    await _dio.delete<void>('https://jsonplaceholder.typicode.com/posts/1');
    await _dio.get<void>('http://jsonplaceholder.typicode.com/test/test');

    await _dio.get<void>('https://jsonplaceholder.typicode.com/photos');
    await _dio.get<void>(
      'https://icons.iconarchive.com/icons/paomedia/small-n-flat/256/sign-info-icon.png',
    );
    await _dio.get<void>(
      'https://images.unsplash.com/photo-1542736705-53f0131d1e98?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80',
    );
    await _dio.get<void>(
      'https://findicons.com/files/icons/1322/world_of_aqua_5/128/bluetooth.png',
    );
    await _dio.get<void>(
      'https://upload.wikimedia.org/wikipedia/commons/4/4e/Pleiades_large.jpg',
    );
    await _dio.get<void>('http://techslides.com/demos/sample-videos/small.mp4');

    await _dio
        .get<void>('https://www.cse.wustl.edu/~jain/cis677-97/ftp/e_3dlc2.pdf');

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/test.txt');
    await file.create();
    file.writeAsStringSync('123456789');

    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    await _dio.post<void>(
      'https://jsonplaceholder.typicode.com/photos',
      data: formData,
    );

    await _dio.get<void>('http://dummy.restapiexample.com/api/v1/employees');
  }

  Future<void> _runHttpHttpRequests() async {
    final body = <String, String>{
      'title': 'foo',
      'body': 'bar',
      'userId': '1',
    };
    await http
        .post(
          Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!,
          body: body,
        )
        .interceptWithAlice(_alice, body: body);

    await http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!)
        .interceptWithAlice(_alice);

    await http
        .put(
          Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
          body: body,
        )
        .interceptWithAlice(_alice, body: body);

    await http
        .patch(
          Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
          body: body,
        )
        .interceptWithAlice(_alice, body: body);

    await http
        .delete(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!)
        .interceptWithAlice(_alice, body: body);

    await http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/test/test')!)
        .interceptWithAlice(_alice);

    await http
        .post(
      Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!,
      body: body,
    )
        .then((response) {
      _alice.onHttpResponse(response, body: body);
    });

    await http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/posts')!)
        .then((response) {
      _alice.onHttpResponse(response);
    });

    await http
        .put(
      Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
      body: body,
    )
        .then((response) {
      _alice.onHttpResponse(response, body: body);
    });

    await http
        .patch(
      Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!,
      body: body,
    )
        .then((response) {
      _alice.onHttpResponse(response, body: body);
    });

    await http
        .delete(Uri.tryParse('https://jsonplaceholder.typicode.com/posts/1')!)
        .then((response) {
      _alice.onHttpResponse(response);
    });

    await http
        .get(Uri.tryParse('https://jsonplaceholder.typicode.com/test/test')!)
        .then((response) {
      _alice.onHttpResponse(response);
    });

    await http
        .post(
          Uri.tryParse(
            'https://jsonplaceholder.typicode.com/posts?key1=value1',
          )!,
          body: body,
        )
        .interceptWithAlice(_alice, body: body);

    await http
        .post(
          Uri.tryParse(
            'https://jsonplaceholder.typicode.com/posts?key1=value1&key2=value2&key3=value3',
          )!,
          body: body,
        )
        .interceptWithAlice(_alice, body: body);

    await http
        .get(
      Uri.tryParse(
        'https://jsonplaceholder.typicode.com/test/test?key1=value1&key2=value2&key3=value3',
      )!,
    )
        .then((response) {
      _alice.onHttpResponse(response);
    });
  }

  void _runHttpHttpClientRequests() {
    final body = <String, dynamic>{
      'title': 'foo',
      'body': 'bar',
      'userId': '1',
    };
    _httpClient
        .getUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
        .interceptWithAlice(_alice);

    _httpClient
        .postUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
        .interceptWithAlice(_alice, body: body, headers: <String, dynamic>{});

    _httpClient
        .putUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
        .interceptWithAlice(_alice, body: body);

    _httpClient
        .getUrl(Uri.parse('https://jsonplaceholder.typicode.com/test/test/'))
        .interceptWithAlice(_alice);

    _httpClient
        .postUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
        .then((request) async {
      _alice.onHttpClientRequest(request, body: body);
      request.write(body);
      final httpResponse = await request.close();
      final responseBody = await utf8.decoder.bind(httpResponse).join();
      _alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .putUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
        .then((request) async {
      _alice.onHttpClientRequest(request, body: body);
      request.write(body);
      final httpResponse = await request.close();
      final responseBody = await utf8.decoder.bind(httpResponse).join();
      _alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .patchUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
        .then((request) async {
      _alice.onHttpClientRequest(request, body: body);
      request.write(body);
      final httpResponse = await request.close();
      final responseBody = await utf8.decoder.bind(httpResponse).join();
      _alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .deleteUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
        .then((request) async {
      _alice.onHttpClientRequest(request);
      final httpResponse = await request.close();
      final responseBody = await utf8.decoder.bind(httpResponse).join();
      _alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    _httpClient
        .getUrl(Uri.parse('https://jsonplaceholder.typicode.com/test/test/'))
        .then((request) async {
      _alice.onHttpClientRequest(request);
      final httpResponse = await request.close();
      final responseBody = await utf8.decoder.bind(httpResponse).join();
      _alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }
}
