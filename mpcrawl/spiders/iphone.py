import scrapy
import scrapy.loader
import re

from mpcrawl.items import Product


class iphoneScraper(scrapy.Spider):
    name = "iphone_scraper"
    start_urls = ['https://www.marktplaats.nl/q/iphone/p/1/#limit:100']

    def parse(self, response):
      list_frames = response.xpath(".//li[@class='mp-Listing mp-Listing--list-item ']")

      if not list_frames:
        self.logger.info('No more data.')
      else:
        for selector in list_frames:
          # Save all elements
          l = scrapy.loader.ItemLoader(item=Product(), selector=selector)
          l.add_xpath('title', 'string(.//h3[@class="mp-Listing-title"])')
          l.add_xpath('description', 'string(.//p[@class="mp-Listing-description mp-text-paragraph"])')
          l.add_xpath('price', 'string(.//span[@class="mp-Listing-price mp-text-price-label"])')
          l.add_xpath('date', 'string(.//span[@class="mp-Listing-date mp-Listing-date--desktop"])')
          l.add_xpath('priority', 'string(.//span[@class="mp-Listing-priority"])')
          l.add_xpath('seller', 'string(.//span[@class="mp-Listing-seller-name"])')
          l.add_xpath('location', 'string(.//span[@class="mp-Listing-location"])')

          # Execute xpath searches and process item
          l.load_item()

        current_page = int(re.search(r'(?:p/)(\d+)', response.request.url)[1])

        if current_page < 30:
          next_url = re.sub(r'p/\d+', 'p/' + str(current_page+1), response.request.url)
          yield scrapy.Request(next_url, callback=self.parse)

