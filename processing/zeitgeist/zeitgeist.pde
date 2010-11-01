import controlP5.*;  
import java.net.URLEncoder;


ControlP5 controlP5;  //ControlP% object
Textfield userQuery;
Button findButton;
//XMLElement xml;

String baseURL = "http://google.com/complete/search?output=toolbar&";

void setup() {
   size(640, 480);
   controlP5 = new ControlP5(this);
   controlP5.addTextfield("userQuery", 50, 60, 100,20);
   controlP5.addButton("findButton", 1, 160, 60, 50,20);
}


//Encodes a parameter to use in a query string
String encode (String name, String value) {
  String retVal = "";
   try {
      retVal = name + "=" + URLEncoder.encode(value, "UTF-8"); 
    } catch (UnsupportedEncodingException ex) {
      throw new RuntimeException("UTF not supported");
    }
    return retVal;
}     


//Seems like there is some undocumented changes happeneing w/in XMLElement in processing
// This post in the forums helped clarify what was up
// http://forum.processing.org/topic/xmlelement-problem-function-getint-getstring-does-not-exist

void getSuggestions(String theURL) {
  String[] results = loadStrings(theURL);
  String suggestions = join(results,"\n");
  println(suggestions);
  
  XMLElement xml = new XMLElement(suggestions);
  for (int j=0; j < xml.getChildCount(); j++) {
     XMLElement suggestion = xml.getChild(j);
     String s = suggestion.getChild(0).getStringAttribute("data");
     int freq = suggestion.getChild(1).getIntAttribute("int");
     println(s + " " + freq);
  }
}
  

public void findButton(int theValue) {
   String alphabet = " ";
   String uq = ((Textfield)controlP5.controller("userQuery")).getText();
   for (int i=0; i < alphabet.length(); i++) {
      String theQuery = encode("q", uq + " " + alphabet.charAt(i));
      getSuggestions(baseURL + theQuery);
   }
}

void draw() {
  
}
