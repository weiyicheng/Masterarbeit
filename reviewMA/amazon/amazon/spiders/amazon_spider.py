import scrapy

from amazon.items import AmazonItem


class AmazonSpider(scrapy.Spider):
	name = "amazon"
	## product url hier
	URL_BEGIN = "http://www.amazon.de/product-reviews/B0068VPN34/ref=cm_cr_pr_top_link_"
	URL_FILTER = "?ie=UTF8&pageNumber="
	URL_END = "&showViewpoints=0&sortBy=byRankDescending"
	## wie viele Webseite fuer reviews gibt es
	pageNumber = 7
	start_urls = ["hhttp://www.amazon.de/product-reviews/B0068VPN34/ref=cm_cr_pr_top_link_1?ie=UTF8&showViewpoints=0&sortBy=byRankDescending"]
	# i=2
	for i in range(2, pageNumber+1):
		start_urls.append(URL_BEGIN+str(i)+URL_FILTER+str(i)+URL_END)
		i = i + 1
	# start_urls = ["http://www.amazon.de/product-reviews/B00HHVFM6C/ref=cm_cr_pr_top_link_2?ie=UTF8&pageNumber=1&showViewpoints=0&sortBy=byRankDescending","http://www.amazon.de/product-reviews/B00HHVFM6C/ref=cm_cr_pr_top_link_2?ie=UTF8&pageNumber=2&showViewpoints=0&sortBy=byRankDescending", "http://www.amazon.de/product-reviews/B00HHVFM6C/ref=cm_cr_pr_top_link_3?ie=UTF8&pageNumber=3&showViewpoints=0&sortBy=byRankDescending","http://www.amazon.de/product-reviews/B00HHVFM6C/ref=cm_cr_pr_top_link_4?ie=UTF8&pageNumber=4&showViewpoints=0&sortBy=byRankDescending"]
	def parse(self, response):
		table = response.xpath('//*[@id="productReviews"]')
		divs = table.xpath('.//div[contains(@style, "margin-left:0.5em;")]')
		for div in divs:
			item = AmazonItem()
			item['titel'] = div.xpath('.//span[contains(@style, "vertical-align:middle;")]/b/text()').extract()
			item['beschreibung'] = div.xpath('.//div[@class="reviewText"]/text()').extract()
			item['sterne'] = div.xpath('.//span[contains(@class, "swSprite s_star_")]/span/text()').extract()
			item['zeit'] = div.xpath('.//span[contains(@style, "vertical-align:middle;")]/nobr/text()').extract()
			yield item
