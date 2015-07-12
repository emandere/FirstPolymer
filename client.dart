import 'dart:io';
import 'package:http_server/http_server.dart';
import 'package:path/path.dart';

main() async {
  var pathToBuild = "C:/Users/user/WebstormProjects/FirstPolymer/build/web";//join(dirname(Platform.script.toFilePath()));

  var staticFiles = new VirtualDirectory(pathToBuild);
  staticFiles.allowDirectoryListing = true;
  staticFiles.directoryHandler = (dir, request) {
    var indexUri = new Uri.file(dir.path).resolve('index.html');
    print(indexUri.toFilePath());
    staticFiles.serveFile(new File(indexUri.toFilePath()), request);
  };

  var server =
  await HttpServer.bind(InternetAddress.ANY_IP_V4, 4048);
  print('Listening on port 4048'+pathToBuild);
  await server.forEach(staticFiles.serveRequest);
}

