import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:dio/dio.dart';

enum RequestMethod { get, post, delete }

extension RequestMethodExt on RequestMethod {
  String get name {
    switch (this) {
      case RequestMethod.get:
        return 'GET';
      case RequestMethod.post:
        return 'POST';
      case RequestMethod.delete:
        return 'DELETE';
    }
  }

  Options get options {
    switch (this) {
      case RequestMethod.get:
        return Options(method: this.name);
      case RequestMethod.post:
        return Options(method: this.name);
      case RequestMethod.delete:
        return Options(method: this.name);
    }
  }

  static RequestMethod getRequestMethodFromOptionName(String name) {
    if (name.toUpperCase() == RequestMethod.get.name) return RequestMethod.get;

    if (name.toUpperCase() == RequestMethod.post.name)
      return RequestMethod.post;
    if (name.toUpperCase() == RequestMethod.delete.name)
      return RequestMethod.delete;
    throw UnhandledException();
  }
}
