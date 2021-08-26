import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:tuple/tuple.dart';

enum ApiType {
  register,
  categories,
  homefeed,
  categoryWiseFeed,
  viewArticle,
}

class PreferenceKey {
  static String storeToken = "UserToken";
  static String storeUser = "UserDetail";
}

class ApiConstant {
  static String get androidAppId => '';

  static String get googlePlacesKey => '';

  static String get baseDomain => 'https://prod.bhaskarapi.com/api/2.0';

  static String getValue(ApiType type) {
    switch (type) {
      case ApiType.register:
        return '/user/register';
      case ApiType.categories:
        return '/lists/cats';
      case ApiType.homefeed:
        return '/feed/home';
      case ApiType.categoryWiseFeed:
        return '/feed/category/';
      case ApiType.viewArticle:
        return '/feed/story/';
      default:
        return "";
    }
  }

  /*
  * Tuple Sequence
  * - Url
  * - Header
  * - params
  * - files
  * */
  static Tuple4<String, Map<String, String>, Map<String, dynamic>,
          List<AppMultiPartFile>>
      requestParamsForSync(ApiType type,
          {Map<String, dynamic>? params,
          List<AppMultiPartFile> arrFile = const [],
          String? urlParams,
          bool isFormDataApi = false}) {
    String apiUrl = ApiConstant.baseDomain + ApiConstant.getValue(type);

    if (urlParams != null) apiUrl = apiUrl + urlParams;

    Map<String, dynamic> paramsFinal = params ?? Map<String, dynamic>();
    Map<String, String> headers = {
      'Host': 'prod.bhaskarapi.com',
      'a-ver-name': '8.3.5',
      'a-ver-code': '206',
      'x-aut-t': 'a6oaq3edtz59',
      'cid': '521',
      'dtyp': 'android',
      'deviceid': 'f7238a09e235629f',
      'content-length': '0',
      'accept-encoding': 'gzip',
      'user-agent': 'okhttp/4.6.0',
      'at':
          'Gu3m3gVhYiR8d_iSCfG8ymQp1AtyHTPH_dEVvgtpW5LNIC8QPda1TfaudniQt5GVbu7ruO9gkLPG0yyggJFZ8jHXA4NeXAvj9JfFvcDjaRkh6bnuZfVXWyVkklMaA7-tl-AHp7_N8xpsuhgMqjlldRiujMEdsnglLnm4eSq758SV4J9qdmGqf5Kaf9rWBgXfQBh1gByVCEnvuW_AE6veaXMHIqp3n5-DdgHqj6Z2-P4Ed37TTQYZwQvzheGUdH6S'
    };

    Logger().d("Request Url :: $apiUrl");
    Logger().d("Request Params :: $paramsFinal");

    return Tuple4(apiUrl, headers, paramsFinal, arrFile);
  }
}

class ResponseKeys {
  static String kMessage = 'message';
  static String kTitle = 'title';
  static String kStatus = 'status';
  static String kData = 'data';
}

class HttpResponse {
  int? status;
  String? errMessage;
  dynamic data;
  dynamic mainResponse;
  bool failDueToToken;

  HttpResponse(
      {this.status,
      this.errMessage,
      this.data,
      this.mainResponse,
      this.failDueToToken = false});
}

class AppMultiPartFile {
  List<File>? localFiles;
  String? key;

  AppMultiPartFile({this.localFiles, this.key});
}
