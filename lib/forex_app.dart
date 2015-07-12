import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:async';
import 'dart:js';
import 'candle_stick.dart';
import 'dart:convert';
import 'package:paper_elements/paper_input.dart';

class ForexChart {
  var jsOptions;
  var jsTable;
  var jsChart;

  ForexChart(Element element,var data, String title,Map options) {

    final vis = context["google"]["visualization"];
    jsTable = new JsObject(vis["DataTable"]);
    jsTable.callMethod('addColumn',['date','Col 0']);
    jsTable.callMethod('addColumn',['number','Col 1']);
    jsTable.callMethod('addColumn',['number','Col 2']);
    jsTable.callMethod('addColumn',['number','Col 3']);
    jsTable.callMethod('addColumn',['number','Col 4']);
    //jsTable = vis.callMethod('arrayToDataTable',[new JsObject.jsify(data)]);
    jsTable.callMethod('addRows',[new JsObject.jsify(data)]);
    jsChart = new JsObject(vis["CandlestickChart"], [element]);//new JsObject(vis["Gauge"], [element]);

    jsOptions = new JsObject.jsify(options);
    draw();
  }

  void draw() {
    //jsTable.callMethod('setValue', [0, 1, value]);
    jsChart.callMethod('draw', [jsTable, jsOptions]);
  }


  static Future load() {
    Completer c = new Completer();
    context["google"].callMethod('load',
    ['visualization', '1', new JsObject.jsify({
      'packages': ['corechart'],//['gauge'],
      'callback': new JsFunction.withThis(c.complete)
    })]);
    return c.future;
  }


}

class ForexHistogram {
  var jsOptions;
  var jsTable;
  var jsChart;

  ForexHistogram(Element element,var data, String title,Map options) {

    final vis = context["google"]["visualization"];
    //jsTable = new JsObject(vis["DataTable"]);
    //jsTable.callMethod('addColumn',['date','day']);
    //jsTable.callMethod('addColumn',['number','Daily Moves']);
    List histodata=new List();
    histodata.add(['Date','Moves']);
    for(List candle in data)
    {
       List tempList = new List();
       num move = ((candle[3]-candle[2])/candle[2])*100;
       tempList.add(candle[0].toString());
       tempList.add(move);
       histodata.add(tempList);
    }

    /*jsTable.callMethod('addColumn',['number','Col 1']);
    jsTable.callMethod('addColumn',['number','Col 2']);
    jsTable.callMethod('addColumn',['number','Col 3']);
    jsTable.callMethod('addColumn',['number','Col 4']);*/
    //jsTable = vis.callMethod('arrayToDataTable',[new JsObject.jsify(data)]);
    //jsTable.callMethod('addRows',[new JsObject.jsify(histodata)]);
    jsTable = vis.callMethod('arrayToDataTable',[new JsObject.jsify(histodata)]);
    jsChart = new JsObject(vis["Histogram"], [element]);//new JsObject(vis["Gauge"], [element]);

    jsOptions = new JsObject.jsify(options);
    draw();
  }

  void draw() {
    //jsTable.callMethod('setValue', [0, 1, value]);
    jsChart.callMethod('draw', [jsTable, jsOptions]);
  }


  static Future load() {
    Completer c = new Completer();
    context["google"].callMethod('load',
    ['visualization', '1', new JsObject.jsify({
      'packages': ['corechart'],//['gauge'],
      'callback': new JsFunction.withThis(c.complete)
    })]);
    return c.future;
  }


}
/// A Polymer `<main-app>` element.
@CustomTag('forex-app')
class ForexApp extends PolymerElement
{
  @observable var item;
  @observable List<String> currencyPairs;
  var showChart;
  //DivElement visualization;
  /// Constructor used to create instance of MainApp.
  ForexApp.created() : super.created();
  ready()
  {
    super.ready();
    var panel = shadowRoot.querySelector('#drawerPanel');
        showChart = shadowRoot.querySelector('#dialogChart');
    var navMenu = shadowRoot.querySelector("#naviconmenu");
    var navMain = shadowRoot.querySelector("#navicon");
    var selectPair = shadowRoot.querySelector("#selectPair");
    var btnCharts = shadowRoot.querySelector("#btnCharts");
    var btnCancel = shadowRoot.querySelector("#btnCancel");

    panel.forceNarrow=true;

    var navMenuSub = navMenu.onClick.listen(
            (event) =>panel.togglePanel());
    var navMainSub = navMain.onClick.listen(
            (event) =>panel.togglePanel());
    var selectPairSub = selectPair.onClick.listen(
            (event) =>showChart.toggle());
    var btnChartsSub = btnCharts.onClick.listen(
            loadChart);
    var btnCancelSub = btnCancel.onClick.listen(
            (event) =>showChart.toggle());

    loadCurrencyPairs();

  }

  loadCurrencyPairs()
  {
    var url = "http://192.168.0.6:8080/api/forex/v1/pairs";
    var request = HttpRequest.getString(url).then(updateCurrencyList);
  }

  updateCurrencyList(String responseText)
  {
    currencyPairs = JSON.decode(responseText);
  }

  loadChart(var Event)
  {
    var chartSpinner = shadowRoot.querySelector("#chartSpinner");
    ForexChart.load().then(loadData).then((var x){showChart.close();chartSpinner.active=true;});
  }

  loadData(Window Test)
  {
    //var selectPair = shadowRoot.querySelector("#selectPair");

    var url = "http://192.168.0.6:8080/api/forex/v1/dailyvalues/"+currencyPairs[$['menuPair'].selected];
    var request = HttpRequest.getString(url).then(drawChart);
  }

  drawChart(String responseText)
  {
    var chartSpinner = shadowRoot.querySelector("#chartSpinner");
    var data=readResponse(responseText);
    final DivElement visualization = shadowRoot.querySelector('#historychart');
    final DivElement visualizationHistogram = shadowRoot.querySelector('#historygramchart');
    var options = {
      'title':'Currency Pair '+ currencyPairs[$['menuPair'].selected],
      'legend': 'none',
      'vAxis':{'title':'Price'},
      'hAxis':{'title':'Date'},
      'candlestick': {
        'fallingColor': { 'strokeWidth': 0, 'fill': '#a52714' }, // red
        'risingColor': { 'strokeWidth': 0, 'fill': '#0f9d58' }   // green
      }
    };

    var optionsHistogram = {
      'title':'Histogram '+ currencyPairs[$['menuPair'].selected],
      'legend': 'none'
    };
    ForexChart gauge = new ForexChart(visualization,data, "Slider", options);
    ForexHistogram gauge2 = new ForexHistogram(visualizationHistogram,data, "Slider", optionsHistogram);
    chartSpinner.active=false;
  }

  List readResponse(String responseText)
  {
    List<ForexDailyValue> dailyVals= new List<ForexDailyValue>();
    List<Map> JsonData = JSON.decode(responseText);
    for(var jsonNode in JsonData)
    {
      ForexDailyValue dailyVal = new ForexDailyValue.fromJson(jsonNode);
      dailyVals.add(dailyVal);
    }
    var data=new List();
    //data.add(['date','Col 1','Col 2','Col 3','Col 4']);
    PaperInput startDate = shadowRoot.querySelector("#startDate");
    PaperInput endDate = shadowRoot.querySelector("#endDate");
    for(ForexDailyValue dailyVal in dailyVals.where((ForexDailyValue i) => DateTime.parse(i.date).isAfter(DateTime.parse(startDate.value)) && DateTime.parse(i.date).isBefore(DateTime.parse(endDate.value)) ))
    {
      var dval = new List();
      //dval.add(dailyVal.date);
      dval.add(new JsObject(context["Date"],[dailyVal.date]));
      dval.add(dailyVal.low);
      dval.add(dailyVal.open);
      dval.add(dailyVal.close);
      dval.add(dailyVal.high);

      data.add(dval);
    }
    return data;
  }




}
