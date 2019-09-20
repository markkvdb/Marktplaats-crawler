import scrapy


class Product(scrapy.Item):
  title = scrapy.Field()
  description = scrapy.Field()
  price = scrapy.Field()
  date = scrapy.Field()
  priority = scrapy.Field()
  seller = scrapy.Field()
  location = scrapy.Field()