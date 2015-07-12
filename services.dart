library io_rpc_sample;

import 'dart:io';


//import 'packages/rpc/rpc.dart';
import 'package:rpc/rpc.dart';
import 'lib/treeapi.dart';
import 'lib/forex_data.dart';


const String _API_PREFIX = '/api';
final ApiServer _apiServer = new ApiServer(apiPrefix: _API_PREFIX, prettyPrint: true);

main() async
{
  _apiServer.addApi(new TreeApi());
  _apiServer.addApi(new ForexData());
  _apiServer.enableDiscoveryApi();
  HttpServer server = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8080);
  server.listen(_apiServer.httpRequestHandler);
}