import 'package:newsium/services/api_constant.dart';

import 'all_request.dart';
import 'all_response.dart';
import 'api_provider.dart';

class AppRepository {
  final apiProvider = ApiProvider();

  Future<BaseResponse> wallsApi() => apiProvider.registerApi();
}
