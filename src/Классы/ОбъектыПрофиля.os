// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем ТипЭлементов;
Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Профиль_Владелец;
Перем Элементы;

Перем ПараметрыОбъекта;

Перем МоментАктуальности;
Перем ПериодОбновления;

Перем Лог;

Процедура ПриСозданииОбъекта(Агент, Кластер, Профиль, Тип)

	Элементы = Неопределено;

	Кластер_Агент = Агент;
	Кластер_Владелец = Кластер;
	Профиль_Владелец = Профиль;

	ТипЭлементов = Тип;

	ПараметрыОбъекта = Новый КомандыОбъекта(СтрШаблон("%1.%2",
														Перечисления.РежимыАдминистрирования.ПрофилиБезопасности,
														ТипЭлементов));

	ПериодОбновления = 60000;
	МоментАктуальности = 0;

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"   , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"     , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера" , Кластер_Владелец.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("ИмяПрофиля"                , Профиль_Владелец.Имя());
	ПараметрыКоманды.Вставить("ВидОбъектовПрофиля"        , ТипЭлементов);

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Список"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка доступа объектов ""%1"" профиля ""%2"": %3",
		                            ТипЭлементов,
		                            Профиль_Владелец.Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Элементы = Кластер_Агент.ВыводКоманды();

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Функция признак необходимости обновления данных
//   
// Параметры:
//   ОбновитьПринудительно     - Булево        - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Булево - Истина - требуется обновитьданные
//
Функция ТребуетсяОбновление(ОбновитьПринудительно = Ложь) Экспорт

	Возврат (ОбновитьПринудительно
		ИЛИ Элементы = Неопределено
		ИЛИ (ПериодОбновления < (ТекущаяУниверсальнаяДатаВМиллисекундах() - МоментАктуальности)));

КонецФункции // ТребуетсяОбновление()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//    Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "Имя") Экспорт

	Возврат ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает список объектов кластера
//   
// Параметры:
//   Отбор                         - Структура    - Структура отбора объектов (<поле>:<значение>)
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Массив - список объектов кластера 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	ОбновитьДанные(ОбновитьПринудительно);

	Результат = Служебный.ПолучитьЭлементыИзМассиваСоответствий(Элементы, Отбор);

	Если Результат.Количество() = 0 Тогда
		Возврат Неопределено;
	Иначе
		Возврат Результат;
	КонецЕсли;

КонецФункции // Список()

// Функция возвращает список объектов кластера
//   
// Параметры:
//   ПоляИерархии            - Строка        - Поля для построения иерархии списка объектов, разделенные ","
//   ОбновитьПринудительно    - Булево        - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Соответствие - список объектов кластера 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список объектов кластера или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	ОбновитьДанные(ОбновитьПринудительно);

	Результат = Служебный.ИерархическоеПредставлениеМассиваСоответствий(Элементы, ПоляИерархии);
	
	Возврат Результат;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество обектов в списке профиля безопасности
//   
// Возвращаемое значение:
//    Число - количество объектов
//
Функция Количество() Экспорт

	ОбновитьДанные();

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Процедура устанавливает значение периода обновления
//   
// Параметры:
//   НовыйПериодОбновления     - Число        - новый период обновления
//
Процедура УстановитьПериодОбновления(НовыйПериодОбновления) Экспорт

	ПериодОбновления = НовыйПериодОбновления;

КонецПроцедуры // УстановитьПериодОбновления()

// Процедура устанавливает новое значение момента актуальности данных
//   
Процедура УстановитьАктуальность() Экспорт

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // УстановитьАктуальность()

// Процедура добавляет новый или изменяет существующий объект профиля безопасности
//   
// Параметры:
//   Имя                 - Строка        - имя объекта профиля безопасности 1С
//   ПараметрыОбъекта    - Структура     - параметры объекта профиля безопасности 1С
//
Процедура Изменить(Имя, ПараметрыОбъектаПрофиля = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыОбъектаПрофиля) = Тип("Структура") Тогда
		ПараметрыОбъектаПрофиля = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"   , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"     , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера" , Кластер_Владелец.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("ИмяПрофиля"                , Профиль_Владелец.Имя());
	ПараметрыКоманды.Вставить("ВидОбъектовПрофиля"        , ТипЭлементов);
	ПараметрыКоманды.Вставить("ИмяОбъектаПрофиля"         , Имя);

	Для Каждого ТекЭлемент Из ПараметрыОбъектаПрофиля Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Изменить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка изменения объекта доступа ""%1"" (%2) профиля ""%3"": %4",
		                            Имя,
		                            ТипЭлементов,
		                            Профиль_Владелец.Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Изменить()

// Процедура удаляет объект профиля из профиля безопасности
//   
// Параметры:
//   Имя            - Строка    - Имя объекта профиля безопасности
//
Процедура Удалить(Имя) Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"   , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"     , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера" , Кластер_Владелец.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("ИмяПрофиля"                , Профиль_Владелец.Имя());
	ПараметрыКоманды.Вставить("ВидОбъектовПрофиля"        , ТипЭлементов);
	ПараметрыКоманды.Вставить("ИмяОбъектаПрофиля"         , Имя);

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Удалить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления объекта доступа ""%1"" (%2) профиля ""%3"": %4",
		                            Имя,
		                            ТипЭлементов,
		                            Профиль_Владелец.Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Удалить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
