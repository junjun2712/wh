# wh

https://www.eahub.cn/thread-14706-1-1.html

https://www.eahub.cn/thread-10355-1-1.html

https://www.daily-ea.com/ea-myfxbook.php

www.jisilu.cn

https://www.ninwin.c


TUQ19x6jXcyxMRmQQsee19wxr6eQ75VTXC

此剥头皮系统基于 EMA 指标。

时间范围：1分钟；

货币对：所有货币对

指标：

短期
3 EMA（绿色）
5 EMA（绿色）
8 EMA（绿色）
10 EMA（绿色）
12 EMA（绿色）
15 EMA（黄色）

长期
30 EMA（浅绿色）
35 EMA（红色）
40 EMA（红色）
45 EMA（红色）
50 EMA（红色）
55 EMA（浅绿色）

趋势
200（棕色，虚线）
以上均线多头排列Ema 10 20之上做多 
以上均线空头排列Ema 10 20之下做空

当两组 MMA 分开时，您就有入场信号。您可以通过观察黄色和浅绿色 EMA 之间的间隙来判断何时发生这种情况。

当长期（红色）组已经在短期（绿色）组指示的趋势后一面以完美的顺序排列时，就会给出最佳条件。草率的交叉导致草率的交易。

https://www.fxeye.us/

https://www.eafxtech.com/2699.html


1小时定方向 十日线均线向上买 十日均线向下卖 （隐藏K线只看均线）

5分钟 RSI低于30买 高于70卖

5分钟 120均线临界点买 卖


https://yukifx.web.fc2.com/sub/make/01_root/cone/make_root.html

https://fxprosystems.com/super-trend-profit/

http://www.criss.school/

#指标学习论坛

https://www.forexfactory.com/forum

#指标
JBR_Indicator_System  （判断大方向）
Trade_Confirmed_Indicator （小方向顺大方向买卖）
结合使用

10 和 20 EMA 的高
10 和 20 EMA 的低

RSI
10 周期与RSI 的移动平均线也设置为 10
水平 45 和 55 在 RSI 图表上

系统
20 EMA 就像一个带, 我只在价格收盘时进行交易当 RSI 水平也在 45 到 55 水平之外时。此外，当 RSI 高于 10 MA 时高于 55 水平或低于 MA 低于 45 水平

多头：
如果价格收于高线的 20 EMA 以上，RSI 高于 55，RSI 高于 10 MA 我进入在下一根蜡烛开盘时
场景 1：SL 最初刚好低于低线的 20 EMA，而 TP 是从开盘到止损的距离，因此交易为 1:1 RR
场景 2：SL 随低点的 20 EMA 移动，止盈为当价格通过低点的 10 EMA 反转时。
场景 3：SL 设置在 20 EMA 下方并设置追踪止损。



在这里，我向您展示如何对冲“circel 对”= GBPUSD > USDCHF > GBPCHF”

“Circel 对”表示每种货币“GBP”、“USD”和“CHF”出现两次在这三对中 。

GBPUSD = 买入
USDCHF = 买入
GBPCHF = 卖出

或

GBPUSD = 卖出
USDCHF = 卖出
GBPCHF = 买入

我根本没有使用任何指标，但有时需要一段时间才能获利。
我对所有三对都使用了相同的手数和 100$ 的 TP

可能有人会说，嘿，你为什么不只交易 GBPUSD 和 GBPCHF？
因为，它会导致如此大的 DD，可以在很短的时间内炸毁一个账户，所以请不要在家里尝试;-)



外汇

mt5和mt4的跟单方式可以粗略分为本地跟单和远程跟单，其根本原理就是将某个账号的做单信息共享出来（下面我们称这个账号为主账号），然后根据这个账号的信息进行做单，手数、方向、货币都可以进行相应的处理。

首先我们得确立几个知识点：
  1、mt4和mt5的编译环境中，对于文件的读写并不是那么友好，它只能识别数据文件夹下面的文件，对于其他地方的文件不能识别
  2、在window下面，当程序在运行的时候，除了会加载自带的dll文件之外，还会加载system32下面的dll文件。明明是mt4/mt5开发，为什么会提到window自带的dll呢？看完全部自然会明白的。

本地跟单其实可以分为两种，一直是通过内存共享数据，还有一种是通过文件共享数据。内存共享数据本人没有研究过，所以在此不做讲解。在此讲解的是通过文件共享数据实现跟单，就是将主账号的做单信息写入文件中，然后其他账号的来读取这个文件的信息，实现跟单。但是mt4/5编程中，文件的读写只能在它的文件盒子下面进行，所以导致了两个mt4/5客户端不能共享数据，这个时候我们需要借助系统自带的kernel32dll动态库了。

kernel32.dll里面有上千个函数，我们只需要其中的两个函数就够了，CopyFileW和CreateDirectoryW，CopyFileW是将主账号的做单信息文件复制到某个固定的文件夹中，然后其他账号也是通过这个函数将此文件复制到本账号的文件盒子中，以此达到数据共享。CreateDirectoryW函数可用可不用，但是为了方便，我们还是调用该函数，为了创建一个数据跟单软件的专属文件夹，这样就完美了。

 贴上引入dll的源码：

#import "kernel32.dll"

int  CopyFileW(string a0, string a1, int a2);

bool CreateDirectoryW(string a0,int a1);

#import


本地跟单方法

许多汇友都有机会得到一些观察帐号，用来查看一些平台、机构提供的账户

交易状况，眼看着人家的账户赚钱。笔者通过反复测试，琢磨出一套“本地跟单方法”，特制作一个模型分享给大家。

首先了解两个基本概念：

1、MQL4

规定文件读写只允许在\experts\files文件夹戒者它的子文件夹里面进行读写，这就给我们实现本地跟单提供了机会。

2、MT4

终端软件安装完毕后，你可以将安装好的文件直接复制粘贴到硬盘的仸何地方，甚至是U盘，只要双击“terminal.exe”就可以运行。通过这种方法，你可以在一台电脑中同时运行若干个MT4软件。

基于以上两个概念，本地跟单的工作原理描述如下：

我们把做单的平台定义为“信号平台”，在这个平台上运行观察账户，并加

载“信号EA”程序，一旦有开仓戒者平仓等劢作，程序就会自劢记录到指定的

中间文件当中，如图所示的“交易信息”文件。我们把跟单操作的平台定义为“操作平台”，加载“跟单EA”，该程序会随时读叏“交易信息”文件，识别最新的交易行为，自劢按照更新的信息执行开仓、平仓操作。

通过这种方法实现跟单，理论上只有毫秒级的延时，可谓是“秒杀”。

如果你有兴趣，那么FollowMe！

在D盘新建一个文件夹：myMT4，把MT4安装文件夹中（C:\ProgramFiles\MetaTrader4）的所有文件复制粘贴到myMT4文件夹中，此时建好了操作平台。在“D:\myMT4\experts\files\”文件夹中新建一个文件夹“myMT4Signal”，把MT4安装文件夹中（C:\ProgramFiles\MetaTrader4）的所有文件复制粘贴到myMT4Signal文件夹中，此时建好了信号平台。分别双击myMT4和myMT4Signal文件夹下面的erminal.exe，系统就会运行两个MT4终端，申请模拟帐号，就可以分别操作了。

【第二步】编写两个程序

第一个程序，命名为“myMT4Signal.mq4”，编译后运行在信号平台中，

详细说明及源代码如下：

/*

程序名：myMT4Signal

程序仸务：监控帐户持仓单变化情况

1、将新开仓订单信息写到"TradeInfo"文件当中，

包括开仓时间、订单号、货币对、订单类型、开仓量、开仓价、订单注释、订单特征码

2、如果没有持仓订单，则删除文件

*/

int start()

{

if (OrdersTotal()==1 && OrderSelect(0, SELECT_BY_POS, MODE_TRADES))//有一单选中

{

int myHandle = FileOpen("TradeInfo.csv", FILE_CSV | FILE_WRITE, ",");

FileWrite(myHandle,OrderOpenTime(),OrderTicket(),OrderSymbol(),OrderType(),

OrderLots(), OrderOpenPrice(), OrderComment(), OrderMagicNumber());

FileClose(myHandle);//将订单信息写入文件

}

if (OrdersTotal()==0) FileDelete("TradeInfo.csv");

return(0);

}

第二个程序，命名为“myMT4Trade.mq4”，编译后运行在操作平台中，

详细说明及源代码如下：

/*

程序名：myMT4Trade

程序仸务：监控帐户持仓单变化情况

1、读取"myMT4Trade"文档中的订单号、货币对、开仓类型、开仓量

2、如果没有持仓订单，根据获取的货币对、开仓类型、开仓量市价开仓

3、如果没有读到指定的文件，则持仓单平仓

*/

string myType, myLots, mySymobl;

int myHandle;

int start()

{

if (iReadFile() == 1 && OrdersTotal()==0)//读取"myMT4Trade"文档中的订单号、货币对、开仓类型、开仓量

{

int mycmd1 = StrToInteger(myType);

string mySymobl1 = mySymobl;

double mylots1 = NormalizeDouble(StrToDouble(myLots),2);

double myOpenPrice;

if (mycmd1 == 0) myOpenPrice = MarketInfo(mySymobl1, MODE_ASK);

if (mycmd1 == 1) myOpenPrice = MarketInfo(mySymobl1, MODE_BID);

OrderSend(mySymobl1, mycmd1, mylots1, myOpenPrice, 0, 0, 0);

}

if (iReadFile() == 0 && OrderSelect(0, SELECT_BY_POS, MODE_TRADES))

{

double myClosePrice;

if (OrderType()==OP_BUY) myClosePrice=Bid;

if (OrderType()==OP_SELL) myClosePrice=Ask;

OrderClose(OrderTicket(), OrderLots(), myClosePrice, 0);

}

return(0);

}

int iReadFile()

{

myHandle = FileOpen("\myMT4Signal\experts\files\TradeInfo.csv", FILE_BIN | FILE_READ);

if (myHandle == -1) return(0);

string myValue;

myValue = FileReadString(myHandle, 60);

int myDatecnt = StringFind(myValue, ",", 0);

string myDate = StringSubstr(myValue, 0 ,myDatecnt);

int myTicketcnt = StringFind(myValue, ",", myDatecnt+1);

string myTicket = StringSubstr(myValue, myDatecnt+1, myTicketcnt-myDatecnt-1);

int mySymbolcnt = StringFind(myValue, ",", myTicketcnt+1);

mySymobl = StringSubstr(myValue, myTicketcnt+1, mySymbolcnt-myTicketcnt-1);

int myTypecnt = StringFind(myValue, ",", mySymbolcnt+1);

myType = StringSubstr(myValue, mySymbolcnt+1, myTypecnt-mySymbolcnt-1);

int myLotscnt = StringFind(myValue, ",", myTypecnt+1);

myLots = StringSubstr(myValue, myTypecnt+1, myLotscnt-myTypecnt-1);

int myPricecnt = StringFind(myValue, ",", myLotscnt+1);

string myPrice = StringSubstr(myValue, myLotscnt+1, myPricecnt-myLotscnt-1);

FileClose(myHandle);

return(1);

}

【第三步】实施跟单测试

在信号平台手工开仓，我们会看到操作平台会自劢开出一张同类型的订单。

将信号平台的持仓单平掉，操作平台的持仓单也随乊平仓。

将你所要下的单子参数设置一下，然后点击红色的按钮就可以轻松的，下单了。

83W6mt1cXxajA8wLyMSbWrKhHqNvnJcVb6vyX8fSn1eEU5aBUMUdQnEMw7mz265tBHiGXbfUMqPeohopiHmc3wsUEgNLEhK


国际各主要外汇市场开盘收盘时间（北京时间）：

新西兰惠灵顿外汇市场： 04：00-12：00（冬令时）； 05：00-13：00 （夏时制）。

澳大利亚悉尼外汇市场：06：00-14：00（冬令时）； 07：00-15：00 （夏时制）。

日 本东京外汇市场： 08：00-14：30

新 加 坡 外汇市场： 09：00-16：00

德国法兰克福外汇市场：14：00-22：00

英国伦敦外汇市场： 16：30-00：30（冬令时）； 15：30-23：30（夏时制）。

美国纽约外汇市场： 21：20-04：00（冬令时）； 20：30-03：00（夏时制）

中国香港： 09：00-16：00

时间优势

在中国的外汇交易者拥有别的时区不能比拟的时间优势，就是能够抓住15点到24点的这个波动最大的时间段，其对于一般的投资者而言都是从事非外汇专业的工作，下午5点下班到24点这段时间是自由时间，正好可以用来

做外汇投资，不必为工作的事情分心。一般周末全球都是休市的。周一凌晨5点左右开市。
