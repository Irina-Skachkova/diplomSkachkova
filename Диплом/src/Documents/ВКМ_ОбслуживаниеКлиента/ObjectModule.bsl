
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий 

Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	Если Не ЗначениеЗаполнено(Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить()) Тогда
		Отказ = Истина;
		ОбщегоНазначения.СообщитьПользователю("Не заполнена константа Номенклатура Работы специалиста.");
		Возврат;
	КонецЕсли;

	Если Не ЗначениеЗаполнено(Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить()) Тогда
		Отказ = Истина;
		ОбщегоНазначения.СообщитьПользователю("Не заполнена константа Номенклатура Абонентская плата.");
		Возврат;
	КонецЕсли;

	РеквизитыДоговора = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Договор,
		"ВидДоговора, ВКМ_ПериодС, ВКМ_По, ВКМ_СтоимостьЧасаРаботы");

	Если РеквизитыДоговора.ВидДоговора <> Перечисления.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание Тогда
		Отказ = Истина;
		ОбщегоНазначения.СообщитьПользователю(
			"Договор не является договором на абонентское обслуживание. Выберите другой договор.");
		Возврат;
	КонецЕсли;

	Если РеквизитыДоговора.ВКМ_ПериодС > Дата Или РеквизитыДоговора.ВКМ_По < Дата Тогда
		Отказ = Истина;
		ОбщегоНазначения.СообщитьПользователю(
			"Дата документа не попадает в период действия договора. Выберите другой договор.");
		Возврат;
	КонецЕсли;

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
				   |	ВКМ_УсловияОплатыСотрудниковСрезПоследних.ПроцентОтРабот КАК ПроцентОтРабот
				   |ИЗ
				   |	РегистрСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних(&Дата, Сотрудник = &Сотрудник) КАК ВКМ_УсловияОплатыСотрудниковСрезПоследних";

	Запрос.УстановитьПараметр("Сотрудник", Специалист);
	Запрос.УстановитьПараметр("Дата", Дата);

	Выборка = Запрос.Выполнить();

	Если Выборка.Пустой() Тогда	
		Отказ = Истина;
		ОбщегоНазначения.СообщитьПользователю("Не заполнены условия оплаты сотруднику.");
		Возврат;		
	КонецЕсли;

	Результат = Выборка.Выбрать();
	
	Пока Результат.Следующий() Цикл
		УсловияОплатыСотрудников = Результат.ПроцентОтРабот;
	КонецЦикла;

	Движения.ВКМ_ВыполненныеКлиентуРаботы.Записывать = Истина;
	Движения.ВКМ_ВыполненныеСотрудникомРаботы.Записывать = Истина;

	Для Каждого ТекСтрокаВыполненныеРаботы Из ВыполненныеРаботы Цикл
		
		СтоимостьЧасаРаботы = РеквизитыДоговора.ВКМ_СтоимостьЧасаРаботы;
		
		//движения по регистру ВКМ_ВыполненныеКлиентуРаботы
		Движение = Движения.ВКМ_ВыполненныеКлиентуРаботы.Добавить();
		Движение.Период = Дата;
		Движение.Клиент = Клиент;
		Движение.Договор = Договор;
		Движение.КоличествоЧасов = ТекСтрокаВыполненныеРаботы.ЧасыКОплатеКлиенту;
		Движение.СуммаКОплате = СтоимостьЧасаРаботы * ТекСтрокаВыполненныеРаботы.ЧасыКОплатеКлиенту;
		
		//движения по регистру ВКМ_ВыполненныеСотрудникомРаботы
		Движение = Движения.ВКМ_ВыполненныеСотрудникомРаботы.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Сотрудник = Специалист;
		Движение.ЧасовКОплате = ТекСтрокаВыполненныеРаботы.ЧасыКОплатеКлиенту;
		Движение.СуммаКОплате = СтоимостьЧасаРаботы * УсловияОплатыСотрудников
			* ТекСтрокаВыполненныеРаботы.ЧасыКОплатеКлиенту / 100;

	КонецЦикла;

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	Если ОбменДанными.Загрузка = Истина Тогда
		Возврат;
	КонецЕсли;

	ДополнительныеСвойства.Вставить("ЭтоНовыйОбъект", ЭтоНовый());

	ТекстУведомления = "";

	СтарыйРеквизит = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка,
		"ДатаПроведенияРабот, ВремяНачалаРаботПлан, ВремяОкончанияРаботПлан, Специалист");
	ПроверитьИзменениеРеквизитов(ТекстУведомления, ДатаПроведенияРабот, СтарыйРеквизит.ДатаПроведенияРабот,
		"ДатаПроведенияРабот");
	ПроверитьИзменениеРеквизитов(ТекстУведомления, ВремяНачалаРаботПлан, СтарыйРеквизит.ВремяНачалаРаботПлан,
		"ВремяНачалаРаботПлан");
	ПроверитьИзменениеРеквизитов(ТекстУведомления, ВремяОкончанияРаботПлан, СтарыйРеквизит.ВремяОкончанияРаботПлан,
		"ВремяОкончанияРаботПлан");
	ПроверитьИзменениеРеквизитов(ТекстУведомления, Специалист, СтарыйРеквизит.Специалист, "Специалист");

	Если ЗначениеЗаполнено(ТекстУведомления) Тогда
		ТекстУведомленияДок = СтрШаблон("В заявке №%1 от %2 на обслуживание клиента ""%3"" внесены изменения.",
			ПрефиксацияОбъектовКлиентСервер.УдалитьЛидирующиеНулиИзНомераОбъекта(Номер), Формат(Дата, "ДЛФ=DD"), Клиент);
		МассивСтрок = Новый Массив;
		МассивСтрок.Добавить(ТекстУведомленияДок);
		МассивСтрок.Добавить(ТекстУведомления);
		ТекстУведомления = СтрСоединить(МассивСтрок, Символы.ПС);
		ДополнительныеСвойства.Вставить("ТекстУведомления", ТекстУведомления);
	КонецЕсли;

КонецПроцедуры

Процедура ПриЗаписи(Отказ)

	Если ОбменДанными.Загрузка = Истина Тогда
		Возврат;
	КонецЕсли;

	Если ДополнительныеСвойства.ЭтоНовыйОбъект Тогда
		ТекстУведомления = СтрШаблон("Получена заявка №%1 от %2 на обслуживание клиента ""%3"". 
									 |Исполнителем назначен специалист: %4. 
									 |Планируемый период проведения работ: %5 с %6 до %7.",
			ПрефиксацияОбъектовКлиентСервер.УдалитьЛидирующиеНулиИзНомераОбъекта(Номер), Формат(Дата, "ДЛФ=DD"),
			Клиент, Специалист, Формат(ДатаПроведенияРабот, "ДЛФ=DD"), Формат(ВремяНачалаРаботПлан, "ДЛФ=T"), 
			Формат(ВремяОкончанияРаботПлан, "ДЛФ=T"));
		СформироватьУведомление(ТекстУведомления);
		Возврат;
	КонецЕсли;

	Если ДополнительныеСвойства.Свойство("ТекстУведомления") Тогда
		СформироватьУведомление(ДополнительныеСвойства.ТекстУведомления);
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПроверитьИзменениеРеквизитов(ТекстУведомления, ПроверяемыйРеквизит, СтарыйРеквизит, НаименованиеРеквизита)

	Если ПроверяемыйРеквизит <> СтарыйРеквизит Тогда
		Если НаименованиеРеквизита = "Специалист" Тогда
			НовыйТекстУведомления = СтрШаблон("Назначен новый исполнитель работ: %1.", Специалист);
		ИначеЕсли НаименованиеРеквизита = "ДатаПроведенияРабот" Тогда
			НовыйТекстУведомления = СтрШаблон("Установлена новая планируемая дата проведения работ: %1", Формат(Дата,
				"ДЛФ=DD"));
		ИначеЕсли НаименованиеРеквизита = "ВремяНачалаРаботПлан" Тогда
			НовыйТекстУведомления = СтрШаблон("Установлено новое планируемое время начала проведения работ с: %1.",
				Формат(ВремяНачалаРаботПлан, "ДЛФ=T"));
		ИначеЕсли НаименованиеРеквизита = "ВремяОкончанияРаботПлан" Тогда
			НовыйТекстУведомления = СтрШаблон("Установлено новое планируемое время окончания проведения работ до: %1.",
				Формат(ВремяОкончанияРаботПлан, "ДЛФ=T"));
		КонецЕсли;

		Если ТекстУведомления = "" Тогда
			ТекстУведомления = НовыйТекстУведомления;
		Иначе
			МассивСтрок = Новый Массив;
			МассивСтрок.Добавить(ТекстУведомления);
			МассивСтрок.Добавить(НовыйТекстУведомления);
			ТекстУведомления = СтрСоединить(МассивСтрок, Символы.ПС);
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

Процедура СформироватьУведомление(ТекстУведомления)

	НовоеУведомление = Справочники.ВКМ_УведомленияТелеграмБоту.СоздатьЭлемент();
	НовоеУведомление.Текст = ТекстУведомления;
	НовоеУведомление.Записать();

КонецПроцедуры

#КонецОбласти

#КонецЕсли