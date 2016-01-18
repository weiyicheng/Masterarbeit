# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class TmallItem(scrapy.Item):
	rate_premiere_titel = scrapy.Field()
	rate_premiere_date = scrapy.Field()
	rate_premiere_content = scrapy.Field()
	rate_photos_href = scrapy.Field()
	rate_append_titel = scrapy.Field()
	rate_append_date = scrapy.Field()
	rate_append_content = scrapy.Field()
	
    # define the fields for your item here like:
    # name = scrapy.Field()
    pass
