# encoding:utf-8
import json
import re
import os
import filecmp
import urllib.request
import requests

r = requests.get('https://api-ddc.wallstcn.com/market/real?fields=symbol%2Cen_name%2Cprod_name%2Clast_px%2Cpx_change%2Cpx_change_rate%2Chigh_px%2Clow_px%2Copen_px%2Cpreclose_px%2Cmarket_value%2Cturnover_volume%2Cturnover_ratio%2Cturnover_value%2Cdyn_pb_rate%2Camplitude%2Cdyn_pe%2Ctrade_status%2Ccirculation_value%2Cupdate_time%2Cprice_precision%2Cweek_52_high%2Cweek_52_low%2Cstatic_pe%2Csource&prod_code=XAUUSD.OTC')
#print(type(r.text))

json_str=r.text
results=json.loads(json_str)
print(results)
print(type(results))

total = results['data']['snapshot']['XAUUSD.OTC'][2]
print (total)
