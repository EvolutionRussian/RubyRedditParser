<p align="center">
  <img src="/image/icon.png" height="150">
</p>

<h2 align="center">RedditParser</h2>

<h3 align="center"> Parser for the reddit community to search for images, gifs and video </h3>
<h3 align="center"> Using this parser you can get a txt sheet with links to files, and also download the result </h3>

<p align="center">
  <a href="https://www.ruby-lang.org"><img src="https://img.shields.io/badge/Ruby-%23CC342D?style=for-the-badge&logo=ruby&logoColor=white"></a>
  <a href="https://www.linux.org"><img src="https://img.shields.io/badge/Linux-%23FCC624?style=for-the-badge&logo=linux&logoColor=black"></a>
</p>


### Download Pakets

Downloading Ruby and Bundle for Debian family

```bash
sudo apt install ruby && gem install bundler
```

Downloading Ruby and Bundle for Arch family

```bash
sudo pacman -S ruby && gem install bundler
```

### Download Repository

```bash
git clone https://github.com/EvolutionRussian/RubyRedditParser
```
```bash
cd RubyRedditParser
```
```bash
sudo bundle install
```
### Go to reddit and copy the community names
<img src="/image/1.png" height="500">

```bash
ruby RedditParser.rb
```

### Then we go to the repository and run the script using the first or second method.
<img src="/image/2.png" height="600">

### After running the script, a txt file with links will be automatically created.

```bash
ruby RedditParser.rb animegifs -d
```

### You can specify the name of the community when starting, and by specifying the <code>-d</code> key, the result will be downloaded
<img src="/image/3.png" height="600">

### I hope it helps someone (╯✧▽✧)╯

<img align="center" src="/image/4.gif" width="700">



