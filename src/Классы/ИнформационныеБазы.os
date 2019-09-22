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
Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера        - АгентКластера    - ссылка на родительский объект агента кластера
//   Кластер            - Кластер        - ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.ИБ);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры

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
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Список"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка информационных баз, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивИБ = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивИБ.Добавить(Новый ИнформационнаяБаза(Кластер_Агент, Кластер_Владелец, ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивИБ);

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

// Функция возвращает список информационных баз
//   
// Параметры:
//   Отбор                         - Структура    - Структура отбора информационных баз (<поле>:<значение>)
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Массив - список информационных баз
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	СписокИБ = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Возврат СписокИБ;

КонецФункции // Список()

// Функция возвращает список информационных баз
//   
// Параметры:
//   ПоляИерархии             - Строка        - Поля для построения иерархии списка информационных баз, разделенные ","
//   ОбновитьПринудительно     - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//    Соответствие - список информационных баз
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список информационных баз или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	СписокИБ = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно);
	
	Возврат СписокИБ;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество информационных баз в списке
//   
// Возвращаемое значение:
//    Число - количество информационных баз
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание информационной базы 1С
//   
// Параметры:
//   Имя                     - Строка    - Имя информационной базы 1С
//   ОбновитьПринудительно     - Булево    - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Соответствие - описание информационной базы 1С
//
Функция Получить(Знач Имя, Знач ОбновитьПринудительно = Ложь) Экспорт

	Отбор = Новый Соответствие();
	Отбор.Вставить("name", Имя);

	СписокИБ = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Если СписокИБ.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат СписокИБ[0];

КонецФункции // Получить()

// Процедура добавляет новую информационную базу
//   
// Параметры:
//   Имя                 - Строка        - имя информационной базы
//   Локализация         - Строка        - локализация базы
//   СоздатьБазуСУБД     - Булево        - Истина - создать базу данных на сервере СУБД; Ложь - не создавать
//   ПараметрыИБ         - Структура        - параметры информационной базы
//
Процедура Добавить(Имя, Локализация = "ru_RU", СоздатьБазуСУБД = Ложь, ПараметрыИБ = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыИБ) = Тип("Структура") Тогда
		ПараметрыИБ = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	
	ПараметрыКоманды.Вставить("Имя"            , Имя);
	ПараметрыКоманды.Вставить("Локализация"    , Локализация);
	ПараметрыКоманды.Вставить("СоздатьБазуСУБД", СоздатьБазуСУБД);

	Для Каждого ТекЭлемент Из ПараметрыИБ Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Добавить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка добавления информационной базы ""%1"": %2",
	                                Имя,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Добавить()

// Процедура удаляет информационную базу
//   
// Параметры:
//   Имя                 - Строка        - имя информационной базы
//   ДействияСБазойСУБД  - Строка        - "drop" - удалить базу данных; "clear" - очистить базу данных;
//                                         иначе оставить базу данных как есть
//
Процедура Удалить(Имя, ДействияСБазойСУБД = "") Экспорт
	
	ИБ = Получить(Имя);

	Если ИБ = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ИБ.Удалить(ДействияСБазойСУБД);

	ОбновитьДанные(Истина);

КонецПроцедуры // Удалить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
