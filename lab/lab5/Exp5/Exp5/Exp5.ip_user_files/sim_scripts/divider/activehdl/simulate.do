transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+divider  -L xbip_utils_v3_0_13 -L axi_utils_v2_0_9 -L xbip_pipe_v3_0_9 -L xbip_dsp48_wrapper_v3_0_6 -L xbip_dsp48_addsub_v3_0_9 -L xbip_bram18k_v3_0_9 -L mult_gen_v12_0_21 -L floating_point_v7_0_23 -L xbip_dsp48_mult_v3_0_9 -L xbip_dsp48_multadd_v3_0_9 -L div_gen_v5_1_22 -L xil_defaultlib -L secureip -O5 xil_defaultlib.divider

do {divider.udo}

run 1000ns

endsim

quit -force
