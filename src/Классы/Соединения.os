// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Процесс_Владелец;
Перем ИБ_Владелец;

Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера    - АгентКластера            - ссылка на родительский объект агента кластера
//   Кластер        - Кластер                - ссылка на родительский объект кластера
//   Процесс        - РабочийПроцесс        - ссылка на родительский объект рабочего процесса
//   ИБ                - ИнформационнаяБаза    - ссылка на родительский объект информационной базы
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Процесс = Неопределено, ИБ = Неопределено)

	Кластер_Агент        = АгентКластера;
	Кластер_Владелец    = Кластер;
	Процесс_Владелец    = Процесс;
	ИБ_Владелец            = ИБ;

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.Соединения);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

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
	
	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	
	Если НЕ Процесс_Владелец = Неопределено Тогда
		ПараметрыКоманды.Вставить("ИдентификаторПроцесса", Процесс_Владелец.Ид());
	КонецЕсли;

	Если НЕ ИБ_Владелец = Неопределено Тогда
		ПараметрыКоманды.Вставить("ИдентификаторИБ", ИБ_Владелец.Ид());
		ПараметрыКоманды.Вставить("СтрокаАвторизацииИБ", ИБ_Владелец.СтрокаАвторизации());
	КонецЕсли;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Список"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка соединений, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивПроцессов = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивПроцессов.Добавить(Новый Соединение(Кластер_Агент,
												  Кластер_Владелец,
												  ИБ_Владелец,
												  ТекОписание,
												  Процесс_Владелец));
	КонецЦикла;
	Элементы.Заполнить(МассивПроцессов);

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

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

// Функция возвращает список соединений
//   
// Параметры:
//   Отбор                         - Структура    - Структура отбора соединений (<поле>:<значение>)
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Массив - список соединений
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	Соединения = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Возврат Соединения;

КонецФункции // Список()

// Функция возвращает список соединений
//   
// Параметры:
//   ПоляИерархии            - Строка        - Поля для построения иерархии списка соединений, разделенные ","
//   ОбновитьПринудительно    - Булево        - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Соответствие - список соединений
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	Соединения = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно);

	Возврат Соединения;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество соединений в списке
//   
// Возвращаемое значение:
//    Число - количество соединений
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание соединения
//   
// Параметры:
//   Номер                     - Структура    - Номер соединения
//   ОбновитьПринудительно     - Булево    - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Соответствие - описание соединения
//
Функция Получить(Знач Номер, Знач ОбновитьПринудительно = Ложь) Экспорт

	Отбор = Новый Соответствие();
	Отбор.Вставить("conn-id", Номер);

	Соединения = Элементы.Список(Отбор, ОбновитьПринудительно);

	Возврат Соединения[0];

КонецФункции // Получить()

// Процедура отключает соединение
//   
// Параметры:
//   Номер                     - Структура    - Номер соединения
//
Процедура Отключить(Знач Номер) Экспорт

	Соединение = Получить(Номер, Истина);

	Если Соединение = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Соединение.Отключить();

	ОбновитьДанные(Истина);

КонецПроцедуры // Отключить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
