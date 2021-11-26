library(tidyr)
library(dplyr)
library(ggplot2)
library(glue)

rm(list=ls())

season = 36

raw.data = c(
  1,1,1,
  1,2,1,
  1,1,1,
  2,1,1,
  2,1,3,
  1,1,5,
  1,1,1,
  1,1,3,
  1,1,1,
  1,1,3,
  1,1,1,
  1,1,1,
  3,1,1,
  1,1,1,
  1,1,1,
  1,1,1,
  1,1,4,
  1,5,5,
  1,1,1,
  1,1,1,
  1,1,1,
  1,1,1,
  3,1,1,
  1,1,1,
  3,1,1,
  2,1,1,
  1,2,2,
  1,1,1,
  3,2,1
)

ranking.score = 
  tribble(
    ~ranking, ~score,
    1, 12,
    2, 8,
    3, 5,
    4, 3,
    5, 0
  )

data = 
  data.frame(
    season,
    ranking = raw.data
  ) %>% 
  inner_join(ranking.score, by='ranking') %>%
  transmute(
    season,
    ranking,
    score = score,
    total.score = cumsum(score),
    total.round = 1:n(),
    daily.round = (total.round %% 3) + 1,
    day = rep(1:31, each=3) %>% head(n())
  )

total.score = 
  data %>% tail(1) %>% .$total.score

data %>%
  mutate(colour = ifelse(ranking > 1, TRUE, FALSE)) %>%
  group_by(day) %>%
  mutate(count = 1:n()) %>%
  ggplot(aes(x=day, y=count)) +
  geom_text(aes(label=ranking, color=colour)) +
  scale_x_continuous(limits=c(1,31), breaks=1:31, expand=c(.03,.03)) +
  scale_y_continuous(limits=c(1,3), breaks=1:3, expand = c(.2,.1)) +
  scale_color_manual(values=c('black','red')) +
  labs(
    title = glue('BS Season {season} : Day of Errors'), 
    subtitle = glue('Total Score : {total.score}'), 
    y='Round', x='Day'
  ) +
  theme_bw() +
  theme(
    panel.grid.minor.x = element_blank(),
    legend.position = 'none'
  )
