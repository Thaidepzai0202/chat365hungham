// import 'dart:_http';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_chat365_pc/common/repos/get_token_repo.dart';
import 'package:app_chat365_pc/core/constants/local_storage_key.dart';
import 'package:app_chat365_pc/core/error_handling/exceptions.dart';
import 'package:app_chat365_pc/main.dart';
import 'package:app_chat365_pc/utils/data/clients/interceptors/response_interceptor.dart';
import 'package:app_chat365_pc/utils/data/extensions/num_extension.dart';
import 'package:app_chat365_pc/utils/data/extensions/string_extension.dart';
import 'package:app_chat365_pc/utils/data/models/error_response.dart';
import 'package:app_chat365_pc/utils/helpers/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:sp_util/sp_util.dart';

import '../../../core/constants/api_path.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/status_code.dart';
import '../models/request_method.dart';
import '../models/request_response.dart';
import 'interceptors/debug_log_interceptor.dart';

const _exceptionCanResolveByReFecth = [
  'HttpException: Connection closed before full header was received',
  'HandshakeException: Connection terminated during handshake',
  'Connecting timed out',
  'Receiving data timeout',
  'OS Error: Network is unreachable',
  'SocketException: Connection',
  'HttpException: Connection reset by peer',
  'HttpException: Connection closed while receiving data',
];

final _baseOptions = BaseOptions(
  // connectTimeout: Duration(milliseconds: 15000), //5000
  // receiveTimeout: Duration(milliseconds: 15000), //3000
  // sendTimeout: Duration(milliseconds: 15000), //3000
  baseUrl: ApiPath.baseUrl,
  responseType: ResponseType.json,
);

class ApiClient {
  late final Dio _dio;

  final Logger _log = Logger();

  // static ApiClient? _instance;

  // factory ApiClient() => _instance ??= ApiClient._();

  ApiClient()
      : _dio = Dio(_baseOptions)
          ..interceptors.addAll([
            ResponseInterceptor(),
            /*if (kReleaseMode) */
            // LogInterceptor(),
            DebugLogInterceptor(),
            // TokenInterceptor(),
          ]);

  Future<RequestResponse> fetch(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? searchParams,
    Map<String, dynamic>? headers,
    Options? options,
    String? token,
    RequestMethod method = RequestMethod.post,
    BaseOptions? baseOptions,
    int retryTime = AppConst.refecthApiThreshold,
    bool? isFormData,
  }) async {
    DateTime begin = DateTime.now();
    headers ??= HashMap();

    bool isExpriedToken = false;
    String? _token = token;

    if (options == null)
      options = method.options;
    else
      options.method = method.name;

    if (token != null) headers.putIfAbsent('Authorization', () => "$_token");

    options.headers = headers;
    options.contentType ??= headers.containsKey('Authorization')
        ? ContentType('application', 'x-www-form-urlencoded', charset: "utf-8")
            .mimeType
        : ContentType.json.mimeType;

    Response response;
    int retryTimes = 1;

    if (baseOptions != null) _dio.options = baseOptions;

    final bool useFormData =
        isFormData ?? (method == RequestMethod.post && data != null);

    while (true) {
      try {
        response = await _dio.request(
          url,
          data: useFormData ? FormData.fromMap(data ?? {}) : data,
          queryParameters: searchParams,
          options: options,
        );
        print(
            '\x1B[35m$url response in: ${DateTime.now().difference(begin).inMilliseconds}ms\x1B[m');
        break;
      } on DioException catch (e) {
        if (_exceptionCanResolveByReFecth
                .any((el) => e.message!.contains(el)) &&
            retryTimes <= retryTime) {
          retryTimes++;
          continue;
        }
        final errorRes = _dioErrorHandle(e);
        if (errorRes.code == StatusCode.errorCode401 && !isExpriedToken) {
          isExpriedToken = true;
          try {
            _token = await navigatorKey.currentContext!
                .read<GetTokenRepo>()
                .getToken();
            headers.update('Authorization', (_) => _token);
            retryTimes--;
            continue;
          } catch (e, s) {
            if (e is CustomException)
              logger.logError(e, s, 'RefreshTokenError: ');
          }
        }

        return errorRes;
      } catch (e) {
        return _unknowErrorHandle(e);
      }
    }

    try {
      json.decode(response.data);
    } catch (e, s) {
      _log.log(
        '=================DATA EXCEPTION===================',
        color: StrColor.red,
      );
      _log.logError(e, s);
      _log.logError(response.data);
      _log.log(
        '====================================',
        color: StrColor.red,
      );
      var error = ErrorResponse(message: 'Lỗi, vui lòng thử lại sau');
      return RequestResponse(
        '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
        false,
        0,
        error: error,
      );
    }

    return RequestResponse(
      response.data,
      true,
      response.statusCode ?? StatusCode.ok,
    );
  }

  Future<RequestResponse> fetchTest(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? searchParams,
    Map<String, dynamic>? headers,
    Options? options,
    String? token,
    RequestMethod method = RequestMethod.post,
    BaseOptions? baseOptions,
    int retryTime = AppConst.refecthApiThreshold,
  }) async {
    DateTime begin = DateTime.now();
    headers ??= HashMap();

    bool isExpriedToken = false;
    String? _token = token;

    if (options == null)
      options = method.options;
    else
      options.method = method.name;

    if (token != null) headers.putIfAbsent('Authorization', () => "$_token");

    options.headers = headers;
    options.contentType ??= headers.containsKey('Authorization')
        ? ContentType('application', 'x-www-form-urlencoded', charset: "utf-8")
            .mimeType
        : ContentType.json.mimeType;

    Response response;
    int retryTimes = 1;

    if (baseOptions != null) _dio.options = baseOptions;

    while (true) {
      try {
        response = await _dio.request(
          url,
          data: data,
          queryParameters: searchParams,
          options: options,
        );
        print(
            '\x1B[35m$url response in: ${DateTime.now().difference(begin).inMilliseconds}ms\x1B[m');
        break;
      } on DioException catch (e) {
        if (_exceptionCanResolveByReFecth
                .any((el) => e.message!.contains(el)) &&
            retryTimes <= retryTime) {
          retryTimes++;
          continue;
        }
        final errorRes = _dioErrorHandle(e);
        if (errorRes.code == StatusCode.errorCode401 && !isExpriedToken) {
          isExpriedToken = true;
          try {
            _token = await navigatorKey.currentContext!
                .read<GetTokenRepo>()
                .getToken();
            headers.update('Authorization', (_) => _token);
            retryTimes--;
            continue;
          } catch (e, s) {
            if (e is CustomException)
              logger.logError(e, s, 'RefreshTokenError: ');
          }
        }

        return errorRes;
      } catch (e) {
        return _unknowErrorHandle(e);
      }
    }

    try {
      json.decode(response.data);
    } catch (e, s) {
      _log.log(
        '=================DATA EXCEPTION===================',
        color: StrColor.red,
      );
      _log.logError(e, s);
      _log.logError(response.data);
      _log.log(
        '====================================',
        color: StrColor.red,
      );
      var error = ErrorResponse(message: 'Lỗi, vui lòng thử lại sau');
      return RequestResponse(
        '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
        false,
        0,
        error: error,
      );
    }

    return RequestResponse(
      response.data,
      true,
      response.statusCode ?? StatusCode.ok,
    );
  }



  Future<RequestResponse> fetchPost(
      String url, {
        Map<String, dynamic>? data,
        Map<String, dynamic>? searchParams,
        Map<String, dynamic>? headers,
        Options? options,
        String? token,
        RequestMethod method = RequestMethod.post,
        BaseOptions? baseOptions,
        int retryTime = AppConst.refecthApiThreshold,
        bool? isFormData,
      }) async {
    DateTime begin = DateTime.now();
    headers ??= HashMap();

    bool isExpriedToken = false;
    String? _token = token;

    if (options == null)
      options = method.options;
    else
      options.method = method.name;

    if (token != null) headers.putIfAbsent('Authorization', () => "$_token");

    options.headers = headers;
    options.contentType = ContentType.json.mimeType;

    Response response;
    int retryTimes = 1;

    if (baseOptions != null) _dio.options = baseOptions;

    final bool useFormData =
        isFormData ?? (method == RequestMethod.post && data != null);

    while (true) {
      try {
        response = await _dio.request(
          url,
          data: useFormData ? FormData.fromMap(data ?? {}) : data,
          queryParameters: searchParams,
          options: options,
        );
        print(
            '\x1B[35m$url response in: ${DateTime.now().difference(begin).inMilliseconds}ms\x1B[m');
        break;
      } on DioError catch (e) {
        if (_exceptionCanResolveByReFecth
            .any((el) => e.message!.contains(el)) &&
            retryTimes <= retryTime) {
          retryTimes++;
          continue;
        }
        final errorRes = _dioErrorHandle(e);
        if (errorRes.code == StatusCode.errorCode401 && !isExpriedToken) {
          isExpriedToken = true;
          try {
            _token = await navigatorKey.currentContext!
                .read<GetTokenRepo>()
                .getToken();
            headers.update('Authorization', (_) => _token);
            retryTimes--;
            continue;
          } catch (e, s) {
            if (e is CustomException)
              logger.logError(e, s, 'RefreshTokenError: ');
          }
        }

        return errorRes;
      } catch (e) {
        return _unknowErrorHandle(e);
      }
    }

    try {
      json.decode(response.data);
    } catch (e, s) {
      _log.log(
        '=================DATA EXCEPTION===================',
        color: StrColor.red,
      );
      _log.logError(e, s);
      _log.logError(response.data);
      _log.log(
        '====================================',
        color: StrColor.red,
      );
      var error = ErrorResponse(message: 'Lỗi, vui lòng thử lại sau');
      return RequestResponse(
        '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
        false,
        0,
        error: error,
      );
    }

    return RequestResponse(
      response.data,
      true,
      response.statusCode ?? StatusCode.ok,
    );
  }


  //copywith
  Future<RequestResponse> fetchQLC(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? searchParams,
    Map<String, dynamic>? headers,
    Options? options,
    String? token,
    RequestMethod method = RequestMethod.post,
    BaseOptions? baseOptions,
    int retryTime = AppConst.refecthApiThreshold,
    bool? isFormData,
  }) async {
    DateTime begin = DateTime.now();
    headers ??= HashMap();

    bool isExpriedToken = false;
    String? _token = token;

    if (options == null)
      options = method.options;
    else
      options.method = method.name;

    headers.putIfAbsent('Authorization',
        () => " Bearer ${token ?? SpUtil.getString(LocalStorageKey.tokenQLC)}");

    options.headers = headers;
    options.contentType ??= headers.containsKey('Authorization')
        ? ContentType('application', 'x-www-form-urlencoded', charset: "utf-8")
            .mimeType
        : ContentType.json.mimeType;

    Response response;
    int retryTimes = 1;

    if (baseOptions != null) _dio.options = baseOptions;

    final bool useFormData =
        isFormData ?? (method == RequestMethod.post && data != null);

    while (true) {
      try {
        response = await _dio.request(
          url,
          data: useFormData ? FormData.fromMap(data ?? {}) : data,
          queryParameters: searchParams,
          options: options,
        );
        print(
            '\x1B[35m$url response in: ${DateTime.now().difference(begin).inMilliseconds}ms\x1B[m');
        break;
      } on DioException catch (e) {
        if (_exceptionCanResolveByReFecth
                .any((el) => e.message!.contains(el)) &&
            retryTimes <= retryTime) {
          retryTimes++;
          continue;
        }
        final errorRes = _dioErrorHandle(e);
        if (errorRes.code == StatusCode.errorCode401 && !isExpriedToken) {
          isExpriedToken = true;
          try {
            _token = await navigatorKey.currentContext!
                .read<GetTokenRepo>()
                .getToken();
            headers.update('Authorization', (_) => _token);
            retryTimes--;
            continue;
          } catch (e, s) {
            if (e is CustomException)
              logger.logError(e, s, 'RefreshTokenError: ');
          }
        }

        return errorRes;
      } catch (e) {
        return _unknowErrorHandle(e);
      }
    }

    try {
      json.decode(response.data);
    } catch (e, s) {
      _log.log(
        '=================DATA EXCEPTION===================',
        color: StrColor.red,
      );
      _log.logError(e, s);
      _log.logError(response.data);
      _log.log(
        '====================================',
        color: StrColor.red,
      );
      var error = ErrorResponse(message: 'Lỗi, vui lòng thử lại sau');
      return RequestResponse(
        '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
        false,
        0,
        error: error,
      );
    }

    return RequestResponse(
      response.data,
      true,
      response.statusCode ?? StatusCode.ok,
    );
  }

  //copywith
  Future<RequestResponse> fetchCC(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? searchParams,
    Map<String, dynamic>? headers,
    Options? options,
    String? token,
    RequestMethod method = RequestMethod.post,
    BaseOptions? baseOptions,
    int retryTime = AppConst.refecthApiThreshold,
    bool? isFormData,
  }) async {
    DateTime begin = DateTime.now();
    headers ??= HashMap();

    bool isExpriedToken = false;
    String? _token = token;

    if (options == null)
      options = method.options;
    else
      options.method = method.name;

    headers.putIfAbsent('Authorization',
        () => "${token ?? SpUtil.getString(LocalStorageKey.tokenCC)}");

    options.headers = headers;
    options.contentType ??= headers.containsKey('Authorization')
        ? ContentType('application', 'x-www-form-urlencoded', charset: "utf-8")
            .mimeType
        : ContentType.json.mimeType;

    Response response;
    int retryTimes = 1;

    if (baseOptions != null) _dio.options = baseOptions;

    final bool useFormData =
        isFormData ?? (method == RequestMethod.post && data != null);

    while (true) {
      try {
        response = await _dio.request(
          url,
          data: useFormData ? FormData.fromMap(data ?? {}) : data,
          queryParameters: searchParams,
          options: options,
        );
        print(
            '\x1B[35m$url response in: ${DateTime.now().difference(begin).inMilliseconds}ms\x1B[m');
        break;
      } on DioException catch (e) {
        if (_exceptionCanResolveByReFecth
                .any((el) => e.message!.contains(el)) &&
            retryTimes <= retryTime) {
          retryTimes++;
          continue;
        }
        final errorRes = _dioErrorHandle(e);
        if (errorRes.code == StatusCode.errorCode401 && !isExpriedToken) {
          isExpriedToken = true;
          try {
            _token = await navigatorKey.currentContext!
                .read<GetTokenRepo>()
                .getToken();
            headers.update('Authorization', (_) => _token);
            retryTimes--;
            continue;
          } catch (e, s) {
            if (e is CustomException)
              logger.logError(e, s, 'RefreshTokenError: ');
          }
        }

        return errorRes;
      } catch (e) {
        return _unknowErrorHandle(e);
      }
    }

    try {
      json.decode(response.data);
    } catch (e, s) {
      _log.log(
        '=================DATA EXCEPTION===================',
        color: StrColor.red,
      );
      _log.logError(e, s);
      _log.logError(response.data);
      _log.log(
        '====================================',
        color: StrColor.red,
      );
      var error = ErrorResponse(message: 'Lỗi, vui lòng thử lại sau');
      return RequestResponse(
        '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
        false,
        0,
        error: error,
      );
    }

    return RequestResponse(
      response.data,
      true,
      response.statusCode ?? StatusCode.ok,
    );
  }

  /*
  Future<Response> fetchWithRequestOptions(RequestOptions options) =>
      _dio.request(
        options.path,
        data: options.data,
        options: Options(
          method: options.method,
          headers: options.headers,
        ),
      );
  */

  Future<RequestResponse> upload(
    url,
    List<MultipartFile> data, {
    Map<String, dynamic> mapData = const {},
    Map<String, dynamic>? headers,
    Options? options,
    ValueNotifier<double>? progressListener,
  }) async {
    Response? response;

    logger.log('SendFileDioLogger');

    final d = FormData()..files.addAll(data.map((e) => MapEntry('', e)));

    var fileTimeout = Duration(minutes: 15).inMilliseconds;

    var uploadOptions =
        (options == null ? RequestMethod.post.options : options).copyWith(
      sendTimeout: Duration(milliseconds: fileTimeout),
    );

    var uploadDio = _dio
      ..options = BaseOptions(
        sendTimeout: Duration(milliseconds: fileTimeout),
      );

    var listener = progressListener ?? ValueNotifier(0);

    try {
      response = await uploadDio.request(
        url,
        data: d,
        options: uploadOptions,
        onSendProgress: (count, total) {
          listener.value = (count / total).toPrecision(2);
        },
      );
    } on DioException catch (e) {
      // throw _requestFailure(e, retryTimes);
      return _dioErrorHandle(e);
    }

    // try {
    //   json.decode(response.data);
    // } catch (e, s) {
    //   logger.logError(e, s);
    //   return _unknowErrorHandle(e);
    //   // var error = ErrorResponse(message: 'Lỗi, vui lòng thử lại sau');
    //   // return RequestResponse(
    //   //   '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
    //   //   false,
    //   //   0,
    //   //   error: error,
    //   // );
    // }

    return RequestResponse(
      response.data,
      true,
      response.statusCode!,
    );
  }

  Future<dynamic> download(
    String url, {
    String? savePath,
    ProgressCallback? onReceiveProgress,
  }) async {
    Response response;
    int retryTimes = 1;
    while (true) {
      try {
        response = await _dio.download(
          url,
          savePath,
          onReceiveProgress: onReceiveProgress,
        );
        break;
      } on DioException catch (e) {
        if (_exceptionCanResolveByReFecth
                .any((el) => e.message!.contains(el)) &&
            retryTimes <= AppConst.refecthApiThreshold) {
          retryTimes++;
          continue;
        }

        // throw await _requestFailure(e, retryTimes);
      }
    }

    return response.data;
  }

  // TL 13/1/2024: Tải và cache ảnh
  Future<Image> downloadImage(String url) async {
    // TL: Thử cache ngay đầu nguồn luôn
    if (url.isEmpty) {
      // logger.log("URL ảnh rỗng. Call stack:\n${StackTrace.current}",
      //     name: "$runtimeType");
      logger.log("URL ảnh rỗng.", name: "$runtimeType");
      return Image.memory(Uint8List(0));
    }
    // getImageFile là stream, khá khó dùng
    //DefaultCacheManager().getImageFile(url).listen((fileResponse) {});
    return Image.memory(await DefaultCacheManager()
        .getSingleFile(url)
        .then((value) => value.readAsBytes()));
  }

    //copywith
  Future<RequestResponse> fetchVanThu(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? searchParams,
    Map<String, dynamic>? headers,
    Options? options,
    String? token,
    RequestMethod method = RequestMethod.post,
    BaseOptions? baseOptions,
    int retryTime = AppConst.refecthApiThreshold,
    bool? isFormData,
  }) async {
    DateTime begin = DateTime.now();
    headers ??= HashMap();

    bool isExpriedToken = false;
    String? _token = token;

    if (options == null)
      options = method.options;
    else
      options.method = method.name;

    headers.putIfAbsent('Authorization',
        () => "Bearer ${token ?? SpUtil.getString(LocalStorageKey.tokenVT)}");

    options.headers = headers;
    options.contentType ??= headers.containsKey('Authorization')
        ? ContentType('application', 'x-www-form-urlencoded', charset: "utf-8")
            .mimeType
        : ContentType.json.mimeType;

    Response response;
    int retryTimes = 1;

    if (baseOptions != null) _dio.options = baseOptions;

    final bool useFormData =
        isFormData ?? (method == RequestMethod.post && data != null);

    while (true) {
      try {
        response = await _dio.request(
          url,
          data: useFormData ? FormData.fromMap(data ?? {}) : data,
          queryParameters: searchParams,
          options: options,
        );
        print(
            '\x1B[35m$url response in: ${DateTime.now().difference(begin).inMilliseconds}ms\x1B[m');
        break;
      } on DioError catch (e) {
        if (_exceptionCanResolveByReFecth
                .any((el) => e.message!.contains(el)) &&
            retryTimes <= retryTime) {
          retryTimes++;
          continue;
        }
        final errorRes = _dioErrorHandle(e);
        if (errorRes.code == StatusCode.errorCode401 && !isExpriedToken) {
          isExpriedToken = true;
          try {
            _token = await navigatorKey.currentContext!
                .read<GetTokenRepo>()
                .getToken();
            headers.update('Authorization', (_) => _token);
            retryTimes--;
            continue;
          } catch (e, s) {
            if (e is CustomException)
              logger.logError(e, s, 'RefreshTokenError: ');
          }
        }

        return errorRes;
      } catch (e) {
        return _unknowErrorHandle(e);
      }
    }

    try {
      json.decode(response.data);
    } catch (e, s) {
      _log.log(
        '=================DATA EXCEPTION===================',
        color: StrColor.red,
      );
      _log.logError(e, s);
      _log.logError(response.data);
      _log.log(
        '====================================',
        color: StrColor.red,
      );
      var error = ErrorResponse(message: 'Lỗi, vui lòng thử lại sau');
      return RequestResponse(
        '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
        false,
        0,
        error: error,
      );
    }

    return RequestResponse(
      response.data,
      true,
      response.statusCode ?? StatusCode.ok,
    );
  }

  // TL 13/1/2024:
  // @Deprecated("Chuyển hóa qua dùng flutter_cache_manager. Chỉ lưu url ảnh thôi")
  // Future<List<int>> downloadImage(String url) async {
  //   var bytes = <int>[];
  //   try {
  //     var res = await Dio(
  //       _baseOptions.copyWith(
  //         responseType: ResponseType.bytes,
  //         connectTimeout: Duration(minutes: 5),
  //         receiveTimeout: Duration(minutes: 5),
  //         sendTimeout: Duration(minutes: 5),
  //       ),
  //     ).get(url);
  //     if (res.statusCode == 200) {
  //       bytes.addAll(res.data as List<int>);
  //     }
  //   } catch (e) {
  //     _log.logError('Download ảnh thất bại');
  //   }
  //   return bytes;
  // }

  // Future<dynamic> _requestFailure(DioError e, int retryTimes) async {
  //   if (e.message.contains('Failed host lookup')) {
  //     if ((await ConnectivityService.canConnectToNetwork()) == false)
  //       return NoConnectionException();
  //     else
  //       return InternalServerException();
  //   }

  //   if (retryTimes == AppConst.refecthApiThreshold)
  //     return PoorConnectionException();

  //   return e;
  // }
}

_dioErrorHandle(DioException e) {
  Response? errorResponse = e.response;

  var errorCode = errorResponse?.statusCode ?? StatusCode.errorUnknownCode;
  var errorMsg =
      'Đã có lỗi xảy ra khi tải dữ liệu, vui lòng thử lại $errorCode';

  if (_exceptionCanResolveByReFecth
      .any((el) => e.message?.contains(el) ?? false)) {
    errorCode = StatusCode.networkError;
    errorMsg = 'Vui lòng kiểm tra kết nối internet và thử lại';
  } else if (StatusCode.serverError.contains(errorCode)) {
    errorMsg = 'Hệ thống đã xảy ra lỗi, vui lòng thử lại sau ! \n[$errorCode]';
  } else if (errorCode == StatusCode.errorCode401) {
    errorMsg = 'Phiên đăng nhập hết hạn !';
  } else if (errorCode == StatusCode.errorCode402) {
    errorMsg = 'Tài khoản chưa được xác thực';
  } else if (errorCode == StatusCode.wrongEmailOrPassword) {
    errorMsg = 'Tài khoản hoặc mật khẩu không chính xác';
  }

  var error = ErrorResponse(
    code: errorCode,
    message: errorMsg,
  );

  return RequestResponse(
    '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
    false,
    error.code,
    error: error,
  );
}

_unknowErrorHandle(e) {
  // _log.appLog('=================DATA EXCEPTION===================',
  //     color: StrColor.red);
  // _log.appLog(response.data);
  // _log.appLog(e.toString(), color: StrColor.red);
  var error = ErrorResponse(message: 'Lỗi, vui lòng thử lại sau');
  return RequestResponse(
    '{"result":false,"code":${error.code},"error": ${json.encode(error.toJson())}}',
    false,
    0,
    error: error,
  );
}
