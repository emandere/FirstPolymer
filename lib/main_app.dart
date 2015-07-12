// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:isolate';
import 'package:paper_elements/paper_input.dart';
import 'package:paper_elements/paper_button.dart';
import 'package:polymer/polymer.dart';
import 'tree.dart';
import 'dart:async';
import 'dart:js';
class Point {
  final int x;
  final int y;

  Point(this.x, this.y);
}





class Gauge {
  var jsOptions;
  var jsTable;
  var jsChart;

  // Access to the value of the gauge.
  num _value;
  get value => _value;
  set value(num x) {
    _value = x;
    draw();
  }

  Gauge(Element element, String title, this._value, Map options) {
    final data = [
      ['Col 0','Col 1','Col 2','Col 3','Col 4'],
      ['1/1/2011', 25, 28, 38, 45],
      ['1/2/2011', 31, 38, 55, 66],
      ['1/3/2011', 50, 55, 77, 80],
      ['1/4/2011', 77, 77, 66, 50],
      ['1/6/2011', 25, 28, 38, 45],
      ['1/7/2011', 31, 38, 55, 66],
      ['1/8/2011', 50, 55, 77, 80],
      ['1/9/2011', 77, 77, 66, 50],
      ['1/11/2011', 68, 66, 22, 15]
      // Treat first row as data as well.
    ];//[['Label', 'Value'], [title, value]];
    final vis = context["google"]["visualization"];
    jsTable = vis.callMethod('arrayToDataTable',[new JsObject.jsify(data)]);
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

// Bindings to html elements.






/// A Polymer `<main-app>` element.
@CustomTag('main-app')
class MainApp extends PolymerElement {
  @observable String reversed = '';
  @observable int x=0;
  @observable int y=0;
  @observable String jsonQuote='';
  @observable var menuitem;
  Point clientBoundingRect;
  tree testtree;

  List<String> choices = ['United States of America','Afghanistan','Albania','Algeria','Andorra','Angola','Antigua & Deps','Argentina','Armenia','Australia','Austria','Azerbaijan','Bahamas','Bahrain','Bangladesh','Barbados','Belarus','Belgium','Belize','Benin','Bhutan','Bolivia','Bosnia Herzegovina','Botswana','Brazil','Brunei','Bulgaria','Burkina','Burma','Burundi','Cambodia','Cameroon','Canada','Cape Verde','Central African Rep','Chad','Chile','Peoples Republic of China','Republic of China','Colombia','Comoros','Democratic Republic of the Congo','Republic of the Congo','Costa Rica','','Croatia','Cuba','Cyprus','Czech Republic','Danzig','Denmark','Djibouti','Dominica','Dominican Republic','East Timor','Ecuador','Egypt','El Salvador','Equatorial Guinea','Eritrea','Estonia','Ethiopia','Fiji','Finland','France','Gabon','Gaza Strip','The Gambia','Georgia','Germany','Ghana','Greece','Grenada','Guatemala','Guinea','Guinea-Bissau','Guyana','Haiti','Holy Roman Empire','Honduras','Hungary','Iceland','India','Indonesia','Iran','Iraq','Republic of Ireland','Israel','Italy','Ivory Coast','Jamaica','Japan','Jonathanland','Jordan','Kazakhstan','Kenya','Kiribati','North Korea','South Korea','Kosovo','Kuwait','Kyrgyzstan','Laos','Latvia','Lebanon','Lesotho','Liberia','Libya','Liechtenstein','Lithuania','Luxembourg','Macedonia','Madagascar','Malawi','Malaysia','Maldives','Mali','Malta','Marshall Islands','Mauritania','Mauritius','Mexico','Micronesia','Moldova','Monaco','Mongolia','Montenegro','Morocco','Mount Athos','Mozambique','Namibia','Nauru','Nepal','Newfoundland','Netherlands','New Zealand','Nicaragua','Niger','Nigeria','Norway','Oman','Ottoman Empire','Pakistan','Palau','Panama','Papua New Guinea','Paraguay','Peru','Philippines','Poland','Portugal','Prussia','Qatar','Romania','Rome','Russian Federation','Rwanda','St Kitts & Nevis','St Lucia','Saint Vincent & the','Grenadines','Samoa','San Marino','Sao Tome & Principe','Saudi Arabia','Senegal','Serbia','Seychelles','Sierra Leone','Singapore','Slovakia','Slovenia','Solomon Islands','Somalia','South Africa','Spain','Sri Lanka','Sudan','Suriname','Swaziland','Sweden','Switzerland','Syria','Tajikistan','Tanzania','Thailand','Togo','Tonga','Trinidad & Tobago','Tunisia','Turkey','Turkmenistan','Tuvalu','Uganda','Ukraine','United Arab Emirates','United Kingdom','Uruguay','Uzbekistan','Vanuatu','Vatican City','Venezuela','Vietnam','Yemen','Zambia','Zimbabwe'];
  @observable List<String> countries =toObservable(new List());
  @observable List<String> showNodes =toObservable(new List());

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created();

  void searchTree(Event event, Object object, PaperInput target)
  {
     showNodes.clear();
     testtree.searchTree(target.value);
     for(List<String> path in testtree.paths)
     {
        String printpath = path.fold("",(prev,element)=>element+" "+prev);
        showNodes.add(printpath);
        for(treenode node in testtree.nodes)
        {
             node.show=false;
        }
        for(String id in path)
        {
           treenode selectednode = testtree.nodes.firstWhere((treenode i)=>i.id==id);
           selectednode.show =true;
        }

     }

     CanvasElement canvas;
     canvas = shadowRoot.querySelector("#area");

     testtree.context.clearRect(0, 0, canvas.width, canvas.height);
     testtree.writetext();
     /*for(treenode val in testtree.nodes.where((treenode i)=>i.id.startsWith(target.value)))
     {
       showNodes.add(val.id);
     }*/

  }

  void reverseText(Event event, Object object, PaperInput target)
  {
    reversed = target.value.split('').reversed.join('');
   
  }

  void showCountries(Event event, Object object, PaperInput target)
  {
    countries.clear();
    for(String val in choices.where((String i)=>i.startsWith(target.value)))
    {
      countries.add(val);
    }
  }

  void showCoordinate(Event event,Object object,CanvasElement canvas)
  {
    var context = canvas.context2D;
    context.clearRect(0, 0, canvas.width, canvas.height);
    Rectangle rect = canvas.getBoundingClientRect();
    clientBoundingRect = new Point(rect.left.toInt(), rect.top.toInt());
    x =  event.clientX - clientBoundingRect.x;
    y =  event.clientY - clientBoundingRect.y;
    rectangle uparrow = new rectangle();
    uparrow.xmin=200;
    uparrow.xmax=210;
    uparrow.ymin=50;
    uparrow.ymax=60;
    uparrow.draw(context);

    rectangle downarrow = new rectangle();
    downarrow.xmin=200;
    downarrow.xmax=210;
    downarrow.ymin=10;
    downarrow.ymax=20;
    downarrow.draw(context);


    rectangle leftarrow = new rectangle();
    leftarrow.xmin=170;
    leftarrow.xmax=180;
    leftarrow.ymin=27;
    leftarrow.ymax=37;
    leftarrow.draw(context);

    rectangle rightarrow = new rectangle();
    rightarrow.xmin=230;
    rightarrow.xmax=240;
    rightarrow.ymin=27;
    rightarrow.ymax=37;
    rightarrow.draw(context);

    treenode selectednode = testtree.nodes.firstWhere(checkpoint,orElse:()=>null);

    if(checkpoint(uparrow))
    {
      testtree.rooty+=10;
    }

    if(checkpoint(downarrow))
    {
      testtree.rooty-=10;
    }

    if(checkpoint(rightarrow))
    {
      testtree.rootx+=10;
    }

    if(checkpoint(leftarrow))
    {
      testtree.rootx-=10;
    }
    if (selectednode!=null)
    {
      if(selectednode.show == true)
        selectednode.show=false;
      else
        selectednode.show=true;
    }


    testtree.context = context;
    testtree.writetext();
  }

  bool checkpoint(rectangle i)
  {
    if(i!=null) {
      if (i.xmin < x && i.xmax > x && i.ymin < y && i.ymax > y) {
        return true;
      }
      else {
        return false;
      }
    }
    else
      return false;

  }

  void onDataLoaded(String responseText) {
    var jsonString = responseText;
    CanvasElement canvas;
    canvas = shadowRoot.querySelector("#area");
    testtree = new tree.fromJson(jsonString);

    var context = canvas.context2D;
    testtree.context = context;
    testtree.writetext();
  }

  void drawLines (Event event,Object object,PaperButton target)
  {
    var url = "http://127.0.0.1:8080/api/cloud/v1/tree";//http://api-sandbox.oanda.com/v1/prices?instruments=EUR_USD%2CUSD_JPY
    final DivElement visualization = shadowRoot.querySelector('#gauge');
    final InputElement slider = shadowRoot.querySelector("#slider");
    Gauge.load().then((_) {
      int sliderValue() => int.parse(slider.value);
      // Create a Guage after the library has been loaded.
      Gauge gauge = new ForexChart(visualization, "Slider", sliderValue(),
      { 'legend': 'none'});
      // Connect slider value to gauge.
      slider.onChange.listen((_) => gauge.value = sliderValue());
    });

    // call the web server asynchronously
    //var request = HttpRequest.getString(url).then(onDataLoaded);

    /*CanvasElement canvas;
    canvas = shadowRoot.querySelector("#area");

    testtree=new tree.gen();//.fromJson(strtree);
    testtree.autogenerate();
    var context = canvas.context2D;
    testtree.context = context;
    testtree.writetext();*/


    /*
    context.setLineDash([5, 15]);
    context.beginPath();
    context.moveTo(0, 0);
    context.lineTo(canvas.width, canvas.height);

    context.strokeStyle = '#4285f4';
    context.font = 'thin 15pt RobotoDraft';
    context.fillText('Reversed', 100, 150);
    context.stroke();*/
  }

  void getQuotes (Event event,Object object,PaperButton target)
  {
    var url = "http://api-sandbox.oanda.com/v1/prices?instruments=EUR_USD%2CUSD_JPY";

    // call the web server asynchronously
    var request = HttpRequest.getString(url).then(onQuoteLoaded);

  }

  void onQuoteLoaded(String responseText)
  {
      jsonQuote = responseText;
  }


  

  // Optional lifecycle methods - uncomment if needed.

//  /// Called when an instance of main-app is inserted into the DOM.
//  attached() {
//    super.attached();
//  }

//  /// Called when an instance of main-app is removed from the DOM.
//  detached() {
//    super.detached();
//  }

//  /// Called when an attribute (such as a class) of an instance of
//  /// main-app is added, changed, or removed.
//  attributeChanged(String name, String oldValue, String newValue) {
//    super.attributeChanges(name, oldValue, newValue);
//  }

//  /// Called when main-app has been fully prepared (Shadow DOM created,
//  /// property observers set up, event listeners attached).
//  ready() {
//    super.ready();
//  }
}
