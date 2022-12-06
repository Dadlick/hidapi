XIncludeFile "HidApi.pbi"

#Window_0      = 0 
#ListView_0    = 1 
#Button_0      = 2
#Button_1      = 3
#Button_2      = 4
#Button_3      = 5

Structure Hid_dev
  Pid.u
  Vid.u
  Manufacturer.s
  Product.s
EndStructure

Global NewList Hid_dev_List.Hid_dev()
Global *device
Define Hidapi_Library.s

Procedure Thread(*xx) ; Процедура работает в отдельном потоке и в ней выполняется приём данных 
  Protected ReadByte.i, *InByte 
  *InByte = AllocateMemory(64)
  Repeat
    If *device
      ReadByte = hid_read_timeout(*device,  *InByte, 64, 100) ; Приём данных от HID устройства
      If ReadByte > 0
        Debug( PeekB(*InByte))
        Debug( PeekB(*InByte+1))
        Debug( PeekB(*InByte+2))
      EndIf
    Else
      Delay(100)
    EndIf
  ForEver
EndProcedure

Procedure hid_enum()
  Protected *devs , *dev
  *devs= hid_enumerate(0,0)
  *dev=*devs
  While *dev   
    AddElement(Hid_dev_List())
    Hidapi_enum_path(*dev)
    Hid_dev_List()\Pid = Hidapi_enum_product_id(*dev)
    Hid_dev_List()\Vid = Hidapi_enum_vendor_id(*dev)
    Hid_dev_List()\Manufacturer = Hidapi_enum_manufacturer_string(*dev)
    Hid_dev_List()\Product = Hidapi_enum_product_string(*dev)
    AddGadgetItem(#ListView_0, -1, RSet(Hex(Hid_dev_List()\Vid),4,"0") + ":" + RSet(Hex(Hid_dev_List()\Pid),4,"0")  + " - " + Hid_dev_List()\Manufacturer + " " + Hid_dev_List()\Product)
    *dev = Hidapi_enum_next(*dev)
  Wend
  Hidapi_free_enumeration(*devs)
EndProcedure  


CompilerSelect #PB_Compiler_OS 
  CompilerCase #PB_OS_Windows   
   Hidapi_Library = GetCurrentDirectory() + "hidapi.dll"
  CompilerCase #PB_OS_Linux   
   Hidapi_Library = GetCurrentDirectory() + "libhidapi.so"   
CompilerEndSelect 

If Hidapi_Load_Library(Hidapi_Library) = #False
	Debug "Failed to load hidapi"
	End
EndIf


Procedure Main()
  Protected Event, EventType, EventGadget,*outputByte
  If OpenWindow(#Window_0, 100, 100, 400, 200, "Gui Hidapi Purebasic" , #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered )
    ListViewGadget(#ListView_0, 0, 0, 400, 150)
    ButtonGadget(#Button_0, 10, 155, 72, 32, "Open") 
    ButtonGadget(#Button_1, 92, 155, 72, 32, "Close")
    DisableGadget(#Button_1, 1)
    ButtonGadget(#Button_2, 174, 155, 72, 32, "Write_1")
    DisableGadget(#Button_2, 1)
    ButtonGadget(#Button_3, 256, 155, 72, 32, "Write_2")
    DisableGadget(#Button_3, 1)
    ;CreateThread(@Thread(),0)
    ;MessageRequester("AutoCad 2009", "Да - установить - x86", #PB_MessageRequester_YesNo)
    hid_enum()
    
    Repeat
      Event = WaitWindowEvent()
      EventType = EventType()
      EventGadget = EventGadget()
      Select event
        Case #PB_Event_CloseWindow
          
          
        Case #PB_Event_Menu
          Select EventMenu()
          EndSelect
          
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Button_0
              If GetGadgetState(#ListView_0) > -1
                SelectElement(Hid_dev_List(),GetGadgetState(#ListView_0))
                *device = Hidapi_open(Hid_dev_List()\Vid, Hid_dev_List()\pid, #Null)               
                If *device
                  Debug(Hidapi_manufacturer_string(*device))       
                  Debug(Hidapi_get_serial_number_string(*device))
                  Debug(Hidapi_error(*device))
                  Debug(Hidapi_get_indexed_string(*device))
                  Debug(Hidapi_get_product_string(*device))
                  DisableGadget(#Button_1, 0)
                  DisableGadget(#Button_2, 0)
                  DisableGadget(#Button_3, 0)
                EndIf
              EndIf
            Case #Button_1
              Hidapi_close(*device)
              *device =#NUL
              DisableGadget(#Button_1, 1)
              DisableGadget(#Button_2, 1)
              DisableGadget(#Button_3, 1)
            Case #Button_2
              *outputByte = AllocateMemory(3)
              PokeB(*outputByte, 0)
              PokeB(*outputByte+1, 1)
              PokeB(*outputByte+2, 0)
              Hidapi_write(*device, *outputByte , 3)
            Case #Button_3
              *outputByte = AllocateMemory(3)
              PokeB(*outputByte, 0)
              PokeB(*outputByte+1, 2)
              PokeB(*outputByte+2, 0)
              Hidapi_write(*device, *outputByte , 3)
          EndSelect
      EndSelect
    Until Event = #PB_Event_CloseWindow 
  EndIf
  Hidapi_Free_Library()
EndProcedure 

main()
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; Folding = -
; EnableXP
; Executable = HidTest.exe