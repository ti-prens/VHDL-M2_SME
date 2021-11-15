set_global_assignment -entity "nios_mcu" -library "lib_nios_mcu" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "nios_mcu" -library "lib_nios_mcu" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "nios_mcu" -library "lib_nios_mcu" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_nios_mcu" -name SPD_FILE [file join $::quartus(sip_path) "../nios_mcu.spd"]
set_global_assignment -library "lib_nios_mcu" -name MISC_FILE [file join $::quartus(sip_path) "../../nios_mcu.qsys"]

set_global_assignment -library "lib_nios_mcu" -name MISC_FILE [file join $::quartus(sip_path) "nios_mcu.vhd"]
