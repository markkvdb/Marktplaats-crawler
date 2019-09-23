# Marktplaats-crawler

This project contains a webscraper that scrapes all listings for a user-given search term. Scraped dataset is analysed using an R script that cleans and transforms the raw dataset and subsequently analyses it.

## Getting Started

These instruction will get you a copy of the project up and running. I provide the instructions using the Anaconda environment but this project can be built using pip as well. Furthermore, I give the instructions for MacOS.

### Prerequisites

You have to download Anaconda and activate the appriorate virtual environment, e.g. create environment `mpcrawler`.

```bash
conda create mpcrawler
conda activate mpcrawler
```

You also need MongoDB Community to store all scraped data. install MongoDB, start it, and create a database under the name `mpcrawler`. For MacOS, you can do:

```bash
brew install mongodb-community

# Activate mongo manually
mongod --config /usr/local/etc/mongod.conf
```

### Installing

Second, we download the project using github in a chosen location and open it.

```bash
git clone https://github.com/markkvdb/Marktplaats-crawler.git
cd Marktplaats-crawler
```

We need a few python modules to run the program.

```bash
conda env create -f environment.yml
```

### Run

Activate and run the scraper (this can take a while).

```python
scrapy crawl iphone_scraper
```

Now, it's up to you whether you want to analayse the output using the R script analysis.R provided in the `R` folder.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details
