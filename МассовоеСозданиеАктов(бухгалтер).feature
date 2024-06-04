﻿#language: ru

@tree

Функционал: Массовое создание актов

Как Бухгалтер я хочу
создать акты
чтобы закрыть месяц   

Контекст:
	Дано я подключаю TestClient "Диплом(бухгалтер)" логин "Сидорова(Бухгалтер)" пароль ""
		
		И я закрываю все окна клиентского приложения

Сценарий: Я создаю акты
И В командном интерфейсе я выбираю 'Добавленные объекты' 'Массовое создание актов'
Тогда открылось окно 'Массовое создание актов'
И я нажимаю кнопку выбора у поля с именем "Период"
Тогда открылось окно 'Выберите период'
И я нажимаю кнопку выбора у поля с именем "DateBegin"
И в поле с именем 'DateBegin' я ввожу текст '01.05.2024'
И в поле с именем 'DateEnd' я ввожу текст '30.05.2024'
И я нажимаю на кнопку с именем 'Select'
Тогда открылось окно 'Массовое создание актов'
И я нажимаю на кнопку с именем 'ФормаСоздатьДокументы'

