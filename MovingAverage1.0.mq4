//+------------------------------------------------------------------+
//|                                                MovingAverage.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input int    MagicNumber   = 215484;
input int    TakeProfit    = 400;
input int    StopLoss      = 200;
input int    TrailingStop  = 0;
input int    MA_PERIOD     = 50;
input double Lots          = 0.01;

int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---   
   if (TrailingStop != 0) Trail();
   
   int TotalBuyOrders  = TotalOrders(OP_BUY);
   int TotalSellOrders = TotalOrders(OP_SELL);
   
   if(Close[1] > MA(1) && TotalBuyOrders == 0) {      
      OrderSend(Symbol(),OP_BUY,Lots,Ask,0,Ask-StopLoss*Point,Ask+TakeProfit*Point,NULL,MagicNumber,0,CLR_NONE);
   }
   
   if(Close[1] < MA(1) && TotalSellOrders == 0) {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,0,Bid+StopLoss*Point,Bid-TakeProfit*Point,NULL,MagicNumber,0,CLR_NONE);
   }   
  }
//+------------------------------------------------------------------+

double MA(int shift) {
   return iMA(Symbol(), 0, MA_PERIOD, 0, MODE_SMA, PRICE_CLOSE, shift);
}

int TotalOrders(int orderType) {

   int counting = 0;
   
   for(int i=0; i<OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == orderType) {
         counting++;
      }
   }
   
   return counting;
}


void Trail() {

   if(TrailingStop == 0) return;
   
   for(int i=0; i<OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);      
      if((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderMagicNumber() == MagicNumber ) {
         if(OrderType() == OP_BUY) {
            if(OrderStopLoss() < Bid-TrailingStop*Point) {
               OrderModify(OrderTicket(), OrderOpenPrice(), Bid-TrailingStop*Point, OrderTakeProfit(), OrderExpiration(), CLR_NONE);
            }
         } else if(OrderType() == OP_SELL) {            
            if(OrderStopLoss() > Ask+TrailingStop*Point) {
               OrderModify(OrderTicket(), OrderOpenPrice(), Ask+TrailingStop*Point, OrderTakeProfit(), OrderExpiration(), CLR_NONE);
            }
         }
      }
   }
}
