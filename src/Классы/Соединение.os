Перем Соединение_Ид;
Перем Соединение_Параметры;
Перем ПараметрыОбъекта;

Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Процесс_Владелец;
Перем ИБ_Владелец;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера      - АгентКластера             - ссылка на родительский объект агента кластера
//   Кластер            - Кластера                  - ссылка на родительский объект кластера
//   Процесс            - Процесс                      - ссылка на родительский объект процесса
//   ИБ                 - ИнформационнаяБаза        - ссылка на родительский объект информационной базы
//   Соединение         - Строка, Соответствие      - идентификатор или параметры соединения
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, ИБ, Соединение, Процесс = Неопределено)
	
	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	ИБ_Владелец = ИБ;
	Процесс_Владелец = Процесс;
	
	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.Соединения);

	Если ТипЗнч(Соединение) = Тип("Соответствие") Тогда
		Соединение_Ид = Соединение["connection"];
		Служебный.ЗаполнитьПараметрыОбъекта(ЭтотОбъект, Соединение_Параметры, Соединение);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Соединение_Ид = Соединение;
		МоментАктуальности = 0;
	КонецЕсли;
	
	ПериодОбновления = 60000;
	
КонецПроцедуры // ПриСозданииОбъекта()

// Функция возвращает ИД объекта
//
// Возвращаемое значение:
//    Строка     - идентификатор объекта
//
Функция Ид() Экспорт
	
	Возврат Соединение_Ид;
	
КонецФункции // Ид()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт
	
	Если НЕ Служебный.ТребуетсяОбновление(Соединение_Параметры,
	     МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;
   
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСоединения", Ид());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Описание"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения описания соединения, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Служебный.ЗаполнитьПараметрыОбъекта(ЭтотОбъект, Соединение_Параметры, МассивРезультатов[0]);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
КонецПроцедуры // ОбновитьДанныеОбъекта()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//     Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "ИмяПараметра") Экспорт
	
	Возврат ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает значение параметра соединения 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра соединения
//   ОбновитьПринудительно     - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//     Произвольный - значение параметра соединения 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	Если НЕ Найти(ВРег("Ид, connection"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Соединение_Ид;
	КонецЕсли;
	
	ЗначениеПоля = Соединение_Параметры.Получить(ИмяПоля);

	Если ЗначениеПоля = Неопределено Тогда
	    
		ОписаниеПараметра = ПараметрыОбъекта("ИмяПоляРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Соединение_Параметры.Получить(ОписаниеПараметра["ИмяПараметра"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;

КонецФункции // Получить()

// Процедура отключает соединение в кластере 1С
//   
Процедура Отключить() Экспорт

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());

	ПараметрыКоманды.Вставить("ИдентификаторПроцесса"  , Процесс_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторСоединения", Ид());

	ОтборИБ = Новый Соответствие();
	ОтборИБ.Вставить("infobase", Получить("infobase"));

	СписокИБ = Кластер_Владелец.ИнформационныеБазы().Список(ОтборИБ);
	Если НЕ СписокИБ.Количество() = 0 Тогда
		ПараметрыКоманды.Вставить("СтрокаАвторизацииИБ", СписокИБ[0].СтрокаАвторизации());
	КонецЕсли;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Отключить"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления соединения, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);
	
КонецПроцедуры // Отключить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");