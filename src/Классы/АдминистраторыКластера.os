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

	ПараметрыОбъекта = Новый КомандыОбъекта("cluster.admin");

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
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Список"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка администраторов кластера, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Элементы.Заполнить(Кластер_Агент.ВыводКоманды());

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

// Функция возвращает список администраторов кластера
//   
// Параметры:
//   Отбор                         - Структура    - Структура отбора администраторов (<поле>:<значение>)
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Массив - список администраторов кластера 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	АдминистраторыКластера = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Возврат АдминистраторыКластера;

КонецФункции // Список()

// Функция возвращает список администраторов кластера 1С
//   
// Параметры:
//   ПоляИерархии             - Строка        - Поля для построения иерархии списка администраторов, разделенные ","
//   ОбновитьПринудительно     - Булево        - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Соответствие - список администраторов кластеров 1С
//        <имя поля объекта>    - Массив(Соответствие), Соответствие    - список администраторов или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	АдминистраторыКластера = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно);
	
	Возврат АдминистраторыКластера;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество администраторов кластера в списке
//   
// Возвращаемое значение:
//    Число - количество администраторов кластера
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание администратора кластера 1С
//   
// Параметры:
//   Имя                     - Строка    - Имя администраторов кластера
//   ОбновитьПринудительно     - Булево    - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Соответствие - описание администратора кластера 1С
//
Функция Получить(Знач Имя, Знач ОбновитьПринудительно = Ложь) Экспорт

	Отбор = Новый Соответствие();
	Отбор.Вставить("name", Имя);
	
	АдминистраторыКластера = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Если АдминистраторыКластера.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат АдминистраторыКластера[0];

КонецФункции // Получить()

// Процедура добавляет нового администратора кластера
//   
// Параметры:
//    Имя                            - Строка        - имя администратора кластера 1С
//    ПараметрыАдминКластера        - Структура        - параметры создаваемого администратора
//        - Пароль                    - Строка        - пароль администратора кластера 1С
//        - Описание                    - Строка        - описание администратора кластера 1С
//        - СпособАвторизации            - Строка        - Пароль / пользователь ОС
//        - ПользовательОС            - Строка    - пользователь ОС, соответствующий администратору
//    УстановитьТекущим             - Булево        - Истина - сделать добавленного администратора
//                                                  текущим для кластера
//
Процедура Добавить(Знач Имя, Знач ПараметрыАдминКластера = Неопределено, УстановитьТекущим = Ложь) Экспорт

	Если НЕ ТипЗнч(ПараметрыАдминКластера) = Тип("Структура") Тогда
		ПараметрыАдминКластера = Новый Структура();
	КонецЕсли;

	ТекущееКоличество = Количество();

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииАгента"  , Кластер_Агент.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("Имя"                    , Имя);

	Для Каждого ТекЭлемент Из ПараметрыАдминКластера Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Добавить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка добавления администратора кластера ""%1"", КодВозврата = %2: %3",
	                                Имя,
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Если УстановитьТекущим ИЛИ ТекущееКоличество = 0 Тогда
		Кластер_Владелец.УстановитьАдминистратора(Имя, ПараметрыАдминКластера.Пароль);
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Добавить()

// Процедура удаляет администратора кластера
//   
// Параметры:
//   Имя                 - Строка        - имя администратора кластера 1С
//
Процедура Удалить(Имя) Экспорт

	ТекущееКоличество = Количество();

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииАгента"  , Кластер_Агент.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("Имя"                    , Имя);

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Удалить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления администратора кластера ""%1"", КодВозврата = %2: %3",
	                                Имя,
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Если ТекущееКоличество = 1 Тогда
		Кластер_Владелец.УстановитьАдминистратора("", "");
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Удалить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
