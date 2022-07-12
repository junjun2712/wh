//+------------------------------------------------------------------+
//|                                            1-4H-ema+5min-sto.mq4 |
//|                                          Copyright 2022, Another |
//|                                                 182265304@qq.com |
//|//////////////////////////////////////////////////////////////////|
//|//////////////////////////////////////////////////////////////////|
//|//////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Another"
#property link "182265304@qq.com"
#property version "1.0"
#property strict

//定义本EA操作的订单的唯一标识
#define MAGICMA 20200626
input double BaseLots = 0.01; //基础手数
input double CloseAtProfit= 1; //盈利金额
input int jz = 50; //净值
input int Limit = 3; //订单数量
extern int RunPeriod = PERIOD_M5; // EA运行的周期
double TP = 2; // 止盈金额
double SL = 1; // 止损金额
int Delta = 1;// 开仓间隔
extern int BeginH1 = 14; //开始时间
extern int EndH1 = 12; //结束时间




extern int RSI_Period = 14;
extern int RSI_Price = 5;
extern double RSI_Hi_Level = 75;
extern double RSI_Lo_Level = 25;


// 指标数据结构体
struct Indicator
{
	// KD指标
	double StocMain;
	double StocSignal;
	// KD超买超卖
	bool IsOverBuy;
	bool IsOverSell;

   double Ema1_30;
	double Ema10_30;
	double Ema20_30;
	double Ema50_30;
   double Ema60_30;
   double Ema200_30;
   
   double preHeiken0; 
   double preHeiken1; 
   double preHeiken2; 
   double preHeiken3; 

   double currHeiken0;
   double currHeiken1;
   double currHeiken2;
   double currHeiken3;
   
   double fdup;
   double fddown;
   
   double dcup;
   double dcdown;
	// 买多信号
	bool IsBuySignal;

	// 卖空信号
	bool IsSellSignal;
};

// 订单统计
struct Counter
{
	int BuyTotal; // 多单计数
	int SellTotal; // 空单计数
	double PointTotal; // 获利点数
	double ProfitTotal; // 获利金额
	double BuyProfit; // 多单获利金额
	double SellProfit; // 空单获利金额
	double LastSellLots; // 最后一笔空单手数量
	double LastBuyLots; // 最后一笔多单手数量
	int BarsDelta; // 最近一笔订单与当前时间的间隔
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() 
{
	return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() 
{
	// 指标计算
	Indicator ind = CalcInd();
	// 小数点位计算
	//string unit = IntegerToString((int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) - 1);
	//Comment(StringFormat("KD主要：%." + unit + "f\n" + "KD信号：%." + unit + "f\n", ind.StocMain, ind.StocSignal));
	if (!IsExpertEnabled()) {
		//Print("没有启用EA自动交易，无法开仓平仓");
		return;
	}
	
	// 遍历订单，统计盈利
   double totalProfit = SumProfit();
   Print("DEBUG=>统计利润=[",totalProfit,"]，设定退出利润=[",CloseAtProfit,"]");
   
   
   
   if(totalProfit > CloseAtProfit)
   //if(OrdersTotal() >= 5 && totalProfit > 10)
   {      
      CloseAllOrder();
     
     
      
      
      //Alert("EA is Expired. Please contact EA programmer!");
      //ExpertRemove();
      //return;
   } 
   
   
   
   if(OrdersTotal() >= Limit && totalProfit > 0)
   //if(AccountEquity()< 200 )
   {      
      CloseAllOrder();
      //Alert("EA is Expired. Please contact EA programmer!");
     //ExpertRemove();
     //return;
   }   
   
   if(OrdersTotal() >= Limit)
   //if(AccountEquity()< 200 )
   {  
      SendNotification("OrdersTotal max "+Symbol()+"");    
      //CloseAllOrder();
      //Alert("EA is Expired. Please contact EA programmer!");
    // ExpertRemove();
    // return;
   }   
   
   //订单>= 3退出EA
   if(AccountEquity()< jz )
   {    
     SendNotification("jz "+Symbol()+"");  
     // CloseAllOrder();
   //   Alert("EA is Expired. Please contact EA programmer!");
      //ExpertRemove();
      //return;
   }  
   
   
   	// 统计仓位
	Counter counter = CalcTotal();

	// 平仓检查
	//CheckForClose(ind, counter);

	// 开仓检查
	CheckForOpen(ind, counter);

}

//////////////////////////////////////////////////////////////////////
/////////////////// 自定义函数区 /////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//+------------------------------------------------------------------+
//| 指标计算                                                         |
//+------------------------------------------------------------------+
Indicator CalcInd() 
{
	Indicator ind = {};
	
	ind.StocMain = iStochastic(_Symbol, RunPeriod, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
	ind.StocSignal = iStochastic(_Symbol, RunPeriod, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);
	ind.IsOverBuy = (ind.StocMain > ind.StocSignal);
	ind.IsOverSell = ( ind.StocMain < ind.StocSignal);
	
	double RSI_1 = iRSI( Symbol(), Period(), RSI_Period, RSI_Price, 1);
   double RSI_2 = iRSI( Symbol(), Period(), RSI_Period, RSI_Price, 2);
	
	// Heiken指标
	ind.preHeiken0 = iCustom(NULL,0, "Heiken Ashi",1,20,0,2);
   ind.preHeiken1 = iCustom(NULL,0, "Heiken Ashi",1,20,1,2);
   ind.preHeiken2 = iCustom(NULL,60, "Heiken Ashi",1,20,0,2);
   ind.preHeiken3 = iCustom(NULL,60, "Heiken Ashi",1,20,1,2);

   ind.currHeiken0 = iCustom(NULL,0, "Heiken Ashi",1,20,0,1);
   ind.currHeiken1 = iCustom(NULL,0, "Heiken Ashi",1,20,1,1);
   ind.currHeiken2 = iCustom(NULL,60, "Heiken Ashi",1,20,0,1);
   ind.currHeiken3 = iCustom(NULL,60, "Heiken Ashi",1,20,1,1);
   
   ind.Ema1_30 = iMA(NULL,60,3,0,MODE_EMA,PRICE_CLOSE,0);
   ind.Ema20_30 = iMA(NULL,60,10,0,MODE_EMA,PRICE_CLOSE,0);
   ind.Ema60_30 = iMA(NULL,240,3,0,MODE_EMA,PRICE_CLOSE,0);
   ind.Ema200_30 = iMA(NULL,240,10,0,MODE_EMA,PRICE_CLOSE,0);
   ind.fdup = ind.Ema60_30 - ind.Ema200_30;
   ind.fddown = ind.Ema200_30 - ind.Ema60_30;
   ind.dcup = Close[1] - Close[2];
   ind.dcdown = Close[2] - Close[1];

	// 买信号
	//ind.IsBuySignal = ind.preHeiken0 < ind.preHeiken1 && ind.currHeiken0 > ind.currHeiken1;
	//ind.IsBuySignal = ind.preHeiken0 < ind.preHeiken1 && ind.Ema1_30 > ind.Ema10_30 && ind.fdup > 2 && ind.dcup >1;
	//ind.IsBuySignal = ind.Ema1_30 > ind.Ema20_30 && ind.Ema60_30 > ind.Ema200_30 && ind.IsOverBuy && Close[1] > Close[2];// && Hour()<EndH1;
	ind.IsBuySignal = RSI_1 > RSI_2 && RSI_1 < RSI_Lo_Level && RSI_2 < RSI_Lo_Level && Close[1] > Close[2] && ind.preHeiken0 > ind.preHeiken1 && Hour()<EndH1;
	//ind.IsBuySignal = Close[1] < ind.Ema20_30  && Close[1] < Close[2] && ind.preHeiken0 > ind.preHeiken1 && ind.IsOverSell;
	//ind.IsBuySignal = ind.preHeiken0 < ind.preHeiken1 && ind.Ema1_30 > ind.Ema10_30 && Close[1] > Close[2] && Hour()> BeginH1;
	// 卖信号
	//ind.IsSellSignal = ind.preHeiken0 > ind.preHeiken1 && ind.currHeiken0 < ind.currHeiken1;
	//ind.IsSellSignal = ind.preHeiken0 > ind.preHeiken1 && ind.Ema1_30 < ind.Ema10_30 && ind.fddown > 2 && ind.dcdown >1;
   //ind.IsSellSignal = ind.preHeiken0 > ind.preHeiken1  && ind.Ema1_30 < ind.Ema10_30  && Close[1] < Close[2] && Hour()> BeginH1;
   //ind.IsSellSignal = ind.Ema1_30 < ind.Ema20_30 && ind.Ema60_30 < ind.Ema200_30  && ind.IsOverSell && Close[1] < Close[2];// && Hour()< EndH1;
   ind.IsSellSignal = RSI_1 < RSI_2 && RSI_1 > RSI_Hi_Level  && RSI_2 > RSI_Hi_Level  && Close[1] < Close[2] && ind.preHeiken0 < ind.preHeiken1 && Hour()<EndH1;
   //ind.IsSellSignal = Close[1] > ind.Ema20_30 && Close[1] > Close[2] && ind.preHeiken0 < ind.preHeiken1 && ind.IsOverBuy;
   
	return ind;
}

//+------------------------------------------------------------------+
//| 开仓                                                             |
//+------------------------------------------------------------------+
void CheckForOpen(const Indicator & ind, const Counter & counter) 
{
	double lsdd = lsdingdan();
   Print("DEBUG=>历史订单=[",lsdd,"]");
   //Print("jy=[",jy,"]");
	// KD超卖,K价在布林通道下方：开多
	if (ind.IsBuySignal && lsdd < 1 && OrdersTotal() <= Limit) 
	//if(ind.Ema1_30 > ind.Ema200_30 && ind.StocMain > 50)
	//if (ind.IsBuySignal) 
	{
		if (NewBar()) OpenBuy(BaseLots);
		//if (NewBar()) OpenSell_one(BaseLots);
	
	   //if (NewBar()) OpenSell(BaseLots);
		//if (counter.SellTotal == 0)
		//    OpenBuy(BaseLots);
		//else if (counter.BuyTotal > 2) // 开仓至少间隔
		  // OpenBuy(BaseLots);
		  //return;
	  //if (counter.BuyTotal < 3)
	      //if (NewBar()) OpenBuy(BaseLots);
		
	}
	else if (ind.IsSellSignal && lsdd < 1 && OrdersTotal() <= Limit)
	//else if(ind.Ema1_30 < ind.Ema200_30 && ind.StocMain < 50)
	//else if (ind.IsSellSignal)  
	{
		if (NewBar()) OpenSell(BaseLots);
		//if (NewBar()) OpenBuy_one(BaseLots);
		//if (NewBar()) OpenBuy(BaseLots);
		//if (counter.SellTotal == 0)
		//    OpenSell(BaseLots);
		//else if (counter.SellTotal > 2) // 开仓至少间隔
		 //  OpenSell(BaseLots);
		//return;
		//if (counter.SellTotal)
	      //if (NewBar()) OpenSell(BaseLots);
	}
}

/+------------------------------------------------------------------+
//| 下单间隔                                                         |
//+------------------------------------------------------------------+
bool NewBar()
{
   static datetime dt = 0;
   if (dt != Time[0])
   {
      dt = Time[0]; Sleep(100); // wait for tick
      return(true);
   }
   return(false);
}

//+------------------------------------------------------------------+
//| 历史订单                                                            |
//+------------------------------------------------------------------+
bool lsdingdan() {
bool res=false;
for(int i=OrdersHistoryTotal();i>=0;i--){
 if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==true){
 if(iBarShift(NULL,PERIOD_D1,OrderOpenTime())==0){
res=true;
    }
  }
 }
return(res);
}
//+------------------------------------------------------------------+
//| 平仓                                                             |
//+------------------------------------------------------------------+
void CheckForClose(const Indicator & ind, const Counter & counter) 
{
   
   //if(OrdersTotal() >= 10 && OrdersTotal() <= 20 &&ind.Ema1_30 > ind.Ema200_30 && ind.StocMain > 50)
   //if(OrdersTotal() >= 10  && ind.preHeiken2 < ind.preHeiken3 )
   //if(AccountEquity()< 200 && ind.IsBuySignal )
   
   if(counter.SellTotal >= 1 && ind.IsOverBuy && ind.Ema1_30 > ind.Ema20_30 && ind.Ema60_30 > ind.Ema200_30)
   
   //if(ind.Ema20_30 < ind.Ema60_30)
   {   
      //CloseBuy();
     
      
		if (NewBar()) OpenBuy(BaseLots*2);
	
	   //if (NewBar()) OpenSell(BaseLots);
		//if (counter.SellTotal == 0)
		//    OpenBuy(BaseLots);
		//else if (counter.BuyTotal > 2) // 开仓至少间隔
		  // OpenBuy(BaseLots);
		  //return;
	  //if (counter.BuyTotal < 3)
	      //if (NewBar()) OpenBuy(BaseLots);
		
	
      
   }   
   if(counter.BuyTotal >= 1 && ind.IsOverSell && ind.Ema1_30 < ind.Ema20_30 && ind.Ema60_30 > ind.Ema200_30)
   //if(ind.Ema20_30 > ind.Ema60_30)
   //if(OrdersTotal() >= 10 && ind.preHeiken2 > ind.preHeiken3)
   //if(AccountEquity()< 200 && ind.IsSellSignal )
   {      
      
     if (NewBar()) OpenSell(BaseLots*2);
   } 
}  
	

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenBuy(double lots) 
{
	if (!OrderSend(_Symbol, OP_BUY, lots, Ask, 0, 0, 0, "MT", MAGICMA, 0, clrBlue))
		Print("开仓出错", GetLastError());
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSell(double lots) 
{
	if (!OrderSend(_Symbol, OP_SELL, lots, Bid, 0, 0, 0, "MT", MAGICMA, 0, clrRed))
		Print("开仓出错", GetLastError());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenBuy_one(double lots) 
{
	if (!OrderSend(_Symbol, OP_BUY, lots, Ask, 0,  Ask-SL, Ask+TP, "MT", MAGICMA, 0, clrBlue))
		Print("开仓出错", GetLastError());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenSell_one(double lots) 
{
	if (!OrderSend(_Symbol, OP_SELL, lots, Bid, 0, Bid+SL, Bid-TP, "MT", MAGICMA, 0, clrRed))
		Print("开仓出错", GetLastError());
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 统计盈利
//+------------------------------------------------------------------+
double SumProfit()
{
   double sum = 0;
   // 遍历订单，关闭全部
   for(int i=0;i<OrdersTotal();i++)
   {      
      // 选中仓单，选择不成功时，跳过本次循环
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      {
         Print("统计盈利=>注意！选中仓单失败！序号=[",i,"]");
         continue;
      }
      sum += OrderProfit();
    }
    return sum;
}




//+------------------------------------------------------------------+
//| 平仓，关闭所有订单
//+------------------------------------------------------------------+
void CloseAllOrder()
{
   // 遍历订单，关闭全部
   
   
   for(int i=0;i<OrdersTotal();i++)
   {      
      // 选中仓单，选择不成功时，跳过本次循环
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      {
         Print("自动平仓=>注意！选中仓单失败！序号=[",i,"]");
         continue;
      }
      //如果 仓单编号不是本系统编号，或者 仓单货币对不是当前货币对时，跳过本次循环
      /*if(OrderMagicNumber() != MAGICMA || OrderSymbol()!= _Symbol)
      { 
         Print("注意！订单魔术标记不符！仓单魔术编号=[",OrderMagicNumber(),"]","本EA魔术编号=[",MAGICMA,"]");
         continue;
      }*/
      Print("自动平仓=>处理订单ticket=[",OrderTicket(),"],品种=[",OrderSymbol(),"],手数=[",OrderLots(),"]");
      // 多单平仓：
      if(OrderType()==OP_BUY)
      {
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,2,White)) Print("自动平仓=>关闭[多]单出错",GetLastError());
         continue;
      }
      // 空单平仓：
      if(OrderType()==OP_SELL)
      {
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White)) Print("自动平仓=>关闭[空]单出错",GetLastError());
         continue;
      }
      // 挂单平仓：
      if((OrderType()==OP_BUYLIMIT)||(OrderType()==OP_BUYSTOP)||(OrderType()==OP_SELLLIMIT)||(OrderType()==OP_SELLSTOP)) 
      {
          OrderDelete(OrderTicket()); 
          
      }
   }
}

//+------------------------------------------------------------------+
//| 统计订单数量                                                     |
//+------------------------------------------------------------------+
Counter CalcTotal() 
{
	Counter counter = {};
	int ticket = 0;
	for (int i = 0; i < OrdersTotal(); i++) 
	{
		//如果 仓单编号不符合，或者 选中仓单失败，跳过
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES) || OrderMagicNumber() != MAGICMA)
			continue;

		//统计利润
		counter.ProfitTotal += OrderProfit();

		// 下单时间间隔的K线数量：秒转分转周期
		int diff = (int)((TimeCurrent() - OrderOpenTime()) / 60 / RunPeriod);
		// 最新的订单id最大
		if (OrderTicket() > ticket)
			counter.BarsDelta = diff;

		//多单
		if (OrderType() == OP_BUY) 
		{
			// 计数
			counter.BuyTotal++;
			// 计利润点数
			counter.PointTotal += MathPow(10, _Digits) * (Bid - OrderOpenPrice()) / 10;
			counter.BuyProfit += OrderProfit();
			if (OrderLots() > counter.LastBuyLots)
				counter.LastBuyLots = OrderLots();
		}
		//空单
		else if (OrderType() == OP_SELL)
		{
			// 计数
			counter.SellTotal++;
			// 计利润点数
			counter.PointTotal += MathPow(10, _Digits) * (OrderOpenPrice() - Ask) / 10;
			counter.SellProfit += OrderProfit();
			if (OrderLots() > counter.LastSellLots)
				counter.LastSellLots = OrderLots();
		}
	}
	return counter;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuy() 
{
    int total = OrdersTotal();
	while(total>0)
	{
		// 如果 选中仓单失败（优先判断，以获取到订单），或者仓单编号不符合 ，跳过
		if (!OrderSelect(0, SELECT_BY_POS, MODE_TRADES) || OrderMagicNumber() != MAGICMA)
		{
			continue;
		}
		total--;
		//多单
		if (OrderType() == OP_BUY)
		{			
			if (!OrderClose(OrderTicket(), OrderLots(), Bid, 0, White)) Print("多单平仓出错", GetLastError());
		}
	}
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseSell() 
{
    int total = OrdersTotal();
	while(total>0)
	{
		// 如果 选中仓单失败（优先判断，以获取到订单），或者仓单编号不符合 ，跳过
		if (!OrderSelect(0, SELECT_BY_POS, MODE_TRADES) || OrderMagicNumber() != MAGICMA)
		{
			continue;		
		}
		total--;
		//空单
		if (OrderType() == OP_SELL)
		{
			if (!OrderClose(OrderTicket(), OrderLots(), Ask, 0, White)) Print("空单平仓出错", GetLastError());
		}		
	}
}


