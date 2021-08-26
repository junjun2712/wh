//去掉了全局变量设置。
//去掉了加仓方案设置&#xff0c;加仓方案按照数组里面设置。
//增加了停止开新仓的设置&#xff0c;意思是当前一波结束了不再下单。
//ea运行途中可随时设置参数&#xff0c;不会影响运行效果。

//-------------------------------------------------------------------
#property copyright "Copyright &#64;2011, 80364276&#64;qq.com"
#property link      "Copyright &#64;2011, 80364276&#64;qq.com"
#property description "间隔: 0, 20,20,15,15,20,20,30。"
#property description "倍率: 1, 2, 1, 2, 1, 3, 2, 4。"
#property description "最大交易量5手,大于5手不开仓。"
#property strict
//-------------------------------------------------------------------
input int Magic=1800; //魔术码
input bool IsStop=false; //当前一波结束是否停止
input double lots=0.01; //初始手数
//-加仓时的间隔点数,数组从0开始
int Interval_Pips[20]= {0, 20,20,15,15,20,20,30};
//-加仓时的交易量倍数
int Interval_Lots[20]= {1, 2, 1, 2, 1, 3, 2, 4};
int slippage=3;
input int TP=300; //止盈点数
input int SL=2000;//止损点数
//止损点数为第一单的止损点数计算出来的价格作为每一单的止损价。加仓的时候会考虑下单价格距离止损价太近就不加仓。
string comt="WinKey->";
int i,db=1;
int Digitslots;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//----
   double minlot=MarketInfo(Symbol(),MODE_MINLOT);
   if(minlot==0.001) Digitslots=3;
   if(minlot==0.01) Digitslots=2;
   if(minlot==0.1) Digitslots=1;

   if(MarketInfo(Symbol(),MODE_DIGITS)==5 || MarketInfo(Symbol(),MODE_DIGITS)==3)
     {
      Print("五位小数平台.");
      db=10;
     }
   else   Print("四位小数平台.");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Comment("");
//----
   return;
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void OnTick()
  {
//----
   int buys=0,sells=0,signal=0;
   int result=0;
   double LastBuyPrice=0,LastSellPrice=0,SLp=0,TPp=0;
   double top=0,tol=0,avp=0;
//----统计
   for(i=0; i<=OrdersTotal()-1; i++)
     {
      result=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
        {
         if(OrderType()==OP_BUY)
           {
            buys++;
            LastBuyPrice=OrderOpenPrice();
            tol=tol+OrderLots();
            top=top+OrderLots()*OrderOpenPrice();
            if(SLp==0 && SL>0) SLp=OrderOpenPrice()-SL*db*Point;
           }
         if(OrderType()==OP_SELL)
           {
            sells++;
            LastSellPrice=OrderOpenPrice();
            tol=tol+OrderLots();
            top=top+OrderLots()*OrderOpenPrice();
            if(SLp==0 && SL>0) SLp=OrderOpenPrice()+SL*db*Point;
           }
        }
     }
   if(tol>0)
     {
      avp=NormalizeDouble(top/tol,Digits);
      if(buys>0) TPp=avp+TP*db*Point;
      if(sells>0) TPp=avp-TP*db*Point;
     }
//----显示信息---
   int ti;
   if(buys>0) ti=buys;
   else ti=sells;
   string dsy="\nWinKey\n";
   dsy=dsy+"===================\n";
   dsy=dsy+"P.Lots             ="+DoubleToStr(NormalizeDouble(lots,Digitslots),Digitslots)    +"\n";
   dsy=dsy+"P.SL               ="+IntegerToString(SL)    +"\n";
   dsy=dsy+"P.TP              ="+IntegerToString(TP)    +"\n";
   dsy=dsy+"P.MAGIC       ="+IntegerToString(Magic)    +"\n";
   dsy=dsy+"===================\n";
   dsy=dsy+"B.Numbers      ="+IntegerToString(buys)    +"\n";
   dsy=dsy+"S.Numbers      ="+IntegerToString(sells)   +"\n";
   dsy=dsy+"LastB.Price      ="+DoubleToStr(LastBuyPrice,Digits)  +"\n";
   dsy=dsy+"LastS.Price      ="+DoubleToStr(LastSellPrice,Digits)  +"\n";
   dsy=dsy+"SL.Price          ="+DoubleToStr(SLp,Digits)  +"\n";
   dsy=dsy+"TP.Price         ="+DoubleToStr(TPp,Digits)  +"\n";
   dsy=dsy+"NEXT.Lots      ="+DoubleToStr(NormalizeDouble(Interval_Lots[ti]*lots,Digitslots),Digitslots)    +"\n";
   dsy=dsy+"NEXT.Pips      ="+IntegerToString(Interval_Pips[ti])    +"\n";
   dsy=dsy+"===================\n";
   Comment(dsy);
//----修改订单
   for(i=0; i<=OrdersTotal()-1; i++)
     {
      result=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
        {
         if(OrderType()==OP_BUY)
           {
            if(SLp>0 && DoubleToStr(OrderStopLoss(),Digits)!=DoubleToStr(SLp,Digits))
              {
               result=OrderModify(OrderTicket(),OrderOpenPrice(),SLp,OrderTakeProfit(),0,Green);
               if(result<0) Print("BUY 止损修改出错"+DoubleToStr(OrderStopLoss(),Digits)+"-->"+DoubleToStr(SLp,Digits));
               else return;
              }
            if(TPp>0 && DoubleToStr(OrderTakeProfit(),Digits)!=DoubleToStr(TPp,Digits))
              {
               result=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TPp,0,Green);
               if(result<0) Print("BUY 止盈修改出错"+DoubleToStr(OrderTakeProfit(),Digits)+"-->"+DoubleToStr(TPp,Digits));
               else return;
              }
           }
         if(OrderType()==OP_SELL)
           {
            if(SLp>0 && DoubleToStr(OrderStopLoss(),Digits)!=DoubleToStr(SLp,Digits))
              {
               result=OrderModify(OrderTicket(),OrderOpenPrice(),SLp,OrderTakeProfit(),0,Red);
               if(result<0) Print("SELL 止损修改出错"+DoubleToStr(OrderStopLoss(),Digits)+"-->"+DoubleToStr(SLp,Digits));
               else return;
              }
            if(TPp>0 && DoubleToStr(OrderTakeProfit(),Digits)!=DoubleToStr(TPp,Digits))
              {
               result=OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TPp,0,Red);
               if(result<0) Print("SELL 止盈修改出错"+DoubleToStr(OrderTakeProfit(),Digits)+"-->"+DoubleToStr(TPp,Digits));
               else return;
              }
           }
        }
     }
//--------------------------------------------------
//第一单
   if(buys+sells==0 && IsStop==false)
     {
      signal=signal();
      if(signal==1 && NormalizeDouble(lots*Interval_Lots[buys],Digitslots)<=5)
         result=OrderSend(Symbol(), OP_BUY, NormalizeDouble(lots*Interval_Lots[buys],Digitslots), Ask, slippage*db, 0, 0, comt+"0", Magic, 0, Green);
      if(signal==-1 && NormalizeDouble(lots*Interval_Lots[sells],Digitslots)<=5)
         result=OrderSend(Symbol(), OP_SELL, NormalizeDouble(lots*Interval_Lots[sells],Digitslots), Bid, slippage*db, 0, 0, comt+"0", Magic, 0, Red);
      return;
     }
//----
   if(buys==0 && sells>0 && NormalizeDouble(lots*Interval_Lots[sells],Digitslots)<=5)
     {
      if(Bid-LastSellPrice>=Interval_Pips[sells]*db*Point && TimeCurrent()-Time[0]<60 && SLp-Bid>Interval_Pips[sells]*db*Point)
        {
         result=OrderSend(Symbol(),OP_SELL,NormalizeDouble(lots*Interval_Lots[sells],Digitslots),Bid,slippage*db,0,0,comt+IntegerToString(sells),Magic,0,Red);
         return;
        }
     }
   if(buys>0 && sells==0 && NormalizeDouble(lots*Interval_Lots[buys],Digitslots)<=5)
     {
      if(LastBuyPrice-Ask>=Interval_Pips[buys]*db*Point && TimeCurrent()-Time[0]<60 && Ask-SLp>Interval_Pips[buys]*db*Point)
        {
         result=OrderSend(Symbol(),OP_BUY,NormalizeDouble(lots*Interval_Lots[buys],Digitslots),Ask,slippage*db,0,0,comt+IntegerToString(buys),Magic,0,Green);
         return;
        }
     }
//----
   return;
  }
//+------------------------------------------------------------------+
int signal()
  {
   int res;
   if(Close[1]<Open[1]) res=-1;
   else res=1;
   return(res);
  }
//+------------------------------------------------------------------+