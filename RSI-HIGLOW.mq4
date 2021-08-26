
#property copyright "eevviill"
#property link      "http://volli7.blogspot.com/"
#property version   "2.7"
#property strict
//#property icon "\\Files\\evi.ico"

#property indicator_chart_window

//enum fonts set
enum fonts
{
font1,/*Aharoni*/ font2,/*Algerian*/ font3,/*Andalus*/ font4,/*Angsana New*/ font5,/*AngsanaUPC*/ font6,/*Aparajita*/ font7,/*Arabic Typesetting*/ font8,/*Arial*/ font9,/*Arial Black*/ 
font10,/*Arial Narrow*/ font11,/*Arial Unicode MS*/ font12,/*Baskenville Old Face*/ font13,/*Batang*/ font14,/*BatangChe*/ font15,/*Bauhaus 93*/ font16,/*Bell MT*/ font17,/*Berlin Sans FB*/ font18,/*Berlin Sans FB Demi*/ font19,/*Bernard MT Condensed*/ 
font20,/*Bodoni MT Poster Compressed*/ font21,/*Book Antiqua*/ font22,/*Bookman Old Style*/ font23,/*Bookshelf Symbol 7*/ font24,/*Britannic Bold*/ font25,/*Broadway*/ font26,/*Browallia New*/ font27,/*Browa|liaUPC*/ font28,/*Brush Script MT*/ font29,/*Calibri*/ 
font30,/*Calibri Light*/ font31,/*Californian FB*/ font32,/*Cambria*/ font33,/*Cambria Math*/ font34,/*Candara*/ font35,/*Centaur*/ font36,/*Century*/ font37,/*Century Gothic*/ font38,/*Chiller*/ font39,/*Colonna MT*/ 
font40,/*Comic Sans MS*/ font41,/*Consolas*/ font42,/*Constantia*/ font43,/*Cooper Black*/ font44,/*Corbel*/ font45,/*Cordia New*/ font46,/*CordiaUPC*/ font47,/*Courier*/ font48,/*Courier New*/ font49,/*DaunPenh*/ 
font50,/*David*/ font51,/*DFKai-SB*/ font52,/*DilleniaUPC*/ font53,/*DokChampa*/ font54,/*Dotum*/ font55,/*DotumChe*/ font56,/*Ebrima*/ font57,/*Estrangelo Edessa*/ font58,/*EucrosiaUPC*/ font59,/*Euphemia*/ 
font60,/*FangSong*/ font61,/*Fixedsys*/ font62,/*Footlight MT Light*/ font63,/*Franklin Gothic Medium*/ font64,/*FrankRuehl*/ font65,/*FreesiaUPC*/ font66,/*Freestyle Script*/ font67,/*Gabriola*/ font68,/*Garamond*/ font69,/*Gautami*/ 
font70,/*Georgia*/ font71,/*Gisha*/ font72,/*Gulim*/ font73,/*GulimChe*/ font74,/*Gungsuh*/ font75,/*GungsuhChe*/ font76,/*Haettenschweiler*/ font77,/*Harlow Solid Italic*/ font78,/*Harrington*/ font79,/*High Tower Text*/ 
font80,/*Impact*/ font81,/*Informal Roman*/ font82,/*IrisUPC*/ font83,/*Iskoola Pota*/ font84,/*JasmineUPC*/ font85,/*Jokerman*/ font86,/*Juice ITC*/ font87,/*KaiTi*/ font88,/*Kalinga*/ font89,/*Kartika*/ 
font90,/*Khmer UI*/ font91,/*KodchiangUPC*/ font92,/*Kokila*/ font93,/*Kristen ITC*/ font94,/*Kunstler Script*/ font95,/*Lao UI*/ font96,/*Latha*/ font97,/*Lato*/ font98,/*Lato Light*/ font99,/*Lato Semibold*/ 
font100,/*Leelawadee*/ font101,/*Levenim MT*/ font102,/*LilyUPC*/ font103,/*Lucida Bright*/ font104,/*Lucida Calligraphy*/ font105,/*Lucida Console*/ font106,/*Lucida Fax*/ font107,/*Lucida Handwriting*/ font108,/*Lucida Sans Unicode*/ font109,/*Magneto*/ 
font110,/*Malgun Gothic*/ font111,/*Mangal*/ font112,/*Marlett*/ font113,/*Matura MT Script Capitals*/ font114,/*Meiryo*/ font115,/*Meiryo UI*/ font116,/*Microsoft Himalaya*/ font117,/*Microsoft JhengHei*/ font118,/*Microsoft New Tai Lue*/ font119,/*Microsoft PhagsPa*/ 
font120,/*Microsoft Sans Serif*/ font121,/*Microsoft Tai Le*/ font122,/*Microsoft Uighur*/ font123,/*Microsoft YaHei*/ font124,/*Microsoft Yi Baiti*/ font125,/*MingLiU*/ font126,/*MingLiU_HKSCS*/ font127,/*MingLiU_HKSCS-ExtB*/ font128,/*MingLiU-ExtB*/ font129,/*Miriam*/ 
font130,/*Miriam Fixed*/ font131,/*Mistral*/ font132,/*Modern*/ font133,/*Modern No.20*/ font134,/*Mongolian Baiti*/ font135,/*Monotype Corsiva*/ font136,/*MoolBoran*/ font137,/*MS Gothic*/ font138,/*MS Mincho*/ font139,/*MS Outlook*/ 
font140,/*MS PGothic*/ font141,/*MS PMincho*/ font142,/*MS Reference Sans Serif*/ font143,/*MS Reference Specialty*/ font144,/*MS Sans Serifv*/ font145,/*MS Serif*/ font146,/*MS UI Gothic*/ font147,/*MT Extra*/ font148,/*MV Boli*/ font149,/*Narkisim*/ 
font150,/*Niagara Engraved*/ font151,/*Niagara Solid*/ font152,/*NSimSun*/ font153,/*Nyala*/ font154,/*Old English Text MT*/ font155,/*Onyx*/ font156,/*Palatino Linotype*/ font157,/*Parchment*/ font158,/*Plantagenet Cherokee*/ font159,/*Playbill*/ 
font160,/*PMingLiU*/ font161,/*PMingLiU-ExtB*/ font162,/*Poor Richard*/ font163,/*Raavi*/ font164,/*Ravie*/ font165,/*Rod*/ font166,/*Roman*/ font167,/*Sakkal Majalla*/ font168,/*Script*/ font169,/*Segoe Print*/ 
font170,/*Segoe Script*/ font171,/*Segoe UI*/ font172,/*Segoe UI Light*/ font173,/*Segoe UI Semibold*/ font174,/*Segoe UI Symbol*/ font175,/*Shonar Bangla*/ font176,/*Showcard Gothic*/ font177,/*Shruti*/ font178,/*SimHei*/ font179,/*Simplified Arabic*/ 
font180,/*Simplified Arabic Fixed*/ font181,/*SimSun*/ font182,/*SimSun-ExtB*/ font183,/*Small Fonts*/ font184,/*Snap ITC*/ font185,/*Stencil*/ font186,/*Sylfaen*/ font187,/*Symbol*/ font188,/*System*/ font189,/*Tahoma*/ 
font190,/*Tempus Sans ITC*/ font191,/*Terminal*/ font192,/*Times New Roman*/ font193,/*Traditional Arabic*/ font194,/*Trebuchet MS*/ font195,/*Tunga*/ font196,/*Utsaah*/ font197,/*Vani*/ font198,/*Verdana*/ font199,/*Vijaya*/ 
font200,/*Viner Hand ITC*/ font201,/*Vivaldi*/ font202,/*Vladimir Script*/ font203,/*Vrinda*/ font204,/*Webdings*/ font205,/*Wide Latin*/ font206,/*Wingdings*/ font207,/*Wingdings 2*/ font208,/*Wingdings 3*/ 
};
//fonts buf
string fonts_buf[208]=
{
"Aharoni","Algerian","Andalus","Angsana New","AngsanaUPC","Aparajita","Arabic Typesetting","Arial","Arial Black","Arial Narrow","Arial Unicode MS","Baskenville Old Face","Batang",
"BatangChe","Bauhaus 93","Bell MT","Berlin Sans FB","Berlin Sans FB Demi","Bernard MT Condensed","Bodoni MT Poster Compressed","Book Antiqua","Bookman Old Style","Bookshelf Symbol 7",
"Britannic Bold","Broadway","Browallia New","Browa|liaUPC","Brush Script MT","Calibri","Calibri Light","Californian FB","Cambria","Cambria Math","Candara","Centaur","Century","Century Gothic",
"Chiller","Colonna MT","Comic Sans MS","Consolas","Constantia","Cooper Black","Corbel","Cordia New","CordiaUPC","Courier","Courier New","DaunPenh","David","DFKai-SB","DilleniaUPC","DokChampa",
"Dotum","DotumChe","Ebrima","Estrangelo Edessa","EucrosiaUPC","Euphemia","FangSong","Fixedsys","Footlight MT Light","Franklin Gothic Medium","FrankRuehl","FreesiaUPC","Freestyle Script","Gabriola",
"Garamond","Gautami","Georgia","Gisha","Gulim","GulimChe","Gungsuh","GungsuhChe","Haettenschweiler","Harlow Solid Italic","Harrington","High Tower Text","Impact","Informal Roman","IrisUPC",
"Iskoola Pota","JasmineUPC","Jokerman","Juice ITC","KaiTi","Kalinga","Kartika","Khmer UI","KodchiangUPC","Kokila","Kristen ITC","Kunstler Script","Lao UI","Latha","Lato","Lato Light","Lato Semibold",
"Leelawadee","Levenim MT","LilyUPC","Lucida Bright","Lucida Calligraphy","Lucida Console","Lucida Fax","Lucida Handwriting","Lucida Sans Unicode","Magneto","Malgun Gothic","Mangal","Marlett",
"Matura MT Script Capitals","Meiryo","Meiryo UI","Microsoft Himalaya","Microsoft JhengHei","Microsoft New Tai Lue","Microsoft PhagsPa","Microsoft Sans Serif","Microsoft Tai Le","Microsoft Uighur",
"Microsoft YaHei","Microsoft Yi Baiti","MingLiU","MingLiU_HKSCS","MingLiU_HKSCS-ExtB","MingLiU-ExtB","Miriam","Miriam Fixed","Mistral","Modern","Modern No.20","Mongolian Baiti","Monotype Corsiva",
"MoolBoran","MS Gothic","MS Mincho","MS Outlook","MS PGothic","MS PMincho","MS Reference Sans Serif","MS Reference Specialty","MS Sans Serifv","MS Serif","MS UI Gothic","MT Extra","MV Boli","Narkisim",
"Niagara Engraved","Niagara Solid","NSimSun","Nyala","Old English Text MT","Onyx","Palatino Linotype","Parchment","Plantagenet Cherokee","Playbill","PMingLiU","PMingLiU-ExtB","Poor Richard","Raavi",
"Ravie","Rod","Roman","Sakkal Majalla","Script","Segoe Print","Segoe Script","Segoe UI","Segoe UI Light","Segoe UI Semibold","Segoe UI Symbol","Shonar Bangla","Showcard Gothic","Shruti","SimHei",
"Simplified Arabic","Simplified Arabic Fixed","SimSun","SimSun-ExtB","Small Fonts","Snap ITC","Stencil","Sylfaen","Symbol","System","Tahoma","Tempus Sans ITC","Terminal","Times New Roman",
"Traditional Arabic","Trebuchet MS","Tunga","Utsaah","Vani","Verdana","Vijaya","Viner Hand ITC","Vivaldi","Vladimir Script","Vrinda","Webdings","Wide Latin","Wingdings","Wingdings 2","Wingdings 3"
};




extern string ma_set = "///////////////////Main settings///////////////////";
extern string pairs = "EURUSD-EURJPY-GBPJPY-GBPUSD-XAUUSD";
extern string TFs = "M5";
extern int update_seconds = 7;
extern ENUM_BASE_CORNER corner = CORNER_LEFT_LOWER;
extern bool redraw_objects = false;
extern bool draw_data = true;
extern int window = 0;
//extern bool EnableSoundAlert = true;
extern bool Alert_On = false;
extern bool sound_long=true;

extern string ind_set = "///////////////////Indicator settings///////////////////";
extern int rsi_period = 14;
extern ENUM_APPLIED_PRICE rsi_price = PRICE_CLOSE;
extern double rsi_high_level = 70;
extern double rsi_low_level = 30;
 
extern string rec_set = "///////////////////Rectangles settings///////////////////";
extern int Rectangle_width = 37;
extern int Rectangle_height = 25;
extern int Rectangle_X = 60;
extern int Rectangle_X_step = 42;
extern int Rectangle_Y = 50;
extern int Rectangle_Y_step = 32;
extern int Rectangle_main_plus = 22;
extern color Rectangle_main_color = clrBlack;
extern color Rectangle_color_up = clrDodgerBlue;
extern color Rectangle_color_medium = clrGray;
extern color Rectangle_color_down = clrRed;
extern color Rectangle_border_color = clrWhite;
extern fonts Text_symb_font = font9;
extern int Text_symb_size = 9;
extern int Text_symb_shift_X = -4;
extern int Text_symb_shift_Y = 24;
extern int Text_symb2_shift_Y = 12;
extern color Text_symb_color = clrWhite;
extern fonts Text_numb_font = font9;//font32;
extern int Text_numb_size = 14;
extern int Text_numb_shift_X = -7;
extern int Text_numb_shift_Y = -12;
extern color Text_numb_color = C'211,211,211';
extern int Text_numb_digits = 1;
extern fonts Text_TF_font = font9;
extern int Text_TF_size = 10;
extern int Text_TF_shift_X = 38;
extern int Text_TF_shift_Y = -12;
extern color Text_TF_color = clrWhite;




string identif="RSIHIGLOW";
string spliter = "-";
string pairs_b[];
int TFs_b[];
 int overall_rectangles;
 int one_line_rectangles;
string str_spl_tf[];
bool first_chek=false;
bool testing;
int Rectangle_X_real;
int Rectangle_Y_real;
int main_chart_width_pix_;
int main_chart_height_pix_;


////////////////////////////////////////////////////////////////
int OnInit()
  {
  //update seconds or every tick
  if(update_seconds>0) EventSetTimer(update_seconds);
  
    //delete all
  delete_all_objects_f();
  
  //is it testing
  testing=IsTesting();
  
  //pairs and TFs cut to buffs
  pairs_to_buf_f();
  TFs_to_buf_f();
  
  //overall rectangles and rectangles in one line
overall_rectangles=ArraySize(TFs_b)*ArraySize(pairs_b);
one_line_rectangles=ArraySize(pairs_b);

 //different corners
 X_Y_set_f();
 
      //main reactangle
  create_Rectangle_main_f();
 
 //pairs to market watch
 add_symbols_market_watch_f();
 
 
 
   return(INIT_SUCCEEDED);
  }

//////////////////////////////////////////////////////////////
 void OnDeinit(const int reason)
 {
 delete_all_objects_f();

 }



////////////////////////////////////////////////////////////////////////
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],
                const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[])
  {
  if(update_seconds==0 || !first_chek || testing) 
  {
  All();
   first_chek=true;
  }
  
   return(rates_total);
  }

//////////////////////////////////////////////////////
void OnTimer()
{
All();
}

////////////////////////////////////////////////////////////////////////
 void All()
 {
 //chart size
  if(main_chart_width_pix_!=int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)) || main_chart_height_pix_!=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0))) 
  {
  main_chart_width_pix_=int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0));
  main_chart_height_pix_=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0));
  //delete_all_objects_f();
  X_Y_set_f();
  create_Rectangle_main_f();
  }

 
 
 //variables
int st_X=Rectangle_X_real;
int st_Y=Rectangle_Y_real;
int tf_count=0;
int pair_count=0;
bool first_raw_chaked=false;
string rectan_name;

////main
for(int y=1;y<=overall_rectangles;y++)
{
//rectangles drawing
rectan_name=identif+"rectan"+string(y);
create_Rectangle_f(rectan_name,st_X,st_Y);
//symbols drawing
if(!first_raw_chaked)
{
create_label_f(y,st_X-Text_symb_shift_X,st_Y-Text_symb_shift_Y,symb_cut_f(pairs_b[pair_count],1),Text_symb_size,"SYMB",Text_symb_color,fonts_buf[Text_symb_font]);
create_label_f(y,st_X-Text_symb_shift_X,st_Y-Text_symb2_shift_Y,symb_cut_f(pairs_b[pair_count],2),Text_symb_size,"SYMB2",Text_symb_color,fonts_buf[Text_symb_font]);
}

//data
double data=data_get_f(TFs_b[tf_count],pairs_b[pair_count]);
//numb draw
if(draw_data) create_label_f(y,st_X-Text_numb_shift_X,st_Y-Text_numb_shift_Y,DoubleToString(data,Text_numb_digits-1),Text_numb_size,"NUMB",Text_numb_color,fonts_buf[Text_numb_font]);
//rectangle color set 
color_set_f(rectan_name,data); 



//counters
st_X+=Rectangle_X_step;
pair_count++;


//raw end
if(y%one_line_rectangles==0)
{
if(!first_raw_chaked) first_raw_chaked=true;

st_X=Rectangle_X_real;
create_label_f(y,st_X-Text_TF_shift_X,st_Y-Text_TF_shift_Y,str_spl_tf[tf_count],Text_TF_size,"TF",Text_TF_color,fonts_buf[Text_TF_font]); //TF drawing
st_Y+=Rectangle_Y_step;
tf_count++;
pair_count=0;
}

}

}

///////////////////////funcs
/////////////////////////////////////////////////////////////////////////
double data_get_f(int TF,string symb)
{
double value=0;
value=iRSI(symb,TF,rsi_period,rsi_price,0);


return(value);
}

////////////////////////////////////////////////////////////////////////
void color_set_f(string name,double data)
{
color col=clrNONE;

if(data>=rsi_high_level)Alert("up",data);
else
if(data<=rsi_low_level)Alert("down",data);
else
col=Rectangle_color_medium;


ObjectSetInteger(0,name,OBJPROP_BGCOLOR,col);
}

/////////////////////////////////////////////////////////////////////////////////////////////
void create_Rectangle_f(string name,int X,int Y)
{

if(ObjectFind(name)==-1)
{
ObjectCreate(name,OBJ_RECTANGLE_LABEL,window,0,0);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,Rectangle_width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,Rectangle_height);
   //
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrNONE);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_RAISED); 
   ObjectSetInteger(0,name,OBJPROP_COLOR,Rectangle_border_color); 
   //
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}
   ObjectSetInteger(0,name, OBJPROP_XDISTANCE,X);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE, Y);


}

/////////////////////////////////////////////////////////////////////////////////////////////
void create_label_f(int i,int X,int Y,string text,int Text_size,string name_add,color colo,string font)
{
string name=identif+"label"+string(i)+name_add;

if(ObjectFind(name)==-1)
{
ObjectCreate(name,OBJ_LABEL,window,0,0);
   //
   ObjectSetString(0,name,OBJPROP_FONT, font);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE, Text_size);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_COLOR, colo);
   //
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}
   ObjectSetInteger(0,name, OBJPROP_XDISTANCE,X);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE, Y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);


}

////////////////////////////////////////////////////////////////////////
void pairs_to_buf_f()
{
string str_spl[];
int size=StringSplit(pairs,StringGetCharacter(spliter,0),str_spl);
ArrayResize(pairs_b,size);
for(int i=0;i<size;i++)
{
pairs_b[i]=str_spl[i];
}

}

////////////////////////////////////////////////////////////////////////
void TFs_to_buf_f()
{
int size=StringSplit(TFs,StringGetCharacter(spliter,0),str_spl_tf);
ArrayResize(TFs_b,size);
for(int i=0;i<size;i++)
{
TFs_b[i]=String_to_TF(str_spl_tf[i]);
}

}

/////////////////////////////////////////////////////////////////////////
int String_to_TF(string tf)
{
int TF=0;

if(tf=="M1") TF=PERIOD_M1;
if(tf=="M5") TF=PERIOD_M5;
if(tf=="M15") TF=PERIOD_M15;
if(tf=="M30") TF=PERIOD_M30;
if(tf=="H1") TF=PERIOD_H1;
if(tf=="H4") TF=PERIOD_H4;
if(tf=="D1") TF=PERIOD_D1;
if(tf=="W1") TF=PERIOD_W1;
if(tf=="MN1") TF=PERIOD_MN1;



return(TF);
}

////////////////////////////////////////////////////////////////////
string symb_cut_f(string symb,short half)
{
string cutted_symb=symb;

if(half==1) cutted_symb=StringSubstr(symb,0,3);
if(half==2) cutted_symb=StringSubstr(symb,3,3);


return(cutted_symb);
}

///////////////////////////////////////////////////////////////
void X_Y_set_f()
{
 if(corner==CORNER_LEFT_UPPER) 
 {
 Rectangle_X_real=Rectangle_X;
 Rectangle_Y_real=Rectangle_Y;
 }
 else
 if(corner==CORNER_RIGHT_UPPER) 
 {
   int main_chart_width_pix=int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0));
int size_all_X=ArraySize(pairs_b)*(Rectangle_X_step-1);
Rectangle_X_real=main_chart_width_pix-Rectangle_X-size_all_X;
Rectangle_Y_real=Rectangle_Y;
 }
 else
 if(corner==CORNER_LEFT_LOWER)
 {
   int main_chart_height_pix=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0));
int size_all_Y=ArraySize(TFs_b)*(Rectangle_Y_step-1);
Rectangle_Y_real=main_chart_height_pix-Rectangle_Y-size_all_Y;
Rectangle_X_real=Rectangle_X;
 }
 else
  if(corner==CORNER_RIGHT_LOWER) 
 {
   int main_chart_width_pix=int(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0));
int size_all_X=ArraySize(pairs_b)*(Rectangle_X_step-1);
Rectangle_X_real=main_chart_width_pix-Rectangle_X-size_all_X;
   int main_chart_height_pix=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0));
int size_all_Y=ArraySize(TFs_b)*(Rectangle_Y_step-1);
Rectangle_Y_real=main_chart_height_pix-Rectangle_Y-size_all_Y;
 }
 
 
 }
 
//////////////////////////////////////////////////////////
 void delete_all_objects_f()
 {
  string name_delete;
 for(int i=ObjectsTotal()-1;i>=0;i--)
 {
 name_delete=ObjectName(i);
 if(StringFind(name_delete,identif)!=-1) ObjectDelete(name_delete);
 }
 
 }
 
 ///////////////////////////////////////////////////////////////////
void add_symbols_market_watch_f()
{
string pair_name;

for(int i=0;i<ArraySize(pairs_b);i++)
{
pair_name=pairs_b[i];
if(!SymbolInfoInteger(pair_name,SYMBOL_SELECT)) SymbolSelect(pair_name,true);
}

}

/////////////////////////////////////////////////////////////////////////////////////////////
void create_Rectangle_main_f()
{
string name=identif+"rectan"+string(-1);
int X_dist_bet_rects=Rectangle_X_step-Rectangle_width;
int Y_dist_bet_rects=Rectangle_Y_step-Rectangle_height;

if(ObjectFind(0,name)==-1)
{
ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,window,0,0);
   //
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,Rectangle_main_color);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_RAISED); 
   ObjectSetInteger(0,name,OBJPROP_XSIZE,(Rectangle_width+X_dist_bet_rects)*ArraySize(pairs_b)+Text_TF_shift_X-X_dist_bet_rects+Rectangle_main_plus);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,(Rectangle_height+Y_dist_bet_rects)*ArraySize(TFs_b)+Text_symb_shift_Y-Y_dist_bet_rects+Rectangle_main_plus);
   //
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}

   ObjectSetInteger(0,name, OBJPROP_XDISTANCE,Rectangle_X_real-Text_TF_shift_X-Rectangle_main_plus/2);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE, Rectangle_Y_real-Text_symb_shift_Y-Rectangle_main_plus/2);


}