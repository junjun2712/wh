//+------------------------------------------------------------------+
//|                                                 Basket_Stats.mq4 |
//|                               Copyright © 2011, Patrick M. White |
//|                     https://sites.google.com/site/marketformula/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Patrick M. White"
#property link      "https://sites.google.com/site/marketformula/"

/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
    
    If you need a commercial license, please send me an email:
    market4mula@gmail.com
*/


#property indicator_chart_window
extern int MagicNumber = -1;

double BeginningBalance = 0;
string symbols[20];
double tottrades, totlots, totopnl, totcpnl;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  DeleteObjects();
  BeginningBalance = CalcBeginningBalance();
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
   DeleteObjects();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   SetLabel("objSymbol", "Symbol", DimGray, 250, 25);
   SetLabel("objTrades", "Trades", DimGray, 200, 25);
   SetLabel("objLots", "Lots", DimGray, 150, 25);
   SetLabel("objOpenPnL", "O PnL", DimGray, 100, 25);
   SetLabel("objClosedPnL", "C PnL", DimGray, 50, 25);
   
   Assign_Symbols();
   totlots =0.0; tottrades = 0.0; totopnl =0.0; totcpnl =0.0;
   for (int i =0; i <=20; i++) {
      if(StringLen(symbols[i])==0) break;
      Output_Row(i, symbols[i]);
   }
   int row = i;
   SetLabel("objSymbol" + row, "Totals", White, 250, 25+ (row + 1)*14);
   SetLabel("objTrades" + row, DoubleToStr(tottrades,0), White, 200, 25 + (row + 1)*14);
   SetLabel("objLots" + row, DoubleToStr(totlots,2), White, 150, 25 + (row + 1)*14);
   SetLabel("objOpenPnL" + row, DoubleToStr(totopnl,2), White, 100, 25 + (row + 1)*14);
   SetLabel("objClosedPnL" + row, DoubleToStr(totcpnl,2), White, 50, 25 + (row + 1)*14);
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

void Output_Row(int row, string sym)
{
   SetLabel("objSymbol" + row, sym, DimGray, 250, 25 + (row + 1)*14);
   double trades =0;
   double lots = 0.0;
   double opnl = 0.0;
   double cpnl =0.0;
   double clots = 0.0;
   double ctrades = 0;
   int pos = 1, lcolor = DimGray;
   for(int i =0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if((OrderMagicNumber() == MagicNumber || MagicNumber == -1 ) && OrderSymbol() == sym) {
         opnl += OrderProfit()+OrderCommission()+OrderSwap();
         lots += OrderLots();
         trades +=1;
         if(OrderType() == OP_SELL) pos = -1;
      }
   }
   if (pos == 1) lcolor = Lime;
   if (pos ==-1) lcolor = Red;
   int clr = Lime; if(opnl <0) clr = Red;
   SetLabel("objTrades" + row, DoubleToStr(trades,0), DimGray, 200, 25 + (row + 1)*14);
   SetLabel("objLots" + row, DoubleToStr(lots,2), lcolor, 150, 25 + (row + 1)*14);
   SetLabel("objOpenPnL" + row, DoubleToStr(opnl,2), clr, 100, 25 + (row + 1)*14);
   
   for(i =0; i < OrdersHistoryTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if((OrderMagicNumber() == MagicNumber || MagicNumber == -1) && OrderSymbol() == sym) {
         cpnl += OrderProfit()+OrderCommission()+OrderSwap();
         clots += OrderLots();
         ctrades +=1;
      }
   }
   if (cpnl >=0) lcolor = Lime; else lcolor = Red;
   SetLabel("objClosedPnL" + row, DoubleToStr(cpnl,2), lcolor, 50, 25 + (row + 1)*14);
   tottrades += trades;
   totlots += lots;
   totopnl += opnl;
   totcpnl += cpnl;
}

void Assign_Symbols()
{
   int i =0;
   for (i =0; i < OrdersHistoryTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if(OrderMagicNumber() == MagicNumber || MagicNumber == -1) {
         for (int k = 0; k<=20; k++) {
            if(OrderSymbol() == symbols[k]) break;
            if(StringLen(symbols[k]) == 0) {
               symbols[k] = OrderSymbol();
               break;
            }
         }
      }
   }
   
   for (i=0; i<OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderMagicNumber() == MagicNumber || MagicNumber == -1) {
         for (k = 0; k <=20; k++) {
            if(OrderSymbol() == symbols[k]) break;
            if(StringLen(symbols[k]) == 0) {
               symbols[k] = OrderSymbol();
               break;
            }         
         }
      }
   }
}

double CalcBeginningBalance()
{
   double pips = 0.0;
   for (int i = 0; i < 1; i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if(OrderMagicNumber() == MagicNumber || MagicNumber == -1){
         pips += OrderProfit();
      }
   }
   return(pips);
}

//+--------------------------------------------------------------------------+
//| corner - room corner bindings - (0 - upper left)                         |
//| fontsize - font size - (9 - default)                                     |
//+--------------------------------------------------------------------------+
  void SetLabel(string name, string text, color clr, int xdistance, int ydistance, int corner=1, int fontsize=9)
  {
   if (ObjectFind(name)==-1) {
      ObjectCreate(name, OBJ_LABEL, 0, 0,0);
      ObjectSet(name, OBJPROP_XDISTANCE, xdistance);
      ObjectSet(name, OBJPROP_YDISTANCE, ydistance);
      ObjectSet(name, OBJPROP_CORNER, corner);
   }
   ObjectSetText(name, text, fontsize, "Arial", clr);
 
  }
//+--------------------------------------------------------------------------+

  void     DeleteObjects() {
  for(int i=ObjectsTotal()-1; i>-1; i--)
   if (StringFind(ObjectName(i),"obj")>=0)  ObjectDelete(ObjectName(i));  
 }