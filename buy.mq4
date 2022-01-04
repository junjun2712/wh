//+------------------------------------------------------------------+
//|                                                       BetaMT.mq4 |
//|                                          Copyright 2020, Another |
//|                                                 448036253@qq.com |
//|//////////////////////////////////////////////////////////////////|
//|//////////////////////传说中的最终都会爆仓的马丁格尔策略//////////|
//|//////////////////////////////////////////////////////////////////|
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Another"
#property link "448036253@qq.com"
#property version "1.68"
#property strict

//定义本EA操作的订单的唯一标识
#define MAGICMA 20200626

input double BaseLots = 0.01; //基础手数


extern int RSI_Period = 6;
extern int RSI_Price = 5;
extern double RSI_Hi_Level = 80;
extern double RSI_Lo_Level = 20;

// 止盈金额
double TP = 20;
// 开仓间隔
int Delta = 6;

// EA运行的周期
extern int RunPeriod = PERIOD_M15;

extern int BeginH1 = 9;
extern int EndH1 = 23;

// 指标数据结构体
struct Indicator
{
	// KD指标
	double StocMain;
	double StocSignal;
	// KD超买超卖
	bool IsOverBuy;
	bool IsOverSell;

	// 布林通道指标
	double BollUpper;
	double BollLower;
	double BollMain;

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
	string unit = IntegerToString((int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) - 1);
	Comment(StringFormat("KD主要：%." + unit + "f\n" + "KD信号：%." + unit + "f\n", ind.StocMain, ind.StocSignal));
	if (!IsExpertEnabled()) {
		//Print("没有启用EA自动交易，无法开仓平仓");
		return;
	}

	// 统计仓位
	Counter counter = CalcTotal();

	// 平仓检查
	CheckForClose(ind, counter);

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
	// STO指标
	ind.StocMain = iStochastic(_Symbol, RunPeriod, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
	ind.StocSignal = iStochastic(_Symbol, RunPeriod, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);
	ind.IsOverBuy = (ind.StocMain >= 80 && ind.StocSignal >= 80);
	ind.IsOverSell = (ind.StocMain <= 20 && ind.StocSignal <= 20);

	// 布林通道指标
	ind.BollUpper = iBands(_Symbol, RunPeriod, 100, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
	ind.BollLower = iBands(_Symbol, RunPeriod, 100, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
	ind.BollMain = iBands(_Symbol, RunPeriod, 100, 2, 0, PRICE_CLOSE, MODE_MAIN, 1);
	
	double RSI_1 = iRSI( Symbol(), Period(), RSI_Period, RSI_Price, 1);
   double RSI_2 = iRSI( Symbol(), Period(), RSI_Period, RSI_Price, 2);

	// 买卖信号
	//ind.IsBuySignal = ind.IsOverSell && Close[1] < ind.BollMain;
	//ind.IsSellSignal = ind.IsOverBuy && Close[1] > ind.BollMain;

   //ind.IsBuySignal = ind.IsOverSell && Close[1] < ind.BollLower;
	//ind.IsSellSignal = ind.IsOverBuy && Close[1] > ind.BollUpper;
	
	//ind.IsBuySignal = ind.IsOverSell && Close[1] < ind.BollLower && ind.StocMain < ind.StocSignal && Hour()> BeginH1 && Hour()< EndH1;
	//ind.IsSellSignal = ind.IsOverBuy && Close[1] > ind.BollUpper && ind.StocMain > ind.StocSignal && Hour()> BeginH1 && Hour()< EndH1;
	
	//ind.IsBuySignal = RS < RSI_Lo_Level && RSI_1 > RSI_2 &&  Hour() > BeginH1 && Hour() < EndH1;
	//ind.IsSellSignal =  RSI_1 > RSI_Hi_Level && RSI_1 < RSI_2  &&  Hour() > BeginH1 && Hour() < EndH1;
	
	ind.IsBuySignal = RSI_Lo_Level < ind.BollLower && RSI_1 > RSI_2;
	ind.IsSellSignal =  RSI_Hi_Level > ind.BollUpper && RSI_1 < RSI_2;
	
	//ind.IsBuySignal = RSI_Lo_Level < ind.BollLower &&  Hour() > BeginH1 && Hour() < EndH1;
	//ind.IsSellSignal = RSI_Hi_Level > ind.BollUpper &&  Hour() > BeginH1 && Hour() < EndH1;
	return ind;
}

//+------------------------------------------------------------------+
//| 开仓                                                             |
//+------------------------------------------------------------------+
void CheckForOpen(const Indicator & ind, const Counter & counter) 
{
	// KD超买,K价在布林通道上方：开空
	if (ind.IsSellSignal) 
	{
		if (counter.SellTotal == 0)
		    OpenSell(BaseLots);
		else if (counter.SellTotal > 0 && counter.BarsDelta >= Delta) // 开仓至少间隔
		   OpenSell(counter.LastSellLots * 1.618);
	}

	// KD超卖,K价在布林通道下方：开多
	else if (ind.IsBuySignal) 
	{
		if (counter.BuyTotal == 0)
		    OpenBuy(BaseLots);
		else if (counter.BuyTotal > 0 && counter.BarsDelta >= Delta) // 开仓至少间隔
			OpenBuy(counter.LastBuyLots * 1.618);
	}
}

//+------------------------------------------------------------------+
//| 平仓                                                             |
//+------------------------------------------------------------------+
void CheckForClose(const Indicator & ind, const Counter & counter) 
{

	if (
		counter.BuyProfit >= TP // 止盈
		|| (ind.IsSellSignal && counter.BuyProfit > 1) // 或 (反向信号 & 且盈利)
		|| (counter.BuyTotal > 1 && counter.BuyProfit > TP/counter.BuyTotal) // 或 (持仓>1 & 且盈利)->降低止盈加大盈率
		|| (counter.BuyTotal >= 2 && counter.BuyProfit >=1) // 或 (持仓>3 & 平保)
	)CloseBuy();
	
	if (
		counter.SellProfit >= TP // 止盈
		|| (ind.IsBuySignal && counter.SellProfit > 1) // 或 (反向信号 & 且盈利)
		|| (counter.SellTotal > 1 && counter.SellProfit > TP/counter.SellTotal) // 或 (持仓>1 & 且盈利)
		|| (counter.SellTotal >= 2 && counter.SellProfit >=1) // 或 (持仓>3 & 平保)
	)CloseSell();
	
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
