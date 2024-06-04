#Область СлужебныеПроцедурыИФункции

Функция СоздатьСписокНаСервере(Параметры) Экспорт
	
	Запрос = Новый Запрос;          
	Запрос.Текст = "ВЫБРАТЬ
	               |	РеализацияТоваровУслуг.Ссылка КАК Ссылка
	               |ПОМЕСТИТЬ ВТ_Реализации
	               |ИЗ
	               |	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	               |ГДЕ
	               |	РеализацияТоваровУслуг.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
	               |	И НЕ РеализацияТоваровУслуг.ПометкаУдаления
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ДоговорыКонтрагентов.Ссылка КАК Договор,
	               |	ВТ_Реализации.Ссылка КАК Реализация,
	               |	ДоговорыКонтрагентов.Владелец КАК Владелец,
	               |	ДоговорыКонтрагентов.Организация КАК Организация
	               |ИЗ
	               |	ВТ_Реализации КАК ВТ_Реализации
	               |		ПРАВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	               |		ПО (ДоговорыКонтрагентов.Ссылка = ВТ_Реализации.Ссылка.Договор)
	               |ГДЕ
	               |	ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора";
	
	Запрос.УстановитьПараметр("ВидДоговора",Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание);
	Запрос.УстановитьПараметр("ДатаНачала",НачалоДня(Параметры.Период.ДатаНачала));
	Запрос.УстановитьПараметр("ДатаОкончания",КонецДня(Параметры.Период.ДатаОкончания));
	
	СписокРеализацийМассив = Новый Массив;

	Выборка = Запрос.Выполнить().Выбрать(); 
	
		
	Пока Выборка.Следующий() Цикл 
		
		СписокРеализацийСтруктура = Новый Структура; 
		
		Если НЕ ЗначениеЗаполнено(Выборка.Реализация) Тогда 
			
			НоваяРеализация = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
			НоваяРеализация.Дата = КонецДня(Параметры.Период.ДатаОкончания); 
			НоваяРеализация.Ответственный = Пользователи.ТекущийПользователь(); 
			НоваяРеализация.Договор = Выборка.Договор;
			НоваяРеализация.Контрагент = Выборка.Владелец;
			НоваяРеализация.Организация = Выборка.Организация;
			НоваяРеализация.Комментарий = "Документ создан автоматической обработкой Массовое создание актов.";
			НоваяРеализация.ВКМ_ВыполнитьАвтозаполнение(Выборка.Договор);
			НоваяРеализация.Записать();
			
			Если НоваяРеализация.ПроверитьЗаполнение() Тогда
				
				Попытка 

					НоваяРеализация.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
					СписокРеализацийСтруктура.Вставить("Договор", Выборка.Договор);
					СписокРеализацийСтруктура.Вставить("Реализация", НоваяРеализация.Ссылка);
					
				Исключение   
					
					ЗаписьВЖурнал = СтрШаблон("По клиенту ""%2"" по договору ""%1"" не удалось создать Реализацию. Дата документа не попадает в период действия договора. Укажите актуальный договор.", Выборка.Договор, Выборка.Владелец);
					ЗаписьЖурналаРегистрации("Обработка Массовое создание актов", УровеньЖурналаРегистрации.Ошибка,,, ЗаписьВЖурнал);
					СписокРеализацийСтруктура.Вставить("Договор", Выборка.Договор);
					СписокРеализацийСтруктура.Вставить("Реализация", );  
					
				КонецПопытки;
				
			Иначе  
				
				ЗаписьЖурналаРегистрации("Обработка Массовое создание актов", УровеньЖурналаРегистрации.Ошибка,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				СписокРеализацийСтруктура.Вставить("Договор", Выборка.Договор);
				СписокРеализацийСтруктура.Вставить("Реализация", );
				
			КонецЕсли;
			
		Иначе
			
			СписокРеализацийСтруктура.Вставить("Договор", Выборка.Договор);
			СписокРеализацийСтруктура.Вставить("Реализация", Выборка.Реализация);  
			
		КонецЕсли;  
		
		СписокРеализацийМассив.Добавить(СписокРеализацийСтруктура);
		
	КонецЦикла; 
	
	Возврат СписокРеализацийМассив;
	
КонецФункции

# КонецОбласти
