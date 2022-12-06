EnableExplicit

Macro GetFunctionProtoQuote
	"
EndMacro
Macro GetFunctionProto(dll, name)
	Global name.name
	name = GetFunction(dll, GetFunctionProtoQuote#name#GetFunctionProtoQuote)
	CompilerIf #PB_Compiler_Debugger  ; Only enable assert in debug mode
		If name = #Null
			Debug "Assert on line " + #PB_Compiler_Line + ", GetFunction(" + GetFunctionProtoQuote#dll#GetFunctionProtoQuote + ", " + GetFunctionProtoQuote#name#GetFunctionProtoQuote + ")"
		EndIf
	CompilerEndIf
EndMacro


PrototypeC.l hid_open(vendor_id.c, product_id.c,  *serial_number)
PrototypeC.l hid_open_path(*path)
PrototypeC.i hid_write(*device, *Data, length.i)
PrototypeC.i hid_read(*device, *Data, length.i)
PrototypeC.i hid_read_timeout(*device, *Data, length.i, milliseconds.i )
PrototypeC   hid_close(*device)
PrototypeC.l hid_enumerate(vendor_id.u, product_id.u)
PrototypeC.i hid_send_feature_report(*device, *Data, length.i)
PrototypeC.i hid_get_feature_report(*device, *Data, length.i)
PrototypeC.i hid_get_manufacturer_string(*device, *string, maxlen.i)
PrototypeC.i hid_get_product_string(*device, *string, maxlen.i)
PrototypeC.i hid_get_serial_number_string(*device, *string, maxlen.i)
PrototypeC.i hid_get_indexed_string(*device, *string, maxlen.i)
PrototypeC.l hid_error(*device)
PrototypeC.l hid_enum_path(devs.l)
PrototypeC.u hid_enum_vendor_id(devs.l)
PrototypeC.u hid_enum_product_id(devs.l)
PrototypeC.l hid_enum_serial_number(devs.l)
PrototypeC.u hid_enum_release_number(devs.l)
PrototypeC.l hid_enum_manufacturer_string(devs.l)
PrototypeC.l hid_enum_product_string(devs.l)
PrototypeC.l hid_enum_next(devs.l)
PrototypeC.i hid_wchart_size()
PrototypeC   hid_free_enumeration(devs.l)
PrototypeC.i hid_set_nonblocking(*device, nonblock.i)

Threaded _Hidapi_Library_DLL_.i


Procedure Hidapi_Free_Library()
	If IsLibrary(_Hidapi_Library_DLL_)
		CloseLibrary(_Hidapi_Library_DLL_)
	EndIf
EndProcedure

Procedure.i Hidapi_Load_Library(dllpath$)
	Protected  dll.i, result.i
	
	If IsLibrary(_Hidapi_Library_DLL_)
		ProcedureReturn #False
	EndIf
	
	_Hidapi_Library_DLL_ = OpenLibrary(#PB_Any, dllpath$)
	dll = _Hidapi_Library_DLL_
	If IsLibrary(dll) = #False
		ProcedureReturn #False
	EndIf
	
	GetFunctionProto(dll, hid_open)
	GetFunctionProto(dll, hid_open_path)
	GetFunctionProto(dll, hid_write)
	GetFunctionProto(dll, hid_read)
	GetFunctionProto(dll, hid_read_timeout)
	GetFunctionProto(dll, hid_close)
	GetFunctionProto(dll, hid_enumerate)
	GetFunctionProto(dll, hid_free_enumeration)
	GetFunctionProto(dll, hid_set_nonblocking)
	GetFunctionProto(dll, hid_send_feature_report)
	GetFunctionProto(dll, hid_get_feature_report)
	GetFunctionProto(dll, hid_get_manufacturer_string)
	GetFunctionProto(dll, hid_get_product_string)
	GetFunctionProto(dll, hid_get_serial_number_string)
	GetFunctionProto(dll, hid_get_indexed_string)
	GetFunctionProto(dll, hid_error)
			
	GetFunctionProto(dll, hid_enum_path)
	GetFunctionProto(dll, hid_enum_vendor_id)
	GetFunctionProto(dll, hid_enum_product_id)
	GetFunctionProto(dll, hid_enum_serial_number)
	GetFunctionProto(dll, hid_enum_release_number)
	GetFunctionProto(dll, hid_enum_manufacturer_string)
	GetFunctionProto(dll, hid_enum_product_string)
	GetFunctionProto(dll, hid_enum_next)
  GetFunctionProto(dll, hid_wchart_size)
	
	ProcedureReturn #True
EndProcedure

Procedure.i Hidapi_wchart_size()
  Protected  Result
  Result = hid_wchart_size()
  ProcedureReturn Result
EndProcedure

Procedure.s Wchar_tToStr(*Mem)
  Protected  Result$, i, rs$ , Stp.i, Max.i
  Result$ = ""
  Stp = Hidapi_wchart_size()
  Max = 127* Stp
  If *Mem
    i=0
    While i < Max 
      rs$ = PeekS(*Mem +i, Stp, #PB_UTF8 | #PB_ByteLength ) 
      If rs$ =""
        Break
      EndIf  
      Result$ = Result$ + rs$
      i = i + stp
    Wend
  EndIf 
  ProcedureReturn Result$ 
EndProcedure

Procedure.s Hidapi_enum_path(*devs) 
  Protected *Mem, Result$
  Result$ = ""
  *Mem = hid_enum_path(*devs)
  If *Mem
    Result$ = PeekS(*Mem, -1, #PB_UTF8)
  EndIf 
  ProcedureReturn Result$ 
EndProcedure

Procedure.u Hidapi_enum_vendor_id(*devs) 
  Protected Result.u
  Result = hid_enum_vendor_id(*devs)
  ProcedureReturn Result 
EndProcedure

Procedure.u Hidapi_enum_product_id(*devs) 
  Protected Result.u
  Result = hid_enum_product_id(*devs)
  ProcedureReturn Result 
EndProcedure

Procedure.s Hidapi_enum_serial_number(*devs) 
  Protected *Mem, Result$
  *Mem = hid_enum_serial_number(*devs)
  Result$ =Wchar_tToStr(*Mem)
  ProcedureReturn Result$ 
EndProcedure

Procedure.u Hidapi_enum_release_number(*devs) 
  Protected Result.u
  Result = hid_enum_release_number(*devs)
  ProcedureReturn Result 
EndProcedure

Procedure.s Hidapi_enum_manufacturer_string(*devs) 
  Protected *Mem, Result$
  *Mem = hid_enum_manufacturer_string(*devs)
  Result$ =Wchar_tToStr(*Mem)
  ProcedureReturn  Result$
EndProcedure

Procedure.s Hidapi_enum_product_string(*devs) 
  Protected *Mem, Result$
  *Mem = hid_enum_product_string(*devs)
  Result$ =Wchar_tToStr(*Mem)
  ProcedureReturn  Result$
EndProcedure

Procedure.l Hidapi_enum_next(*devs) 
  Protected *Next
  *Next = hid_enum_next(*devs)
  ProcedureReturn *Next 
EndProcedure

Procedure.l Hidapi_open(vendor_id.c, product_id.c,  *serial_number) 
  Protected *Device
  *Device = hid_open(vendor_id, product_id, *serial_number)
  ProcedureReturn *Device 
EndProcedure

Procedure.l Hidapi_close(*device) 
  hid_close(*device)
EndProcedure
  
Procedure Hidapi_write(*device , *OutByte, Size.i)
  hid_write(*device, *OutByte ,Size)
EndProcedure

Procedure Hidapi_free_enumeration(*devs) 
  hid_free_enumeration(*devs)
EndProcedure

Procedure.s Hidapi_manufacturer_string(*device) 
  Protected *string, Result$ , ret.i
  Result$=""
  *string = AllocateMemory(255)
  ret = hid_get_manufacturer_string(*device, *string, 255)
  If ret =0
    Result$ =Wchar_tToStr(*string)
  EndIf 
  ProcedureReturn Result$ 
EndProcedure

Procedure.s Hidapi_get_product_string(*device) 
  Protected *string, Result$ , ret.i
  Result$=""
  *string = AllocateMemory(255)
  ret = hid_get_product_string(*device, *string, 255)
  If ret =0
    Result$ =Wchar_tToStr(*string)
  EndIf 
  ProcedureReturn Result$ 
EndProcedure

Procedure.s Hidapi_get_serial_number_string(*device) 
  Protected *string, Result$ , ret.i
  Result$=""
  *string = AllocateMemory(255)
  ret = hid_get_serial_number_string(*device, *string, 255)
  If ret =0
    Result$ =Wchar_tToStr(*string)
  EndIf 
  ProcedureReturn Result$ 
EndProcedure

Procedure.s Hidapi_get_indexed_string(*device) 
  Protected *string, Result$ , ret.i
  Result$=""
  *string = AllocateMemory(255)
  ret = hid_get_indexed_string(*device, *string, 255)
  If ret =0
    Result$ =Wchar_tToStr(*string)
  EndIf 
  ProcedureReturn Result$ 
EndProcedure

Procedure.s Hidapi_error(*device) 
  Protected *Mem, Result$
  *Mem = hid_error(*device)
  Result$ =Wchar_tToStr(*Mem)
  ProcedureReturn Result$ 
EndProcedure
; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 121
; FirstLine = 207
; Folding = ----
; EnableXP