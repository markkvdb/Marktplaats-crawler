import scrapy
import scrapy.loader
import re
from datetime import date

from mpcrawl.items import Product


class iphoneScraper(scrapy.Spider):
  name = "iphone_scraper"
  start_urls = ['https://www.marktplaats.nl/l/telecommunicatie/mobiele-telefoons-apple-iphone/p/1/']


  def parse(self, response):
    listing_links = response.xpath(".//a[@class='mp-Listing-coverLink']/@href").getall()

    if not listing_links:
      self.logger.info('No more data.')
    else:
      for link in listing_links:
        # Save all elements
        yield response.follow(link, self.process_listing)

      # Find next page and visit (site nevers gives a 404 error)
      current_page = int(re.search(r'(?:p/)(\d+)', response.request.url)[1])
      next_url = re.sub(r'p/\d+', 'p/' + str(current_page+1), response.request.url)
      
      yield scrapy.Request(next_url, callback=self.parse)
  

  def process_listing(self, response):
    # Create item loader object to save all listing info
    l = scrapy.loader.ItemLoader(item=Product(), response=response)

    # Get url and type
    listing_id = re.search(r'([am]\d+)-.*$', response.request.url)[1]

    # Extract information from page
    l.add_value('url', listing_id)
    l.add_xpath('title', 'string(//*[@id="title"])')
    l.add_xpath('price', 'string(//*[@id="content"]/section/section[1]/section[1]/section[3]/div[1]/span)')
    l.add_xpath('views', 'string(//*[@id="view-count"])')
    l.add_xpath('date', 'string(//*[@id="displayed-since"]/span[3])')
    l.add_xpath('description', 'normalize-space(//*[@id="vip-ad-description"])')
    l.add_xpath('seller', 'normalize-space(//*[@id="vip-seller"]/div[1]/div[1]/a/h2)')
    l.add_xpath('location', 'normalize-space(//*[@id="vip-map-show"])')
    l.add_value('scrap_date', date.today().strftime("%d/%m/%Y"))

    yield l.load_item()