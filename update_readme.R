rm(list=ls())

# initial setting ===============
packages.needed <- c('dplyr', 'stringr', 'glue')
packages.installed <- rownames(installed.packages())
packages.not.installed <- packages.needed[!packages.needed %in% packages.installed]

# package install ===============
installed.packages(packages.not.installed)

# package load ===============
for(p in packages.needed) require(p, character.only=TRUE)

# write README.md ===============
readme.file <- 'README.md'
articles.dir <- 'articles'
assets.dir <- 'assets'
first.play.day <- '2020-06-29'

readme.base <- 
"<div align='center'>
  <img src='./assets/logo.png' alt='logo'>
</div>

# Hades' Star Diary
Diary for [Hades' Star](https://store.steampowered.com/app/755800) :ringed_planet:  
[Discord for KR users](http://discord.gg/TR5CJ2p)

# Table of Contents"

write(readme.base, file=readme.file)

articles <- 
  list.files(articles.dir) %>% 
  tibble(file.name = .) %>% 
  mutate(
    file.name.no.extension = file.name %>% str_remove('\\.md$'),
    title = file.name.no.extension %>% str_remove('^\\d{8}') %>% str_remove('^_') %>% str_trim,
    title = ifelse(title == '', 'No Title', title),
    date.str = paste(substring(file.name, 1, 4), substring(file.name, 5, 6), substring(file.name, 7, 8), sep='-')
  ) %>%
  arrange(desc(date.str))

# append articles to README.md ===============
for(a in 1:nrow(articles)){
  
  date.str <- articles[a, "date.str"] %>% .[[1]]
  day.gap <- (as.Date(date.str) - as.Date(first.play.day) + 1) %>% as.integer
  
  title <- articles[a, "title"] %>% .[[1]]
  file.name.no.extension <- articles[a, 'file.name.no.extension'] %>% .[[1]]
  
  article.file <- articles[a, "file.name"] %>% .[[1]]
  article.image.files <- list.files(assets.dir, file.name.no.extension)
  
  article.text.raw <- glue('./{articles.dir}/{article.file}') %>% readLines(encoding='UTF-8') %>% paste(collapse='<br/>')
  
  # remove redundant md image src, a href tags 
  # e.g) <br/>![](../assets/20201027_BS_Bond_Counter.png)
  # e.g) <br/>[youtube_video](https://youtu.be/TJeWz9vuZx8)<br/>
  article.text <- article.text.raw %>% str_replace_all('(<br/>)?\\!+\\[.*?\\]\\(.*?\\)(<br/>)?', '') %>% str_trim
  
  text.exists <- article.text != ''
  image.exists <- length(article.image.files) > 0
  
  image.html <- ''
  if(image.exists){
    image.html <- sapply(article.image.files, function(x) glue('<image src="./{assets.dir}/{x}" align="center">'))
    image.html <- paste(image.html, collapse='<br/><br/>')
  }
  
  article.html <- 
    if(image.exists & text.exists){
      glue('
        <details>
          <summary>Day {day.gap} - {title}</summary>
          <br/>{article.text}<br/>
          {image.html}
        </details>
      ')
    }else if(!image.exists & text.exists){
      glue('
        <details>
          <summary>Day {day.gap} - {title}</summary>
          <br/>{article.text}<br/>
        </details>
      ')
    }else if(image.exists & !text.exists){
      glue('
        <details>
          <summary>Day {day.gap} - {title}</summary>
          {image.html}
        </details>
      ')
    }else{
      glue('- Day {day.gap} - {title}')
    }
  
  article.html %>% write(file=readme.file, append=TRUE)
}
