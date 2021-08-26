class BaseResponse extends Object {
  int? status;
  String? message;

  BaseResponse({this.status, this.message});
}

// class WallsResponse {
//   int status;
//   String message;
//   List<WallsModel> data;

//   WallsResponse({this.status, this.message, this.data});
// }
