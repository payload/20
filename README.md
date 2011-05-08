# 20

* make entries by POSTing `/entry?name=$(name)&score=$(score)`
* you can POST multiple entries by repeating these parameters pairwise
* get a special top 10 by GETing `/top10/$(score)` where score is the score you want to submit later on

### using

* [CoffeeScript](http://jashkenas.github.com/coffee-script/)
* [GNU make](http://www.gnu.org/software/make/)
    * it sucks and does its job
    * also the Makefile is public domain
* [GNU AGPL 3](http://www.gnu.org/licenses/agpl.html)
    * this is free software
* http://flattr.com/
    * yes, you can give me money at http://flattr.com/thing/186537/20-a-highscore-server

