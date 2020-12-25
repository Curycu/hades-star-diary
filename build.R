rm(list=ls())

# initial setting ===============
packages.needed <- c('dplyr', 'stringr', 'glue')
packages.installed <- installed.packages() %>% rownames()
packages.not.installed <- packages.needed[!packages.needed %in% packages.installed]

# package install ===============
installed.packages(packages.not.installed)

# package load ===============
for(p in packages.needed) require(p, character.only=TRUE)

# build README.md ===============
readme.file <- 'README.md'
article.dir <- 'articles'
asset.dir <- 'assets'

readme.base <- 
  "<div align='center'>
  <img src='./assets/logo.png' alt='logo'>
</div>

# Hades' Star Diary
Diary for [Hades' Star](https://store.steampowered.com/app/755800) :ringed_planet:

# Table of Contents"

write(readme.base, file=readme.file)

articles <- 
  list.files(article.dir) %>% 
  tibble(file.name = .) %>% 
  mutate(
    year = substring(file.name, 1, 4),
    month = substring(file.name, 5, 6),
    day = substring(file.name, 7, 8),
    title = str_replace_all(file.name, '\\.md', '') %>% str_replace_all('^\\d{8}', ''),
    date.str = paste(year, month, day, sep='-')
  ) %>%
  arrange(desc(date.str))

first.play.day <- '2020-06-29'

# append article links ===============
for(a in 1:nrow(articles)){
  
  date.str <- articles[a, "date.str"] %>% .[[1]]
  day.gap <- as.integer(as.Date(date.str) - as.Date(first.play.day) + 1)
  
  title <- articles[a, "title"] %>% .[[1]]
  title <- str_replace_all(title, '_', ' ')
  title <- str_trim(title)
  title <- ifelse(title == '', 'No Title', title)
  
  file.name.no.extension <- articles[a, 'file.name'] %>% str_remove('.md')
  article.file <- articles[a, "file.name"] %>% .[[1]]
  article.image.files <- list.files(asset.dir, file.name.no.extension)
  
  article.content <- 
    readLines(glue('./{article.dir}/{article.file}'), encoding='UTF-8') %>% 
    paste(collapse='<br/>')
  
  article.link <- 
    if(length(article.image.files) > 0){
      image.links <- sapply(article.image.files, function(x) glue('<image src="./{asset.dir}/{x}" align="center">'))
      image.links <- paste(image.links, collapse='\n')
      glue('
        <details>
          <summary>Day {day.gap} - {title}</summary>
          {article.content}
          <br/>
          {image.links}
        </details>
      ')
    }else{
      glue('
        <details>
          <summary>Day {day.gap} - {title}</summary>
          {article.content}
        </details>
      ')
    }
    
  write(article.link, file=readme.file, append=TRUE)
}
