# Исходный образ для установки необходимых библиотек линукса
FROM groovy:alpine

# Установка файлов библиотеки по управлению временем
COPY --from=trajano/alpine-libfaketime  /faketime.so /lib/faketime.so

# Базовый образ
FROM openjdk:14-slim

# Копируем все необходимые для работы артефакты с предыдущего образа (0 - индекс)
COPY --from=0 /lib/faketime.so /lib

# Уставление необходимых переменных для манипулирования временем внутри контейнера
ENV LD_PRELOAD /lib/faketime.so \
    DONT_FAKE_MONOTONIC 1

#Дальше - установка необходимых переменных, EXPOSE, COPY, WORKDIR, CMD, etc.
