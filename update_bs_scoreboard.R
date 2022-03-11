library(dplyr)
library(ggplot2)
library(glue)

rm(list=ls())

season = 39

ranking = c(
  1,2,2,
  2,1,1,
  1,1,1,
  1,1,1,
  2,3,1,
  1,1,1,
  2,4,1,
  1,1,1,
  1,1,1,
  2,1,1,
  1,2,1,
  1,2,3,
  1,1,1,
  1,1,1,
  1,2,1,
  1,1,1,
  1,2,1,
  1,2,1,
  1,1,1,
  1,1,1,
  4,1,1,
  1,1,2,
  1,1,1,
  1,2,2,
  1,1,1,
  1,1,1,
  1,1,1,
  1,1,1,
  1,1,1,
  3,1,1,
  1,1,1
)

total_round = length(ranking)
ranking_score = c(12,8,5,3,0)

data = 
  data.frame(season, ranking) %>% 
  transmute(
    season,
    ranking,
    score = ranking_score[ranking],
    total_score = cumsum(coalesce(score, 0)),
    daily_round = rep(1:3, times=31) %>% head(total_round),
    day = rep(1:31, each=3) %>% head(total_round)
  )

last_data = data %>% tail(1)
total_score = last_data$total_score
ideal_total_score = total_round * ranking_score[1]
missing_score = ideal_total_score - total_score

data %>%
  mutate(is_error = ifelse(ranking > 1, TRUE, FALSE)) %>%
  group_by(day) %>%
  mutate(count = 1:n()) %>%
  ggplot(aes(x=day, y=count)) +
  geom_text(aes(label=ranking, color=is_error)) +
  scale_x_continuous(limits=c(1,31), breaks=1:31, expand=c(.03,.03)) +
  scale_y_continuous(limits=c(1,3), breaks=1:3, expand = c(.2,.1)) +
  scale_color_manual(values=c('black','red')) +
  labs(
    title = glue('BS Season {season} : Day of Errors'), 
    subtitle = glue('Total Score : {total_score} (= {ideal_total_score} - {missing_score})'), 
    y='Round', x='Day'
  ) +
  theme_bw() +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = 'none'
  )
