
#add_cells_to_pblock [get_pblock payload] payload
delete_pblocks [get_pblocks *]

#set_min_delay 0.000 -from [get_clocks clks_aux_u_0] -to [get_clocks clk_payload_pseudo]
#set_max_delay 2.778 -from [get_clocks clks_aux_u_0] -to [get_clocks clk_payload_pseudo]

#set_min_delay 0.000 -from [get_clocks clk_payload_pseudo] -to [get_clocks clks_aux_u_0]
#set_max_delay 2.778 -from [get_clocks clk_payload_pseudo] -to [get_clocks clks_aux_u_0]
