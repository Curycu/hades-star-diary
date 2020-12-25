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

readme.base <- 
"<div align='center'>
  <img src='./assets/hades_logo.png' alt='logo'>
</div>

# Hades' Star Diary
Diary for [Hades' Star](https://store.steampowered.com/app/755800) :dizzy:

# Table of Contents"

write(readme.base, file=readme.file)

articles <- 
  list.files('articles') %>% 
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
  
  article.file <- articles[a, "file.name"] %>% .[[1]]
  
  title <- articles[a, "title"] %>% .[[1]]
  title <- str_replace_all(title, '_', ' ')
  title <- str_trim(title)
  title <- ifelse(title == '', 'No Title', title)
  
  date.str.compact <- str_replace_all(date.str, '-', '')
  title.underscore <- str_replace_all(title, ' ', '_')
  article.previews <- list.files('./assets', glue('^{date.str.compact}_{title.underscore}'))
  
  article.link <- 
    if(length(article.previews) == 0){
      glue('  
      <details>
        <summary>
          <a href="./articles/{article.file} target="_blank">Day {day.gap}: {title}</a>,
        </summary>
      </details>
      ')
    }else{
      article.preview.img.src <- sapply(article.previews, function(x) glue('<img src="./assets/{x}">'))
      article.preview.img.src <- paste0(article.preview.img.src, collapse='\n  ')
      
      glue('  
      <details>
        <summary>
          <a href="./articles/{article.file} target="_blank">Day {day.gap}: {title}</a>,
        </summary>
        {article.preview.img.src}
      </details>
      ')
    }
  
  write(article.link, file=readme.file, append=TRUE)
}
