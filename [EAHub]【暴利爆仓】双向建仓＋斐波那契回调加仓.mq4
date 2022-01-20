#property copyright ""
#property link      ""
#property version   "1.00"
#property strict
string 使用期限=""; //不填写则不限制，格式：2018.04.08 00:00
string 账号限制="";  //不填写则不限制，填写授权数字账号，|间隔，如：8888|9999|666

enum MYPERIOD{当前=PERIOD_CURRENT,M1=PERIOD_M1,M5=PERIOD_M5,M15=PERIOD_M15,M30=PERIOD_M30,H1=PERIOD_H1,H4=PERIOD_H4,D1=PERIOD_D1,W1=PERIOD_W1,MN1=PERIOD_MN1};
input MYPERIOD 时间周期=当前;

enum MY_OP2{BUY=OP_BUY,SELL=OP_SELL}; 

input double __首单手数=0.1;
input int __止盈点数=200;
input int __亏损大于百分之几不再加仓=50;
input double __回调百分比1=15;
input int __保本盈利点数1=10;
input int __弹性点数1=100;
input int __逆向点数范围1a=1500;
input int __逆向点数范围1b=6000;
input int __加仓后可用保证金比率不低于百分之几=50;
input int __加仓间隔秒数=0;
input double __回调百分比2=10;
input int __保本盈利点数2=0;
input int __弹性点数2=100;
input int __逆向点数范围2a=6001;
input int __逆向点数范围2b=150000;

input int 最大允许滑点=900;

#define _tn_int int
#define _m_int int
#define _p_int int

input _m_int _订单识别码=0;
_m_int _内码=0;
input string 订单注释="";
_m_int 子识别码=0;

_m_int 订单识别码=0;
_m_int 备份_分组码=0;
_m_int 备份_指定码=0;
int 强制判断识别码=0;

int 分组循环中=0;

int 指令执行了操盘=0;

_m_int 订单_R_识别码=0;

_m_int 备份_R_分组码=0;
_m_int 备份_R_指定码=0;

int _点系数=1;

_tn_int _mPubTsIns[1000]={};
int _mPubTsInc=0;
_tn_int _mPubTsExs[1000]={};
int _mPubTsExc=0;
_tn_int _mPubTs2Ins[1000]={};

_tn_int _mPubTs2Exs[1000]={};

_tn_int _mPubTn0=0;

#define MYARC 20
#define MYPC 300
_p_int _mPubi[MYPC];
double _mPubv[MYPC];
datetime _mPubTime[MYPC];
double _mPubFs[MYARC][MYPC]={};
_p_int _mPubIs[MYARC][MYPC]={};
int _mPubIsc[MYARC]={};
int _mPubFsc[MYARC]={};

#define MYARR_DC 1
#define MYARR_IC 1

int mArrDc[MYARR_DC];
_p_int mArrIs[MYARR_IC][300];
int mArrIc[MYARR_IC];

int §=0;

int gGa=0;

string sym="";

int period=0;

string mPreCap="";
string mPreCapP=""; //此类变量会在修改参数后也删除重置
string mPreCapNoDel="";//此类变量如果是挂ea，则永不清除；若是回测，则清除
string _mInitCap_LoadTime="";
string _mCap_TimePos1=""; //时间标注点
int OnInit() {
   string hd=MQLInfoString(MQL_PROGRAM_NAME);
   mPreCap=hd+"_"+string(_订单识别码)+"_"+Symbol()+"_"; if (IsTesting()) mPreCap+="test_";
   if (StringLen(mPreCap)>26) mPreCap=StringSubstr(mPreCap,StringLen(mPreCap)-26);

   mPreCapNoDel=hd+"_"+string(_订单识别码)+"*_"+Symbol()+"_"; if (IsTesting()) mPreCapNoDel+="test_";
   if (StringLen(mPreCapNoDel)>26) mPreCapNoDel=StringSubstr(mPreCapNoDel,StringLen(mPreCapNoDel)-26);
   
   if (IsTesting()) {
      myObjectDeleteByPreCap(mPreCap);
      myDeleteGlobalVariableByPre(mPreCap);
      myObjectDeleteByPreCap(mPreCapNoDel);
      myDeleteGlobalVariableByPre(mPreCapNoDel);
   }   
   mPreCapP=mPreCap+"#_";
      
   _mInitCap_LoadTime=mPreCap+"_pub_loadtime";
   if (myGlobalVDateTimeCheck(_mInitCap_LoadTime)==false) myGlobalVDateTimeSet(_mInitCap_LoadTime,TimeCurrent());
   _mCap_TimePos1=mPreCap+"_pub_tmpos1";
   if (myGlobalVDateTimeCheck(_mCap_TimePos1)==false) myGlobalVDateTimeSet(_mCap_TimePos1,TimeCurrent());

   //显性复位   
   for (int i=0;i<MYPC;++i) {
      _mPubi[i]=0;
      _mPubv[i]=0;
      _mPubTime[i]=0;
   }
   for (int i=0;i<MYARC;++i) {
      for (int j=0;j<MYPC;++j) {
         _mPubFs[i][j]=0;
         _mPubIs[i][j]=0;
      }
      _mPubIsc[i]=0;
      _mPubFsc[i]=0;
   }
   
   ArrayInitialize(mArrDc,-1);
   ArrayInitialize(mArrIc,-1);
   
   _内码=_订单识别码; if (_内码==0) _内码=444;
   订单识别码=_内码;
   订单_R_识别码=_内码;
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

   //if (IsTesting()==false) myObjectDeleteByPreCap(mPreCap);  //切换周期不能删除，否则按钮状态会改变
   if (reason==REASON_REMOVE || reason==REASON_CHARTCLOSE) {
      if (IsTesting()==false) {
         myObjectDeleteByPreCap(mPreCap);
         bool ok=true;

         if (ok) myDeleteGlobalVariableByPre(mPreCap);
      }
   }
   else if (reason==REASON_PARAMETERS) {
      myObjectDeleteByPreCap(mPreCapP);
      myDeleteGlobalVariableByPre(mPreCapP);
   }
}

void OnTick() {
   if (myTimeLimit(使用期限)==false) return;
   if (myAccountNumCheck()==false) return;
   if (_订单识别码==444 || _订单识别码==-444) { Alert("~~~~~~自定识别码不能设置为444和-444这两个数字"); ExpertRemove(); return; } 
   int _tmp_w_break=0;

   int _or=0;
   §=0; gGa=0; _mPubTsInc=_mPubTsExc=-1;
   period=时间周期; if (period==0) period=Period();
   sym=Symbol();

   int _ok0=-1;
   if (_ok0==-1) {
      int _ok1=myFun17_1();
      //r/ _ok0=_ok1;
      if (_ok1==1) { myFun139_1(); }
   }
   if (_ok0==-1) {
      int _ok2=myFun17_2();
      //r/ _ok0=_ok2;
      if (_ok2==1) { myFun139_2(); }
   }
   if (_ok0==-1) {
      int _ok3=-1;
      if (_ok3==-1) {
         int _ok4=myFun116_1();
         //r/ _ok3=_ok4;
         if (_ok4==0) { if (myFun6_1()==-3) _ok3=0; }
      }
      if (_ok3==-1) {
         int _ok5=myFun8_1();
         //r/ _ok3=_ok5;
         if (_ok5==1) { myFun177_1(); }
      }
      if (_ok3==-1) {
         int _ok6=myFun8_2();
         _ok3=_ok6;
         if (_ok6==1) { myFun177_2(); }
      }
      _ok0=_ok3;
   }

}

int mMaxX=0;
int mMaxY=0;

datetime myGlobalVDateTimeGet(string vcap) {
   string hcap=vcap+"__h";
   string lcap=vcap+"__l";
   double h=GlobalVariableGet(hcap);
   double l=GlobalVariableGet(lcap);
   double r=h*1000000+l;
   return (datetime)r;
}

void myGlobalVDateTimeSet(string vcap,datetime t) {
   string hcap=vcap+"__h";
   string lcap=vcap+"__l";
   double f=(double)t;
   double h=int(f/1000000);
   double l=int(f)%1000000;
   GlobalVariableSet(hcap,h);
   GlobalVariableSet(lcap,l);
}

bool myGlobalVDateTimeCheck(string vcap) {
   return GlobalVariableCheck(vcap+"__h");
}

bool myIsOpenByThisEA(_m_int om) {
  if (订单识别码==0 && 强制判断识别码==0)  return true;
  if (_订单识别码==0 && 强制判断识别码==0)  return true; //用户接口参数直接设置为0表示忽略识别码（判断的是“_订单识别码”，而非“订单识别码”，因此不影响区分手工单）
  if (分组循环中==1) return om==订单识别码;

   return om==订单识别码;
}

bool myIsOpenByThisEA2(_m_int om,int incSub) {
  if (订单识别码==0 && 强制判断识别码==0)  return true; 
  if (_订单识别码==0 && 强制判断识别码==0)  return true; //用户接口参数直接设置为0表示忽略识别码（判断的是“_订单识别码”，而非“订单识别码”，因此不影响区分手工单）
  if (分组循环中==1) return om==订单识别码;

   if (订单识别码==0) return om==订单识别码 || (incSub && int(om/100000)==444); //避免将其它ea的小于100000的识别码误认为是手工单
   return om==订单识别码 || (incSub && int(om/100000)==订单识别码);
}

void myCreateLabel(string str="mylabel",string ID="def_la1",long chartid=0,int xdis=20,int ydis=20,int fontsize=12,color clr=clrRed,int corner=CORNER_LEFT_UPPER) {
    ObjectCreate(chartid,ID,OBJ_LABEL,0,0,0);
    ObjectSetInteger(chartid,ID,OBJPROP_XDISTANCE,xdis);
    ObjectSetInteger(chartid,ID,OBJPROP_YDISTANCE,ydis);
    ObjectSetString(chartid,ID,OBJPROP_FONT,"Trebuchet MS");
    ObjectSetInteger(chartid,ID,OBJPROP_FONTSIZE,fontsize);
    ObjectSetInteger(chartid,ID,OBJPROP_CORNER,corner);
    ObjectSetInteger(chartid,ID,OBJPROP_SELECTABLE,true);
    ObjectSetString(chartid,ID,OBJPROP_TOOLTIP,"\n");
    ObjectSetString(chartid,ID,OBJPROP_TEXT,str);
   ObjectSetInteger(chartid,ID,OBJPROP_COLOR,clr);
}

double myLotsValid(string sym0,double lots,bool returnMin=false) {
   double step=MarketInfo(sym0,MODE_LOTSTEP);
   if (step<0.000001) { Alert("品种【",sym0,"】数据读取失败，请检查此品种是否存在。若有后缀，请包含后缀。");  return lots; }
   int v=(int)MathRound(lots/step); lots=v*step;
   double min=MarketInfo(sym0,MODE_MINLOT);
   double max=MarketInfo(sym0,MODE_MAXLOT);
   if (lots<min) {
      if (returnMin) return min;
      Alert("手数太小，不符合平台要求"); lots=-1;
   }
   if (lots>max) lots=max;
   return lots;
}

string 时间限制_时间前缀="使用期限：";
string 时间限制_时间后缀="";
string 时间过期_时间前缀="~~~~~~~已过使用期限：";
string 时间过期_时间后缀="";
bool myTimeLimit(string timestr) {
   if (timestr=="") return true;
   datetime t=StringToTime(timestr);
   if (TimeCurrent()<t) {
      myCreateLabel(时间限制_时间前缀+timestr+时间限制_时间后缀,mPreCap+"myTimeLimit",0,20,20,10,255,CORNER_LEFT_LOWER);
      return true;
   }
   else {
      myCreateLabel(时间过期_时间前缀+timestr+时间过期_时间后缀,mPreCap+"myTimeLimit",0,20,20,10,255,CORNER_LEFT_LOWER);
      return false;
   }
}

bool myAccountNumCheck() {
   if (账号限制=="") return true;
   
   ushort u_sep=StringGetCharacter("|",0);
   string ss[1000]; int c=StringSplit(账号限制,u_sep,ss);
   if (c>=1000) Alert("授权列表数量太大");
   
   string s=string(AccountNumber());
   for (int i=0;i<c;++i) if (s==ss[i]) return true;
     
   myCreateLabel("非授权账户账号:"+s,mPreCap+"onlyuser2"); 
   return false; 
}

void myDeleteGlobalVariableByPre(string pre) {
   int len=StringLen(pre);
   for (int i=GlobalVariablesTotal()-1;i>=0;--i) {
      string cap=GlobalVariableName(i);
      if (StringSubstr(cap,0,len)==pre)
   GlobalVariableDel(cap);
   }
}

void myObjectDeleteByPreCap(string PreCap) {
//删除指定名称前缀的对象
   int len=StringLen(PreCap);
   for (int i=ObjectsTotal()-1;i>=0;--i) {
      string cap=ObjectName(i);
      if (StringSubstr(cap,0,len)==PreCap)
         ObjectDelete(cap);
   }
}

string myPeriodStr(int p0) {
   int pid=0; if (p0==0) p0=Period();
   string pstr;
   switch (p0) {
      case 1: pid=0; pstr="M1"; break;
      case 5: pid=1; pstr="M5"; break;
      case 15: pid=2; pstr="M15"; break;
      case 30: pid=3; pstr="M30"; break;
      case 60: pid=4; pstr="H1"; break;
      case 240: pid=5; pstr="H4"; break;
      case 1440: pid=6; pstr="D1"; break;
      case 10080: pid=7; pstr="W1"; break;
      case 43200: pid=8; pstr="MN"; break;
      default: pstr=string(p0);
   }
   return pstr;
}

bool myOrderOks(_tn_int tn) {
   if (_mPubTsExc>0) { for (int i=0;i<_mPubTsExc;++i) { if (_mPubTsExs[i]==tn) return false; }  }
   if (_mPubTsInc>=0){ 
      int i=0; for (;i<_mPubTsInc;++i) { if (_mPubTsIns[i]==tn) break; } 
      if (i>=_mPubTsInc) return false;  
   }
   return true;
}

double myFun25_1() {
   if (OrdersTotal()<=0) return 0;
   int magic=1; if (0==1) magic=0;   
   int ts[10]={}; ArrayInitialize(ts,0);
   ts[OP_BUY]=1;
   ts[OP_BUYLIMIT]=0;
   ts[OP_BUYSTOP]=0;
   ts[OP_SELL]=0;
   ts[OP_SELLLIMIT]=0;
   ts[OP_SELLSTOP]=0;
   if (ts[OP_BUY]+ts[OP_BUYLIMIT]+ts[OP_BUYSTOP]+ts[OP_SELL]+ts[OP_SELLLIMIT]+ts[OP_SELLSTOP]==0) ArrayInitialize(ts,1);
   int c=0;
   for (int cnt=OrdersTotal()-1;cnt>=0;cnt--) {
     if (OrderSelect(cnt,SELECT_BY_POS)==false) continue;
     if (magic!=0 && myIsOpenByThisEA2(OrderMagicNumber(),1)==false) continue;

     if (sym!="" && OrderSymbol()!=sym) continue;

     if (ts[OrderType()]==0) continue;
     if (myOrderOks(OrderTicket())==false) continue;
     c+=1;
   }
   return c;

}

bool myFun17_1() {
   double a=double(myFun25_1());
   double b=double(0);

   return MathAbs(a-b)<0.00000001;

}

_p_int myFun139_1() {
   指令执行了操盘=0;

   _m_int magic=订单识别码;
   int slip=最大允许滑点;
   string comm=订单注释;

   double pnt=MarketInfo(sym,MODE_POINT);

   int type=0; 

   double lots=myLotsValid(sym,double(__首单手数),true);
   double sl=double(0*_点系数);
   double tp=double(int(__止盈点数)*_点系数);

   for(int pos=OrdersTotal()-1;pos>=0;pos--)           {
      if (OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if (magic!=444 && myIsOpenByThisEA2(OrderMagicNumber(),1)==false) continue;
      if (sym!="" && OrderSymbol()!=sym) continue;

      if (OrderType()==type) return 0; //一个方向只持仓一单

   }

_tn_int tn=0;
for (int w=0;w<4;++w) { if (w>0) { Sleep(3000); Alert("~~~m=",magic,"~~~slip=",slip,"~~~~~建仓重试",w); RefreshRates(); } 
   double op=0;
   if (type==OP_BUY) {
      op=MarketInfo(sym,MODE_ASK);
      if (sl>0.001) sl=op-sl*MarketInfo(sym,MODE_POINT);
      if (tp>0.001) tp=op+tp*MarketInfo(sym,MODE_POINT);
   }
   else if (type==OP_SELL) {
      op=MarketInfo(sym,MODE_BID);
      if (sl>0.001) sl=op+sl*MarketInfo(sym,MODE_POINT);
      if (tp>0.001) tp=op-tp*MarketInfo(sym,MODE_POINT);
   }
   else return 0;
   tn=OrderSend(sym,type,lots,op,slip,sl,tp,comm,magic);
   if (tn>0 && w>0) Alert("~~~~重试建仓成功");
   if (tn<=0) {
      int err=GetLastError();
      if (err==134) { Alert("~~~~~~~~~~保证金不足，建仓手数无效：",lots); Sleep(3000); return 0; }
      else if (err>=135 && err<=138) { Alert("~~m=",magic,"~~~网速慢或平台服务器卡~~~~~建仓失败：",err); continue; }
      else Alert("~~m=",magic,"~~~~~~~~建仓失败：",err);
      Sleep(3000); break; 
   }

   if (tn>0) { 指令执行了操盘=1; break; }
}   
   return tn;

}

double myFun25_2() {
   if (OrdersTotal()<=0) return 0;
   int magic=1; if (0==1) magic=0;   
   int ts[10]={}; ArrayInitialize(ts,0);
   ts[OP_BUY]=0;
   ts[OP_BUYLIMIT]=0;
   ts[OP_BUYSTOP]=0;
   ts[OP_SELL]=1;
   ts[OP_SELLLIMIT]=0;
   ts[OP_SELLSTOP]=0;
   if (ts[OP_BUY]+ts[OP_BUYLIMIT]+ts[OP_BUYSTOP]+ts[OP_SELL]+ts[OP_SELLLIMIT]+ts[OP_SELLSTOP]==0) ArrayInitialize(ts,1);
   int c=0;
   for (int cnt=OrdersTotal()-1;cnt>=0;cnt--) {
     if (OrderSelect(cnt,SELECT_BY_POS)==false) continue;
     if (magic!=0 && myIsOpenByThisEA2(OrderMagicNumber(),1)==false) continue;

     if (sym!="" && OrderSymbol()!=sym) continue;

     if (ts[OrderType()]==0) continue;
     if (myOrderOks(OrderTicket())==false) continue;
     c+=1;
   }
   return c;

}

bool myFun17_2() {
   double a=double(myFun25_2());
   double b=double(0);

   return MathAbs(a-b)<0.00000001;

}

_p_int myFun139_2() {
   指令执行了操盘=0;

   _m_int magic=订单识别码;
   int slip=最大允许滑点;
   string comm=订单注释;

   double pnt=MarketInfo(sym,MODE_POINT);

   int type=1; 

   double lots=myLotsValid(sym,double(__首单手数),true);
   double sl=double(0*_点系数);
   double tp=double(int(__止盈点数)*_点系数);

   for(int pos=OrdersTotal()-1;pos>=0;pos--)           {
      if (OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if (magic!=444 && myIsOpenByThisEA2(OrderMagicNumber(),1)==false) continue;
      if (sym!="" && OrderSymbol()!=sym) continue;

      if (OrderType()==type) return 0; //一个方向只持仓一单

   }

_tn_int tn=0;
for (int w=0;w<4;++w) { if (w>0) { Sleep(3000); Alert("~~~m=",magic,"~~~slip=",slip,"~~~~~建仓重试",w); RefreshRates(); } 
   double op=0;
   if (type==OP_BUY) {
      op=MarketInfo(sym,MODE_ASK);
      if (sl>0.001) sl=op-sl*MarketInfo(sym,MODE_POINT);
      if (tp>0.001) tp=op+tp*MarketInfo(sym,MODE_POINT);
   }
   else if (type==OP_SELL) {
      op=MarketInfo(sym,MODE_BID);
      if (sl>0.001) sl=op+sl*MarketInfo(sym,MODE_POINT);
      if (tp>0.001) tp=op-tp*MarketInfo(sym,MODE_POINT);
   }
   else return 0;
   tn=OrderSend(sym,type,lots,op,slip,sl,tp,comm,magic);
   if (tn>0 && w>0) Alert("~~~~重试建仓成功");
   if (tn<=0) {
      int err=GetLastError();
      if (err==134) { Alert("~~~~~~~~~~保证金不足，建仓手数无效：",lots); Sleep(3000); return 0; }
      else if (err>=135 && err<=138) { Alert("~~m=",magic,"~~~网速慢或平台服务器卡~~~~~建仓失败：",err); continue; }
      else Alert("~~m=",magic,"~~~~~~~~建仓失败：",err);
      Sleep(3000); break; 
   }

   if (tn>0) { 指令执行了操盘=1; break; }
}   
   return tn;

}

double myFun103_1() {
   return AccountBalance();

}
bool myFun116_1() {
   double a=0,b=0;
   a=double(_mPubv[9]);
   double v1=double(a);
   a=double(myFun103_1());
   b=double(int(__亏损大于百分之几不再加仓));
   double v2=double(-(a*b/100.0));

   return v1>v2;

}
_p_int myFun6_1() {
   return -3;

}

bool myFun8_1() {
   return true;

}

_p_int myFun177_1() {
   指令执行了操盘=0;
   _m_int magic=订单识别码;
   int slip=最大允许滑点;
   string comm=订单注释;
   double ask=MarketInfo(sym,MODE_ASK);
   double bid=MarketInfo(sym,MODE_BID);
   double pnt=MarketInfo(sym,MODE_POINT);
   int digit=(int)MarketInfo(sym,MODE_DIGITS);
   double stoplevel=MarketInfo(sym,MODE_STOPLEVEL)+10; //多增加10个点，预留修改时间，尽量避免“一半订单修改成功，一半不成功”的情况
   double ask2=ask+stoplevel*pnt;
   double bid2=bid-stoplevel*pnt;
   int t=0;
   double per=double(double(__回调百分比1));
   double tpp=double(int(__保本盈利点数1));
   double pp=double(int(__弹性点数1)); //预留点数
   double p1=MathAbs(int(__逆向点数范围1a));
   double p2=MathAbs(int(__逆向点数范围1b));
   int mc=5;
   int spansecond=3600;
   double mper=double(int(__加仓后可用保证金比率不低于百分之几));
   int sspan=int(int(__加仓间隔秒数));
   
   //读取首单
   double op[2]={0,0},ls[2]={0,0},op00[2]={0,0},tp00[2]={}; _tn_int tn00[2]={0,0}; int cs[2]={0,0}; datetime ts00[2]={},ts22[2]={0,0};
   for(int pos=OrdersTotal()-1;pos>=0;pos--)           {
      if (OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if (magic!=444 && myIsOpenByThisEA2(OrderMagicNumber(),1)==false) continue;
      if (sym!="" && OrderSymbol()!=sym) continue;
      t=OrderType();
      if (t!=OP_BUY && t!=OP_SELL) continue;
      if (tn00[t]==0 || OrderTicket()<tn00[t]) { op00[t]=OrderOpenPrice(); tn00[t]=OrderTicket(); ts00[t]=OrderOpenTime(); tp00[t]=OrderTakeProfit(); }
      op[t]+=OrderOpenPrice()*OrderLots(); ls[t]+=OrderLots(); if (OrderOpenTime()>ts22[t]) ts22[t]=OrderOpenTime(); cs[t]+=1;
   }
   if (cs[0]+cs[1]==0) return 0;

   t=0; 
   if (cs[t]>0) {
      int k=iBarShift(sym,period,ts00[t]); if (iTime(sym,period,k)>ts00[t]) k+=1;
      op00[t]=iHigh(sym,period,iHighest(sym,period,MODE_HIGH,k+1));
   }
   t=1; 
   if (cs[t]>0) {
      int k=iBarShift(sym,period,ts00[t]); if (iTime(sym,period,k)>ts00[t]) k+=1;
      op00[t]=iLow(sym,period,iLowest(sym,period,MODE_LOW,k+1));
   }

   for (int i=0;i<2;++i) {
      if (cs[i]==0) continue;
      op[i]/=ls[i]; op[i]=NormalizeDouble(op[i],digit);
      if (i==0) {
         if (bid>=op00[i]) { cs[i]=0; continue; }
         int p=int((op00[i]-bid)/pnt);
         if (p<p1 || p>p2) { cs[i]=0; continue; }
      }
      else if (i==1) {
         if (bid<=op00[i]) { cs[i]=0; continue; } //都根据Bid来判断逆向点数
         int p=int((bid-op00[i])/pnt);
         if (p<p1 || p>p2) { cs[i]=0; continue; }
      }      
   }
   
   //加仓
   int z=0;
   double tp0=bid+(MathAbs(op00[z]-bid)*(per/100.0)); tp0=NormalizeDouble(tp0,digit); //底线止盈价
   if (cs[z]>0 && (tp00[z]>tp0 || tp00[z]<pnt)) {
      if (tp0<ask2) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",buy,设置的“首单逆向起始点数”或“回调百分比”参数值太小，造成没有足够的回调空间设置止盈价，无法完成加仓。"); 
         }
         return 0;
      }
      double tp=bid-pp*pnt+(MathAbs(op00[z]-bid)+pp*pnt)*(per/100.0); tp=NormalizeDouble(tp,digit); //最高反弹到的Bid价，此价格将设置为止盈价
      double pp2=pp;
      if (tp<ask2) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",buy,设置的“预留弹性点数”太大，同时“回调百分比”太小，造成止盈价在ASK价之下，ea将自主选择合适的弹性点数。"); 
         }
         while (true) {
            if (pp2<=5.01) { tp=tp0; break; }
            if (pp2>100.01) pp2=100;
            else if (pp2>80.01) pp2=80;
            else if (pp2>60.01) pp2=60;
            else if (pp2>40.01) pp2=40;
            else if (pp2>20.01) pp2=20;
            else if (pp2>10.01) pp2=10;
            else pp2=5;
            tp=bid-pp2*pnt+(MathAbs(op00[z]-bid)+pp2*pnt)*(per/100.0); tp=NormalizeDouble(tp,digit);
            if (tp>ask2) break;
         }
      }
      
      double ap=0; //预设均价
      //止盈价与“预建仓价”的点差
      int x=int((tp-ask)/pnt); x-=5; //为将来的均价与“预建仓价”至少预留5个点的点差，因为两个价格很难重合
      if (tpp>x) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",buy,本次加仓的止盈空间达不到“建仓均价保本盈利点数”参数的要求，ea将以保本为首要目标。"); 
         }
         if (x>100) x=100;
         ap=tp-x*pnt;
      }
      else ap=tp-tpp*pnt;
      
      static int openerr=0;
      //根据预设均价，计算本次加仓量
      static datetime ot0=0;
      if (ap<op[z] && TimeCurrent()-ot0>spansecond) {  ot0=TimeCurrent();
         double bs=MathAbs(op[z]-ap)/MathAbs(ask-ap);
         double lots=ls[z]*bs; lots=myLotsValid(sym,lots,true);
         Print("~~~~~~~~~~~buy亏损加仓设止盈,p1=",DoubleToStr(p1,digit),", p2=",DoubleToStr(p2,digit),", 弹性点数：",pp2,", lots=",lots);
         Print("~~~~~~~~~~~bs=",bs,", aver0=",DoubleToStr(op[z],digit),", aver_new=",DoubleToStr(ap,digit));
         double m2=AccountFreeMarginCheck(sym,OP_BUY,lots);
         if (m2<AccountBalance()*(mper/100.0) || GetLastError()==134) {
            openerr=1;
            static datetime tm0=0;
            if (TimeCurrent()-tm0>mc*60) {
               tm0=TimeCurrent();
               Alert(sym,",buy,若加仓，加仓后的可用保证金将低于设定比例，放弃加仓。lots=",lots); 
            }
         }
         else {
            if (TimeCurrent()-ts22[z]<sspan) {
               openerr=1;
               static datetime tm0=0;
               if (TimeCurrent()-tm0>mc*60) {
                  tm0=TimeCurrent();
                  Alert(sym,",buy,加仓间隔秒数不足，放弃加仓。lots=",lots); 
               }
            }
            else  {
               _tn_int tn=OrderSend(sym,OP_BUY,lots,ask,slip,0,0,comm,magic);
               if (tn<=0) {
                  openerr=1;
                  static datetime tm0=0;
                  if (TimeCurrent()-tm0>mc*60) {
                     tm0=TimeCurrent();
                     Alert(sym,"~~~~~~~~~~buy加仓错误：",GetLastError(),", lots=",lots);
                  }
               }
               else {
                  指令执行了操盘=1;
                  ot0=0;
                  openerr=0;
               }
            }
         }
      }
      if (openerr==0) {
         for(int pos=OrdersTotal()-1;pos>=0;pos--)           {
            if (OrderSelect(pos,SELECT_BY_POS)==false) continue;
            if (magic!=444 && myIsOpenByThisEA2(OrderMagicNumber(),1)==false) continue;
            if (sym!="" && OrderSymbol()!=sym) continue;
            if (OrderType()!=OP_BUY) continue;
            if (OrderTakeProfit()>pnt && OrderTakeProfit()<=tp+0.0000001) continue;
            if (OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,OrderExpiration())==false)
               Print("buy~~~~~加仓后修改止盈失败，",GetLastError());
         }
      }
   }
   
   z=1;
   tp0=bid-(MathAbs(op00[z]-bid)*(per/100.0))+(ask-bid); tp0=NormalizeDouble(tp0,digit); //底线止盈价 （sell单需要加一个点差）
   if (cs[z]>0 && (tp00[z]<tp0 || tp00[z]<pnt)) {
      if (tp0>bid2) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",sell,设置的“首单逆向起始点数”或“回调百分比”参数值太小，造成没有足够的回调空间设置止盈价，无法完成加仓。"); 
         }
         return 0;
      }
      double tp=bid+pp*pnt-(MathAbs(op00[z]-bid)+pp*pnt)*(per/100.0)+(ask-bid); tp=NormalizeDouble(tp,digit); //最高反弹到的Bid价，此价格将设置为止盈价
      double pp2=pp;
      if (tp>bid2) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",sell,设置的“预留弹性点数”太大，同时“回调百分比”太小，造成止盈价在BID价之上，ea将自主选择合适的弹性点数。"); 
         }
         while (true) {
            if (pp2<=5.01) { tp=tp0; break; }
            if (pp2>100.01) pp2=100;
            else if (pp2>80.01) pp2=80;
            else if (pp2>60.01) pp2=60;
            else if (pp2>40.01) pp2=40;
            else if (pp2>20.01) pp2=20;
            else if (pp2>10.01) pp2=10;
            else pp2=5;
            tp=bid+pp2*pnt-(MathAbs(op00[z]-bid)+pp2*pnt)*(per/100.0)+(ask-bid); tp=NormalizeDouble(tp,digit);
            if (tp<bid2) break;
         }
      }
      
      double ap=0; //预设均价
      //止盈价与“预建仓价”的点差
      int x=int((bid-tp)/pnt); x-=5; //为将来的均价与“预建仓价”至少预留5个点的点差，因为两个价格很难重合
      if (tpp>x) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",sell,本次加仓的止盈空间达不到“建仓均价保本盈利点数”参数的要求，ea将以保本为首要目标。"); 
         }
         if (x>100) x=100;
         ap=tp+x*pnt;
      }
      else ap=tp+tpp*pnt;
      
      static int openerr=0;
      //根据预设均价，计算本次加仓量
      static datetime ot0=0;
      if (ap>op[z] && TimeCurrent()-ot0>spansecond) {  ot0=TimeCurrent();
         double bs=MathAbs(op[z]-ap)/MathAbs(bid-ap);
         double lots=ls[z]*bs; lots=myLotsValid(sym,lots,true);
         Print("~~~~~~~~~~~sell亏损加仓设止盈,p1=",DoubleToStr(p1,digit),", p2=",DoubleToStr(p2,digit),", 弹性点数：",pp2,", lots=",lots);
         Print("~~~~~~~~~~~bs=",bs,", aver0=",DoubleToStr(op[z],digit),", aver_new=",DoubleToStr(ap,digit));
         double m2=AccountFreeMarginCheck(sym,OP_SELL,lots);
         if (m2<AccountBalance()*(mper/100.0) || GetLastError()==134) {
            openerr=1;
            static datetime tm0=0;
            if (TimeCurrent()-tm0>mc*60) {
               tm0=TimeCurrent();
               Alert(sym,",sell,若加仓，加仓后的可用保证金将低于设定比例，放弃加仓。lots=",lots); 
            }
         }
         else {
            if (TimeCurrent()-ts22[z]<sspan) {
               openerr=1;
               static datetime tm0=0;
               if (TimeCurrent()-tm0>mc*60) {
                  tm0=TimeCurrent();
                  Alert(sym,",sell,加仓间隔秒数不足，放弃加仓。lots=",lots); 
               }
            }
            else  {
               _tn_int tn=OrderSend(sym,OP_SELL,lots,bid,slip,0,0,comm,magic);
               if (tn<=0) {
                  openerr=1;
                  static datetime tm0=0;
                  if (TimeCurrent()-tm0>mc*60) {
                     tm0=TimeCurrent();
                     Alert(sym,"~~~~~~~~~~sell加仓错误：",GetLastError(),", lots=",lots);
                  }
               }
               else {
                  指令执行了操盘=1;
                  openerr=0;
                  ot0=0;
               }
            }
         }
      }
      if (openerr==0) {
         for(int pos=OrdersTotal()-1;pos>=0;pos--) {
            if (OrderSelect(pos,SELECT_BY_POS)==false) continue;
            if (magic!=444 && myIsOpenByThisEA2(OrderMagicNumber(),1)==false) continue;
            if (sym!="" && OrderSymbol()!=sym) continue;
            if (OrderType()!=OP_SELL) continue;
            if (OrderTakeProfit()>pnt && OrderTakeProfit()>=tp+0.0000001) continue;
            if (OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,OrderExpiration())==false)
               Print("sell~~~~~加仓后修改止盈失败，",GetLastError());
         }
      }
   }
   return 0;

}

bool myFun8_2() {
   return true;

}

_p_int myFun177_2() {
   指令执行了操盘=0;
   _m_int magic=订单识别码;
   int slip=最大允许滑点;
   string comm=订单注释;
   double ask=MarketInfo(sym,MODE_ASK);
   double bid=MarketInfo(sym,MODE_BID);
   double pnt=MarketInfo(sym,MODE_POINT);
   int digit=(int)MarketInfo(sym,MODE_DIGITS);
   double stoplevel=MarketInfo(sym,MODE_STOPLEVEL)+10; //多增加10个点，预留修改时间，尽量避免“一半订单修改成功，一半不成功”的情况
   double ask2=ask+stoplevel*pnt;
   double bid2=bid-stoplevel*pnt;
   int t=0;
   double per=double(double(__回调百分比2));
   double tpp=double(int(__保本盈利点数2));
   double pp=double(int(__弹性点数2)); //预留点数
   double p1=MathAbs(int(__逆向点数范围2a));
   double p2=MathAbs(int(__逆向点数范围2b));
   int mc=5;
   int spansecond=3600;
   double mper=double(int(__加仓后可用保证金比率不低于百分之几));
   int sspan=int(int(__加仓间隔秒数));
   
   //读取首单
   double op[2]={0,0},ls[2]={0,0},op00[2]={0,0},tp00[2]={}; _tn_int tn00[2]={0,0}; int cs[2]={0,0}; datetime ts00[2]={},ts22[2]={0,0};
   for(int pos=OrdersTotal()-1;pos>=0;pos--)           {
      if (OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if (magic!=444 && myIsOpenByThisEA2(OrderMagicNumber(),1)==false) continue;
      if (sym!="" && OrderSymbol()!=sym) continue;
      t=OrderType();
      if (t!=OP_BUY && t!=OP_SELL) continue;
      if (tn00[t]==0 || OrderTicket()<tn00[t]) { op00[t]=OrderOpenPrice(); tn00[t]=OrderTicket(); ts00[t]=OrderOpenTime(); tp00[t]=OrderTakeProfit(); }
      op[t]+=OrderOpenPrice()*OrderLots(); ls[t]+=OrderLots(); if (OrderOpenTime()>ts22[t]) ts22[t]=OrderOpenTime(); cs[t]+=1;
   }
   if (cs[0]+cs[1]==0) return 0;

   t=0; 
   if (cs[t]>0) {
      int k=iBarShift(sym,period,ts00[t]); if (iTime(sym,period,k)>ts00[t]) k+=1;
      op00[t]=iHigh(sym,period,iHighest(sym,period,MODE_HIGH,k+1));
   }
   t=1; 
   if (cs[t]>0) {
      int k=iBarShift(sym,period,ts00[t]); if (iTime(sym,period,k)>ts00[t]) k+=1;
      op00[t]=iLow(sym,period,iLowest(sym,period,MODE_LOW,k+1));
   }

   for (int i=0;i<2;++i) {
      if (cs[i]==0) continue;
      op[i]/=ls[i]; op[i]=NormalizeDouble(op[i],digit);
      if (i==0) {
         if (bid>=op00[i]) { cs[i]=0; continue; }
         int p=int((op00[i]-bid)/pnt);
         if (p<p1 || p>p2) { cs[i]=0; continue; }
      }
      else if (i==1) {
         if (bid<=op00[i]) { cs[i]=0; continue; } //都根据Bid来判断逆向点数
         int p=int((bid-op00[i])/pnt);
         if (p<p1 || p>p2) { cs[i]=0; continue; }
      }      
   }
   
   //加仓
   int z=0;
   double tp0=bid+(MathAbs(op00[z]-bid)*(per/100.0)); tp0=NormalizeDouble(tp0,digit); //底线止盈价
   if (cs[z]>0 && (tp00[z]>tp0 || tp00[z]<pnt)) {
      if (tp0<ask2) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",buy,设置的“首单逆向起始点数”或“回调百分比”参数值太小，造成没有足够的回调空间设置止盈价，无法完成加仓。"); 
         }
         return 0;
      }
      double tp=bid-pp*pnt+(MathAbs(op00[z]-bid)+pp*pnt)*(per/100.0); tp=NormalizeDouble(tp,digit); //最高反弹到的Bid价，此价格将设置为止盈价
      double pp2=pp;
      if (tp<ask2) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",buy,设置的“预留弹性点数”太大，同时“回调百分比”太小，造成止盈价在ASK价之下，ea将自主选择合适的弹性点数。"); 
         }
         while (true) {
            if (pp2<=5.01) { tp=tp0; break; }
            if (pp2>100.01) pp2=100;
            else if (pp2>80.01) pp2=80;
            else if (pp2>60.01) pp2=60;
            else if (pp2>40.01) pp2=40;
            else if (pp2>20.01) pp2=20;
            else if (pp2>10.01) pp2=10;
            else pp2=5;
            tp=bid-pp2*pnt+(MathAbs(op00[z]-bid)+pp2*pnt)*(per/100.0); tp=NormalizeDouble(tp,digit);
            if (tp>ask2) break;
         }
      }
      
      double ap=0; //预设均价
      //止盈价与“预建仓价”的点差
      int x=int((tp-ask)/pnt); x-=5; //为将来的均价与“预建仓价”至少预留5个点的点差，因为两个价格很难重合
      if (tpp>x) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",buy,本次加仓的止盈空间达不到“建仓均价保本盈利点数”参数的要求，ea将以保本为首要目标。"); 
         }
         if (x>100) x=100;
         ap=tp-x*pnt;
      }
      else ap=tp-tpp*pnt;
      
      static int openerr=0;
      //根据预设均价，计算本次加仓量
      static datetime ot0=0;
      if (ap<op[z] && TimeCurrent()-ot0>spansecond) {  ot0=TimeCurrent();
         double bs=MathAbs(op[z]-ap)/MathAbs(ask-ap);
         double lots=ls[z]*bs; lots=myLotsValid(sym,lots,true);
         Print("~~~~~~~~~~~buy亏损加仓设止盈,p1=",DoubleToStr(p1,digit),", p2=",DoubleToStr(p2,digit),", 弹性点数：",pp2,", lots=",lots);
         Print("~~~~~~~~~~~bs=",bs,", aver0=",DoubleToStr(op[z],digit),", aver_new=",DoubleToStr(ap,digit));
         double m2=AccountFreeMarginCheck(sym,OP_BUY,lots);
         if (m2<AccountBalance()*(mper/100.0) || GetLastError()==134) {
            openerr=1;
            static datetime tm0=0;
            if (TimeCurrent()-tm0>mc*60) {
               tm0=TimeCurrent();
               Alert(sym,",buy,若加仓，加仓后的可用保证金将低于设定比例，放弃加仓。lots=",lots); 
            }
         }
         else {
            if (TimeCurrent()-ts22[z]<sspan) {
               openerr=1;
               static datetime tm0=0;
               if (TimeCurrent()-tm0>mc*60) {
                  tm0=TimeCurrent();
                  Alert(sym,",buy,加仓间隔秒数不足，放弃加仓。lots=",lots); 
               }
            }
            else  {
               _tn_int tn=OrderSend(sym,OP_BUY,lots,ask,slip,0,0,comm,magic);
               if (tn<=0) {
                  openerr=1;
                  static datetime tm0=0;
                  if (TimeCurrent()-tm0>mc*60) {
                     tm0=TimeCurrent();
                     Alert(sym,"~~~~~~~~~~buy加仓错误：",GetLastError(),", lots=",lots);
                  }
               }
               else {
                  指令执行了操盘=1;
                  ot0=0;
                  openerr=0;
               }
            }
         }
      }
      if (openerr==0) {
         for(int pos=OrdersTotal()-1;pos>=0;pos--)           {
            if (OrderSelect(pos,SELECT_BY_POS)==false) continue;
            if (magic!=444 && myIsOpenByThisEA2(OrderMagicNumber(),1)==false) continue;
            if (sym!="" && OrderSymbol()!=sym) continue;
            if (OrderType()!=OP_BUY) continue;
            if (OrderTakeProfit()>pnt && OrderTakeProfit()<=tp+0.0000001) continue;
            if (OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,OrderExpiration())==false)
               Print("buy~~~~~加仓后修改止盈失败，",GetLastError());
         }
      }
   }
   
   z=1;
   tp0=bid-(MathAbs(op00[z]-bid)*(per/100.0))+(ask-bid); tp0=NormalizeDouble(tp0,digit); //底线止盈价 （sell单需要加一个点差）
   if (cs[z]>0 && (tp00[z]<tp0 || tp00[z]<pnt)) {
      if (tp0>bid2) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",sell,设置的“首单逆向起始点数”或“回调百分比”参数值太小，造成没有足够的回调空间设置止盈价，无法完成加仓。"); 
         }
         return 0;
      }
      double tp=bid+pp*pnt-(MathAbs(op00[z]-bid)+pp*pnt)*(per/100.0)+(ask-bid); tp=NormalizeDouble(tp,digit); //最高反弹到的Bid价，此价格将设置为止盈价
      double pp2=pp;
      if (tp>bid2) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",sell,设置的“预留弹性点数”太大，同时“回调百分比”太小，造成止盈价在BID价之上，ea将自主选择合适的弹性点数。"); 
         }
         while (true) {
            if (pp2<=5.01) { tp=tp0; break; }
            if (pp2>100.01) pp2=100;
            else if (pp2>80.01) pp2=80;
            else if (pp2>60.01) pp2=60;
            else if (pp2>40.01) pp2=40;
            else if (pp2>20.01) pp2=20;
            else if (pp2>10.01) pp2=10;
            else pp2=5;
            tp=bid+pp2*pnt-(MathAbs(op00[z]-bid)+pp2*pnt)*(per/100.0)+(ask-bid); tp=NormalizeDouble(tp,digit);
            if (tp<bid2) break;
         }
      }
      
      double ap=0; //预设均价
      //止盈价与“预建仓价”的点差
      int x=int((bid-tp)/pnt); x-=5; //为将来的均价与“预建仓价”至少预留5个点的点差，因为两个价格很难重合
      if (tpp>x) {
         static datetime tm0=0;
         if (TimeCurrent()-tm0>mc*60) {
            tm0=TimeCurrent();
            Alert(sym,",sell,本次加仓的止盈空间达不到“建仓均价保本盈利点数”参数的要求，ea将以保本为首要目标。"); 
         }
         if (x>100) x=100;
         ap=tp+x*pnt;
      }
      else ap=tp+tpp*pnt;
      
      static int openerr=0;
      //根据预设均价，计算本次加仓量
      static datetime ot0=0;
      if (ap>op[z] && TimeCurrent()-ot0>spansecond) {  ot0=TimeCurrent();
         double bs=MathAbs(op[z]-ap)/MathAbs(bid-ap);
         double lots=ls[z]*bs; lots=myLotsValid(sym,lots,true);
         Print("~~~~~~~~~~~sell亏损加仓设止盈,p1=",DoubleToStr(p1,digit),", p2=",DoubleToStr(p2,digit),", 弹性点数：",pp2,", lots=",lots);
         Print("~~~~~~~~~~~bs=",bs,", aver0=",DoubleToStr(op[z],digit),", aver_new=",DoubleToStr(ap,digit));
         double m2=AccountFreeMarginCheck(sym,OP_SELL,lots);
         if (m2<AccountBalance()*(mper/100.0) || GetLastError()==134) {
            openerr=1;
            static datetime tm0=0;
            if (TimeCurrent()-tm0>mc*60) {
               tm0=TimeCurrent();
               Alert(sym,",sell,若加仓，加仓后的可用保证金将低于设定比例，放弃加仓。lots=",lots); 
            }
         }
         else {
            if (TimeCurrent()-ts22[z]<sspan) {
               openerr=1;
               static datetime tm0=0;
               if (TimeCurrent()-tm0>mc*60) {
                  tm0=TimeCurrent();
                  Alert(sym,",sell,加仓间隔秒数不足，放弃加仓。lots=",lots); 
               }
            }
            else  {
               _tn_int tn=OrderSend(sym,OP_SELL,lots,bid,slip,0,0,comm,magic);
               if (tn<=0) {
                  openerr=1;
                  static datetime tm0=0;
                  if (TimeCurrent()-tm0>mc*60) {
                     tm0=TimeCurrent();
                     Alert(sym,"~~~~~~~~~~sell加仓错误：",GetLastError(),", lots=",lots);
                  }
               }
               else {
                  指令执行了操盘=1;
                  openerr=0;
                  ot0=0;
               }
            }
         }
      }
      if (openerr==0) {
         for(int pos=OrdersTotal()-1;pos>=0;pos--) {
            if (OrderSelect(pos,SELECT_BY_POS)==false) continue;
            if (magic!=444 && myIsOpenByThisEA2(OrderMagicNumber(),1)==false) continue;
            if (sym!="" && OrderSymbol()!=sym) continue;
            if (OrderType()!=OP_SELL) continue;
            if (OrderTakeProfit()>pnt && OrderTakeProfit()>=tp+0.0000001) continue;
            if (OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,OrderExpiration())==false)
               Print("sell~~~~~加仓后修改止盈失败，",GetLastError());
         }
      }
   }
   return 0;

}

