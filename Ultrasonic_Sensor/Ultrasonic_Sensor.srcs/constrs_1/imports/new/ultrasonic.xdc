set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { clock }];
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { reset }];
set_property -dict { PACKAGE_PIN H20 IOSTANDARD LVCMOS33 } [get_ports { pulse_pin }];
set_property -dict { PACKAGE_PIN J20 IOSTANDARD LVCMOS33 } [get_ports { trigger_pin }];
set_property -dict { PACKAGE_PIN U12 IOSTANDARD LVCMOS33 } [get_ports {an[0]}]; #LSB
set_property -dict { PACKAGE_PIN T12 IOSTANDARD LVCMOS33 } [get_ports {an[1]}];
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports {an[2]}];
set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports {sseg[0]}];#A
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports {sseg[1]}];#B
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports {sseg[2]}];#C
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports {sseg[3]}];#D
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports {sseg[4]}];#E
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports {sseg[5]}];#F
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 } [get_ports {sseg[6]}];#G
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports {sseg[7]}];#DP

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets pulse_pin_IBUF]