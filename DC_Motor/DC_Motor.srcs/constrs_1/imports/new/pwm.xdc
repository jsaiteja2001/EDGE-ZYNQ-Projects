# Clock signal
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { clk }];
 
##Buttons
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {inc}];
set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {dec}];

set_property -dict { PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports {pwm_out}];
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {nsleep}];


