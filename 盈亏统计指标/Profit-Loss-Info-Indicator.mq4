//+------------------------------------------------------------------+
//|                                             Profit_Loss_Info.mq4 |
//|                                                    Goldexcalibur |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Goldexcalibur"
#property link      ""

#property description "edited by eevviill"
#property description "view settings"

#property indicator_chart_window

extern bool showPLPerPosition = true;
extern bool showFloatPLPercentage = false;
extern bool showDailyPLPercentage = false;
extern bool showPeriodePLPercentage = false;

extern string notes1 = "startDayAccordingTo menunjukan acuan permulaan hari (kaitannya dengan balance) mengikuti broker / localtime";
extern string notes2 = "0= broker time; 1= localtime";
extern int startDayAccordingTo = 1;
extern string notes3 = "periode format : yyyy.mm.dd hh:mm";
extern datetime periodeStartTime = D'2009.11.01 00:00';
extern bool useTodayAsEndTime = true;
extern datetime periodeEndTime = D'2009.11.04 00:00';

extern int myfont = 10; // This extern variable was added by Agoenk of Forexindo. Thanks for the contibution :)

extern color positifColor = Chartreuse;
extern color negatifColor = Magenta;

extern string emp1 = "//////////View settings";
extern ENUM_BASE_CORNER Corner = CORNER_LEFT_UPPER;
extern int X_plus = 0;
extern int Y_plus = 0;


int x = NULL;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   int idx;

   if(x != NULL) {
      for(idx = 0; idx<x; idx++) {
         ObjectDelete("O"+idx);
         ObjectDelete("PL"+idx);
      }
            
      ObjectDelete("h");      
      ObjectDelete("Total1");
      ObjectDelete("Total2");
      ObjectDelete("PercentageDailyLabel");
      ObjectDelete("PercentageDaily");
      ObjectDelete("PercentagePeriodeLabel");
      ObjectDelete("PercentagePeriode");
      ObjectDelete("PeriodeLabel");
      ObjectDelete("PercentageFloatLabel");
      ObjectDelete("PercentageFloat");
   }

//----
   return(0);
  }
  
void DisplayText(string objname, string text, int fontsize, color clr, double C, double X, double Y, string font)
{
   ObjectDelete(objname);
   ObjectCreate(objname, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(objname, text, fontsize, font, clr);
   ObjectSet(objname, OBJPROP_CORNER, Corner);
   ObjectSet(objname, OBJPROP_XDISTANCE, X+X_plus);
   ObjectSet(objname, OBJPROP_YDISTANCE, Y+Y_plus);
}

double percentageValue(datetime start, datetime end){
   int i;
   double startTime = 86400 * (start / 86400);
   double endTime;
   if (startDayAccordingTo == 1) startTime = startTime + ((TimeCurrent() - TimeLocal()) / 100) * 100;
   
   endTime = 86400 * (end / 86400) + 86400;
   if (startDayAccordingTo == 1) endTime = endTime + ((TimeCurrent() - TimeLocal()) / 100) * 100;
   
   double startBalance;
   double histPL = 0;
   double bruteHistPL = 0;
      
   for(i=1; i <= OrdersHistoryTotal(); i++){
      if(OrderSelect(OrdersHistoryTotal() - i, SELECT_BY_POS , MODE_HISTORY)==true)  {
         if(OrderCloseTime() >= startTime) {
            bruteHistPL = bruteHistPL + OrderProfit();
            if(OrderCloseTime() < endTime) histPL = histPL + OrderProfit();
         }
      }   
   }
   
   startBalance = AccountBalance() - bruteHistPL;
   
   if(TimeCurrent() >= startTime && TimeCurrent() < endTime){
      for(i=OrdersTotal()-1; i >=0 ; i--){
         if(OrderSelect(i, SELECT_BY_POS , MODE_TRADES)==true)  {
         
               histPL = histPL + OrderProfit();
         
         }   
      }
   }   
  
   return(NormalizeDouble(histPL / startBalance * 100, 4));

}


  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int    j;
   int    idx;
   string text;
   double PL;
   double total;
   int strLen;
   double xPos;
//----
         if(x != NULL) {
            for(idx = 0; idx<x; idx++) {
               ObjectDelete("O"+idx);
               ObjectDelete("PL"+idx);
            }
            
            ObjectDelete("Total1");
            ObjectDelete("Total2");
         }
            
         text = "";
         j=1;
         total = 0;
         
         
                  
   
         DisplayText("h", "Profit/Loss Info ", myfont, Gold, 0, 5, 15 , "Arial Bold"); 

         if(showPLPerPosition) {
            for (int i = OrdersTotal()-1 ; i >= 0; i--) 
            { 
               if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
               { 
                  text = OrderSymbol() + " (" + OrderTicket() + ")" + " : ";
                  strLen = StringLen(text);
                  xPos = NormalizeDouble(strLen * 0.65 * myfont,0) + 18;
               
                  if(OrderType() == OP_BUY)  {
                     DisplayText("O"+j, OrderSymbol() + " (" + OrderTicket() + ")" + " : ", myfont, Chartreuse, 0, 5, (2 + j * 1.5) * myfont, "Arial bold"); 
   
                     PL = (OrderClosePrice()-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT);
                     total = total + PL;
                     if(PL<0) DisplayText("PL"+j, DoubleToStr(PL, 0), myfont, negatifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial"); 
                     else if(PL>0) DisplayText("PL"+j, "+"+DoubleToStr(PL, 0), myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial"); 
                     else DisplayText("PL"+j, DoubleToStr(PL, 0), myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial"); 
                  }
                  else if(OrderType() == OP_SELL)  {
                     DisplayText("O"+j, OrderSymbol() + " (" + OrderTicket() + ")" + " : ", myfont, Magenta, 0, 5, (2 + j * 1.5) * myfont, "Arial bold"); 
                  
                     PL = (OrderOpenPrice()-OrderClosePrice())/MarketInfo(OrderSymbol(),MODE_POINT);
                     total = total + PL;
                     if(PL<0) DisplayText("PL"+j, DoubleToStr(PL, 0) , myfont, negatifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial"); 
                     else if(PL>0) DisplayText("PL"+j,"+"+DoubleToStr(PL, 0) , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial"); 
                     else DisplayText("PL"+j,DoubleToStr(PL, 0) , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial"); 
                  }
                  j=j+1;
               } 
            } 
   
            DisplayText("Total1","Total Profit/Loss : ", myfont, Gold, 0, 5, (2 + j * 1.5) * myfont, "Arial Bold");
            strLen = StringLen("Total Profit/Loss : ");
            xPos = NormalizeDouble(strLen * 0.65 * myfont,0) + 18;
            if(total<0) DisplayText("Total2", DoubleToStr(total, 0) , myfont, negatifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
            else if (total>0) DisplayText("Total2","+" + DoubleToStr(total, 0) , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
            else DisplayText("Total2", DoubleToStr(total, 0) , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
         
            x=j;
         
            j = j+2;
         }
   
   //=================================================================================================================
   // current float P/L  : current balance
   if(showFloatPLPercentage) {
      DisplayText("PercentageFloatLabel","Float Profit/Loss Percentage : ", myfont, Gold, 0, 5, (2 + j * 1.5) * myfont, "Arial Bold");
      double floatPL = 0;
      for (i = OrdersTotal()-1 ; i >= 0; i--) 
      { 
       if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
       {
        floatPL = floatPL + OrderProfit(); 
       }
      }
      strLen = StringLen("Float Profit/Loss Percentage : ");
      xPos = NormalizeDouble(strLen * 0.6 * myfont,0) + 15;
      if(floatPL < 0) DisplayText("PercentageFloat", DoubleToStr(floatPL/AccountBalance()*100,4) + " %" , myfont, negatifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
      else if(floatPL < 0) DisplayText("PercentageFloat", "-" + DoubleToStr(floatPL/AccountBalance()*100,4) + " %" , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
      else DisplayText("PercentageFloat", DoubleToStr(floatPL/AccountBalance()*100,4) + " %" , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
   
      j = j+2;
   }
   
   double temp;
   
   // Today's closed n float P/L : today balance
   if(showDailyPLPercentage) {
      DisplayText("PercentageDailyLabel","Daily Profit/Loss Percentage : ", myfont, Gold, 0, 5, (2 + j * 1.5) * myfont, "Arial Bold");
      temp = percentageValue(TimeCurrent(),TimeCurrent());
      strLen = StringLen("Daily Profit/Loss Percentage : ");
      xPos = NormalizeDouble(strLen * 0.6 * myfont,0) + 15;
      if(temp < 0) DisplayText("PercentageDaily", DoubleToStr(temp,4) + " %" , myfont, negatifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
      else if(temp > 0) DisplayText("PercentageDaily", "+"+ DoubleToStr(temp,4) + " %" , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
      else DisplayText("PercentageDaily", DoubleToStr(temp,4) + " %" , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
      j = j+2;
   }
   
   if(showPeriodePLPercentage) {
      // periode's closed n float P/L : start periode balance
      DisplayText("PercentagePeriodeLabel","Periode Profit/Loss Percentage : ", myfont, Gold, 0, 5, (2 + j * 1.5) * myfont, "Arial Bold");
      strLen = StringLen("Periode Profit/Loss Percentage : ");
      xPos = NormalizeDouble(strLen * 0.6 * myfont,0) + 15;
      if(useTodayAsEndTime) {
         temp = percentageValue(periodeStartTime,TimeCurrent());
         if(temp < 0) DisplayText("PercentagePeriode", DoubleToStr(temp,4) + " %" , myfont, negatifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
         else if(temp > 0) DisplayText("PercentagePeriode", "+" + DoubleToStr(temp,4) + " %" , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
         else DisplayText("PercentagePeriode", DoubleToStr(temp,4) + " %" , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
      }
      else {
         temp = percentageValue(periodeStartTime,periodeEndTime);
         if(temp < 0) DisplayText("PercentagePeriode", DoubleToStr(temp,4) + " %" , myfont, negatifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
         else if(temp < 0) DisplayText("PercentagePeriode", "+" + DoubleToStr(temp,4) + " %" , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
         else DisplayText("PercentagePeriode", DoubleToStr(temp,4) + " %" , myfont, positifColor, 0, xPos, (2 + j * 1.5) * myfont, "Arial Bold");
      }
      j = j+1;
      if(useTodayAsEndTime) DisplayText("PeriodeLabel","("+ TimeToStr(periodeStartTime) +" - "+ TimeToStr(86400 * (TimeCurrent() / 86400) + 86400) +")", myfont, Gold, 0, 5, (2 + j * 1.5) * myfont, "Arial Bold");
      else DisplayText("PeriodeLabel","("+ TimeToStr(periodeStartTime, TIME_DATE) + " - " + TimeToStr(periodeEndTime, TIME_DATE) + ")", myfont, Gold, 0, 5, (2 + j * 1.5) * myfont, "Arial Bold");
   }   
   
   //=================================================================================================================
   return(0);
  }
//+------------------------------------------------------------------+