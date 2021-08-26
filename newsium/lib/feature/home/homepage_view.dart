import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:newsium/services/api_provider.dart';
import 'package:http/http.dart' as http;

class HomePageView extends StatefulWidget {
  const HomePageView({Key? key}) : super(key: key);

  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Row(
            children: [
              TextButton(
                child: Text("Dio | Call Register Api"),
                onPressed: () async {
                  // await callDioApi();
                  await ApiProvider().registerApi();
                },
              ),
              Spacer(),
              TextButton(
                child: Text("HTTP | Call Register Api"),
                onPressed: () async {
                  await callApi();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  callDioApi() async {
    final dio = Dio();

    final opt = Options(headers: {
      'Host': 'prod.bhaskarapi.com',
      'a-ver-name': '8.3.5',
      'a-ver-code': '457',
      'x-aut-t': 'a6oaq3edtz59',
      'cid': '521',
      'dtyp': 'android',
      'deviceid': 'f7238a09e235629f',
      'content-length': '0',
      'accept-encoding': 'gzip',
      'user-agent': 'okhttp/4.6.0',
      'at':
          'Gu3m3gVhYiR8d_iSCfG8ymQp1AtyHTPH_dEVvgtpW5LNIC8QPda1TfaudniQt5GVbu7ruO9gkLPG0yyggJFZ8jHXA4NeXAvj9JfFvcDjaRkh6bnuZfVXWyVkklMaA7-tl-AHp7_N8xpsuhgMqjlldRiujMEdsnglLnm4eSq758SV4J9qdmGqf5Kaf9rWBgXfQBh1gByVCEnvuW_AE6veaXMHIqp3n5-DdgHqj6Z2-P4Ed37TTQYZwQvzheGUdH6S'
    });
    try {
      Logger().d(opt.headers);

      final response = await dio.post(
          'https://prod.bhaskarapi.com/api/1.0/user/register',
          options: opt);
      if (response.statusCode == 200) {
        Logger().d(await response.data);
      }
    } on DioError catch (error) {
      final result = await error;
      if (result.error) {
        return error.message;
      }
      return result;
    }
  }

  callApi() async {
    var headers = {
      'Host': 'prod.bhaskarapi.com',
      'a-ver-name': '8.3.5',
      'a-ver-code': '457',
      'x-aut-t': 'a6oaq3edtz59',
      'cid': '521',
      'dtyp': 'android',
      'deviceid': 'f7238a09e235629f',
      'content-length': '0',
      'accept-encoding': 'gzip',
      'user-agent': 'okhttp/4.6.0'
    };
    var request = http.Request(
        'POST', Uri.parse('https://prod.bhaskarapi.com/api/1.0/user/register'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    Logger().d(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Logger().d(await response.stream.bytesToString());
    } else {
      Logger().d(response.reasonPhrase);
    }
  }
}
