//+------------------------------------------------------------------+
//|                                                  KI_Exposure.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_minimum 0.0
#property indicator_maximum 0.1

#define SYMBOLS_MAX 1024
#define DEALS          0
#define BUY_LOTS       1
#define BUY_PRICE      2
#define SELL_LOTS      3
#define SELL_PRICE     4
#define NET_LOTS       5
#define PROFIT         6
#define PROFITPER      7
#define BUY_PROFIT     8
#define SELL_PROFIT    9

extern color ExtColor=Navy;
extern color ExtTotalColor=Red;
color  tmpColor=Navy;

string ExtName="KI_Exposure";
string ExtSymbols[SYMBOLS_MAX];
int    ExtSymbolsTotal=0;
double ExtSymbolsSummaries[SYMBOLS_MAX][10];
int    ExtLines=-1;
string ExtCols[11]={"Symbol",
                   "Deals",
                   "Buy lots",
                   "Buy price",
                   "Sell lots",
                   "Sell price",
                   "Net lots",
                   "Profit",
                   "ProfitPer,[%]",
                   "Buy profit",
                   "Sell profit"};
int    ExtShifts[11]={ 10, 80, 130, 180, 260, 310, 390, 460, 550, 650, 720};
int    ExtVertShift=14;
double ExtMapBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init()
  {
	IndicatorShortName(ExtName);
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexStyle(0,DRAW_NONE);
   IndicatorDigits(0);
	SetIndexEmptyValue(0,0.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   int windex=WindowFind(ExtName);
   if(windex>0) ObjectsDeleteAll(windex);
   Comment("");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start()
  {
   string name;
   int    i,col,line,windex=WindowFind(ExtName);
//----
   if(windex<0) return; 
//---- header line
   if(ExtLines<0)
     {
      for(col=0; col<11; col++)
        {
         name="kiHead_"+col;
         if(ObjectCreate(name,OBJ_LABEL,windex,0,0))
           {
            ObjectSet(name,OBJPROP_XDISTANCE,ExtShifts[col]);
            ObjectSet(name,OBJPROP_YDISTANCE,ExtVertShift);
            ObjectSetText(name,ExtCols[col],9,"Arial",ExtColor);
           }
        }
      ExtLines=0;
     }
//----
   ArrayInitialize(ExtSymbolsSummaries,0.0);
   int total=Analyze(); 
   if(total>0)
     {
      line=0;
      for(i=0; i<ExtSymbolsTotal; i++)
        {
         if(ExtSymbolsSummaries[i][DEALS]<=0) continue;
         line++;
         //---- add line
         if(line>ExtLines)
           {
            int y_dist=ExtVertShift*(line+1)+1;
            for(col=0; col<11; col++)
              {
               name="kiLine_"+line+"_"+col;
               if(ObjectCreate(name,OBJ_LABEL,windex,0,0))
                 {
                  ObjectSet(name,OBJPROP_XDISTANCE,ExtShifts[col]);
                  ObjectSet(name,OBJPROP_YDISTANCE,y_dist);
                 }
              }
            ExtLines++;
           }
         //---- set line
         int    digits=MarketInfo(ExtSymbols[i],MODE_DIGITS);
         double buy_lots=ExtSymbolsSummaries[i][BUY_LOTS];
         double sell_lots=ExtSymbolsSummaries[i][SELL_LOTS];
         double buy_price=0.0;
         double sell_price=0.0;
         if (i<ExtSymbolsTotal-1) tmpColor = ExtColor; else tmpColor = ExtTotalColor;
         if(buy_lots!=0)  buy_price=ExtSymbolsSummaries[i][BUY_PRICE]/buy_lots;
         if(sell_lots!=0) sell_price=ExtSymbolsSummaries[i][SELL_PRICE]/sell_lots;
         name="kiLine_"+line+"_0";
         ObjectSetText(name,ExtSymbols[i],9,"Arial",tmpColor);
         name="kiLine_"+line+"_1";
         ObjectSetText(name,DoubleToStr(ExtSymbolsSummaries[i][DEALS],0),9,"Arial",tmpColor);
         name="kiLine_"+line+"_2";
         ObjectSetText(name,DoubleToStr(buy_lots,2),9,"Arial",tmpColor);
         name="kiLine_"+line+"_3";
         if (i<ExtSymbolsTotal-1) ObjectSetText(name,DoubleToStr(buy_price,digits),9,"Arial",tmpColor); else ObjectSetText(name,"",9,"Arial",tmpColor);
         name="kiLine_"+line+"_4";
         ObjectSetText(name,DoubleToStr(sell_lots,2),9,"Arial",tmpColor);
         name="kiLine_"+line+"_5";
         if (i<ExtSymbolsTotal-1) ObjectSetText(name,DoubleToStr(sell_price,digits),9,"Arial",tmpColor); else ObjectSetText(name,"",9,"Arial",tmpColor);
         name="kiLine_"+line+"_6";
         ObjectSetText(name,DoubleToStr(buy_lots-sell_lots,2),9,"Arial",tmpColor);
         name="kiLine_"+line+"_7";
         ObjectSetText(name,DoubleToStr(ExtSymbolsSummaries[i][PROFIT],2),9,"Arial",tmpColor);
         name="kiLine_"+line+"_8";
         ObjectSetText(name,DoubleToStr(ExtSymbolsSummaries[i][PROFITPER],2),9,"Arial",tmpColor);
         name="kiLine_"+line+"_9";
         ObjectSetText(name,DoubleToStr(ExtSymbolsSummaries[i][BUY_PROFIT],2),9,"Arial",tmpColor);
         name="kiLine_"+line+"_10";
         ObjectSetText(name,DoubleToStr(ExtSymbolsSummaries[i][SELL_PROFIT],2),9,"Arial",tmpColor);
        }
     }
//---- remove lines
   if(total<ExtLines)
     {
      for(line=ExtLines; line>total; line--)
        {
         name="kiLine_"+line+"_0";
         ObjectSetText(name,"");
         name="kiLine_"+line+"_1";
         ObjectSetText(name,"");
         name="kiLine_"+line+"_2";
         ObjectSetText(name,"");
         name="kiLine_"+line+"_3";
         ObjectSetText(name,"");
         name="kiLine_"+line+"_4";
         ObjectSetText(name,"");
         name="kiLine_"+line+"_5";
         ObjectSetText(name,"");
         name="kiLine_"+line+"_6";
         ObjectSetText(name,"");
         name="kiLine_"+line+"_7";
         ObjectSetText(name,"");
         name="kiLine_"+line+"_8";
         ObjectSetText(name,"");
         name="kiLine_"+line+"_9";
         ObjectSetText(name,"");
         name="kiLine_"+line+"_10";
         ObjectSetText(name,"");
        }
     }
//---- to avoid minimum==maximum
   ExtMapBuffer[Bars-1]=-1;
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Analyze()
  {
   ExtSymbolsTotal=0;
   
   double profit;
   int    i,index,type,total=OrdersTotal();
   double total_buylots=0.0;
   double total_selllots=0.0;
   double total_profit=0.0;
   double total_buyprofit=0.0;
   double total_sellprofit=0.0;
   int    total_deals=0;
   
//----
   if (total==0) return (0);
   for(i=0; i<total; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      type=OrderType();
      if(type!=OP_BUY && type!=OP_SELL) continue;
      index=SymbolsIndex(OrderSymbol());
      if(index<0 || index>=SYMBOLS_MAX) continue;
      //----
      ExtSymbolsSummaries[index][DEALS]++; total_deals++;
      profit=OrderProfit()+OrderCommission()+OrderSwap();
      ExtSymbolsSummaries[index][PROFIT]+=profit; total_profit+=profit;
      ExtSymbolsSummaries[index][PROFITPER]=NormalizeDouble(ExtSymbolsSummaries[index][PROFIT]/(AccountBalance()+AccountCredit())*100,1);
      if(type==OP_BUY)
        {
         ExtSymbolsSummaries[index][BUY_LOTS]+=OrderLots(); total_buylots+=OrderLots();
         ExtSymbolsSummaries[index][BUY_PRICE]+=OrderOpenPrice()*OrderLots();
         ExtSymbolsSummaries[index][BUY_PROFIT]+=profit;
         total_buyprofit+=profit;
        }
      else
        {
         ExtSymbolsSummaries[index][SELL_LOTS]+=OrderLots(); total_selllots+=OrderLots();
         ExtSymbolsSummaries[index][SELL_PRICE]+=OrderOpenPrice()*OrderLots();
         ExtSymbolsSummaries[index][SELL_PROFIT]+=profit;
         total_sellprofit+=profit;
        }
     }
   // TOTAL SUMMARY
   ExtSymbols[ExtSymbolsTotal]="TOTAL";
   ExtSymbolsSummaries[ExtSymbolsTotal][DEALS]=total_deals; 
   ExtSymbolsSummaries[ExtSymbolsTotal][BUY_LOTS]=total_buylots;
   ExtSymbolsSummaries[ExtSymbolsTotal][SELL_LOTS]=total_selllots;
   ExtSymbolsSummaries[ExtSymbolsTotal][PROFIT]=total_profit;
   ExtSymbolsSummaries[ExtSymbolsTotal][PROFITPER]=NormalizeDouble(total_profit/(AccountBalance()+AccountCredit())*100,1);
   ExtSymbolsSummaries[ExtSymbolsTotal][BUY_PROFIT]=total_buyprofit;
   ExtSymbolsSummaries[ExtSymbolsTotal][SELL_PROFIT]=total_sellprofit;
   ExtSymbolsTotal++;
   
   
//----
   total=0;
   for(i=0; i<ExtSymbolsTotal; i++)
     {
      if(ExtSymbolsSummaries[i][DEALS]>0) total++;
     }
//----
   //Comment(total);
   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SymbolsIndex(string SymbolName)
  {
   bool found=false;
//----
   for(int i=0; i<ExtSymbolsTotal; i++)
     {
      if(SymbolName==ExtSymbols[i])
        {
         found=true;
         break;
        }
     }
//----
   if(found) return(i);
   if(ExtSymbolsTotal>=SYMBOLS_MAX) return(-1);
//----
   i=ExtSymbolsTotal;
   ExtSymbolsTotal++;
   ExtSymbols[i]=SymbolName;
   ExtSymbolsSummaries[i][DEALS]=0;
   ExtSymbolsSummaries[i][BUY_LOTS]=0;
   ExtSymbolsSummaries[i][BUY_PRICE]=0;
   ExtSymbolsSummaries[i][SELL_LOTS]=0;
   ExtSymbolsSummaries[i][SELL_PRICE]=0;
   ExtSymbolsSummaries[i][NET_LOTS]=0;
   ExtSymbolsSummaries[i][PROFIT]=0;
   ExtSymbolsSummaries[i][PROFITPER]=0;
//----
   return(i);
  }
//+------------------------------------------------------------------+