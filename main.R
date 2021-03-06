# Read all functions
source('Functions.R')

# The availeble options are: Quinoa, Maiz, Amaranto
# And f and p for fiber and protein respectively
fact_desing('Maiz', 'p')

### Pareto Plots
# For protein
paret_3plantP <- lapply(c('Quinoa', 'Maiz', 'Amaranto'), make_3pareto, 'p')
pareto_p <- arrangePareto(paret_3plantP)
ggsave('pareto.png', pareto_p, width = 8, height = 3.5, 
       units = 'in', dpi = 600)

# for fiber
paret_3plantF <- lapply(c('Quinoa', 'Maiz', 'Amaranto'), make_3pareto, 'f')
pareto_f <- arrangePareto(paret_3plantF)

# Merge pareto plots for fiber and protein
grid.arrange(pareto_p, pareto_f)


# Source: https://cran.r-project.org/doc/contrib/Vikneswaran-ED_companion.pdf
png('desigPlot.png', width = 8, height = 3.5,
    units = 'in', res = 600)
par( mfrow = c( 1, 3 ) )
lapply(c('Quinoa', 'Maiz', 'Amaranto'), desingPlot, 'p')
dev.off()

# Interaction plot
# Maiz:     Tg & t
# Quinoa:    t & Tg
# Amaranto: Tr & t
png('interaction.png', width = 8, height = 3.5,
    units = 'in', res = 600)
par(mfrow = c(1, 3))
'Maiz_p' %>% readData() %>% 
  with((interaction.plot(Tg, t, Respuesta, 
                         ylab = 'Promedio del contenido de proteína (%)')))

'Quinoa_p' %>% readData() %>% 
  with((interaction.plot(t, Tg, Respuesta, 
                         ylab = 'Promedio del contenido de proteína (%)')))
'Amaranto_p' %>% readData() %>% 
  with((interaction.plot(Tr, t, Respuesta, 
                         ylab = 'Promedio del contenido de proteína (%)')))
dev.off()

# Data analysis for colada data
colada <- read_csv('colada.csv') %>%  select(- catadores) %>% 
  mutate(Formulación = factor( paste0("F",Formulación) ))
# Exploratory analysis
colada %>% ggplot(aes(x = Formulación,y = Aceptabilidad, 
                      fill = Formulación)) + 
  geom_boxplot() + guides(fill = F) + 
  scale_fill_grey(start = 0, end = .8) +
  theme_bw() + coord_flip()

ggsave('boxplot.png',width = 7.5, height = 4.5, 
       units = 'in', dpi = 600)
# For tukey test
AOVcolada <- aov(Aceptabilidad~Formulación, 
                 data = colada %>% filter(Formulación %in% 
                                            c("F2","F5", "F8")))
TUKcolada <- TukeyHSD(AOVcolada, "Formulación")
TUKcolada$Formulación %>%  as.data.frame %>% 
  mutate(Formulación = rownames(.), Medio = (lwr+upr)/2 ) %>% 
  gather(key = Tipo, value = Valores, lwr, upr, Medio) %>% 
  ggplot(aes(Formulación, Valores)) +
  geom_line() + geom_point(aes(shape = Formulación), size = 2) + 
  geom_text(aes(Formulación, max(Valores)+0.05,
                label = paste0('p = ',round(`p adj`, 2)) ), col = 'black') +
  
  theme_bw() + guides(color = F, shape = F, linetype =F) +
  geom_hline(yintercept = 0, color = 'gray40', linetype = 'dashed') +
  coord_flip()
ggsave('tukey.png',width = 7.5, height = 4.5, 
       units = 'in', dpi = 600)



