# encoding:utf-8
#import urllib2
import urllib.request
from decimal import Decimal
import time
import telegram
bot = telegram.Bot(token="xxxxxxxxx:xxxxxxxxxxx")
chatID = "-xxxxxx"



eurusdopen = Decimal('1.17881')
usdchfopen = Decimal('0.91532')
#pridt (buy)
#print (type(buy))

resp = urllib.request.urlopen('https://hq.sinajs.cn/etag.php?_=1541986012060&list=fx_seurusd')
html = str(resp.read().split(str.encode('"')))
list = html.split(',')
#for item in list[:]:
high = list[7]
low = list[8]
new = list[9]
#print (new)

eurusdprice = Decimal(new)
#print (eurusdprice)

eurusdtotal = eurusdprice - eurusdopen
#print (eurusdtotal)


respusdchf = urllib.request.urlopen('https://hq.sinajs.cn/etag.php?_=1541986012060&list=fx_susdchf')
html = str(respusdchf.read().split(str.encode('"')))
list = html.split(',')
newusdchf = list[9]
#print (newusdchf)

usdchfprice = Decimal(newusdchf)
#print (usdchfprice)


usdchftotal = usdchfopen - usdchfprice
#print (usdchftotal)


cj = eurusdtotal + usdchftotal
#cj = -0.001500 + 0.000020
#print (cj)

datenow = time.strftime('%H.%M',time.localtime(time.time()))
print (datenow)

pc = round(cj,5)
print (pc)


if pc > 0.00250:
   bot.sendMessage(chat_id=chatID, text='平仓')
