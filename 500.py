# encoding:utf-8
import urllib.request
from decimal import Decimal
import datetime
from tkinter import * 
from tkinter import messagebox
from apscheduler.schedulers.blocking import BlockingScheduler

def job_function():
    buy = Decimal('1.176800')
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
    stopsell = buy - price
    print(datetime.datetime.now())
    print (stopbuy)
    print (stopsell)
    
    if stopbuy > 0.005000:
       
       root = Tk()
       root.wm_attributes('-topmost',1)
       root.withdraw()
       messagebox.showinfo("message","buy")
       
    if stopsell > 0.005000:
       
       root = Tk()
       root.wm_attributes('-topmost',1)
       root.withdraw()
       messagebox.showinfo("message","sell")
       
   
scheduler = BlockingScheduler()
scheduler.add_job(job_function, 'cron', day_of_week='0-6', minute="*/1")
scheduler.start()
