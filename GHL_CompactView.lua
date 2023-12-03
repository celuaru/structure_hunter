--[[ 
Version 1.0
]]--
function MainCompactView()
	local stateCompactView = false

	function StateCompactCEWindow(state)
		stateCompactView = state
		local controlMainForm = getMainForm()
		local separator = wincontrol_getControl(controlMainForm,0)
		local Panel1 = wincontrol_getControl(controlMainForm,1)
		local Panel4 = wincontrol_getControl(controlMainForm,2)
		local Panel5 = wincontrol_getControl(controlMainForm,3)

		control_setVisible(separator, state)
		control_setVisible(Panel4, state)
		control_setVisible(Panel5, state)
	end

	function CompactCEWindow()
		menuItem_setCaption(new_item_compact_mode, 'Compact View')
		menuItem_onClick(new_item_compact_mode, UnCompactCEWindow)
		StateCompactCEWindow(true)
    local classSettingsCommpactView = ClassSettings:New('userdata.txt', '*.txt')	
		getMainForm().Height = 
      tonumber(classSettingsCommpactView:Get('compact_height', '600'))
    classSettingsCommpactView:Set('compact_height', getMainForm().Height)
	end

	function UnCompactCEWindow()
		menuItem_setCaption(new_item_compact_mode, 'Full View')
		menuItem_onClick(new_item_compact_mode, CompactCEWindow)
		StateCompactCEWindow(false)
    local classSettingsCommpactView = ClassSettings:New('userdata.txt', '*.txt')
		getMainForm().Height = 
      tonumber(classSettingsCommpactView:Get('uncompact_height', '300'))
    classSettingsCommpactView:Set('uncompact_height', getMainForm().Height)
	end
	

	

	------------
	local menuItem = menu_getItems(form_getMenu(getMainForm()))
	new_item_compact_mode = createMenuItem(menuItem)
	menuItem_add(menuItem, new_item_compact_mode)

  local classSettingsCommpactView = ClassSettings:New('userdata.txt', '*.txt')
	local mainForm =  getMainForm()
	local lastDestroy = mainForm.OnDestroy
  
	mainForm.OnDestroy = function (sender)
			
		if(stateCompactView) then
			classSettingsCommpactView:Set('compactView', '1')
      classSettingsCommpactView:Set('compact_height', getMainForm().Height)
		else
			classSettingsCommpactView:Set('compactView', '0')
      classSettingsCommpactView:Set('uncompact_height', getMainForm().Height)
		end
    
		classSettingsCommpactView:SaveForm(mainForm, 'CEForm')
		classSettingsCommpactView:Save()
		lastDestroy()
	end

	if(classSettingsCommpactView:Get('compactView', '0') == '1') then
		CompactCEWindow()
	else
		UnCompactCEWindow()
	end
	
	classSettingsCommpactView:LoadForm(mainForm, 'CEForm')
end

MainCompactView()