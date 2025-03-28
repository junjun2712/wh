//+------------------------------------------------------------------+
//|                                              Improve grid EA.mq4 |
//|                                                          Ondrejj |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Ondrejj"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs

//-- enums
enum onoff {off = 0, on = 1};

//-- global variables
bool resultModify;
int error, resultSend;
double atrValue, maFastValue, maSlowValue, macdFastValue, macdSlowValue, macdFastValue1, macdSlowValue1, lots;
double accBalance, lotSize, tickValue, maxLot, minLot;
double pipsRisk, tradeRiskPips, tradeRiskDollar, tradeRiskQuoteCurrency, optimalLotSize;
double buyChannelPrice, sellChannelPrice, slChannelPrice;
double lastOpenPrice, lastTpPrice, lastLots;
double openPrice, slPrice, tpPrice, slippage;
double currentAsk, currentBid, pipsOpenPrice, pipsSlPrice;

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input int magicNumber = 2021;

input string runSymbol = "EUR_USD";
input ENUM_TIMEFRAMES runTimeframe = PERIOD_M5;

input double maxSpreadPips = 1;
input double maxSlippagePips = 0.5;

input onoff useMM = 1;
input double riskPercentage = 1;
input double fixedLot = 1;

input datetime runFromHour = 01;
input datetime runFromMinute = 00;
input datetime runToHour = 22;
input datetime runToMinute = 00;

input int atrPeriod = 14;
input int atrShift = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
      if (!IsTradeAllowed()) Print ("Turn on algorithmic trading");
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
//--

   //-- getting market information
   accBalance = AccountBalance();
   lotSize = MarketInfo (Symbol(), MODE_LOTSIZE);
   tickValue = MarketInfo (Symbol(), MODE_TICKVALUE);
      if (_Digits <= 3) tickValue = tickValue / 100;
   maxLot = MarketInfo (Symbol(), MODE_MAXLOT);
   minLot = MarketInfo (Symbol(), MODE_MINLOT);   
  
   //-- reading indicator values
   atrValue = iATR (Symbol(), runTimeframe, atrPeriod, atrShift);
   atrValue = atrValue / 2;
   
//-- LONG
  
   //-- defining channels
   if (OrdersTotal() <= 0)
      {
   if (NormalizeDouble(atrValue, _Digits) > NormalizeDouble(5 * MarketInfo (Symbol(), MODE_SPREAD) * GetTickValue(), _Digits) && useMM == 1) 
      {
         currentAsk = Ask;
         currentBid = Bid;
         buyChannelPrice = currentAsk + atrValue;
         slChannelPrice = currentBid - atrValue;
      }
   else 
      {
         currentAsk = Ask;
         currentBid = Bid;
         buyChannelPrice = currentAsk + 5 * MarketInfo (Symbol(), MODE_SPREAD) * GetTickValue();
         slChannelPrice = currentBid - 5 * MarketInfo (Symbol(), MODE_SPREAD) * GetTickValue();
      } 
      }
   pipsOpenPrice = NormalizeDouble(MathAbs (buyChannelPrice - currentAsk), _Digits);
   pipsSlPrice = NormalizeDouble(MathAbs (currentBid - slChannelPrice), _Digits);              
   pipsRisk = NormalizeDouble(MathAbs (buyChannelPrice - slChannelPrice), _Digits);   
         
   //-- sending order   
   if (OrdersTotal() == 0 && MarketInfo (Symbol(), MODE_SPREAD) < maxSpreadPips * 10 && TradingTime())
      {                     
         openPrice = NormalizeDouble(buyChannelPrice, _Digits);
         slPrice = NormalizeDouble(slChannelPrice, _Digits);
         tpPrice = 0;
         slippage = maxSlippagePips * 10;
         lots = Lots (); 
               
         resultSend = OrderSend (Symbol(), OP_BUYSTOP, lots, openPrice, slippage, slPrice, tpPrice, NULL, magicNumber, 0, clrNONE);
         if (resultSend < 0) Print ("Sending order error: " + DoubleToString (GetLastError(), 0));
      }  
             
   //-- modifying pending order
   if (OrdersTotal() == 1)
      {
         if (OrderSelect (OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES))
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && (OrderType() == OP_BUYSTOP || OrderType() == OP_BUY))
               if (OrderOpenPrice() >= Ask + pipsOpenPrice)
                  {
                     openPrice = Ask + pipsOpenPrice;
                     
                     resultModify = OrderModify (OrderTicket(), openPrice, OrderStopLoss(), 0, 0, clrNONE);
                     if (!resultModify) Print ("Modifying order error: " + DoubleToString (GetLastError(), 0));
                  }
               if (OrderStopLoss() >= Bid - pipsSlPrice && OrderStopLoss() >= OrderOpenPrice() - pipsRisk && OrderStopLoss() != OrderOpenPrice())
                  {
                     slPrice = Bid - pipsSlPrice; 
                           
                     resultModify = OrderModify (OrderTicket(), OrderOpenPrice(), slPrice, 0, 0, clrNONE);
                     if (!resultModify) Print ("Modifying order error: " + DoubleToString (GetLastError(), 0));                                                                             
                  }
               if (Bid >= OrderOpenPrice() + (pipsRisk / 2))
                  {
                     slPrice = OrderOpenPrice(); 
                           
                     resultModify = OrderModify (OrderTicket(), OrderOpenPrice(), slPrice, 0, 0, clrNONE);
                     if (!resultModify) Print ("Modifying order error: " + DoubleToString (GetLastError(), 0));                     
                  }      
      }      
      
   //-- sending following orders   
   if (OrdersTotal() > 0)
      {
         if (OrderSelect (OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && (OrderType() == OP_BUYSTOP || OrderType() == OP_BUY))
            lastOpenPrice = OrderOpenPrice();
            lastLots = OrderLots();
                  
         if (Ask >= lastOpenPrice + pipsRisk)
            {  
               slippage = maxSlippagePips * 10;
               slPrice = lastOpenPrice;
               tpPrice = 0;
               lots = Lots ();
                     
               resultSend = OrderSend (Symbol(), OP_BUY, lots, Ask, slippage, slPrice, tpPrice, NULL, magicNumber, 0, clrNONE);
                     
               if (!resultSend) Print (GetLastError()); 
            }               
      }
      
    //-- modyfing stop loss
    if (OrdersTotal() > 1)
      {
         if (OrderSelect (OrdersTotal() - 2, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && (OrderType() == OP_BUYSTOP || OrderType() == OP_BUY))
            lastOpenPrice = OrderOpenPrice();
                  
         for (int i = OrdersTotal() - 1; i >= 0; i--)
            {
               if (OrderSelect (i, SELECT_BY_POS, MODE_TRADES))
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
                                    
                  resultModify = OrderModify (OrderTicket(), OrderOpenPrice(), lastOpenPrice, OrderTakeProfit(), 0, clrNONE);
                  if (!resultModify) Print ("Modifying order error" + DoubleToString (GetLastError(), 0));                   
            }               
      } 
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom Functions                                                 |
//+------------------------------------------------------------------+

//-- getting pip value
double GetPipValue ()
   {
      if (_Digits >= 4) {return 0.0001;}
      else if (_Digits <= 3) {return 0.01;}
      else return (0);
   }

//-- getting tick value   
double GetTickValue ()
   {
      if (_Digits >= 4) {return 0.00001;}
      else if (_Digits <= 3) {return 0.001;}
      else return (0);
   }
   
//-- counting volume
double Lots ()
   {
      double lastOptimalLotSize;
      
      if (useMM == 0)
         {
            if (OrdersTotal() == 0)
               { 
                  optimalLotSize = fixedLot;
                  
                  return (NormalizeDouble (optimalLotSize, 2));                  
               }   
            else if (OrdersTotal() > 0)
              {
                  if (OrderSelect (OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES))
                     {  
                        lastOptimalLotSize = OrderLots();
                        
                        optimalLotSize = lastOptimalLotSize * 0.5;
                        
                        optimalLotSize = MathMin (optimalLotSize, maxLot);
                        optimalLotSize = MathMax (optimalLotSize, minLot);
                        
                        return (NormalizeDouble (optimalLotSize, 2));                        
                     } 
              }
         }
                      
     if (useMM == 1)
         {  
            if (OrdersTotal() == 0)
               {
            tradeRiskPips = pipsRisk / GetPipValue();
            tradeRiskDollar = accBalance * (riskPercentage / 100);
            tradeRiskQuoteCurrency = tradeRiskDollar / tickValue;
      
            optimalLotSize = tradeRiskQuoteCurrency / (tradeRiskPips * GetPipValue()) / lotSize;
            
            return (NormalizeDouble (optimalLotSize, 2));            
               }
            else if (OrdersTotal() > 0)
               {  
                  if (OrderSelect (OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES))
                     {  
                        lastOptimalLotSize = OrderLots();
                        
                        optimalLotSize = lastOptimalLotSize * 0.5;
                        
                        optimalLotSize = MathMin (optimalLotSize, maxLot);
                        optimalLotSize = MathMax (optimalLotSize, minLot);
                        
                        return (NormalizeDouble (optimalLotSize, 2));                        
                     }                     
               }                    
         }
         
         return (0);          
   }

//-- setting trading time   
bool TradingTime ()
{
   bool go = false;

   if (((TimeHour(TimeLocal()) == runFromHour && TimeMinute(TimeLocal()) >= runFromMinute)
      || (TimeHour(TimeLocal()) > runFromHour)) && ((TimeHour(TimeLocal()) < runToHour) || 
      (TimeHour(TimeLocal()) == runToHour && TimeMinute(TimeLocal()) < runToMinute))) 
      {
         go = true;
      }
      
   else 
      {
         go = false;
      }   
   
   return (go);
}        