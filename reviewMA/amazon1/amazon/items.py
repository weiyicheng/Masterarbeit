# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class AmazonItem(scrapy.Item):
	titel = scrapy.Field()
	sterne = scrapy.Field()
	beschreibung = scrapy.Field()
	zeit = scrapy.Field()
    # pass