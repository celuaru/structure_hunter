  table_bit8  = {'al','ah','bl','bh','cl','ch','dl','dh','sil','dil','bpl','spl','r8b','r9b','r10b','r11b','r12b','r13b','r14b','r15b'}
  table_bit16 = {'ax','bx','cx','dx','si','di','sp','bp','si','di','bp','sp','r8w','r9w','r10w','r11w','r12w','r13w','r14w','r15w'}
  table_bit32 = {'eax','ebx','ecx','edx','esi','edi','esp','ebp','r8d','r9d','r10d','r11d','r12d','r13d','r14d','r15d'}
  table_bit64 = {'rax','rbx','rcx','rdx','rsi','rdi','rsp','rbp','r8','r9','r10','r11','r12','r13','r14','r15'}
  regsT1 = {'rax','eax','ax','ah','al'}
  regsT2 = {'rbx','ebx','bx','bh','bl'}
  regsT3 = {'rcx','ecx','cx','ch','cl'}
  regsT4 = {'rdx','edx','dx','dh','dl'}
  regsT5 = {'rsi','esi','si','sil'}
  regsT6 = {'rdi','edi','di','dil'}
  regsT7 = {'rsp','esp','sp','bpl'}
  regsT8 = {'rbp','ebp','bp','spl'}
  regsT9 = {'r8','r8d','r8w','r8b'}
  regsT10 = {'r9','r9d','r9w','r9b'}
  regsT11 = {'r10','r10d','r10w','r10b'}
  regsT12 = {'r11','r11d','r11w','r11b'}
  regsT13 = {'r12','r12d','r12w','r12b'}
  regsT14 = {'r13','r13d','r13w','r13b'}
  regsT15 = {'r14','r14d','r14w','r14b'}
  regsT16 = {'r15','r15d','r15w','r15b'}
  
  function containtsInTable(sourceTable, item)
    --logg_AddComment(item)
    for i,k in ipairs(sourceTable) do
      if item:match(k) then
        return true
       end
    end
    return false
  end
  function containtsRegisters_8bit(line)  return containtsInTable(table_bit8, line)  end
  function containtsRegisters_16bit(line) return containtsInTable(table_bit16, line) end
  function containtsRegisters_32bit(line) return containtsInTable(table_bit32, line) end
  function containtsRegisters_64bit(line) return containtsInTable(table_bit64, line) end
  
  function getTableRigisters2(sourceTable, tableRegs, opcode)
    for i,k in ipairs(sourceTable) do
        if opcode:match(k) then
           tableRegs[#tableRegs + 1] = k
           opcode = opcode:gsub(k,'')
        end
    end
    return tableRegs, opcode
  end
  function getTableRigisters(opcode)
    local tableRegs = {}
    tableRegs, opcode = getTableRigisters2(table_bit64, tableRegs, opcode)
    tableRegs, opcode = getTableRigisters2(table_bit32, tableRegs, opcode)
    tableRegs, opcode = getTableRigisters2(table_bit16, tableRegs, opcode)
    tableRegs, opcode = getTableRigisters2(table_bit8, tableRegs, opcode)
    return tableRegs
  end
  
  function getTableRigisterRewriter4(tableRegs, resultTable, tableRightRegisters, tableLeftRegisters)
    for i = 1, #tableRightRegisters do
      if tableRightRegisters[i]:match(tableRegs[1]) or
          tableRightRegisters[i]:match(tableRegs[2]) or
          tableRightRegisters[i]:match(tableRegs[3]) or
          tableRightRegisters[i]:match(tableRegs[4]) then
          for y = 1, #tableLeftRegisters do
            if tableLeftRegisters[y]:match(tableRegs[1])     then  resultTable[#resultTable + 1] = tableRegs[1] break
            elseif tableLeftRegisters[y]:match(tableRegs[2]) then  resultTable[#resultTable + 1] = tableRegs[2] break
            elseif tableLeftRegisters[y]:match(tableRegs[3])  then  resultTable[#resultTable + 1] = tableRegs[3] break
            elseif tableLeftRegisters[y]:match(tableRegs[4])  then  resultTable[#resultTable + 1] = tableRegs[4] break end
          end
      end
    end
    return resultTable
  end

  function getTableRigisterRewriter5(tableRegs, resultTable, tableRightRegisters, tableLeftRegisters)
    for i = 1, #tableRightRegisters do
      if tableRightRegisters[i]:match(tableRegs[1]) or
          tableRightRegisters[i]:match(tableRegs[2]) or
          tableRightRegisters[i]:match(tableRegs[3]) or
          tableRightRegisters[i]:match(tableRegs[4]) or
          tableRightRegisters[i]:match(tableRegs[5]) then
          for y = 1, #tableLeftRegisters do
            if tableLeftRegisters[y]:match(tableRegs[1])     then  resultTable[#resultTable + 1] = tableRegs[1] break
            elseif tableLeftRegisters[y]:match(tableRegs[2]) then  resultTable[#resultTable + 1] = tableRegs[2] break
            elseif tableLeftRegisters[y]:match(tableRegs[3])  then  resultTable[#resultTable + 1] = tableRegs[3] break
            elseif tableLeftRegisters[y]:match(tableRegs[4])  then  resultTable[#resultTable + 1] = tableRegs[4] break
            elseif tableLeftRegisters[y]:match(tableRegs[5])  then  resultTable[#resultTable + 1] = tableRegs[5] break end
          end
      end
    end
    return resultTable
  end

   function getContextTable2(data) --> :Возвращает всю таблицу регистров CPU
    local t = {}
	
	if is64bits == nil then
		is64bits = targetIs64Bit()
	end
	
	t.eax = data.EAX
	t.ebx = data.EBX
	t.ecx = data.ECX
	t.edx = data.EDX
	t.edi = data.EDI
	t.esi = data.ESI
	t.ebp = data.EBP
	t.esp = data.ESP
	t.eip = data.EIP
	
	if is64bits then
		t.rax = data.RAX
		t.rbx = data.RBX
		t.rcx = data.RCX
		t.rdx = data.RDX
		t.rsi = data.RSI
		t.rdi = data.RDI
		t.rsp = data.RSP
		t.rbp = data.RBP
		t.rip = data.RIP
		t.r8 = data.R8
		t.r9 = data.R9
		t.r10 = data.R10
		t.r11 = data.R11
		t.r12 = data.R12
		t.r13 = data.R13
		t.r14 = data.R14
		t.r15 = data.R15
	end

    return t
  end  
  
  function getContextTable() --> :Возвращает всю таблицу регистров CPU
    local t = {}   
    t.eax = EAX
    t.ebx = EBX
    t.ecx = ECX
    t.edx = EDX
    t.edi = EDI
    t.esi = ESI
    t.ebp = EBP
    t.esp = ESP
    t.eip = EIP
    t.rax = RAX
    t.rbx = RBX
    t.rcx = RCX
    t.rdx = RDX
    t.rsi = RSI
    t.rdi = RDI
    t.rsp = RSP
    t.rbp = RBP
    t.rip = RIP
    t.r8 = R8
    t.r9 = R9
    t.r10 = R10
    t.r11 = R11
    t.r12 = R12
    t.r13 = R13
    t.r14 = R14
    t.r15 = R15
    return t
  end  
  
  -- Возвращает лучший опкод и таблицу с переазписываемыми опкодами
  function getBestOpcodeAndTableRegisterRewrites(instructions, breakPointAddress) --> bestInstruction, tableInstructionsRewrites    
    tableTargetFloats = {}
    tableOtherInstructions = {}
    tableRewrites = {}    
    local count = #instructions
    local someWriteOpcode = false
    for i = 1, count do
      -- Проверяется корректность адреса
	  local targetAddress = instructions[i]:getTargetAddressFromOpcode()
	  
	  --Log(disassemble(instructions[i].rip)..' RAX =' ..string.format('0x%X', data[i].RAX) )
	  
	  if targetAddress == nil then
        Log ('[info] targetAddress == nil')
	  end
	  
      if targetAddress == breakPointAddress then
      
        --Log ('[info] targetAddress == breakPointAddress = ' ..string.format('0x%X', targetAddress))
		
        if not someWriteOpcode then
          someWriteOpcode = not instructions[i]:isCodeReadingValue()
        end
        
        if instructions[i]:isCodeReadingValue() then
          --Log('[info] READ CODE: '..instructions[i].Opcode)       
        else          
          --Log('[info] WRITE CODE: '..instructions[i].Opcode)
        end
      
        local opcode = instructions[i].Opcode
        
        -- Пока так, исключая repe, movsd и прочее без квадртаных скобок
        if opcode:match('%[') then        
          if instructions[i]:getTableRigisterRewriter() then 
             tableRewrites[#tableRewrites + 1] = instructions[i]
          elseif instructions[i]:isFloatOpcode() then 
             tableTargetFloats[#tableTargetFloats + 1] = instructions[i]
          else
            tableOtherInstructions[#tableOtherInstructions + 1] = instructions[i]
          end
        end        
      end
    end
	
    if #tableTargetFloats > 0 then 
		return tableTargetFloats[1], tableRewrites, someWriteOpcode 
	end
	
    if #tableOtherInstructions > 0 then
		return tableOtherInstructions[1], tableRewrites, someWriteOpcode
	end
	
    return tableRewrites[1], tableRewrites, someWriteOpcode
  end

  
  ClassOpcode = {}
  ClassOpcode.__index = ClassOpcode
  function ClassOpcode:New(context)  
  
    local obj = {}
    obj.Context = context    
    --logg_AddComment(string.format('Context EAX = : %X', context.eax))
    
    obj.RIP_isRepOcode = false         -- цикличные выполнение repe
    obj.RIP_isPostRepeOpcode = false   -- выход из цикла для repe
    obj.RepIsReadingOpcode = nil
    obj.AddressInstruction = ''
    obj.ComplexOpcode = ''            -- выражение в скобках иногда может рассчитываться сразу
    obj.Opcode = '' 
    obj.TableInfoRewriteRegistersInfo = nil   -- в случае, когда регистры для этой инструкции перезаписываются будет рассчет через getTableRigisterRewriter. Иногда можно найти другие инструкции, тогда getTableRigisterRewriter не нужна

    local currentLine = disassemble(context.rip)
	obj.AddressInstruction, _, obj.Opcode = currentLine:match('^(.-)%-(.-)%-(.-)$')
	
  
    -- Возвращает адрес в квадратных скобках
    function obj:getTargetAddressFromOpcode()
     
      local opcode = obj.Opcode

	  --Log("[info] opcodeA1 ".. opcode)  
	  
      local context = obj.Context   
	  
	  -->>>>
	  -- Log(disassemble(context.RIP))
	  
	  if context == nil then
	    Log('[info] Log(context) is nil')
	  end
	  
	  --Log('[info] '..disassemble(context.rip))
 
      if opcode:match('repe movsd') then
        --opcode = '['..string.format('%X',context.rsi)..']'
        Log('[info] change opcode1 ' .. currentLine)
      elseif opcode:match('movsd') then
        --opcode = '['..string.format('%X',context.rsi)..']'
        Log('[info] change opcode2 ' .. currentLine)
      end 
	  
      if opcode == nil then
        Log('[info] C1: '..debug.traceback():gsub('\n','\r\n'))
        --stopDissectDataScanner()
        return nil
      end
      
      if obj.RIP_isRepOcode then
         opcode = obj.ComplexOpcode
          Log('[info] Is repOpcode')
      end
      
      if opcode == nil then
        Log('[info] !!opcode == nil: '..debug.traceback():gsub('\n','\r\n'))
        --stopDissectDataScanner()
        return nil
      end
      
  
      local rightLine = opcode:match( '%S*%s*(%S*)')
      local isPointer = opcode:match( '%[')
	  
	  --Log("[info] rightLine ".. rightLine)
	  
	  
      if isPointer then

        rightLine = opcode:match( '%[(.*)%]')
		
		--Log("[info] isPointer ")
		
        --00454664 - 8B 83 60030000        - mov eax,[ebx+00000360]
        --rightLine = obj:getTargetAddressFromOpcode2(rightLine, 'eax', context.eax)
        
        if context.eax ~= nil and opcode:match('eax') then rightLine = rightLine:gsub('eax', string.format('%X', context.eax)) end
        if context.ebx ~= nil and opcode:match('ebx') then rightLine = rightLine:gsub('ebx', string.format('%X', context.ebx)) end
        if context.ecx ~= nil and opcode:match('ecx') then rightLine = rightLine:gsub('ecx', string.format('%X', context.ecx)) end
        if context.edx ~= nil and opcode:match('edx') then rightLine = rightLine:gsub('edx', string.format('%X', context.edx)) end
        if context.esi ~= nil and opcode:match('esi') then rightLine = rightLine:gsub('esi', string.format('%X', context.esi)) end
        if context.edi ~= nil and opcode:match('edi') then rightLine = rightLine:gsub('edi', string.format('%X', context.edi)) end
        if context.esp ~= nil and opcode:match('esp') then rightLine = rightLine:gsub('esp', string.format('%X', context.esp)) end
        if context.eax ~= nil and opcode:match('ebp') then rightLine = rightLine:gsub('ebp', string.format('%X', context.ebp)) end

		if is64bits == nil then
			is64bits = targetIs64Bit()
		end
	
        if is64bits then
          if opcode:match('rax') then rightLine = rightLine:gsub('rax', string.format('%X', context.rax)) end
          if opcode:match('rbx') then rightLine = rightLine:gsub('rbx', string.format('%X', context.rbx)) end
          if opcode:match('rcx') then rightLine = rightLine:gsub('rcx', string.format('%X', context.rcx)) end
          if opcode:match('rdx') then rightLine = rightLine:gsub('rdx', string.format('%X', context.rdx)) end
          if opcode:match('rsi') then rightLine = rightLine:gsub('rsi', string.format('%X', context.rsi)) end
          if opcode:match('rdi') then rightLine = rightLine:gsub('rdi', string.format('%X', context.rdi)) end
          if opcode:match('rsp') then rightLine = rightLine:gsub('rsp', string.format('%X', context.rsp)) end
          if opcode:match('rbp') then rightLine = rightLine:gsub('rbp', string.format('%X', context.rbp)) end

          if opcode:match('r8') then rightLine = rightLine:gsub('r8', string.format('%X', context.r8)) end
          if opcode:match('r9') then rightLine = rightLine:gsub('r9', string.format('%X', context.r9)) end
          if opcode:match('r10') then rightLine = rightLine:gsub('r10', string.format('%X', context.r10)) end
          if opcode:match('r11') then rightLine = rightLine:gsub('r11', string.format('%X', context.r11)) end
          if opcode:match('r12') then rightLine = rightLine:gsub('r12', string.format('%X', context.r12)) end
          if opcode:match('r13') then rightLine = rightLine:gsub('r13', string.format('%X', context.r13)) end
          if opcode:match('r14') then rightLine = rightLine:gsub('r14', string.format('%X', context.r14)) end
          if opcode:match('r15') then rightLine = rightLine:gsub('r15', string.format('%X', context.r15)) end
        end
		
	
		  --Log("[info] rightLine ".. rightLine)
		  local address = getAddress(rightLine)
        --Log("[info] address ".. address)
        return address
      else
        -- Без скобок делать нечего
        Log('[info] Error not find Brackets:'..rightLine)
        return nil
        --[[
        if opcode:match('eax') then 
            rightLine = rightLine:gsub('eax', string.format('%X', context.eax))
            logg_AddComment('MMMM :'..rightLine)
        end
        if opcode:match('ebx') then rightLine = rightLine:gsub('ebx', string.format('%X', context.ebx)) end
        if opcode:match('ecx') then rightLine = rightLine:gsub('ecx', string.format('%X', context.ecx)) end
        if opcode:match('edx') then rightLine = rightLine:gsub('edx', string.format('%X', context.edx)) end
        if opcode:match('esi') then rightLine = rightLine:gsub('esi', string.format('%X', context.esi)) end
        if opcode:match('edi') then rightLine = rightLine:gsub('edi', string.format('%X', context.edi)) end
        if opcode:match('esp') then rightLine = rightLine:gsub('esp', string.format('%X', context.esp)) end
        if opcode:match('ebp') then rightLine = rightLine:gsub('ebp', string.format('%X', context.ebp)) end

        if is64bits then
          if opcode:match('rax') then rightLine = rightLine:gsub('rax', string.format('%X', context.rax)) end
          if opcode:match('rbx') then rightLine = rightLine:gsub('rbx', string.format('%X', context.rbx)) end
          if opcode:match('rcx') then rightLine = rightLine:gsub('rcx', string.format('%X', context.rcx)) end
          if opcode:match('rdx') then rightLine = rightLine:gsub('rdx', string.format('%X', context.rdx)) end
          if opcode:match('rsi') then rightLine = rightLine:gsub('rsi', string.format('%X', context.rsi)) end
          if opcode:match('rdi') then rightLine = rightLine:gsub('rdi', string.format('%X', context.rdi)) end
          if opcode:match('rsp') then rightLine = rightLine:gsub('rsp', string.format('%X', context.rsp)) end
          if opcode:match('rbp') then rightLine = rightLine:gsub('rbp', string.format('%X', context.rbp)) end

          if opcode:match('r8') then rightLine = rightLine:gsub('r8', string.format('%X', context.r8)) end
          if opcode:match('r9') then rightLine = rightLine:gsub('r9', string.format('%X', context.r9)) end
          if opcode:match('r10') then rightLine = rightLine:gsub('r10', string.format('%X', context.r10)) end
          if opcode:match('r11') then rightLine = rightLine:gsub('r11', string.format('%X', context.r11)) end
          if opcode:match('r12') then rightLine = rightLine:gsub('r12', string.format('%X', context.r12)) end
          if opcode:match('r13') then rightLine = rightLine:gsub('r13', string.format('%X', context.r13)) end
          if opcode:match('r14') then rightLine = rightLine:gsub('r14', string.format('%X', context.r14)) end
          if opcode:match('r15') then rightLine = rightLine:gsub('r15', string.format('%X', context.r15)) end
        end
      ]]--
      
      end
	  
        --Log("[info] rightLine2 ".. rightLine)
        local address = getAddress(rightLine)
        --Log("[info] address2 ".. address)
      return address
    end 
          
  
	--print(currentLine)
	-------------------------------
		if currentLine:match('repe') then

			local breakPointAddress = obj:getTargetAddressFromOpcode()

			local step = 8
			local tempRSI = bShr(context.rsi, step)
			local tempRDI = bShr(context.rdi, step)
			local tempBreakPointAddress = bShr(breakPointAddress, step)

			if tempRSI == tempBreakPointAddress then
			  obj.ComplexOpcode = string.format('[%X]',context.rsi)
			  obj.Opcode = 'repe ' .. obj.ComplexOpcode
			  obj.RepIsReadingOpcode = true
			  Log('[info] REPE1->>')
			elseif tempRDI == tempBreakPointAddress then
			  obj.ComplexOpcode = string.format('[%X]', context.rdi)
			  obj.Opcode = 'repe ' .. obj.ComplexOpcode
			  obj.RepIsReadingOpcode = false
			  Log('[info] REPE2->>')
			else
			  Log (string.format('error repe tempBreakPointAddress = %X, RSI = %X, RDI = %X, ECX = %X', tempBreakPointAddress, tempRSI, tempRDI, context.ecx))
			end

			obj.RIP_isRepOcode = true
			Log('[info] REPE->> FIND  ' .. obj.Opcode)
			return obj
		end

		-- getContextTable2
		local prevAddress = getPreviousOpcode(context.rip)
		local clearStringPrevAddress = disassemble(prevAddress)
		if clearStringPrevAddress:match('repe') then

			-- вышли из репе на шаг инструкции как на аппараиерм бряке
			--local context = getContextTable()
			--local itemOpcode = ClassOpcode:New(context)
			--itemOpcode.AddressInstruction, _, itemOpcode.Opcode = clearStringPrevAddress:match('^(.-)%-(.-)%-(.-)$')
			--itemOpcode.RIP_isPostRepeOpcode = true
			--instructions[#instructions + 1] = itemOpcode
			--Log('REPE->> FIND PREVIOSE '..itemOpcode.Opcode)
			Log('[info] repe 101 getPreviousOpcode')
			return nil
		end
	-------------------------------
	
	
    -- 
    function obj:getTableRigisterRewriter() --> : возвращает таблицу с перезаписываемыми регистрами или nil, если нет

      local opcode = obj.Opcode
      local leftLine, rightLine = opcode:match('(.+),(.+)')

      if leftLine == nil or rightLine == nil then
        return nil
      end
      
      -- Вернуть таблицу регистров левой части
      local tableLeftRegisters = getTableRigisters(leftLine)
      
      -- Вернуть таблицу регистров правой части
      local tableRightRegisters = getTableRigisters(rightLine)

      -- Если в левой части есть любой регистр из правой части, то регистр был перезаписан
      local resultTable = {}
      
      -- Пример. Если левая часть == rax, а правая rax, ax, al, то инструкция перезаписываемая и нужно узнать значение регистра правой части помещая его в resultTable
      for i = 1, #tableRightRegisters do
        resultTable = getTableRigisterRewriter5(regsT1, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter5(regsT2, resultTable, tableRightRegisters, tableLeftRegisters)      
        resultTable = getTableRigisterRewriter5(regsT3, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter5(regsT4, resultTable, tableRightRegisters, tableLeftRegisters)      
        resultTable = getTableRigisterRewriter4(regsT5, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter4(regsT6, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter4(regsT7, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter4(regsT8, resultTable, tableRightRegisters, tableLeftRegisters)      
        resultTable = getTableRigisterRewriter4(regsT9, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter4(regsT10, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter4(regsT11, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter4(regsT12, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter4(regsT13, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter4(regsT14, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter4(regsT15, resultTable, tableRightRegisters, tableLeftRegisters)
        resultTable = getTableRigisterRewriter4(regsT16, resultTable, tableRightRegisters, tableLeftRegisters)
      end
      
      if #resultTable <= 0 then
        return nil
      end
      
      return resultTable
    end


    --
    function obj:isCodeReadingValue()
      local opcode = obj.Opcode
        
        
      if opcode:match('push') then return false end 
      if opcode:match('fstp') then return false end            
      if opcode:match('fst') then return false end
      
      if opcode:match('fsub') then return true end
      if opcode:match('fmul') then return true end
      if opcode:match('div')  then return true end
      if opcode:match('fadd') then return true end  
      if opcode:match('fld') then return true end
      if opcode:match('cmp') then return true end
      if opcode:match('test') then return true end  
      if opcode:match('fcomp') then return true end  
      
      --TODO: смотря куда пишет, переделать потом
      if opcode:match('repe') then
          if obj.RepIsReadingOpcode == nil then
            Log('[info] Error RepIsReadingOpcode == nil ')
            return true
          end
          return RepIsReadingOpcode 
      end   
      
      -- Если скобок нет, то чтение
      if opcode:match('%[') == nil then
        return true
      end
      
      -- левая части до запятой
      local lefLine = opcode:match('(.*),')
      
      -- Если левой части нет, то чтение
      if lefLine == nil then 
      
        -- Есть исключения, когда в опкода нет запятых и есть скобки
        if  opcode:match('dec') or opcode:match('inc') or
          opcode:match('mul') or opcode:match('not') or 
          opcode:match('or') or opcode:match('and') or       
          opcode:match('sub')
        then 
        
          -- Если есть квадраные скобки в левой части, то запись
          if opcode:match('%[') ~= nil then 
            return false            
          end
          
        end 
        
        return true 
      end
      
        if  opcode:match('dec') or opcode:match('inc') or
          opcode:match('mul') or opcode:match('not') or 
          opcode:match('or') or opcode:match('and') or       
          opcode:match('sub') or opcode:match('mov')
        then 
        
          -- Если есть квадраные скобки в левой части, то запись
          if lefLine:match('%[') ~= nil then 
            return false            
          end
          
        end 
        
      -- Во всех сотальных случая чтение
      return true
    end
    -- 
    function obj:isFloatOpcode()
      local opcode = obj.Opcode
      if opcode:match('xmm') or 
        opcode:match('fcomp') or
        opcode:match('fld') or 
        opcode:match('fstp') or
        opcode:match('fsub') or
        opcode:match('fmul') or
        opcode:match('fdiv') or
        opcode:match('fadd') or
        opcode:match('fst') 
      then 
        return true
      else
        return false
      end
    end
  
  
 --[[   function obj:getTargetAddressFromOpcode2(rightLine, r1, r2)
      if opcode:match(r1) then 
        rightLine = rightLine:gsub(r1, string.format('%X', r2)) 
      end
      return rightLine
    end
  ]]--
  

    function obj:GetType2()  -->: sizeValue, typeValue
      local opcode = obj.Opcode
      local leftLine, rightLine = opcode:match('(.+),(.+)')
      -- Смотрим по части без квадратных скобок, есть ли там 64 разрядные регистры или 32-х
      local noPointerLine = ''
      
      if leftLine == nil then
        Log('[info] !!Error:' .. opcode)
        return 1, vtByte
      end
      
      if leftLine:match( '%[') then
        noPointerLine = rightLine
      else
        noPointerLine = leftLine
      end

      if containtsRegisters_64bit(noPointerLine) then
         return 8, vtQword
      elseif containtsRegisters_32bit(noPointerLine) then
        return 4, vtDword
      elseif containtsRegisters_16bit(noPointerLine) then
        return 2, vtWord
      elseif containtsRegisters_8bit(noPointerLine) then
        return 1, vtByte
      else
        if is64bits then
          return 8, vtQword
        else
          return 4, vtDword
        end
      end
    end
    function obj:getTypeValue() -->: sizeValue,typeValue

      --[[
      *    vtByte=0
      *    vtWord=1
      *    vtDword=2
      *    vtQword=3
      *    vtSingle=4

      *    vtDouble=5
        vtString=6
        vtUnicodeString=7 --Only used by autoguess
        vtByteArray=8
      *    vtPointer=12 --Only used by autoguess and structures
        vtCustom=13
      ]]--

      local opcode = obj.Opcode
      local sizeValue = 0
      local typeValue = vtCustom

      --if opcode:match('mulss xmm') then sizeValue = 4 typeValue = vtSingle
      --elseif opcode:match('movsd xmm') then sizeValue = 4 typeValue = vtSingle
      --elseif opcode:match('ucomiss xmm') then sizeValue = 4 typeValue = vtSingle
      --elseif opcode:match('comiss xmm') then sizeValue = 4 typeValue = vtSingle
      --elseif opcode:match('addss xmm') then sizeValue = 4 typeValue = vtSingle
      --elseif opcode:match('subss xmm') then sizeValue = 4 typeValue = vtSingle 

      
      if obj:isFloatOpcode() then
        sizeValue = 4 typeValue = vtSingle
      end

      if sizeValue == 0 then
        if opcode:match('repe movsd') then
          sizeValue = 4 
          typeValue = vtByteArray
        elseif opcode:match('movsd') then
          sizeValue = 4 
          typeValue = vtByteArray
        end
      end
      
      if sizeValue == 0 then
        -- Offset: + 238 : 140F96223 - 09 83 38020000  - or [rbx+00000238],eax  412DFA48  412DFA48 0 uncnow
        if opcode:match('repe') then 
          sizeValue = 1
          typeValue = vtByteArray
        end
      end  
      
      
      if sizeValue == 0 then
          if  opcode:match('movzx')  or
              opcode:match('movsx')  or 
              opcode:match('movsxd') or
              opcode:match('movss')  or            
              opcode:match('mov')    or
              opcode:match('sub')  or
              opcode:match('push')                  
          then 
			if opcode:match('qword') then sizeValue = 8 typeValue = vtQword
            elseif opcode:match('dword') then sizeValue = 4 typeValue = vtDword
            elseif opcode:match('word') then sizeValue = 2 typeValue = vtWord
            elseif opcode:match('byte') then sizeValue = 1 typeValue = vtByte
            else
              sizeValue, typeValue = obj:GetType2()
            end
          end
      end 


      -- TODO: 65490628 - 39 5E 74  - cmp [esi+74],ebx <<
      -- TODO: 654300F4 - 8B 71 74  - mov esi,[ecx+74] <<
      -- +64 byte
      -- +74 word - пропуск
      -- +64 byte    
      -- Для com и mov
      -- найти часть без скобок
        -- определить тип регистра 32, 64,     
      --- Начал писать функцию, убрать её отсюда    
      --local sizeValue, typeValue = GetType2(opcode)


      if sizeValue == 0 then
        --if opcode:match('cmp al') then sizeValue = 1 typeValue = vtByte
        if opcode:match('cmp byte') then sizeValue = 1 typeValue = vtByte
        elseif opcode:match('cmp word') then sizeValue = 2 typeValue = vtWord
        elseif opcode:match('cmp dword') then sizeValue = 4 typeValue = vtDword
		elseif opcode:match('cmp qword') then sizeValue = 8 typeValue = vtQword
        elseif opcode:match('cmp') then  
          sizeValue, typeValue = obj:GetType2()
        end
      end

      if sizeValue == 0 then
        --if opcode:match('cmp al') then sizeValue = 1 typeValue = vtByte
        if opcode:match('add byte') then sizeValue = 1 typeValue = vtByte
        elseif opcode:match('add word') then sizeValue = 2 typeValue = vtWord
        elseif opcode:match('add dword') then sizeValue = 4 typeValue = vtDword
		elseif opcode:match('add qword') then sizeValue = 8 typeValue = vtQword
        elseif opcode:match('add') then  
          sizeValue, typeValue = obj:GetType2()
        end
      end

      if sizeValue == 0 then
        --if opcode:match('cmp al') then sizeValue = 1 typeValue = vtByte
        if opcode:match('inc byte') then sizeValue = 1 typeValue = vtByte
        elseif opcode:match('inc word') then sizeValue = 2 typeValue = vtWord
        elseif opcode:match('inc dword') then sizeValue = 4 typeValue = vtDword
		elseif opcode:match('inc qword') then sizeValue = 8 typeValue = vtQword
        elseif opcode:match('inc') then  
          sizeValue, typeValue = obj:GetType2()
        end
      end

      if sizeValue == 0 then
        --if opcode:match('test al') then sizeValue = 1 typeValue = vtByte
        if opcode:match('test byte') then sizeValue = 1 typeValue = vtByte
        elseif opcode:match('test word') then sizeValue = 2 typeValue = vtWord
        elseif opcode:match('test dword') then sizeValue = 4 typeValue = vtDword
		elseif opcode:match('test qword') then sizeValue = 8 typeValue = vtQword
        elseif opcode:match('test') then
          sizeValue, typeValue = obj:GetType2()
        end
      end


      if sizeValue == 0 then   
        if opcode:match('xor byte') then sizeValue = 1 typeValue = vtByte
        elseif opcode:match('xor word') then sizeValue = 2 typeValue = vtWord
        elseif opcode:match('xor dword') then sizeValue = 4 typeValue = vtDword
		elseif opcode:match('xor qword') then sizeValue = 8 typeValue = vtQword
        elseif opcode:match('xor') then
          sizeValue, typeValue = obj:GetType2()
        end
      end

      if sizeValue == 0 then
        -- Offset: + 238 : 140F96223 - 09 83 38020000  - or [rbx+00000238],eax  412DFA48  412DFA48 0 uncnow
        if opcode:match('or byte') then sizeValue = 1 typeValue = vtByte
        elseif opcode:match('or word') then sizeValue = 2 typeValue = vtWord
        elseif opcode:match('or dword') then sizeValue = 4 typeValue = vtDword
		elseif opcode:match('or qword') then sizeValue = 8 typeValue = vtQword
        elseif opcode:match('or') then
          sizeValue, typeValue = obj:GetType2()
        end
      end

      if sizeValue == 0 then
        -- Offset: + 238 : 140F96223 - 09 83 38020000  - or [rbx+00000238],eax  412DFA48  412DFA48 0 uncnow
        if opcode:match('and byte') then sizeValue = 1 typeValue = vtByte
        elseif opcode:match('and word') then sizeValue = 2 typeValue = vtWord
        elseif opcode:match('and dword') then sizeValue = 4 typeValue = vtDword
		elseif opcode:match('and qword') then sizeValue = 8 typeValue = vtQword
        elseif opcode:match('and') then
          sizeValue, typeValue = obj:GetType2()
        end
      end  
          
      
      local sTypeValue = ''
      if typeValue == 0 then sTypeValue = 'vtByte'
      elseif typeValue == 1 then sTypeValue = 'vtWord'
      elseif typeValue == 2 then sTypeValue = 'vtDword'
      elseif typeValue == 3 then sTypeValue = 'vtQword'
      elseif typeValue == 4 then sTypeValue = 'vtSingle'
      elseif typeValue == 5 then sTypeValue = 'vtDouble'
      elseif typeValue == 6 then sTypeValue = 'vtString'
      elseif typeValue == 7 then sTypeValue = 'vtUnicodeString' --Only used by autoguess
      elseif typeValue == 8 then sTypeValue = 'vtByteArray'
      elseif typeValue == 12 then sTypeValue = 'vtPointer' --Only used by autoguess and structures
      elseif typeValue == 13 then sTypeValue = 'vtCustom' end
      
      if sizeValue == 0 then
        Log('[info] Error opcode: '.. opcode)
        sizeValue = 1
        --stopDissectDataScanner()
      end      
      return sizeValue,typeValue, sTypeValue
    end   
    
    setmetatable(obj, obj)
    return obj
  end