https://www.forexfactory.com/thread/410815-daily-profit-procedure

https://www.forexfactory.com/thread/post/6240084#post6240084


我正在寻找一个程序，mql4，当我达到一个货币对的每日利润限制时，它会告诉我是真是假。我已经尝试了以下代码，但它总是返回 false


bool funcGetTodaysProfit()
{
   int intDailyProfitPips=100;
   double dblReturnValue=0,dblDailyProfitPips=intDailyProfitPips*Point;
   for (int i=0; i<OrdersTotal(); i++)
   {//1 +cycle by orders search
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) break;
      if (OrderSymbol()!=Symbol() continue;
      if (TimeYear(Time[0])!=TimeYear(OrderOpenTime()) &&
          TimeDay(Time[0])!=TimeDay(OrderOpenTime()) &&
          TimeMonth(Time[0])!=TimeMonth(OrderOpenTime()))continue; //not todays profit.
      if (OrderType()==OP_BUY) {dblReturnValue=dblReturnValue+(OrderClosePrice()-OrderOpenPrice());}
      if (OrderType()==OP_SELL) {dblReturnValue=dblReturnValue+(OrderOpenPrice()-OrderClosePrice());}
   }
   Comment("Profit today so far: ",DoubleToStr(dblReturnValue,Digits),"n","Profit target: ",DoubleToStr(dblDailyProfitPips,Digits));
   if (dblReturnValue>dblDailyProfitPips) {return(true);}
   return(false);
}


费鲁，
我明白了。

我添加了这些行：
插入代码
   字符串 strCurrentDate=StringConcatenate(TimeYear(Time[0]),".",TimeMonth(Time[0]),".",TimeDay(Time[0]));
   日期时间 dtCurrentDate=StrToTime(strCurrentDate);
替换了这些行：
插入代码
      if (TimeYear(OrderOpenTime())!=TimeYear(Time[0]) &&
          TimeDay (OrderOpenTime ())! = TimeDay (Time [0]) &&
          TimeMonth(OrderOpenTime())!=TimeMonth(Time[0])) 继续；//不是今天的利润。
有了这条线：
插入代码
      如果 (OrderOpenTime()<dtCurrentDate) 继续；
所有工作都按要求进行！


下面是一个使用包括当前未平仓交易在内的今日总数的示例：

double daily_profit()
{
 double prof=0;
 int trade;
 int trades=OrdersHistoryTotal();
 
for(trade=0;trade<trades;trade++) {
  OrderSelect(trade,SELECT_BY_POS,MODE_HISTORY);  
  if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {   
   if(OrderCloseTime() >= iTime(Symbol(),1440,0)) prof += OrderProfit() + OrderSwap() + OrderCommission(); }}
 
for(trade=0;trade<OrdersTotal();trade++) {
  OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);  
  if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {   
   if(OrderOpenTime() >= iTime(Symbol(),1440,0)) prof += OrderProfit() + OrderSwap() + OrderCommission(); }}
 return(prof);
}
