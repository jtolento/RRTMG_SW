#!/bin/sh
cp input_mosaic1_mls_brd INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mosaic1_mls_brd

cp input_mosaic1_mls_spc INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mosaic1_mls_spc

cp input_mosaic1_saw_brd INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mosaic1_saw_brd

cp input_mosaic1_saw_spc INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mosaic1_saw_spc


cp input_mosaic2_mls_brd INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mosaic2_mls_brd

cp input_mosaic2_mls_spc INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mosaic2_mls_spc

cp input_mosaic2_saw_brd INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mosaic2_saw_brd

cp input_mosaic2_saw_spc INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mosaic2_saw_spc

