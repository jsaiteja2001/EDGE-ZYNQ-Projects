set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { clk }];
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { reset_n }];
set_property -dict { PACKAGE_PIN G19 IOSTANDARD LVCMOS33 } [get_ports { scl }];
set_property -dict { PACKAGE_PIN G20 IOSTANDARD LVCMOS33 } [get_ports { sda }];
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports { gesture[0] }];#LSB
set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports { gesture[1] }];
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { gesture[2] }];
set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 } [get_ports { gesture[3] }];
