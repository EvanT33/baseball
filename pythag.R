setwd("C:/Users/ethompson/Desktop/baseball")

library(dplyr)
library(ggplot2)



# "teamID", "yearID", "lgID", "G", "W", "L", "R", "RA"

Teams_2018 <- read.csv("Teams_2018.csv")

Teams_2018 <-
  Teams_2018 %>%
  mutate(year = 2018) %>%
  select(Tm, year, Lg, G, W, L, R, RA) %>%
  filter(Tm != "Avg")


Teams_2018$RD <- with(Teams_2018, R-RA)
Teams_2018$Wpct <- with(Teams_2018, W/(W+L))

plot(Teams_2018$RD, Teams_2018$Wpct, xlab="run differential", ylab="winning percentage")

linfit <- lm(Wpct ~ RD, data=Teams_2018)
linfit

abline(a=coef(linfit)[1], b=coef(linfit)[2], lwd=2)

Teams_2018$linWpct <- predict(linfit)
Teams_2018$linResiduals <- residuals(linfit)

plot(Teams_2018$RD, Teams_2018$linResiduals,
     xlab="run differential", ylab="residual")
abline(h=0, lty=3)

ggplot(data=Teams_2018, aes(RD, linResiduals)) + 
  geom_point( 
    col="red", 
    fill="green", 
    alpha = .8) + 
  labs(title="Residuals of Linear Model") +
  labs(x="run differential/game") +
  labs(y = "residual") +
  geom_text(aes(label = paste(Tm, "", sep = "")), nudge_y = .007,
            parse = TRUE)


# rmse for linear model is .03999
mean(Teams_2018$linResiduals)
linRMSE <- sqrt(mean(Teams_2018$linResiduals ^2))
linRMSE

nrow(subset(Teams_2018, abs(linResiduals) < linRMSE)) / nrow(Teams_2018)
nrow(subset(Teams_2018, abs(linResiduals) < 2*linRMSE)) / nrow(Teams_2018)



# build "classic" pythag model (exponent = 2)

Teams_2018$pytWpct <- with(Teams_2018, R^2/(R^2+RA^2))
Teams_2018$pytResiduals <- Teams_2018$Wpct - Teams_2018$pytWpct
sqrt(mean(Teams_2018$pytResiduals^2))

#abline(a=coef(pytFit)[1], b=coef(pytFit)[2], lwd=2)

# points(c(66,88), c(0.749, -0.0733), pch=19)
# text(68, .0749, "LAA '08", pos=4, cex=.8)
# text(88, -.0733, "CLE '06", pos=4, cex=.8)

plot(Teams_2018$RD, Teams_2018$pytResiduals,
     xlab="run differential", ylab="residual")
abline(h=0, lty=3)



# plot residuals of classic pythag model
ggplot(data=Teams_2018, aes(RD, pytResiduals)) + 
  geom_point( 
    col="red", 
    fill="green", 
    alpha = .8) + 
  labs(title="Residuals of Classic Pythagorean Model") +
  labs(x="run differential/game") +
  labs(y = "residual") +
  geom_text(aes(label = paste(Tm, "", sep = "")), nudge_y = .007,
            parse = TRUE) +
  geom_hline(yintercept=0)



# build fitted pythag model

Teams_2018$logWratio <- log(Teams_2018$W / Teams_2018$L)
Teams_2018$logRratio <- log(Teams_2018$R / Teams_2018$RA)

pytFittedModel <- lm(logWratio ~ 0 + logRratio, data=Teams_2018)
pytFittedModel
# the fitted Pythag model coefficient for 2018 is 1.598

# adjust classic model coefficients to fitted model
Teams_2018$pytFittedWpct <- with(Teams_2018, R^1.598 / (R^1.598 + RA^1.598))
# Teams_2018$Wpct <- with(Teams_2018, W/(W+L))
Teams_2018$pytFittedResiduals <- with(Teams_2018, Wpct - pytFittedWpct)

sqrt(mean(Teams_2018$pytFittedResiduals^2))

# plot fitted pythag model residuals
ggplot(data=Teams_2018, aes(RD, pytFittedResiduals)) + 
  geom_point( 
    col="red", 
    fill="green", 
    alpha = .8) + 
  labs(title="Residuals of Fitted Pythagorean Model") +
  labs(x="run differential/game") +
  labs(y = "residual") +
  geom_text(aes(label = paste(Tm, "", sep = "")), nudge_y = .007,
            parse = TRUE) +
  geom_hline(yintercept=0) + ggsave("Residauls of Fitted Pythag Model.jpeg")

