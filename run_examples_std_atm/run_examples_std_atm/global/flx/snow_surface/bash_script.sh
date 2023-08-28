#!/bin/sh
cp input_mls_spc INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mls_spc

cp input_mls_brd INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mls_brd

cp input_saw_spc INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_saw_spc

cp input_saw_brd INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_saw_brd


cp input_rrtm_TROP-spc INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_rrtm_TROP-spc 

cp input_rrtm_TROP-brd INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_rrtm_TROP-brd



