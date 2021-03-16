#!/usr/bin/env python 
# -*- coding:utf-8 -*-
import os
import datetime
import time
import shutil
import imaplib
import filecmp
#import win32api
#import win32con
from playsound import playsound
from tkinter import * 
from tkinter import messagebox
from apscheduler.schedulers.blocking import BlockingScheduler



def job_function():
    mailserver = imaplib.IMAP4_SSL('imap.gmail.com', 993)
    username = 'xxxxxxxxx'
    password = 'xxxxxxxxx'
    mailserver.login(username, password)
    status, count = mailserver.select('Inbox')
    status, data = mailserver.fetch(count[0], '(UID BODY[TEXT])')
    print (data[0][1])
    man_file = open('d:\wh\man_data.sql', 'w')
    print (data[0][1],file=man_file)
    man_file.close()
    mailserver.close()
    mailserver.logout()    
    print(datetime.datetime.now())
    x = filecmp.cmp("d:\wh\man_data.sql","d:\wh\old_man_data.sql")
    #x = 0
    if x == 0:
        #os.rename("d:\wh\man_data.sql","d:\wh\old_man_data.sql")
        shutil.copyfile('d:\wh\man_data.sql', 'd:\wh\old_man_data.sql')
        time.sleep (2)   
        #win32api.keybd_event(17,0,0,0)
        #win32api.keybd_event(16,0,0,0)
        #win32api.keybd_event(46,0,0,0)

        #os.system("notepad")
        #os.system('C:/test.bat')
        
        #k = 0
        #while k < 10:
        #     time.sleep (1)
        #    playsound('d:\wh\Windows Error.wav')
        #     k = k + 1
        #top = Tk() 
        #top.withdraw()
        #messagebox.showinfo("message","new message")
        root = Tk()
        root.wm_attributes('-topmost',1)
        root.withdraw()
        messagebox.showinfo("message","erro")

    
scheduler = BlockingScheduler()
scheduler.add_job(job_function, 'cron', day_of_week='0-6', minute="*/1")
scheduler.start()
