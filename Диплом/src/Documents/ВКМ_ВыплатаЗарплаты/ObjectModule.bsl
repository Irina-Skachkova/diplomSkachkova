#Область ОбработчикиСобытий

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;
	Для Каждого ТекСтрокаВыплата Из Выплаты Цикл
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = КонецМесяца(Дата);
		Движение.Сотрудник = ТекСтрокаВыплата.Сотрудник;
		Движение.Сумма = ТекСтрокаВыплата.СуммаКВыплате;
	КонецЦикла;
	
КонецПроцедуры 

Процедура ВКМ_ВыполнитьЗаполнение() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
					|	ВКМ_ВзаиморасчетыССотрудникамиОстатки.Сотрудник,
					|	ВКМ_ВзаиморасчетыССотрудникамиОстатки.СуммаОстаток
					|ИЗ
					|	РегистрНакопления.ВКМ_ВзаиморасчетыССотрудниками.Остатки(&Дата,) КАК ВКМ_ВзаиморасчетыССотрудникамиОстатки";  
	
	Запрос.УстановитьПараметр("Дата", КонецДня(Дата));
	Выборка = Запрос.Выполнить().Выбрать(); 
	
	Выплаты.Очистить();
	
	Пока Выборка.Следующий() Цикл
		
		НоваяСтрока = Выплаты.Добавить();
		НоваяСтрока.Сотрудник = Выборка.Сотрудник;
		НоваяСтрока.СуммаКВыплате = Выборка.СуммаОстаток;
		
	КонецЦикла;
	
КонецПроцедуры


#КонецОбласти

