import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:newsium/services/all_response.dart';
import 'package:newsium/services/reachability.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io' show File;
import 'api_constant.dart';
import '../utils/utils.dart';

class ApiProvider {
  CancelToken? lastRequestToken;

  factory ApiProvider() {
    return _singleton;
  }

  final Dio dio = new Dio();
  static final ApiProvider _singleton = ApiProvider._internal();

  ApiProvider._internal() {
    Logger().v("Instance created ApiProvider");
    // Setting up connection and response time out
    dio.options.connectTimeout = 60 * 1000;
    dio.options.receiveTimeout = 60 * 1000;
  }

  HttpResponse _handleNetworkSuccess({required Response<dynamic> response}) {
    dynamic jsonResponse = response.data;

    Logger().v("Response Status code:: ${response.statusCode}");
    Logger().v("response body :: $jsonResponse");

    final message = jsonResponse[ResponseKeys.kMessage] ??
        (jsonResponse[ResponseKeys.kTitle] ?? '');
    final status = jsonResponse[ResponseKeys.kStatus] ?? response.statusCode;
    final data = jsonResponse[ResponseKeys.kData];
    if (response.statusCode! >= 200 && response.statusCode! < 299) {
      return HttpResponse(
          status: status,
          errMessage: message,
          data: data,
          mainResponse: jsonResponse);
    } else {
      var errMessage = jsonResponse[ResponseKeys.kMessage] ??
          (jsonResponse[ResponseKeys.kTitle] ?? '');
      return HttpResponse(
          status: status, errMessage: errMessage, mainResponse: jsonResponse);
    }
  }

  Future<HttpResponse> _handleDioNetworkError(
      // ignore: unused_element
      {required DioError error,
      ApiType? apiType}) async {
    Logger().v("Error Details :: ${error.message}");

    if ((error.response == null) || (error.response!.data == null)) {
      String errMessage = 'Something went wrong';
      return HttpResponse(
        status: 500,
        errMessage: errMessage,
      );
    } else {
      Logger().v("Error Details :: ${error.response!.data}");
      dynamic jsonResponse = getErrorData(error);
      if (jsonResponse is Map) {
        final status = jsonResponse[ResponseKeys.kStatus] ?? 400;
        String errMessage = jsonResponse[ResponseKeys.kMessage] ??
            (jsonResponse[ResponseKeys.kTitle] ?? 'Something went wrong');
        return HttpResponse(
          status: status,
          errMessage: errMessage,
        );
      } else {
        return HttpResponse(
          status: 500,
          errMessage: 'Something went wrong',
        );
      }
    }
  }

  Map? getErrorData(DioError error) {
    if (error.response!.data is Map) {
      return error.response!.data;
    } else if (error.response!.data is String) {
      return json.decode(error.response!.data);
    }
    return null;
  }

  Future<HttpResponse> getRequest(ApiType apiType,
      {Map<String, String>? params, String? urlParam}) async {
    if (!Reachability().isInterNetAvaialble()) {
      return HttpResponse(status: 101, errMessage: 'No Internet Connection');
    }

    final requestFinal = ApiConstant.requestParamsForSync(apiType,
        params: params ?? Map<String, String>(), urlParams: urlParam);

    final option = Options(headers: requestFinal.item2);
    try {
      final response = await this.dio.get(requestFinal.item1,
          queryParameters: requestFinal.item3, options: option);
      return _handleNetworkSuccess(response: response);
    } on DioError catch (error) {
      final result = await this._handleDioNetworkError(error: error);
      if (result.failDueToToken) {
        return this.getRequest(apiType, params: params, urlParam: urlParam);
      }
      return result;
    }
  }

  Future<HttpResponse> postRequest(ApiType apiType,
      {Map<String, dynamic>? params, String? urlParams}) async {
    // if (!Reachability().isInterNetAvaialble()) {
    //   return HttpResponse(status: 101, errMessage: 'No Internet Connection');
    // }

    final requestFinal = ApiConstant.requestParamsForSync(apiType,
        params: params, urlParams: urlParams);
    final option = Options(headers: requestFinal.item2);

    this.lastRequestToken = CancelToken();
    try {
      final response = await this.dio.post(requestFinal.item1,
          data: json.encode(requestFinal.item3),
          options: option,
          cancelToken: this.lastRequestToken);
      return this._handleNetworkSuccess(response: response);
    } on DioError catch (error) {
      final result = await this._handleDioNetworkError(error: error);
      if (result.failDueToToken) {
        return this.postRequest(
          apiType,
          params: params,
        );
      }
      return result;
    }
  }

  Future<HttpResponse> deleteRequest(ApiType apiType,
      {Map<String, dynamic>? params, String? urlParams}) async {
    if (!Reachability().isInterNetAvaialble()) {
      return HttpResponse(status: 101, errMessage: 'No Internet Connection');
    }

    final requestFinal = ApiConstant.requestParamsForSync(apiType,
        params: params, urlParams: urlParams);
    final option = Options(headers: requestFinal.item2);
    try {
      final response = await this.dio.delete(
            requestFinal.item1,
            data: json.encode(requestFinal.item3),
            options: option,
          );
      return this._handleNetworkSuccess(response: response);
    } on DioError catch (error) {
      final result = await this._handleDioNetworkError(error: error);
      if (result.failDueToToken) {
        return this.postRequest(
          apiType,
          params: params,
        );
      }
      return result;
    }
  }

  Future<HttpResponse> putFormDataRequest(ApiType apiType,
      {Map<String, dynamic>? params,
      List<AppMultiPartFile> arrFile = const [],
      String? urlParam}) async {
    if (!Reachability().isInterNetAvaialble()) {
      return HttpResponse(status: 101, errMessage: 'No Internet Connection');
    }

    final requestFinal = ApiConstant.requestParamsForSync(apiType,
        params: params, arrFile: arrFile, urlParams: urlParam);

    // Create form data Request
    FormData formData = new FormData.fromMap(Map<String, dynamic>());

    MultipartFile mFile =
        MultipartFile.fromBytes(utf8.encode(json.encode(requestFinal.item3)),
            contentType: MediaType(
              'application',
              'json',
              {'charset': 'utf-8'},
            ));
    formData.files.add(MapEntry('requestDTO', mFile));

    /* Adding File Content */
    for (AppMultiPartFile partFile in requestFinal.item4) {
      for (File? file in partFile.localFiles!) {
        Logger().v("File Path :: ${file!.path}");
        String filename = basename(file.path);
        String? mineType = lookupMimeType(filename);
        if (mineType == null) {
          MultipartFile mFile = await MultipartFile.fromFile(
            file.path,
            filename: filename,
          );
          formData.files.add(MapEntry(partFile.key!, mFile));
        } else {
          MultipartFile mFile = await MultipartFile.fromFile(file.path,
              filename: filename,
              contentType: MediaType(
                  mineType.split("/").first, mineType.split("/").last));
          formData.files.add(MapEntry(partFile.key!, mFile));
        }
      }
    }

    final option = Options(headers: requestFinal.item2);
    try {
      final response = await this.dio.put(requestFinal.item1,
          data: formData,
          options: option,
          onSendProgress: (sent, total) =>
              Logger().v("uploadFile ${sent / total}"));
      return this._handleNetworkSuccess(response: response);
    } on DioError catch (error) {
      final result = await this._handleDioNetworkError(error: error);
      if (result.failDueToToken) {
        return this
            .putFormDataRequest(apiType, params: params, urlParam: urlParam);
      }
      return result;
    }
  }

  Future<HttpResponse> putRequest(ApiType apiType,
      {Map<String, dynamic>? params, String? urlParam}) async {
    if (!Reachability().isInterNetAvaialble()) {
      return HttpResponse(status: 101, errMessage: 'No Internet Connection');
    }

    final requestFinal = ApiConstant.requestParamsForSync(apiType,
        params: params, urlParams: urlParam);

    final option = Options(headers: requestFinal.item2);
    try {
      final response = await this.dio.put(
            requestFinal.item1,
            data: json.encode(requestFinal.item3),
            options: option,
          );
      return this._handleNetworkSuccess(response: response);
    } on DioError catch (error) {
      final result = await this._handleDioNetworkError(error: error);
      if (result.failDueToToken) {
        return this.putRequest(apiType, params: params, urlParam: urlParam);
      }
      return result;
    }
  }

  Future<HttpResponse> uploadRequest(ApiType apiType,
      {Map<String, dynamic>? params,
      List<AppMultiPartFile>? arrFile,
      String? urlParam}) async {
    if (!Reachability().isInterNetAvaialble()) {
      final httpResonse =
          HttpResponse(status: 101, errMessage: 'No Internet Connection');
      return httpResonse;
    }

    final requestFinal = ApiConstant.requestParamsForSync(apiType,
        params: params,
        arrFile: arrFile ?? <AppMultiPartFile>[],
        urlParams: urlParam);

    // Create form data Request
    FormData formData = new FormData.fromMap(Map<String, dynamic>());

    MultipartFile mFile =
        MultipartFile.fromBytes(utf8.encode(json.encode(requestFinal.item3)),
            contentType: MediaType(
              'application',
              'json',
              {'charset': 'utf-8'},
            ));
    formData.files.add(MapEntry('requestDTO', mFile));

    /* Adding File Content */
    for (AppMultiPartFile partFile in requestFinal.item4) {
      for (File? file in partFile.localFiles!) {
        Logger().v("File Path :: ${file!.path}");
        String filename = basename(file.path);
        String? mineType = lookupMimeType(filename);
        if (mineType == null) {
          MultipartFile mFile = await MultipartFile.fromFile(
            file.path,
            filename: filename,
          );
          formData.files.add(MapEntry(partFile.key!, mFile));
        } else {
          MultipartFile mFile = await MultipartFile.fromFile(file.path,
              filename: filename,
              contentType: MediaType(
                  mineType.split("/").first, mineType.split("/").last));
          formData.files.add(MapEntry(partFile.key!, mFile));
        }
      }
    }

    /* Create Header */
    final option = Options(headers: requestFinal.item2);

    try {
      final response = await this.dio.post(requestFinal.item1,
          data: formData,
          options: option,
          onSendProgress: (sent, total) =>
              Logger().v("uploadFile ${sent / total}"));
      return this._handleNetworkSuccess(response: response);
    } on DioError catch (error) {
      final result = await this._handleDioNetworkError(error: error);
      return result;
    }
  }

  Future<HttpResponse> upload2Request(ApiType apiType,
      {Map<String, dynamic>? params,
      List<AppMultiPartFile>? arrFile,
      String? urlParam}) async {
    if (!Reachability().isInterNetAvaialble()) {
      final httpResonse =
          HttpResponse(status: 101, errMessage: 'No Internet Connection');
      return httpResonse;
    }

    final requestFinal = ApiConstant.requestParamsForSync(apiType,
        params: params,
        arrFile: arrFile ?? <AppMultiPartFile>[],
        urlParams: urlParam);

    // Create form data Request
    FormData formData = new FormData.fromMap(Map<String, dynamic>());

    MultipartFile mFile =
        MultipartFile.fromBytes(utf8.encode(json.encode(requestFinal.item3)),
            contentType: MediaType(
              'application',
              'json',
              {'charset': 'utf-8'},
            ));
    formData.files.add(MapEntry('requestDTO', mFile));

    /* Adding File Content */
    for (AppMultiPartFile partFile in requestFinal.item4) {
      for (File? file in partFile.localFiles!) {
        Logger().v("File Path :: ${file!.path}");
        String filename = basename(file.path);
        String? mineType = lookupMimeType(filename);
        if (mineType == null) {
          MultipartFile mFile = await MultipartFile.fromFile(
            file.path,
            filename: filename,
          );
          formData.files.add(MapEntry(partFile.key!, mFile));
        } else {
          MultipartFile mFile = await MultipartFile.fromFile(file.path,
              filename: filename,
              contentType: MediaType(
                  mineType.split("/").first, mineType.split("/").last));
          formData.files.add(MapEntry(partFile.key!, mFile));
        }
      }
    }

    /* Create Header */
    final option = Options(headers: requestFinal.item2);

    try {
      final response = await this.dio.post(requestFinal.item1,
          data: formData,
          options: option,
          onSendProgress: (sent, total) =>
              Logger().v("uploadFile ${sent / total}"));
      return this._handleNetworkSuccess(response: response);
    } on DioError catch (error) {
      final result = await this._handleDioNetworkError(error: error);
      return result;
    }
  }
  //endregion
}

//endregion
extension NewsProvider on ApiProvider {
  Future<BaseResponse> registerApi() async {
    final HttpResponse response = await this.postRequest(ApiType.register);
    return BaseResponse(status: response.status, message: response.errMessage);
  }

  // Future<GetWatchListResponse> getWatchListApi(GetWatchListRequest params) async {
  // final HttpResponse response = await this.getRequest(ApiType.getMyWatchList, params: params.toJson());
  // WatchList data;
  // if ((response.status == 200) && (response.json is Map)) {
  //   data = WatchList.fromJson(response.json);
  // }

}
