# Шаблон chip-expo-2021-template-3-axi_stream

## Назначение

Шаблон демонстрирует возможность тестирования компонента с шинами AXI Stream.

Основные свойства:

* Тест "direct" - прямое формирование операций на входной шине axi stream 
* Тест "randomize" - псеводслучайное формирование операций
* Драйвер для формирования операций
* Монитор для контроля результата
* Передача ожидаемых данных через очередь
* Таймаут на время выполнения теста
* Подключние модуля bind_user_axis через команду bind
* Контроль покрытия code coverage, тест randomize завершается только при достижении 100% покрытия
* Запуск на сайте EDA Playground, используется симулятор Mentor Questa 2020.1
* Запуск на Vivado, используется консольный и графический режим
* Параметр test_id передаётся через $value$plusargs()
* Групповой запуск тестов через командный файл


## Описание

Верхним уровенем тестирования является файл testbecnh.sv с компонентом tb(); Параметр test_id задаётся в командной строки симулятора и передаётся через функцию $value$plusargs(); В зависимости от этого параметра запускаются различые тесты.

Массив test_name содержит имена тестов, есть два теста "direct" и "randomize"

## Запуск на EDA Playground

Адрес сайта: https://www.edaplayground.com/

На сайт требуется загрузить исходные файлы проекта и командный файл run.bash

Для работы надо выбрать симулятор Mentor Questa 2020.1

Возможно два режима выполнения:
1. Запуск одиночного теста.
2. Запуск группы тестов

Запуск одиночного теста производится обычным образом. Должен быть снят выбор с поля "Use run.bash"; В поле  "Run option" надо добавить параметр +test_id=<номер теста>. Выбранный тест будет запущен.

Запуск группового теста производится через файл run.bash; Необходимо поставить выбор на поле "Use run.bash". 

В каждом сеансе работы первым запуском должен быть запуск одиночного теста.

Файл run.bash
    vlib work 
    vlog -writetoplevels questa.tops '-timescale' '1ns/1ns' design.sv testbench.sv  
    echo "" > global.txt
    vsim -f questa.tops  -batch -do "vsim -voptargs=+acc=npr ; run -all; exit" -voptargs=+acc=npr +test_id=0
    vsim -f questa.tops  -batch -do "vsim -voptargs=+acc=npr ;coverage save -onexit result.ucdb ; run -all; exit" -voptargs=+acc=npr +test_id=1
    vcover report -details result.ucdb
    #vcover report -html -details result.ucdb
    cat global.txt

Строки которые начинаются с vsim запускают сеанс моделирования с заданным номером теста. Необходимо задать требуемые номера тестов. Покрытие code coverage формируется для теста test_id=1; Отчёт формируется в текстовом виде и выводится в консоль. При необходимости можно убрать комментарий со строчки формирования отчёта в html формате и установить выбор в поле "Download files after run". Все файлы будут собраны в архив result.zip и загружены на локальный компьютер. Пример отчёта в каталоге example_questa_cvr_report.

## Использование Vivado

Необходимо открыть терминал и перейти в каталог vivado. При работе в Visual Studio Code возможно использование встроенного терминала.

Необходимо настроить переменные окружения для работы в выбранной версии Vivado. Текущая версия 2021.1.

В каталоге vivado содержатся командные файлы:

* compile.sh - для компилирования исходных текстов
* elaborate.sh - для сборки проекта
* c_run_0.sh - запуск теста test_id=0 в консольном режиме
* c_run_1.sh - запуск теста test_id=1 в консольном режиме
* g_run_0.sh - запуск теста test_id=0 в режиме GUI
* g_run_1.sh - запуск теста test_id=1 в режиме GUI
* cvr.sh - формирование отчёта code coverage
* all.sh - компиляция, сборка, запуск всех тестов в консольном режиме и формирование отчёта 

При выборе запуска в режиме GUI будет запущен симулятор Vivado. 

Пример отчёта находится в каталоге example_vivado_cvr_report