# clean-sketch-svg

See `twitter-before.svg` and `twitter-after.svg`. 

It depends on **nokogiri**. To install:

```sh
$ gem install nokogiri
```

It's a ruby script that reads from `stdin` and writes to `stdout`. 

```sh
$ ruby cleansvg.rb < twitter-before.svg > twitter-after.svg
```

Sometimes it's nice to copy and paste.

```sh
$ cat twitter-before.svg | ruby cleansvg.rb | pbcopy
```

**Beer License**. Enjoy.
