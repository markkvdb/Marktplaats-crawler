import scrapy


class Product(scrapy.Item):
  url = scrapy.Field()
  title = scrapy.Field()
  description = scrapy.Field()
  price = scrapy.Field()
  date = scrapy.Field()
  views = scrapy.Field()
  seller = scrapy.Field()
  location = scrapy.Field()
  scrap_date = scrapy.Field()