# wh

1小时定方向 十日线均线向上买 十日均线向下卖 （隐藏K线只看均线）


5分钟 120均线临界点买 卖

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

