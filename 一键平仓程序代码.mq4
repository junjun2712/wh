//一键平仓程序代码

 int start()
{
 int cnt, total;
 total=OrdersTotal();
 for(cnt=total-1;cnt>=0;cnt--)
  {
   OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

  if(OrderType()==OP_SELL)
   {
    OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);
   }
  if(OrderType()==OP_BUY)
   {
    OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);
  }

}
 return(0);
 }
