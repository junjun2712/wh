//+------------------------------------------------------------------+
//|                                                RSI Dashboard.mq4 |
//+------------------------------------------------------------------+

//#property show_inputs
#property indicator_chart_window

#include <hanover --- function header (np).mqh>

extern string   ParameterFile         = "NONE";
//extern string   Currencies            = "AUD,CAD,CHF,EUR,GBP,JPY,NZD,USD,TRY,SGD,DKK,HKD,NOK,SEK,PLN,HUF,CZK,ZAR";
extern string   Currencies            = "AUD,CAD,CHF,EUR,GBP,JPY,NZD,USD";
extern string   CurrencySuffix        = "";
extern string   TimeFrames            = "MN,W1,D1,H4,H1,M30,M15,M5,M1";
extern string   RSIParameters         = "14,0,0";                              // period, price field, shift
extern string   FontNameSizeColor     = "Comic Sans MS,13,White";
extern string   Colors                = "100,Red,70,DimGray,30,LimeGreen,-1";  // e.g. 100 <= Red > 70 etc
extern string   PositionSettings      = "0,TR,30,120,45,14,20";                // Window, Corner, HorizPos, HorizAdjust, HorizSpacing, VertPos, VertSpacing
extern string   DisplayMask           = "R5";
extern string   RefreshPeriod         = "+0";
//extern string   UniqueID              = "Stoch0";

double   spr, pnt, tickval, bidp, askp, lswap, sswap;
int      dig, tf, rsi[3], RefreshEveryXMins, FontSize, Window, Corner, HorizPos, HorizAdjust, HorizSpacing, VertPos, VertSpacing;
string   IndiName, ccy, sym, C[40], TFs[9], clrs[20], arr[10], FontName;
datetime prev_time;
color    FontColor;

//+------------------------------------------------------------------+
int init()  {
//+------------------------------------------------------------------+
  ccy     = Symbol();
  sym     = Symbol();
  tf      = Period();
  bidp    = MarketInfo(ccy,MODE_BID);
  askp    = MarketInfo(ccy,MODE_ASK);
  pnt     = MarketInfo(ccy,MODE_POINT);
  dig     = MarketInfo(ccy,MODE_DIGITS);
  spr     = MarketInfo(ccy,MODE_SPREAD);
  tickval = MarketInfo(ccy,MODE_TICKVALUE);
  if (dig == 3 || dig == 5) {
    pnt     *= 10;
    spr     /= 10;
    tickval *= 10;
  }  

  del_obj();
  plot_obj();
  prev_time = -9999;
  return(0);
}
//+------------------------------------------------------------------+
int deinit()  {
//+------------------------------------------------------------------+
  del_obj();
  return(0);
}
//+------------------------------------------------------------------+
int start()  {
//+------------------------------------------------------------------+
  if (RefreshEveryXMins < 0)
    return(0);
  if (RefreshEveryXMins == 0) {
    del_obj();
    plot_obj();    
  }
  else {
    if(prev_time != iTime(sym,RefreshEveryXMins,0))  {
      del_obj();
      plot_obj();
      prev_time = iTime(sym,RefreshEveryXMins,0);
  } }      
  return(0);
}

//+------------------------------------------------------------------+
void del_obj()  {
//+------------------------------------------------------------------+
  int k=0;
  while (k<ObjectsTotal())   {
    string objname = ObjectName(k);
    if (StringSubstr(objname,0,StringLen(IndiName)) == IndiName)  
      ObjectDelete(objname);
    else
      k++;
  }    
  return(0);
}

//+------------------------------------------------------------------+
void plot_obj()   {
//+------------------------------------------------------------------+
  CheckPresets();
  color colr = FontColor;      
  int c = 0;
  int xp = HorizPos;
  int yp = VertPos+c*VertSpacing;
  for (int t=0; t<9; t++)  {
    if (TFs[t] > "")   {
      string tstr1 = StrToStr(TFs[t],"R" + StringLen(NumberToStr(0,DisplayMask)));
      string objname = IndiName + "-hdg" + NumberToStr(-t-1,"T-6");
      PlotLabel (objname, false, Window, Corner, xp+HorizAdjust+t*HorizSpacing, yp, tstr1, FontColor, FontSize, FontName, 0, false, 0);      // Plot text label
  } }
  for (int i=0; i<40; i++)  {
    if (StringLen(C[i]) < 1)   continue;
    for (int j=0; j<40; j++)  {
      if (i==j)   continue;
      if (StringLen(C[j]) < 1)   continue;
      ccy = C[i] + C[j] + CurrencySuffix;
      if (iClose(ccy,1440,0)==0)   continue;      
      c++;
      yp = VertPos+c*VertSpacing;
      objname = IndiName + NumberToStr(-i-1,"T-6") + NumberToStr(-j-1,"T-6");
      PlotLabel (objname, false, Window, Corner, xp, yp, ccy, colr, FontSize, FontName, 0, false, 0);      // Plot text label
      for (t=0; t<9; t++) {
        if (TFs[t] > "")    {
          double rsival = iRSI(ccy,StrToTF(TFs[t]),rsi[0],rsi[1],rsi[2]);
          objname = IndiName + NumberToStr(-i-1,"T-6") + NumberToStr(-j-1,"T-6") + NumberToStr(-t-1,"T-6");
          for (int k=0; k<10; k++)  {
            if (rsival <= StrToNumber(clrs[k*2]) && rsival > StrToNumber(clrs[k*2+2]))  {
              colr = StrToColor(clrs[k*2+1]);
              break;  
          } }
          PlotLabel (objname, false, Window, Corner, xp+HorizAdjust+t*HorizSpacing, yp, NumberToStr(rsival,DisplayMask), colr, FontSize, FontName, 0, false, 0);      // Plot text label
  } } } }
  return(0);
}

//+------------------------------------------------------------------+
int CheckPresets()    {
//+------------------------------------------------------------------+
//---------------------------------------------------------------------------------------------------------------
//    Enter the file name in here
//---------------------------------------------------------------------------------------------------------------
  ParameterFile = StringUpper(ParameterFile);
  string FileName = "Presets---RSIDash.TXT";
  if (ParameterFile > "")  FileName = "Presets---RSIDash." + ParameterFile;
//---------------------------------------------------------------------------------------------------------------
  int handle = FileOpen(FileName, FILE_CSV|FILE_READ,';');
  if (handle > 0)  {
    while(!FileIsEnding(handle))  {
      string text  = FileReadString(handle);
      int t0 = StringFind(text,"//",0);
      if (t0 == 0)       text = "";    
      else if (t0 > 0)   text = StringSubstr(text,0,t0);
      string temp  = "";
      int    quote = 0;
      for (int i=0; i<StringLen(text); i++)   {
        string char = StringSubstr(text,i,1);
        if (char == "\x22")    quote = 1 - quote;  
        else if (quote == 1)    temp  = temp + char;
        else if (char != " " && char != "_") temp  = temp + StringLower(char);  
      }
      if (StringLen(temp) > 0) {
        int equal = StringFind(temp,"=",0);
        int semic = StringFind(temp,";",0);
        string pname = "";
        pname   = StringSubstr(temp,0,equal);
        string pvalue = StringSubstr(temp,equal+1,semic-equal+1);
        if (pvalue != "*")  {
//---------------------------------------------------------------------------------------------------------------
//    Parameter assignment statements go in here
//---------------------------------------------------------------------------------------------------------------
          if (pname == "currencies")                      Currencies                     = pvalue;                 else
          if (pname == "currencysuffix")                  CurrencySuffix                 = pvalue;                 else
          if (pname == "timeframes")                      TimeFrames                     = pvalue;                 else
          if (pname == "rsiparameters")                   RSIParameters                  = pvalue;                 else
          if (pname == "fontnamesizecolor")               FontNameSizeColor              = pvalue;                 else
          if (pname == "colors")                          Colors                         = pvalue;                 else
          if (pname == "positionsettings")                PositionSettings               = pvalue;                 else
          if (pname == "displaymask")                     DisplayMask                    = pvalue;                 else
          if (pname == "refreshperiod")                   RefreshPeriod                  = pvalue;
//          Debug("pname  = " + pname);
//          Debug("pvalue = " + pvalue);
//---------------------------------------------------------------------------------------------------------------
        }
      }  
      temp = FileReadString(handle);
    }
    FileClose(handle);
  }  

  RefreshEveryXMins = StrToTF(RefreshPeriod);

  Currencies  = StringUpper(Currencies);
  if (Currencies == "")  Currencies = StringSubstr(Symbol(),0,3) + "," + StringSubstr(Symbol(),3,3);
  StrToStringArray(Currencies,C,",");
  
  TimeFrames  = StringUpper(TimeFrames);
  if (TimeFrames == "")  TimeFrames = TFToStr(Period());
  StrToStringArray(TimeFrames,TFs,",");

  StrToIntegerArray(RSIParameters,rsi,",");

  StrToStringArray(FontNameSizeColor,arr);
  FontName  = arr[0];
  FontSize  = StrToInteger(arr[1]);
  FontColor = StrToColor(arr[2]);
  
  StrToStringArray(PositionSettings,arr);
  Window       = StrToInteger(arr[0]);
  Corner       = 2*(StringFind(StringUpper(arr[1]),"B")>=0) + (StringFind(StringUpper(arr[1]),"R")>=0);
  HorizPos     = StrToInteger(arr[2]);
  HorizAdjust  = StrToInteger(arr[3]);
  HorizSpacing = StrToInteger(arr[4]);
  VertPos      = StrToInteger(arr[5]);
  VertSpacing  = StrToInteger(arr[6]);  
  
  StrToStringArray(Colors,clrs,",");

  IndiName = NumberToStr(GetUniqueInt(),"'RSIDash-'Z6");
  IndicatorShortName(IndiName);

  return(0);
}

//+------------------------------------------------------------------+
#include <hanover --- extensible functions (np).mqh>

