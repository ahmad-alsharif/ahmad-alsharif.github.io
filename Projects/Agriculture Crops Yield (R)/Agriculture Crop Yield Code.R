#### Installing and loading required libraries ####
library(tidyverse)
library(dplyr)
library(ggplot2)
library(tidyr)
library(class)


#### Loading the dataset ####
crops <- read_csv('E:/Data Analysis/SAIT/DATA 420 - Predictive Analytics/Assignments/Agriculture crop yield/crop_yield.csv')
glimpse(crops)


#### Renaming variables ####
crops <- crops %>% 
  rename(region=Region,
         soilType=Soil_Type,
         crop=Crop,
         rainfall=Rainfall_mm,
         temperature=Temperature_Celsius,
         fertilizer=Fertilizer_Used,
         irrigation=Irrigation_Used,
         weather=Weather_Condition,
         harvestingDays=Days_to_Harvest,
         totalYield=Yield_tons_per_hectare)
glimpse(crops)


#### Transforming data types ####
crops <- crops %>% 
  mutate(region=as.factor(region),
         soilType=as.factor(soilType),
         crop=as.factor(crop),
         weather=as.factor(weather))
glimpse(crops)


#### Filtering data & Selecting relevant variables ####
crops <- crops %>% 
  filter(region == 'South' & soilType == 'Clay' & weather == 'Sunny') %>% 
  select(-region, -soilType, -weather)
  

#### Adding residuals & Correlation to the dataset ####
crops <- crops %>% 
  group_by(crop) %>% 
  mutate(residuals = residuals(lm(totalYield ~ rainfall + temperature, data = cur_data())), # cur_data() refers to the current data being used
         rainCor = cor(crops$rainfall, crops$totalYield),
         tempCor = cor(crops$temperature, crops$totalYield))
glimpse(crops)


#### sub-setting the dataset by crops ####
unique(crops$crop)

# Cotton
cotton_yield <- subset(crops, crop == 'Cotton')
cotton_yield
# Rice
rice_yield <- cotton_yield <- subset(crops, crop == 'Rice')
rice_yield
# Barley
barley_yield <- cotton_yield <- subset(crops, crop == 'Barley')
barley_yield
# Soybean
soybean_yield <- cotton_yield <- subset(crops, crop == 'Soybean')
soybean_yield
# Wheat
wheat_yield <- cotton_yield <- subset(crops, crop == 'Wheat')
wheat_yield
# Maize
maize_yield <- cotton_yield <- subset(crops, crop == 'Maize')
maize_yield


#### Data modeling ####
# Multiple regression analysis
harvest_model <- lm(harvestingDays ~ temperature+rainfall , data=crops)
summary(harvest_model)
coef(harvest_model)

crops_model <- lm(totalYield ~ rainfall+temperature, data=crops)
summary(crops_model)
coef(crops_model)

# Correlations
cor(crops$rainfall, crops$totalYield) # Total yield is strongly affected by rainfall
cor(crops$temperature, crops$totalYield) # The affect of temperature on total yield is minimal

cor(crops$rainfall, crops$harvestingDays) # Harvesting days are not affected by rainfall
cor(crops$temperature, crops$harvestingDays) # Harvesting days are not affected by temperature


#### Predictive Analytics ####
# Ranges
rainfall_range <- seq(min(crops$rainfall), max(crops$rainfall), length.out = 100)
temperature_range <- seq(min(crops$temperature), max(crops$temperature), length.out = 100)
prediction_grid <- expand.grid(rainfall = rainfall_range, temperature = temperature_range) # unique combination of rainfall and temperature

# Model
predict_model <- lm(totalYield ~ rainfall + temperature, data = crops)

# Predictions
prediction_grid$predicted_yield <- predict(predict_model, newdata = prediction_grid)

# Optimal ranges
optimal_ranges <- prediction_grid %>%
  summarise(optimal_rainfall = rainfall[max(predicted_yield)],
            optimal_temperature = temperature[max(predicted_yield)])
print(optimal_ranges)


#### Visualization ####
# rainfall Vs. totalYield (for each crop)
ggplot(crops, aes(x = rainfall, y = totalYield, color = crop)) +
  labs(title = 'Rainfall vs. Yield for Each Crop', 
       x = 'Rainfall (mm)', 
       y = 'Total yield (Tons/Hectare)') +
  geom_point() +
  geom_smooth(method = 'lm', col='blue') +
  facet_wrap(~ crop)

# rainfall Vs. totalYield (Fertilizer)
ggplot(crops, aes(x = rainfall, y = totalYield, color = fertilizer)) +
  labs(title='Rainfall Vs. Total Yield (Effect of Fertilizer on Crops)',
       x='Rainfall (mm)', 
       y='Total yield (Tons/Hectare)') +
  geom_point()+
  geom_smooth(method='lm', col='brown') +
  facet_wrap(~ crop)

# rainfall Vs. totalYield (Irrigation)
ggplot(crops, aes(x = rainfall, y = totalYield, color = irrigation)) +
  labs(title='Rainfall Vs. Total Yield (Effect of Irrigation on Crops)',
       x='Rainfall (mm)', 
       y='Total yield (Tons/Hectare)') +
  geom_point()+
  geom_smooth(method='lm', col='brown') +
  facet_wrap(~ crop)

# rainfall Vs. residuals (for each crop)
ggplot(crops, aes(x = rainfall, y = residuals, color = crop)) +
  labs(title='Rainfall Vs. Residuals for Each Crop',
       x='Rainfall (mm)', 
       y='Residuals') +
  geom_point()+
  geom_smooth(method='lm', col='black') +
  facet_wrap(~ crop)

# Prediction of Rainfall on Total Yield
ggplot(prediction_grid, aes(x = rainfall, y = predicted_yield)) +
  labs(title='Prediction: Rainfall Vs. Predicted Yield',
       x='Rainfall (mm)', 
       y='Total Yield') +
  geom_point()+
  geom_smooth(method='lm', col='orange')

# Prediction of Temperature on Total Yield
ggplot(prediction_grid, aes(x = temperature, y = predicted_yield)) +
  labs(title='Prediction: Temperature Vs. Predicted Yield',
       x='Temperature °C', 
       y='Total Yield') +
  geom_point()+
  geom_smooth(method='lm', col='orange')