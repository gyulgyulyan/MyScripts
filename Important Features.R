library(plyr)
library(dplyr)
library(data.table)

## наши фичи
feat=c("ltv7",
        'trial_yes',
        'photos_uploaded_3',
        'signup_no',
        'photos_liked_5_9',
        'photos_liked_10_14',
        'photos_liked_40_49',
        'photos_liked_50',
        'ads_watched_10_14',
        'ads_watched_15_19',
        'ads_watched_20_29',
        'ads_watched_30_39',
        'ads_watched_40_49',
        'ads_watched_50_74',
        'ads_watched_75_99',
        'ads_watched_100_119',
        'ads_watched_120_149',
        'ads_watched_150_179',
        'ads_watched_180_199',
        'ads_watched_200',
        'matches_1',
        'matches_2',
        'messenger_views_5',
        'chat_views_1',
        'chat_views_3',
        'messages_sent_5',
        'messages_sent_6',
        'messages_sent_7',
        'messages_sent_9',
        'messages_sent_10',
        'messages_received_4',
        'messages_received_7',
        'messages_received_10',
        'conversations_started_2',
        'conversations_started_3',
        'conversations_started_5',
        'conversations_started_6',
        'conversations_started_7',
        'conversations_started_8',
        'conversations_started_9',
        'conversations_started_10',
        'conversations_accepted_2',
        'conversations_accepted_3',
        'conversations_accepted_4',
        'conversations_accepted_6',
        'conversations_accepted_8',
        'conversations_accepted_9',
        'dialogues_8',
        'dialogues_9',
        'dialogues_deep_1',
        'dialogues_deep_2',
        'dialogues_deep_3',
        'dialogues_deep_4',
        'dialogues_deep_5',
        'sessions_started_2',
        'sessions_started_3',
        'sessions_started_4',
        'sessions_started_5',
        'sessions_started_6',
        'sessions_started_7',
        'sessions_started_8',
        'sessions_started_9',
        'sessions_started_10')


# Загрузка данных
dt=read.csv("Documents/ML_task/task_1502.csv", header=T)
# Префичинг
dt=dt[dt$subscribe_yes==0,]
dt=dt[dt$ltv7>=0,]

## ЗАпускаем общую множественную линейную регрессию
lm_pred <- lm(ltv7 ~ .+0, data = dt[, c(4,22:26,28,30:180)], singular.ok = TRUE)
### смотрим на коэффициенты
coef=data.frame(coefficients(lm_pred))
##Смотрим описание модели, R^2, t-value, p-value, значимые фичи
summary(lm_pred)

# Дальше удаляем все незначимык фичи, у кого нет звездочек, избавляемся от мультиколлинеарности и запускаем модель 
# И это делаем до тех пор, пока все фичи не будут значимые. 
# Потом смотри на коэффициенты. Чем больше коэффициент, тем больше влияния на лтв он оказывает
# так ты получаешь список значимых фичей, в порядке от более значимого к менее

# Модель с удлаенными неважными фичами
lm_pred7_5 <- lm(ltv7 ~ .+0, data = dt[feat], singular.ok = TRUE)
# Коэффициенты
coef7=data.frame(coefficients(lm_pred7_5))
# ОПисание модели
summary(lm_pred7_5)
# Смотрим какие фичи мультиколлинеарны, пороговое значение выбираешь сам. 
# На практике в основном приняти 5 или 10. Все что больше удаляешь из набора фичей.
vif_values=vif(lm_pred7_5)


