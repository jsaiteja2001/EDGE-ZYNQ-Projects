# Clock signal
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { clk }];
 
# Switches
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports { position[7] }]; 
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { position[6] }];
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports { position[5] }];
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { position[4] }];
set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } [get_ports { position[3] }];
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports { position[2] }];
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { position[1] }];
set_property -dict { PACKAGE_PIN J16 IOSTANDARD LVCMOS33 } [get_ports { position[0] }];
 
##Buttons
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports {rst}];

set_property -dict { PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {servo}];


