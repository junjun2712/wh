# encoding:utf-8
#import urllib2
import urllib.request
from decimal import Decimal
import time
import telegram
bot = telegram.Bot(token="xxxxxxxxx:xxxxxxxxxxx")
chatID = "-xxxxxx"




buy = Decimal('1.18800')
sell = Decimal('1.18535')
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

price = Decimal(new)
print (price)

stopbuy = price - buy
stopsell = sell - price

print (stopbuy)
print (stopsell)

if price > buy and stopbuy < 0.00050:
   bot.sendMessage(chat_id=chatID, text='买')

if price < sell and stopsell < 0.00050:
   bot.sendMessage(chat_id=chatID, text='卖')
