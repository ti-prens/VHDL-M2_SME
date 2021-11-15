transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/lepetitprince/Seafile/Education/Fac/M2_SME/VHDL/projet_vhdl/components/compteur.vhd}
vcom -93 -work work {/home/lepetitprince/Seafile/Education/Fac/M2_SME/VHDL/projet_vhdl/components/comparateur.vhd}
vcom -93 -work work {/home/lepetitprince/Seafile/Education/Fac/M2_SME/VHDL/projet_vhdl/components/diviseur.vhd}
vlib nios_mcu
vmap nios_mcu nios_mcu

