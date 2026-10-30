# Banner for the home page: Eskom daily peak demand (same series as Project 3)
# Run from the repo root: Rscript images/make_banner.R

library(ggplot2)

daily <- readRDS(here::here("data", "eskom_daily_peak.rds"))

p <- ggplot(daily, aes(date, peak)) +
  geom_line(colour = "white", alpha = 0.35, linewidth = 0.3) +
  theme_void() +
  theme(plot.background = element_rect(fill = "#1f3a5f", colour = NA))

ggsave(here::here("images", "banner.png"), p, width = 12, height = 2.5, dpi = 200)
