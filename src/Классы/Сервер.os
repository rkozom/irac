Перем Сервер_Ид; // server
Перем Сервер_Имя; // name
Перем Сервер_Адрес; // agent-host
Перем Сервер_Порт; // agent-port
Перем Сервер_Параметры;

Перем Кластер_Агент;
Перем Кластер_Владелец;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер			- Кластер		- ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Ид)

	Если НЕ ЗначениеЗаполнено(Ид) Тогда
		Возврат;
	КонецЕсли;

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	Сервер_Ид = Ид;
	
	ОбновитьДанные();

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
Процедура ОбновитьДанные()

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("server");
	ПараметрыЗапуска.Добавить("info");

	ПараметрыЗапуска.Добавить(СтрШаблон("--server=%1", Ид()));
	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	МассивРезультатов = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

	ТекОписание = МассивРезультатов[0];

	Сервер_Адрес = ТекОписание.Получить("agent-host");
	Сервер_Порт = ТекОписание.Получить("agent-port");
	Сервер_Имя = ТекОписание.Получить("name");

	Сервер_Параметры =
		Новый Структура("ДиапазонПортов,
						|ЦентральныйСервер,
						|МенеджерПодКаждыйСервис,
						|КоличествоИБНаПроцесс,
						|МаксОбъемПамятиРабочихПроцессов,
						|КоличествоСоединенийНаПроцесс,
						|БезопасныйОбъемПамятиРабочихПроцессов,
						|БезопасныйРасходПамятиЗаОдинВызов,
						|ПортГлавногоМенеджераКластера",
						Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание, "port-range", 1560),
						Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание, "using", ВариантыИспользованияРабочегоСервера.Главный),
						Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание, "dedicate-managers", ВариантыРазмещенияСервисов.ВОдномМенеджере),
						Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание, "infobases-limit", 8),
						Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание, "memory-limit", 0),
						Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание, "connections-limit", 128),
						Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание, "safe-working-processes-memory-limit", 0),
						Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание, "safe-call-memory-limit", 0),
						Служебный.ПолучитьЗначениеИзСтруктуры(ТекОписание, "cluster-port", 0));

КонецПроцедуры // ОбновитьДанные()

Функция Ид() Экспорт

	Возврат Сервер_Ид;

КонецФункции

Функция Имя() Экспорт

	Возврат Сервер_Имя;
	
КонецФункции

Функция Сервер() Экспорт
	
		Возврат Сервер_Адрес;
		
КонецФункции
	
Функция Порт() Экспорт
	
		Возврат Сервер_Порт;
		
КонецФункции
	
Функция Параметры() Экспорт
	
		Возврат Сервер_Параметры;
		
КонецФункции
	
Процедура Изменить(Знач ПараметрыСервера = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыСервера) = Тип("Структура") Тогда
		ПараметрыСервера = Новый Структура();
	КонецЕсли;

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("server");
	ПараметрыЗапуска.Добавить("update");

	ПараметрыЗапуска.Добавить(СтрШаблон("--server=%1", Ид()));
	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));

	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());
		
	Если ПараметрыСервера.Свойство("ДиапазонПортов") Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--port-range=%1", ПараметрыСервера.ДиапазонПортов));
	КонецЕсли;
	Если ПараметрыСервера.Свойство("ЦентральныйСервер") Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--using=%1", ПараметрыСервера.ЦентральныйСервер));
	КонецЕсли;
	Если ПараметрыСервера.Свойство("МенеджерПодКаждыйСервис") Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--dedicate-managers=%1", ПараметрыСервера.МенеджерПодКаждыйСервис));
	КонецЕсли;
	Если ПараметрыСервера.Свойство("КоличествоИБНаПроцесс") Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--infobases-limit=%1", ПараметрыСервера.КоличествоИБНаПроцесс));
	КонецЕсли;
	Если ПараметрыСервера.Свойство("МаксОбъемПамятиРабочихПроцессов") Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--memory-limit=%1", ПараметрыСервера.МаксОбъемПамятиРабочихПроцессов));
	КонецЕсли;
	Если ПараметрыСервера.Свойство("КоличествоСоединенийНаПроцесс") Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--connections-limit=%1", ПараметрыСервера.КоличествоСоединенийНаПроцесс));
	КонецЕсли;
	Если ПараметрыСервера.Свойство("БезопасныйОбъемПамятиРабочихПроцессов") Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--safe-working-processes-memory-limit=%1", ПараметрыСервера.БезопасныйОбъемПамятиРабочихПроцессов));
	КонецЕсли;
	Если ПараметрыСервера.Свойство("БезопасныйРасходПамятиЗаОдинВызов") Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--safe-call-memory-limit=%1", ПараметрыСервера.БезопасныйРасходПамятиЗаОдинВызов));
	КонецЕсли;
	Если ПараметрыСервера.Свойство("ПортГлавногоМенеджераКластера") Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--cluster-port=%1", ПараметрыСервера.ПортГлавногоМенеджераКластера));
	КонецЕсли;

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация(Служебный.ВыводКоманды());

	ОбновитьДанные();

КонецПроцедуры

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
