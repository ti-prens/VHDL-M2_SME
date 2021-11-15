transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/lepetitprince/Seafile/Education/Fac/M2_SME/VHDL/DE0-Nano/blink/src/blink.vhd}

