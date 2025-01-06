import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alice/core/alice_core.dart';
import 'package:alice/core/alice_utils.dart';
import 'package:alice/model/alice_form_data_file.dart';
import 'package:alice/model/alice_from_data_field.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:chopper/chopper.dart';
import 'package:http/http.dart';

class AliceChopperInterceptor implements chopper.Interceptor {
  /// AliceCore instance
  final AliceCore aliceCore;

  /// Creates instance of chopper interceptor
  AliceChopperInterceptor(this.aliceCore);

  /// Creates hashcode based on request
  int getRequestHashCode(BaseRequest baseRequest) {
    var hashCodeSum = 0;
    hashCodeSum += baseRequest.url.hashCode;
    hashCodeSum += baseRequest.method.hashCode;
    if (baseRequest.headers.isNotEmpty) {
      baseRequest.headers.forEach((key, value) {
        hashCodeSum += key.hashCode;
        hashCodeSum += value.hashCode;
      });
    }
    if (baseRequest.contentLength != null) {
      hashCodeSum += baseRequest.contentLength.hashCode;
    }

    return hashCodeSum.hashCode;
  }

  /// Handles chopper request and creates alice http call.
  /// Handles chopper response and adds data to existing alice http call.
  @override
  FutureOr<chopper.Response<BodyType>> intercept<BodyType>(
    chopper.Chain<BodyType> chain,
  ) async {
    // Start saving the request details.
    final request = chain.request;

    /// The alice_token header is added to the request in order to keep track
    /// of the request in the AliceCore instance.
    final requestId = getRequestHashCode(
      /// The alice_token header is added to the request in order to keep track
      /// of the request in the AliceCore instance.
      applyHeader(
        chain.request,
        'alice_token',
        DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    );

    try {
      aliceCore.addCall(
        AliceHttpCall(requestId)
          ..method = chain.request.method
          ..endpoint =
              chain.request.url.path.isEmpty ? '/' : chain.request.url.path
          ..server = chain.request.url.host
          ..client = 'Chopper'
          ..secure = chain.request.url.scheme == 'https'
          ..uri = chain.request.url.toString()
          ..request = (AliceHttpRequest()
            ..size = switch (chain.request.body) {
              final dynamic body when body is String =>
                utf8.encode(body).length,
              final dynamic body when body is List<int> => body.length,
              final dynamic body when body == null => 0,
              _ => utf8.encode(body.toString()).length,
            }
            ..body = chain.request.body ?? ''
            ..time = DateTime.now()
            ..headers = chain.request.headers
            ..contentType =
                chain.request.headers[HttpHeaders.contentTypeHeader] ??
                    'unknown'
            ..formDataFields = chain.request.parts
                .whereType<PartValue<String>>()
                .map(
                  (field) => AliceFormDataField(field.name, field.value),
                )
                .toList()
            ..formDataFiles = chain.request.parts
                .whereType<PartValueFile<String>>()
                .map((file) => AliceFormDataFile(file.value, '', 0))
                .toList()
            ..queryParameters = chain.request.parameters)
          ..response = AliceHttpResponse(),
      );
    } catch (exception) {
      AliceUtils.log(exception.toString());
    }

    // Make the request to retrieve the response
    final response = await chain.proceed(request);

    final httpResponse = AliceHttpResponse()..status = response.statusCode;
    if (response.body == null) {
      httpResponse
        ..body = ''
        ..size = 0;
    } else {
      httpResponse
        ..body = response.body
        ..size = utf8.encode(response.body.toString()).length;
    }

    httpResponse.time = DateTime.now();
    final headers = <String, String>{};
    response.headers.forEach((header, values) {
      headers[header] = values;
    });
    httpResponse.headers = headers;

    aliceCore.addResponse(httpResponse, requestId);
    return response;
  }
}
