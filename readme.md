Get similar companies via scraping linked in.

Its a rails app, `clone`, `bundle` `rake db:create db:migrate`, `localhost:3000`

You can run the crawler by running `SelfScraper.begin("google")` in `rails console`. This example will start
at the Google  page and move to "related" pages from there. 