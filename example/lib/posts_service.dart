import 'dart:async';

import 'package:chopper/chopper.dart';

// this is necessary for the generated code to find your class
part 'posts_service.chopper.dart';

@ChopperApi(baseUrl: 'https://jsonplaceholder.typicode.com/posts')
abstract class PostsService extends ChopperService {
  // helper methods that help you instantiate your service
  static PostsService create([ChopperClient? client]) => _$PostsService(client);

  @GET(path: '/{id}')
  Future<Response<dynamic>> getPost(@Path() String id);

  @POST(path: '/')
  Future<Response<dynamic>> postPost(@Body() String? body);

  @PUT(path: '/{id}')
  Future<Response<dynamic>> putPost(@Path() String id, @Body() String? body);
}
