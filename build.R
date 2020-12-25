# initial setting
packages.needed <- c('dplyr', 'stringr')
packages.installed <- installed.packages() %>% rownames()
packages.not.installed <- packages.needed[!packages.needed %in% packages.installed]

# package install
installed.packages(packages.not.installed)

# package load
for(p in packages.needed) require(p, character.only=TRUE)

# write README.md
readme.content <- "
<div align='center'>
  <img src='./assets/hades_logo.png' alt='logo'>
</div>

# hades-star-diary
Diary for hades' star : https://store.steampowered.com/app/755800
"

write.text <- function(path, text){
  fc <- file(path)
  writeLines(text, fc)
  close(fc)
}

write.text('README.md', readme.content)
