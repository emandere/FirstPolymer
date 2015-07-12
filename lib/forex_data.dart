library forex_data;
import 'dart:io';
import 'package:rpc/rpc.dart';
import 'package:path/path.dart' as path;
import 'candle_stick.dart';

@ApiClass(
    name: 'forex',  // Optional (default is 'cloud' since class name is Cloud).
    version: 'v1'
)
class ForexData
{
  ForexData();
  @ApiMethod(path: 'pairs')
  List<String> pairs()
  {
    List<String> pairNames = new List<String>();
    Directory forexDirectory = new Directory("C:/ForexData");
    List contents = forexDirectory.listSync();
    for (FileSystemEntity fileOrDir in contents)
    {
      pairNames.add(path.basename(fileOrDir.path));
    }
    return pairNames;
  }
  @ApiMethod(path: 'dailyvalues/{pair}')
  List<ForexDailyValue> dailyValues(String pair)
  {
    List<String> strvalues = new File('C:/ForexData/'+pair+'/'+pair+'dailyval.txt').readAsLinesSync();
    List<ForexDailyValue> dailyvals=new List<ForexDailyValue>();
    for(String line in strvalues)
    {
      ForexDailyValue val = new ForexDailyValue.fromString(line,pairName:pair);
      dailyvals.add(val);
    }
    return dailyvals;
  }

}