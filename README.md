# ![StructureHunter](https://repository-images.githubusercontent.com/726766577/034565b5-7aa9-4bc9-a354-3929cad595d5)
# README #


[RU]
Плагин для поиска сработанных смещений в структуре во время игры.

Поиск сработанных смещений в структуре по типу "запись и чтение", "только запись"
Фильтрация сработанных смещений "изменилось/не изменилось"
Возможность по результатам смещений сгенерировать структуру в CE
В нижней части таблицы просмотр последовательности срабатываний смещений
Принцип работы:

Установить адрес начала структуры числом или меткой и указать размер предполагаемой структуры. Размер точно определить может не получиться, поэтому примерный размер 4096. Его можно выставить и это может захватить соседние структуры или данные.
После старта устанавливается брейкпоинт на область памяти. Это тип брейкпоинта довольно медленный и игра начнет медленно рисовать кадры. Однако это позволит следить за обращением ко всей структуре. Поэтому нужно снимать показания в определённые короткие моменты игры, например, во время получения урона, получения здоровья, прыжка, столкновения и т.п.
Более подробно можно посмотреть на видео.

[![Find offsets](https://img.youtube.com/vi/zC4VgWRMRhs/0.jpg)](https://www.youtube.com/watch?v=zC4VgWRMRhs "Find offsets")

[En]

## This Plugin for searching for triggered offsets in the structure during the game.

* Search for triggered offsets in the structure by type "write and read", "write only".
* Filtering of triggered "changed/unchanged" offsets.
* Ability to generate a structure in CE based on the results of displacements.
* At the bottom of the table is a view of the sequence of displacements.


## Principle of operation:

* Set the address of the start of the structure with a number or label and indicate the size of the intended structure. It may not be possible to determine the exact size, so the approximate size is 4096. It can be set and this may capture neighboring structures or data.
* After the start, a breakpoint is set to the memory area. This type of breakpoint is quite slow and the game will start drawing frames slowly. However, this will allow you to monitor access to the entire structure. Therefore, you need to take readings at certain short moments of the game, for example, while receiving damage, gaining health, jumping, colliding, etc.
* You can watch the video for more details.

Set the address of the start of the structure with a number or label and indicate the size of the intended structure. It may not be possible to determine the exact size, so the approximate size is 4096. It can be set and this may capture neighboring structures or data.
After the start, a breakpoint is set to the memory area. This type of breakpoint is quite slow and the game will start drawing frames slowly. However, this will allow you to monitor access to the entire structure. Therefore, you need to take readings at certain short moments of the game, for example, while receiving damage, gaining health, jumping, colliding, etc.
You can watch the video in more detail.
