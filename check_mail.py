#!/usr/bin/env python
 
import imaplib
import re
 
def LoginMail(hostname, user, password):
    r = imaplib.IMAP4_SSL(hostname)
    r.login(user, password)
    x, y = r.status('INBOX', '(MESSAGES UNSEEN)')
    allmes, unseenmes = mes,unmes = re.match(r'.*\s+(\d+)\s+.*\s+(\d+)', y[0]).groups()
    tomail = ('%s have  %s message, %s is unseenmes'  % (user, allmes, unseenmes))
    with open('tomail.txt', 'a+') as f:
        f.write( tomail + '\n' )     
    r.logout()
 
 
if __name__ == '__main__':
    LoginMail('imap.163.com', 'you mail', 'you password') 
    import smtplib
    from email.mime.text import MIMEText
 
    fp = open('tomail.txt', 'rb')
    msg = MIMEText(fp.read())
    fp.close()
 
    msg['Subject'] = 'The all mail messages'
    msg['from'] = 'your mail address'
    msg['To'] = 'a mail address is accept info'
 
 
    s = smtplib.SMTP()
    s.connect('smtp.163.com')
    s.login('your mail address', 'you password')
    s.sendmail('your mail address', ['a mail address is accept info''], msg.as_string())
    s.quit
