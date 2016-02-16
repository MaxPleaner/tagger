## Tagger

scrapes descriptions & tags for LinkedIn companies 

------

### Setup

It requires one environment variable to be set, `MONKEY_LEARN_TOKEN` which is an api key from
[monkeylearn.com](http://monkeylearn.com) 

Other than that, it's standard Rails:

`clone`, `bundle` `rake db:create db:migrate`, `localhost:3000`

### basic usage

  - Use the HTML interface at `localhost:3000`
  - Scraper command (call with `SelfScraper.begin("google")` in `rails c` when the server is running)

### details on scraper

You can run the crawler by running `SelfScraper.begin("google")` in `rails console`. This example will start
at the Google  page and move to "related" pages from there.
- This automatically interacts with the server using `Mechanize`.
- Eventually it will loop and stop finding new companies.
- This is because of the redundancy in LinkedIn's 'people also clicked' section.
- There are often small groups of companies which all link back to each other.
- When this happens, the scraper will need to be restarted with a new company name. 

Note the 'clear cache' button on the HTML site actually wipes the
entire database.  

This is a HTML scaper, not an authenticated API application, so it probably has
more severe rate limits. `999` errors means the IP address is being throttled. 

The bulk of the code is in [`application_controller.rb`](https://github.com/MaxPleaner/tagger/blob/master/app/controllers/application_controller.rb),
[`pages_controller.rb`](https://github.com/MaxPleaner/tagger/blob/master/app/controllers/pages_controller.rb),
[`pages/root.html.erb`](https://github.com/MaxPleaner/tagger/blob/master/app/views/pages/root.html.erb),
and [`application.rb`](https://github.com/MaxPleaner/tagger/blob/master/config/application.rb).