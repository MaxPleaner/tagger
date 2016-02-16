Get similar companies via scraping linked in.

It requires one environment variable to be set, `MONKEY_LEARN_TOKEN` which is an api key from
[monkeylearn.com](http://monkeylearn.com) 

Its a rails app, `clone`, `bundle` `rake db:create db:migrate`, `localhost:3000`

You can run the crawler by running `SelfScraper.begin("google")` in `rails console`. This example will start
at the Google  page and move to "related" pages from there. This will load up the 
'companies' list and the 'tags' list. Note the 'clear cache' button actually wipes the
entire database. 

This is a HTML scaper, not an authenticated API application, so it probably has
more severe rate limits. `999` errors means the IP address is being throttled. 
