--[[ 
    Скрипт поиска срабатывающих/не срабатывающих смещений у структур через page exception брейкпоинт

    Исходники написал MasterGH 2021г.

    frmStructureHunter
    CEEdit_InputStructure            - строка ввода начала структуры
    CEEdit_sizeStructure             - строка размера структуры
    
    CEButton_Start                   - старт
    CEButton_RemoveActiveOffsets     - удалить активные смещения
    CEButton_RemoveNoActiveOffsets   - удалить неактинвые смещения
    CEButton_DessectData             - расструктуризация (создает новую структуру)
    CEButton_StopDebugger            - удаляет все поставленные точки останова
    CEButton_RemoveBreakpoint        - кнопка снятия брейкпоинта
    CERadioGroup_TypeBreakPoints     - тип брейкпоинта (0 - обращение, 1 - только запись)
    CECheckbox_logout                - выводить логи в Lua консоль 

    CEListView_hunter                - list основоного лога
    
    CEListView_History               - list для лога истории
    CEEdit_History_Offsset           - input для смщения истории
    CEEdit_History_Buffer            - input буфер истори
    
    1. Протестировать на игре
    2. Собрать форму и плагин
    3. Записать видео
    4. Опубликовать файлы
  ]]--
  
  -- Скрывать форму по умолчанию иначе будет показана
  local isHidefrmStructureHinter = true

  function ShowFormfrmStructureHunter()
    frmStructureHunter.show()
  end
  
  --getMainForm().Caption = getMainForm().Caption .. ' (для записи видео MasterGH, 2021)'
  -- Вызов окна из меню
  local menuItem = menu_getItems(form_getMenu(getMainForm()))
  newItem1 = createMenuItem(menuItem)
  menuItem_add(menuItem, newItem1)
  menuItem_setCaption(newItem1, 'Offset Hunter')
  menuItem_onClick(newItem1, ShowFormfrmStructureHunter)
    
  -- Выключает плагин
  isLockPlugin = true
  if isLock then
    return
  end  
  
  require ('autorun\\ClassOpcode')
  local tick_timer =  2000
  
  local structure_address = 0
  local structure_size = 0x1000
  data_structure = {}
  tablehistory = {}
  
  debugAddress = 0x0
  debug_mode = "AFTER_STOP"   -- AFTER_STOP  RUN_TIME
  isShowLog = false
  logs = ''
  local isFindingRip = false
  local hardOpcode = { 'repe'  }
  -- Управление логами
  local is_log_out = true
  -- Radio box тип брейкпоинта
  local type_break_point = bptAccess  
  -- процесс снятия брейкпоинта с верменным отключением контролов
  local is_removed_break_point = false
  
  
  -- оффест, который срабатывает — его история срабатывания как раз логируется в таблицу
  local history_offset = 0
  -- Максимальный буфер истории (количество строк в таблице)
  history_buffer = 8 
  -- Сколько items уже создано в истории
  history_maked_items = 0
  historyOrderCounter = 1
  
  local process_ui_locker = false
  

  function Log(line)
    if is_log_out 
      then print(line) 
    end
  end
  
    -- Удаляет изменившиеся офссеты. Кнопка "Не изменилось" - должна оставить не изменившиеся счетчики
  function RemoveAllActiveOffsets()
    process_ui_locker = true    
    frmStructureHunter.CEListView_hunter.beginUpdate()    
    local cout_data_structure = #data_structure
    for i=#data_structure,1,-1 do
      if not data_structure[i].is_removed then      
        if data_structure[i].counterRIP ~= data_structure[i].last_count_rip then
          data_structure[i].is_removed = true
          RemoveItem(data_structure[i])
          data_structure[i].last_count_rip = data_structure[i].counterRIP
        else 
          data_structure[i].last_count_rip = data_structure[i].counterRIP
        end        
      end
    end
    frmStructureHunter.CEListView_hunter.endUpdate()
    process_ui_locker = false
  end
  
  -- Удаляет все не изменившиеся оффсеты. Кнопка "Изменилось" - должна оставить изменившиеся счетчики
  function RemoveAllNoActiveOffsets()
    process_ui_locker = true
    frmStructureHunter.CEListView_hunter.beginUpdate()
    local iCount = #data_structure
    for i=iCount,1,-1  do
      if not data_structure[i].is_removed then      
        if data_structure[i].counterRIP == data_structure[i].last_count_rip then
          data_structure[i].is_removed = true
          RemoveItem(data_structure[i])
          data_structure[i].last_count_rip = data_structure[i].counterRIP
        else 
          data_structure[i].last_count_rip = data_structure[i].counterRIP
        end          
      end
    end    
    frmStructureHunter.CEListView_hunter.endUpdate()
    process_ui_locker = false
  end
  
  -- Удаляет строку из UI
  function RemoveItem(data_structure_item)
    if data_structure_item.menu_item ~= nil then
      data_structure_item.menu_item.delete()
    end
    data_structure_item.is_removed = true
  end
  
  -- Создает строку данных для UI
  function GetItemtext(data_structure_item)
    local s_is_read_offset = '0'
    local s_is_write_offset = '0'
    
    if data_structure_item.is_read_offset then  s_is_read_offset = '1' end    
    if data_structure_item.is_write_offset then  s_is_write_offset = '1' end
    
    local lineS = string.format('+%03X\n%s\n%s\n%s\n%s\n%s\n%08X\n%s\n%s',
            data_structure_item.offset,
            data_structure_item.counterRIP,
            data_structure_item.size,
            s_is_write_offset,
            s_is_read_offset,
            data_structure_item.value,
            data_structure_item.rip,
            data_structure_item.lineOpcode,
            data_structure_item.bytes)
    
    return  lineS
  end
  
  function GetItemtext2(data_structure_item)
    local s_is_read_offset = '0'
    local s_is_write_offset = '0'
    
    if data_structure_item.is_read_offset then  s_is_read_offset = '1' end    
    if data_structure_item.is_write_offset then  s_is_write_offset = '1' end
    
    local lineS = string.format('+%03X\n%s\n%s\n%s\n%s\n%s\n%08X\n%s\n%s',
            data_structure_item.offset,
            data_structure_item.counterRIP,
            data_structure_item.size,
            s_is_write_offset,
            s_is_read_offset,
            data_structure_item.value,
            data_structure_item.rip,
            data_structure_item.lineOpcode,
            data_structure_item.bytes)
    
    return  lineS
  end

  -- Добавляет строку в UI
  function AddItem(data_structure_item)
    local listItem = frmStructureHunter.CEListView_hunter.Items.add()
    data_structure_item.menu_item = listItem
    listItem.Caption = data_structure_item.order_index
    local textRow = GetItemtext(data_structure_item)
    data_structure_item.rowTable = textRow
    listItem.SubItems.Text = textRow
  end
  
  local checkFistSort = false
  local isDigitSort = false
  local asDescending = false
  local lastClickColumn = nil
  
   -- Сортировка через клики по столблцам (аналогичн сортировке на Дельфи)
  function frmStructureHunter_CEListView_hunterColumnClick(sender, listcolumn)

    if listcolumn == lastClickColumn then
      asDescending = not asDescending
    else
      asDescending = false
    end
    
    lastClickColumn = listcolumn

    if asDescending then
      frmStructureHunter.CEListView_hunter.SortDirection = 'sdDescending'
    else
      frmStructureHunter.CEListView_hunter.SortDirection = 'sdAscending'
    end   
  
    --print('Column '..listcolumn.Caption)
    isDigitSort = false
    
    if listcolumn.Caption == '№' then
      isDigitSort = true
      for i=1, #data_structure do
        if not data_structure.is_removed and data_structure[i].menu_item ~= nil then
          data_structure[i].menu_item.Data = data_structure[i].order_index
        end
      end
    end   
    
    if listcolumn.Caption == 'Смещение' then
      isDigitSort = true
      for i=1, #data_structure do
        if not data_structure.is_removed and data_structure[i].menu_item ~= nil then
          data_structure[i].menu_item.Data = data_structure[i].offset
        end
      end
    end  
    
     if listcolumn.Caption == 'Счетчик' then
      isDigitSort = true
      for i=1, #data_structure do
        if not data_structure.is_removed and data_structure[i].menu_item ~= nil then
          data_structure[i].menu_item.Data = data_structure[i].counterRIP
        end
      end
    end 
    
     if listcolumn.Caption == 'Значение' then
      isDigitSort = true
      for i=1, #data_structure do
        if not data_structure.is_removed and data_structure[i].menu_item ~= nil then
          data_structure[i].menu_item.Data = data_structure[i].value
        end
      end
    end  
    
    if isDigitSort then
      frmStructureHunter.CEListView_hunter.SortType = 'stData'
      frmStructureHunter.CEListView_hunter.OnCompare = frmStructureHunter_CEListView_hunterCompare
    else
      frmStructureHunter.CEListView_hunter.SortType = 'stText'
      frmStructureHunter.CEListView_hunter.OnCompare = nil
    end
  end

  function frmStructureHunter_CEListView_hunterCompare(sender, listitem1, listitem2, data)
    
    if  listitem1.Data == listitem2.Data then  return 0  end    
    
    if asDescending then    
      if listitem1.Data < listitem2.Data then  return 1  end    
      return -1 --0=equal -1=smaller 1=bigger  
    end
    
    if listitem1.Data < listitem2.Data then  return -1  end    
    return 1 --0=equal -1=smaller 1=bigger   
  end

  -- ОБновляет строку в UI
  function UpdateItem(data_structure_item)  
    if data_structure_item.menu_item  ~= nil and 
         data_structure_item.menu_item.SubItems ~= nil then
      data_structure_item.menu_item.SubItems.Text = GetItemtext2(data_structure_item)
    end
  end


  -- Обновляет UI по таймеру (счетчики)
  function UpdateItems()

    
      -- процесс удаление брейкпоинтов
    if continue_remove_breakpoints then
       tableBreakpointList = debug_getBreakpointList()
              
       if tableBreakpointList ~= nil and #tableBreakpointList > 0 then
          RemoveBreakPoints(structure_address)
       else
          StopGUITimer()
          continue_remove_breakpoints = false;
          
          -- Деактивировать контроллы кроме первой кнопки
          SetStateControls(false)
          frmStructureHunter.CEButton_Start.Enabled = true    
          frmStructureHunter.CEButton_DessectData.Enabled = true
       end
    end
    
     if is_removed_break_point then
       return
     end
     
     -- пока меняется таблица с ней ничего не делать
     if process_ui_locker then
        return
     end
     

    frmStructureHunter.CEListView_hunter.beginUpdate()
    local iCount = #data_structure  
    for i = iCount,1,-1  do
      if data_structure[i] == nil then
        print('error data_structure[i] == nil i = '..i)
      else
        local item = data_structure[i]
        if not item.is_executted and not item.is_removed then
          item.is_executted = false
          UpdateItem(item)
        else 
          if item.isUpdateUI and not item.is_removed then
            item.isUpdateUI = false
            UpdateItem(item)
          end
        end
      end
    end
    frmStructureHunter.CEListView_hunter.endUpdate()

    
    -- Обновления истории
    HistoryOnTimerLogCheker()
  end

  -- Запускает таймер обновления UI
  function StartGUITimer()
    if timer_update_gui ~= nil then
       object_destroy(timer_update_gui)
    end
    timer_update_gui = createTimer(nil);
    timer_setInterval(timer_update_gui, tick_timer)
    timer_onTimer(timer_update_gui, UpdateItems)
  end

  -- Останавливает таймер обновления UI
  function StopGUITimer()
    object_destroy(timer_update_gui)
  end


  -- Удаляет брейкпоинты
  function RemoveBreakPoints(address)
    debug_removeBreakpoint(address)
  end

  -- Очищает все данные
  function ClearAllData()
    data_structure = {}
    frmStructureHunter.CEListView_hunter.Items.Clear()
  end

  --Расструктуризация
  function DessectData()
    ShowStructure()
  end
  

   function ButtonRemoveBreakPoint()
      frmStructureHunter.CEButton_Start.Caption = 'Продолжить'
      StopPlugin()
      SetStateControls(false)       
      frmStructureHunter.CEButton_DessectData.Enabled = true       
      is_removed_break_point = true
   end
   
   function SetStateControls(state)
    frmStructureHunter.CEButton_Start.Enabled                   = state
    frmStructureHunter.CEButton_RemoveActiveOffsets.Enabled     = state
    frmStructureHunter.CEButton_RemoveNoActiveOffsets.Enabled   = state
    frmStructureHunter.CEButton_DessectData.Enabled             = state
    frmStructureHunter.CEButton_StopDebugger.Enabled            = state
    frmStructureHunter.CEButton_RemoveBreakpoint.Enabled        = state
   end
   
      
   -- Запуск плагина
   function StartPlugin()
    if is_removed_break_point then 
       frmStructureHunter.CEButton_Start.Caption = 'Старт'
       frmStructureHunter.CEButton_DessectData.Enabled = true
       is_removed_break_point = false
    else
      is_log_out = frmStructureHunter.CECheckbox_logout.Checked 
      structure_address = getAddress(frmStructureHunter.CEEdit_InputStructure.text)
      structure_size = tonumber(frmStructureHunter.CEEdit_sizeStructure.text)
      local index_record = frmStructureHunter.CERadioGroup_TypeBreakPoints.ItemIndex
      if index_record == 0 then
         type_break_point = bptAccess
      else
         type_break_point = bptWrite
      end
      ClearAllData()
      Log('ClearAllData')
    end
    Log('structure_address: '..structure_address)
    Log('structure_size: '..structure_size)
    Log('type_break_point: '..type_break_point)
    debug_setBreakpoint(structure_address, structure_size, type_break_point, bpmException, debugger_onBreakpoint_find_offsets)
    StartGUITimer()
    SetStateControls(true)
    frmStructureHunter.CEButton_Start.Enabled = false 
  end
  
  -- Остановка плагина
  function StopPlugin()
    continue_remove_breakpoints = true
    SetStateControls(false)
  end
  
  local recordIndex = 1
   -- Содержит индексы rip_tabe — это логирование rip, которые срабатывали
  local table_history_index_rips = {}
  local buffer_table_history_index_rips = 4*10*1024
  -- содержит индексы из buffer_table_history_index_rips размермо не более history_buffer
  -- таймер сможет вывести по  buffer_table_for_timerUI индексам предыдущие смещения до указанного
  local buffer_table_for_timerUI = {}
   -- Обновляет историю в таблице.
   -- Пример:
   --     local line = string.format('+%03X\n%s\n%s\n%s\n%s\n%s\n%08X\n%s\n%s',12,69,30,40,50,60,70,80,90)
   --     AddToHistory(line)
   
   function AddToHistory(lineTable)
    if history_maked_items < history_buffer then
        local newItem = history.Items.add()
        newItem.Caption = historyOrderCounter
        newItem.SubItems.Text = lineTable
        history_maked_items = history_maked_items + 1

        for i = history_maked_items - 1, 1, -1  do
          history.Items[i] = history.Items[i-1]
        end
        history.Items[0] = newItem
    else
       local lastItem = history.Items[history_maked_items - 1]

       for i = history_maked_items - 1, 1, -1  do
         history.Items[i] = history.Items[i-1]
       end
       
       lastItem.Caption = historyOrderCounter
       lastItem.SubItems.Text = lineTable
       history.Items[0] = lastItem
    end
     historyOrderCounter = historyOrderCounter + 1
  end 
  
  isHasBufferHistory = false
  
  -- + Проверяет, что нужно обновить данные в таблице истории
  function HistoryOnTimerLogCheker()
  
    if isHasBufferHistory then

      local size_history_buffer = #buffer_table_for_timerUI
      
      for j = 0, size_history_buffer do
         if j < history_buffer then
            local index = buffer_table_for_timerUI[j]

            local item = data_structure[index]
            if item ~= nil then
              -- Из ItemListView скопирует смещение, которое раньше срабтало
              --if item.menu_item ~= nil then
              --  local line = item.menu_item.SubItems.Text
              --end
              AddToHistory(item.rowTable)
            end
         end
      end
      isHasBufferHistory = false
     end
   end
          

  -- +Выводит данные в табилце истории
  function HistoryLogOut(index)
           -- Записывает в историю, что был такой-то rip-index
          table_history_index_rips[recordIndex] = index
          recordIndex = recordIndex + 1
          
          -- Если больше максимального буфера, то счетчик начинается сначала
          if recordIndex > buffer_table_history_index_rips then
            recordIndex = 1
          end
          
          -- Если было прерывание на исследуемый offset, то копировать историю предыдущих прерываний и показать по таймеру
          -- TODO: добавить этот же дело в первую RIP запись
          
          if data_structure[index] == nil then
            print(' data_structure[index] == nil '..index)
          end
          
          if data_structure[index].offset == history_offset then
            for j = 0, history_buffer do
               --print ('1record index '..recordIndex)
               --print ('j index '..j)
               if recordIndex - j > 0 then
                    -- копируюстя index-ы rip таблицы
                    local storyIndex = table_history_index_rips[recordIndex - j]
                    
                    if storyIndex == nil then
                    
                    else
                      buffer_table_for_timerUI[j] = storyIndex
                      --print ('2record index '..recordIndex - j)
                      --print ('index '..table_history_index_rips[recordIndex - j])
                      isHasBufferHistory = true
                    end
               end
            end
            -- обноулятся индекс олга
            recordIndex = 0
          end
           
  end  
           
   -- Собирает данные брейкпоинтов
  function debugger_onBreakpoint_find_offsets()

    -- Когда происходит состояния снятия брейкпоинта ничего логирокать не нужно
    if continue_remove_breakpoints then
      return
    end
    
    isFindingRip = false

    if RIP == nil then
      print('RIP == nil')
      debug_continueFromBreakpoint(co_run)
      return 1
    end

    -- Собираем уникальные RIP
    local iCount = #data_structure
    for i = 1, iCount do
    
      local itemRIPData = data_structure[i]
      
      if itemRIPData.rip == RIP then
      
        isFindingRip = true
        
        if not itemRIPData.is_removed then
          itemRIPData.counterRIP = data_structure[i].counterRIP  + 1
          itemRIPData.is_executted = true          
          -- todo: сделать по таймеру обновление
          itemRIPData.isUpdateUI = true
         end 
         
          -- itemRIPData.is_removed не распрастраняется на HistoryLogOut
          if not itemRIPData.error_found_offset then 
              HistoryLogOut(i)
          end
        
        break
      end
    end

    if not isFindingRip then
      -- А ЕСЛИ один и тот же Rip работает с разными offesets в структуре?
        --  тогда надо учитвать смещение и rip 
           -- если offset такой есть, то структуру не создавать
           -- пока считает что уникальный rip - на уникальынй offset
      
      -- если регистр RIP не найден, то создать контекст и структуру
      local context1 = getContextTable()
      if context1 == nil then Log('error context'..context1 == nil)  end

      Log(disassemble(getPreviousOpcode(RIP)))
      local data_structure_item = 
      {
        -- Ключ данных по RIP регистру
        rip = RIP,
        -- индекс добавления элемента
        order_index = iCount,
        
        -- Счетчик RIP
        counterRIP = 1,
        -- Прошлый сечтик RIP для кнопок: выполнилось и не выполнилось 
        last_count_rip = 0,
        -- Данные нужно обновить в UI по таймеру
        is_executted = true,
        -- Контекст для определения смещения
        context = context1,
        -- Смещение, которое еще не расчитано
        offset = 0,
        -- Размер данных смещения (или тип данных)
        size = 0,
        -- смещение читают
        is_read_offset = false,
        -- в смещение пишут
        is_write_offset = false,
        -- скрыть в таблице этот RIP
        is_removed = false,
        menu_item = nil,
        -- Смещение не определено
        error_found_offset = false,
        -- Дизассемблераня строка
        lineOpcode = '',
        bytes = '',
        value = 0,
        isUpdateUI = false,
        rowTable =''
      }
      -- TODO: что быстрее? table.insert(data_structure, RIP) или  data_structure[#data_structure + 1]
      local localnewIndex = #data_structure + 1
      data_structure[localnewIndex] = data_structure_item
      
      -- Влияет на: offset, lineOpcode,  error_found_offset
      FindOffset(data_structure_item)
      
      if not data_structure_item.error_found_offset then
      
        data_structure_item.error_found_offset = IsProblemOpcode(data_structure_item.context.rip)
                
        if data_structure_item.error_found_offset then
           Log("Eror7. Can't read offset from: "..disassemble(data_structure_item.context.rip))
           return
        end  
    
        -- определения размера данных
        local someOtherOpcode = ClassOpcode:New(data_structure_item.context)
        local isReadValueOrWriteValue = someOtherOpcode:isCodeReadingValue()
        data_structure_item.is_read_offset = isReadValueOrWriteValue
        data_structure_item.is_write_offset = not isReadValueOrWriteValue
        
        local sizeValue, typeValue, sTypeValue = someOtherOpcode:getTypeValue()	
        
      if is64bits == nil then
        is64bits = targetIs64Bit()
      end
  
      local value = 0
      local target_structure_address = data_structure_item.offset + structure_address
      

      if typeValue == 0 then       value = readBytes(target_structure_address,1, false)
        elseif typeValue == 1 then value = readSmallInteger(target_structure_address)
        elseif typeValue == 2 then value = readInteger(target_structure_address)
        elseif typeValue == 3 then value = readQword(target_structure_address)
        elseif typeValue == 4 then value = readFloat(target_structure_address)
        elseif typeValue == 5 then value = readDouble(target_structure_address)
        elseif typeValue == 6 then value = readString(target_structure_address, 8)
        elseif typeValue == 7 then value = readString(target_structure_address, 8, true)
        elseif typeValue == 8 then value = 'vtByteArray'
        elseif typeValue == 12 then value = string.format('0x%08X', target_structure_address)
        elseif typeValue == 13 then value = 'vtCustom' 
      end
   
        data_structure_item.size = sTypeValue        
        data_structure_item.value = value
        AddItem(data_structure_item)
      
      end
      
      if not data_structure_item.error_found_offset then 
          HistoryLogOut(localnewIndex)
      end

    end
    
    debug_continueFromBreakpoint(co_run)
  end

   -- Функция которая ищет оффсет с большого брейкпоинта
  function FindOffset(data_structure_item) -- возвращает offest

    --data_structure_item.error_found_offset = IsProblemOpcode(data_structure_item.context.rip)
            
    --if data_structure_item.error_found_offset then
    --   Log("Eror1. Can't read offset from: "..data_structure_item.context.rip)
    --   return
    --end  

    -- пока только такой костыльный способ через шаг назад на инструкцию
    local prevRipAddress = getPreviousOpcode(data_structure_item.rip)
    
    data_structure_item.error_found_offset = IsProblemOpcode(prevRipAddress)
    
    if data_structure_item.error_found_offset then
       Log("Eror2. Can't read offset from: "..prevRipAddress)
       return
    end

    --TODO^ Да, но здесь на предыдущей инструкции может быть перезапись
      -- mov eax [eax+xx]
      -- mov eax. ebx
    data_structure_item.context.rip = prevRipAddress
    
    local opcode = ClassOpcode:New(data_structure_item.context)
    
    local addressInStructure = opcode:getTargetAddressFromOpcode()
    
    if addressInStructure == nil then
      data_structure_item.error_found_offset = true
      Log('Error3. addressInStructure == nil '..disassemble(prevRipAddress))
    else
    
      local offset = addressInStructure - structure_address
      data_structure_item.offset = offset
      
      -- Если есть перезаписываемые регистры, то 
      local clearStringPrevAddress = disassemble(prevRipAddress)  
      local address, lineOpcode, bytes, extra = splitDisassembledString(clearStringPrevAddress)
      --local lineOpcode = 'mov rax,[rax+00000470]'
      
      data_structure_item.lineOpcode = lineOpcode
      data_structure_item.bytes = bytes
      
      local left, right = lineOpcode:match('%S%s(.+),%[(.+)%]')
      if right == nil or left == nil then
        data_structure_itemis_rewritepcodes = false
      else
        --data_structure_item.is_rewritepcodes = right:match(left)
        data_structure_item.error_found_offset = right:match(left)
      end
      
     if data_structure_item.error_found_offset then
       Log("Problem Opcode from: ".. lineOpcode)
     end
     
    end      
  end    
  
  -- Проблемные опкоды, которые предстоит доработать
  function IsProblemOpcode(someRIP)    
    local opcode = disassemble(someRIP)   
    for i = 1, #hardOpcode do
      if opcode:match(hardOpcode[i]) then
        Log('IsProblemOpcode true'.. opcode)
        return true
      end
    end    
    return false
  end   
    
  -- Одна из записей в таблице выделена
  -- Используется для расструктуризации
  function SomeSelectedMenuItems()
    local selectCount = 0
    local iCount = #data_structure    
    for i = 1, iCount do
      if not data_structure[i].isProblemOpcode and not data_structure[i].is_removed  then
        if data_structure[i].menu_item ~= nil and data_structure[i].menu_item.Selected then
          selectCount = selectCount + 1
        end
      end
    end    
    return selectCount
  end
  
   function AllDelectedMenuItems()

    local iCount = #data_structure    
    for i = 1, iCount do
      if not data_structure[i].isProblemOpcode and not data_structure[i].is_removed  then
        if data_structure[i].menu_item ~= nil and data_structure[i].menu_item.Selected then
          data_structure[i].menu_item.Selected = false
        end
      end
    end    
  end  
    
  -- Функция пытается создать структуру и открыть её в окне расструктуризации
  function ShowStructure()
  
    local filter_out_only_read_opcode = frmStructureHunter.CECheckbox_LogOut_OnlyReadValues.Checked
  
    tableFilteredStructure = {}    
    -- установить типы данных и запись их
    local iCount = #data_structure    
    local dataOffset = {}
    
    local some_row_selected = SomeSelectedMenuItems() > 1
    
    for i = 1, iCount do
      if not data_structure[i].isProblemOpcode and not data_structure[i].is_removed and 
      (not some_row_selected or (some_row_selected and (data_structure[i].menu_item ~= nil and data_structure[i].menu_item.Selected)))  then
      
        -- здесь одинаковые оффсеты в массиве
        local offset = data_structure[i].offset
        local mainOpcode = ClassOpcode:New(data_structure[i].context)
        local complexOffest = {mainOpcode}
        
        local isExistOffset = false
        
        for j = 1, #dataOffset do
          if dataOffset[j].offset == offset then
            isExistOffset = true
            break
          end
        end
        
        if not isExistOffset then
        -- собирает все ассеты по кучкам
        for j = i + 1, iCount do
          if data_structure[i].offset == data_structure[j].offset and not data_structure[j].isProblemOpcode 
          and not data_structure[j].is_removed  then
            local someOtherOpcode = ClassOpcode:New(data_structure[j].context)
            complexOffest[#complexOffest + 1] = someOtherOpcode				
          end
        end

        dataOffset[#dataOffset + 1 ] = 
        {
          offset = offset,
          complexOffest = complexOffest
        }
        end   
      end
    end

    for i = 1, #dataOffset do
      local offset = dataOffset[i].offset
      local complexOffest = dataOffset[i].complexOffest

      local targetAdressInBrakets = structure_address + offset
      local bestInstruction, tableInstructionsRewrites, someWriteOpcode = 
        getBestOpcodeAndTableRegisterRewrites(complexOffest, targetAdressInBrakets)
      ----------------
            
      -- TODO: tableInstructionsRewrites содержит перезаписываемые опкоды

      local currentOpcode = ''
      local prefixWrite = ''

      if someWriteOpcode then
        prefixWrite = 'WRITE: '
      end
      
      if filter_out_only_read_opcode and someWriteOpcode then
        goto continue
      end
        
      if bestInstruction == nil then
        -- TODO: закомментить в релизе
        -- Выводит перезаписываемые регистры
        if #tableInstructionsRewrites > 0 then
        
          Log('Error 1 or Warning')
          local count = #tableInstructionsRewrites
          
          bestInstruction = tableInstructionsRewrites[0]
          currentOpcode = bestInstruction.Opcode
          
          Log("Rewrite "..currentOpcode)
          for j= 1, count do
            Log(addressInStructure..' : '..currentOpcode)
          end
           
           -- Берем первый
          local sizeValue, typeValue, sTypeValue = bestInstruction:getTypeValue()	
          
          local comment = ''

          if currentOpcode:match('cmp') or currentOpcode:match('add') or currentOpcode:match('sub') or currentOpcode:match('xor') or
            currentOpcode:match('or ') or currentOpcode:match('and') or currentOpcode:match('not') or currentOpcode:match('test') or
            currentOpcode:match('mulss') or currentOpcode:match('fsub') or currentOpcode:match('fadd') or currentOpcode:match('fmul') or
             currentOpcode:match('fdiv') or currentOpcode:match('dec') or currentOpcode:match('inc') or currentOpcode:match('fst') or currentOpcode:match('mul')
          then
            comment = prefixWrite..currentOpcode:match('%S.+')..' '..sTypeValue
          else
            --Log('->>'.. currentOpcode)
            --Log('->>>>'.. sTypeValue)
            comment = prefixWrite..'\t'..currentOpcode:match('%[.*%]')..' '..sTypeValue
          end
          
          tableFilteredStructure[#tableFilteredStructure + 1] = 
          {
            Offset	= offset,
            SizeValue = sizeValue,
            Vartype = typeValue,
            Comment = comment,
            BestOpcode = tableInstructionsRewrites[0]
          }
          
          Log('T1 sizeValue '..  sizeValue)
          Log('T1 sTypeValue '..  sTypeValue)
          Log('T1 comment '..  comment)
        
        else
          Log ("Error 2")
        end
        
      else
        
        local sizeValue, typeValue, sTypeValue = bestInstruction:getTypeValue()	
        
        local comment = ''
        currentOpcode = bestInstruction.Opcode
        --[[
        if currentOpcode:match('cmp') or currentOpcode:match('add') or currentOpcode:match('sub') or currentOpcode:match('xor') or
          currentOpcode:match('or ') or currentOpcode:match('and') or currentOpcode:match('not') or currentOpcode:match('test') or
          currentOpcode:match('mulss') or currentOpcode:match('fsub') or currentOpcode:match('fadd') or currentOpcode:match('fmul') or
          currentOpcode:match('dec') or currentOpcode:match('inc') or currentOpcode:match('fst') or currentOpcode:match('mul')
        then
          --comment = prefixWrite..currentOpcode:match('%S.+')..' '..sTypeValue
          comment = sTypeValue..' '..prefixWrite..' 'currentOpcode
        else
          --Log('->>'.. currentOpcode)
          --Log('->>>>'.. sTypeValue)
          --comment = prefixWrite..currentOpcode:match('%[.*%]')..' '..sTypeValue
          comment = sTypeValue..' '..prefixWrite..' 'currentOpcode
        end
        ]]--
        
        comment = sTypeValue..' '..prefixWrite..'\t'..currentOpcode

        
        --tableFilteredStructure[i].typeValue = typeValue
            
        tableFilteredStructure[#tableFilteredStructure + 1] = 
        {
          Offset	= offset,
          SizeValue = sizeValue,
          Vartype = typeValue,
          Comment = comment,
          BestOpcode = bestInstruction
        }
        
        Log('sizeValue '..  sizeValue)
        Log('typeValue '..  typeValue)
        Log('comment '..  comment)
      end
    
      ::continue::
      
    end
    
    MakeStructure(tableFilteredStructure)
    
    
    
    -- учитывать лучший окод по приоритетам: float приоритетней чем 4 байта
    -- открыть окно расструктуризации
    -- создать структуру
    -- открыть её
  end

  function MakeStructure(tableFilteredStructure)

      local addressSome = getNameFromAddress(structure_address)
      local newNameStructure = 'auto_'..addressSome..'_'..#tableFilteredStructure

      myStructure = createStructure(newNameStructure)
      myStructure.addToGlobalStructureList()

      --myStructure.autoGuess(addressSome, 0, sizeStructure)
      myStructure.beginUpdate()
      -- Заполнение структуры по типам, которые определил сканер

      for i,k in ipairs(tableFilteredStructure) do
        -- Проверка на поинтер
        if is64bits then
        if tableFilteredStructure[i].Vartype == vtQword or tableFilteredStructure[i].Vartype == vtDouble then
          if getAddressSafe('[['..getNameFromAddress(tableFilteredStructure[i].Offset + structure_address)..']]') then
          tableFilteredStructure[i].Vartype = vtPointer
          end
        end
        else
        if tableFilteredStructure[i].Vartype == vtDword or tableFilteredStructure[i].Vartype == vtSingle
          then
          if getAddressSafe('[['..getNameFromAddress(tableFilteredStructure[i].Offset + structure_address)..']]') then
          tableFilteredStructure[i].Vartype = vtPointer
          end
        end
        end

        local newElement    = myStructure.addElement()
        newElement.Offset   = tableFilteredStructure[i].Offset
        newElement.Vartype  = tableFilteredStructure[i].Vartype
        newElement.Name     = tableFilteredStructure[i].Comment
      end
      myStructure.endUpdate()
    
    ----------------------------------------------------
    local structureFrm = createStructureForm(addressSome)
    -- Выбрать структуру на форме. Через UI клик по индексу последней созданной структуры
    local structureIndex = getStructureCount() - 1	
    structureFrm.MainStruct = myStructure
    structureFrm.Menu.Items[2][structureIndex+3].doClick()
  end
  
    --------------- Интерфейс ----------------------
   
  function InitfrmStructureHunter()
    history = frmStructureHunter.CEListView_History
    -- Кнопка старта отладки
    frmStructureHunter.CEButton_Start.OnClick                 = StartPlugin
    frmStructureHunter.CEButton_RemoveActiveOffsets.OnClick   = RemoveAllActiveOffsets
    frmStructureHunter.CEButton_RemoveNoActiveOffsets.OnClick = RemoveAllNoActiveOffsets
    frmStructureHunter.CEButton_DessectData.OnClick           = DessectData
    frmStructureHunter.CEButton_StopDebugger.OnClick          = StopPlugin
    frmStructureHunter.CEButton_RemoveBreakpoint.OnClick      = ButtonRemoveBreakPoint
    
    frmStructureHunter.CEEdit_History_Offsset.OnChange    = function (sender) 
      history_offset = tonumber(frmStructureHunter.CEEdit_History_Offsset.Text, 16) 
    end
    
    frmStructureHunter.CEEdit_History_Buffer.OnChange     = function (sender) 
      history_buffer = tonumber(frmStructureHunter.CEEdit_History_Buffer.Text) 
    end
    
    history_offset = tonumber(frmStructureHunter.CEEdit_History_Offsset.Text, 16) 
    history_buffer = tonumber(frmStructureHunter.CEEdit_History_Buffer.Text) 
    

    --frmStructureHunter.CEListView_hunter.OnClick = function ()
    --  if SomeSelectedMenuItems() == 1 then
    --    AllDelectedMenuItems()
    --  end
    --end




    local processname = "gta3.exe"   
    openProcess(processname)
    
    if isHidefrmStructureHinter then
      frmStructureHunter.hide()
     else
      frmStructureHunter.Show()
    end
     
  end
  
  
  function Waitform(timer)
    if frmStructureHunter ~= nil then
      object_destroy(timer_init_waitform)
      InitfrmStructureHunter()
    end
  end

  if frmStructureHunter == nil then
    timer_init_waitform = createTimer(nil);
    timer_setInterval(timer_init_waitform,100)
    timer_onTimer(timer_init_waitform, Waitform)  
  else
     InitfrmStructureHunter()
  end

