# TODO LICENCE
#-------------------------------------------------------------------------------
# block_design.tcl - Create Vivado Project - FDI_module
#
# Launch the script from the base redpitaya-guides/ folder inside Vivado 
# tcl console. This script is modification of Anton Potocnik's block_design.tcl
# and block_design.tcl files
#-------------------------------------------------------------------------------

# Create basic Red Pitaya Block Design
source projects/$project_name/basic_red_pitaya_bd.tcl

#-------------------------------------------------------------------------------
# IP cores
#-------------------------------------------------------------------------------

set_property -dict [list CONFIG.NUM_MI {3}] [get_bd_cells ps7_0_axi_periph]

# GPIO_0
set_property -dict [list CONFIG.C_ALL_INPUTS_2 {1}] [get_bd_cells axi_gpio_0]

# GPIO_1
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_1
set_property -dict [list CONFIG.C_ALL_OUTPUTS {1}] [get_bd_cells axi_gpio_1]
endgroup

# AXI BRAM Reader
startgroup
create_bd_cell -type ip -vlnv anton-potocnik:user:axi_bram_reader axi_bram_reader_0
set_property -dict [list CONFIG.BRAM_ADDR_WIDTH {16} CONFIG.C_S00_AXI_ADDR_WIDTH {18}] [get_bd_cells axi_bram_reader_0]
set_property -dict [list CONFIG.FREQ_HZ {125000000} CONFIG.CLK_DOMAIN {system_processing_system7_0_0_FCLK_CLK0}] [get_bd_intf_pins axi_bram_reader_0/S_AXI]
endgroup

# AXI DAQ
startgroup
create_bd_cell -type ip -vlnv michal-kubicek:user:axis_daq axis_daq_0
endgroup

# BRAM generator
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen: blk_mem_gen_0
set_property -dict [list CONFIG.Memory_Type {Simple_Dual_Port_RAM} CONFIG.Enable_32bit_Address {false} CONFIG.Use_Byte_Write_Enable {false} CONFIG.Byte_Size {9} CONFIG.Write_Width_A {16} CONFIG.Write_Depth_A {65536} CONFIG.Read_Width_A {16} CONFIG.Operating_Mode_A {NO_CHANGE} CONFIG.Enable_A {Always_Enabled} CONFIG.Write_Width_B {32} CONFIG.Read_Width_B {32} CONFIG.Enable_B {Always_Enabled} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {true} CONFIG.Use_RSTA_Pin {false} CONFIG.Port_A_Write_Rate {50} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.use_bram_block {Stand_Alone} CONFIG.EN_SAFETY_CKT {false}] [get_bd_cells blk_mem_gen_0]
endgroup

#-------------------------------------------------------------------------------
# RTL modules
#-------------------------------------------------------------------------------

# signal split
create_bd_cell -type module -reference signal_split signal_split_0

#-------------------------------------------------------------------------------
# Connections 
#-------------------------------------------------------------------------------

# signal split
connect_bd_intf_net [get_bd_intf_pins signal_split_0/S_AXIS] [get_bd_intf_pins axis_red_pitaya_adc_0/M_AXIS]

# AXI BRAM Reader
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_bram_reader_0/S_AXI]


# DAQ BLOCK
connect_bd_intf_net [get_bd_intf_pins axis_daq_0/S_AXIS] [get_bd_intf_pins signal_split_0/M_AXIS_PORT1]
connect_bd_net [get_bd_pins axis_daq_0/aclk] [get_bd_pins axis_red_pitaya_adc_0/adc_clk]

connect_bd_net [get_bd_pins axis_daq_0/daq_control] [get_bd_pins axi_gpio_0/gpio_io_i] [get_bd_pins axi_gpio_0/gpio_io_o] 
connect_bd_net [get_bd_pins axis_daq_0/daq_status] [get_bd_pins axi_gpio_0/gpio2_io_i] 
connect_bd_net [get_bd_pins axis_daq_0/aresetn] [get_bd_pins axi_bram_reader_0/s00_axi_aresetn]

connect_bd_intf_net [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA] [get_bd_intf_pins axis_daq_0/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB] [get_bd_intf_pins axi_bram_reader_0/BRAM_PORTA]

# GPIO BLOCK
connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_gpio_1/s_axi_aclk]
connect_bd_net [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn]


# DAQ @ Signal Generator (meas_flag input)
connect_bd_net [get_bd_pins axis_red_pitaya_dac_0/tx_flag_o] [get_bd_pins axis_daq_0/meas_flag_i]

# GPIO_1 @ Signal Generator (tx_cfg input)
connect_bd_net [get_bd_pins axi_gpio_1/gpio_io_o] [get_bd_pins axis_red_pitaya_dac_0/tx_cfg_i]

# 3th AXI master @ GPIO_1
connect_bd_intf_net [get_bd_intf_pins ps7_0_axi_periph/M02_AXI] [get_bd_intf_pins axi_gpio_1/S_AXI]

# add M02 clock connect
connect_bd_net [get_bd_pins ps7_0_axi_periph/M02_ARESETN] [get_bd_pins rst_ps7_0_125M/peripheral_aresetn]
connect_bd_net [get_bd_pins ps7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]

#-------------------------------------------------------------------------------
# Hierarchies
#-------------------------------------------------------------------------------

group_bd_cells SignalGenerator [get_bd_cells axis_red_pitaya_dac_0] [get_bd_cells dds_compiler_0] [get_bd_cells clk_wiz_0]
group_bd_cells GPIO [get_bd_cells axi_gpio_0] [get_bd_cells axi_gpio_1]
group_bd_cells PS7 [get_bd_cells processing_system7_0] [get_bd_cells rst_ps7_0_125M] [get_bd_cells ps7_0_axi_periph]
group_bd_cells DataAcquisition [get_bd_cells axis_red_pitaya_adc_0] [get_bd_cells signal_split_0]
group_bd_cells DAQ [get_bd_cells blk_mem_gen_0] [get_bd_cells axi_bram_reader_0] [get_bd_cells axis_daq_0]

#-------------------------------------------------------------------------------
# Addresses
#-------------------------------------------------------------------------------

assign_bd_address
set_property offset 0x40000000 [get_bd_addr_segs {PS7/processing_system7_0/Data/SEG_axi_bram_reader_0_reg0}]
set_property range 256K [get_bd_addr_segs {PS7/processing_system7_0/Data/SEG_axi_bram_reader_0_reg0}]

set_property offset 0x41200000 [get_bd_addr_segs {PS7/processing_system7_0/Data/SEG_axi_gpio_1_Reg}]
set_property range 4K [get_bd_addr_segs {PS7/processing_system7_0/Data/SEG_axi_gpio_1_Reg}]
#-------------------------------------------------------------------------------
# Reconfigure appearence
#-------------------------------------------------------------------------------

# connect clock for AXI_M02
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/PS7/processing_system7_0/FCLK_CLK0 (125 MHz)" }  [get_bd_pins PS7/ps7_0_axi_periph/M02_ACLK]

# fancy layout
regenerate_bd_layout
