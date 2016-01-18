#!/usr/bin/env python
# -*- coding: utf-8 -*-
#!/usr/bin/python
# Filename: using_file.py
import requests as rq
import re
import pandas as pd
pageNumber = 50
startPageNumber = 551
for i in range(startPageNumber, startPageNumber+pageNumber+1):
	URL_BEGIN = 'http://rate.tmall.com/list_detail_rate.htm?itemId=21847180765&sellerId=890482188&currentPage='
	url = URL_BEGIN+str(i)
	myweb = rq.get(url)
	myjson = re.findall('\"rateList\":(\[.*?\])\,\"tags\"',myweb.text)[0].encode('utf-8')
	f = file('rate551.json', 'a') # open for 'w'riting
	f.write(myjson) # write text to file
	f.close() # close the file
	i = i + 1

# def crawl(url):
	# myweb = rq.get(url)
	# myjson = re.findall('\"rateList\":(\[.*?\])\,\"tags\"',myweb.text)[0].encode('utf-8')
	# return myjson

# URL_BEGIN = 'http://rate.tmall.com/list_detail_rate.htm?itemId=21847180765&sellerId=890482188&currentPage='

# start_urls =["http://rate.tmall.com/list_detail_rate.htm?itemId=21847180765&sellerId=890482188&currentPage=1"]

# for i in range(2, pageNumber+1):
	# start_urls.append(URL_BEGIN+str(i))
# frames = [pd.read_json(crawl(u)) for u in start_urls]
# result = pd.concat(frames, ignore_index=True)
# result.to_json('mytable.json')



