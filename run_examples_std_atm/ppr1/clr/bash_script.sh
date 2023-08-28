#!/bin/sh
cp input_mls_spc INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mls_spc

cp input_mls_brd INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_mls_brd

cp input_sas_spc INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_spc

cp input_sas_brd INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_sas_brd


cp input_trp_spc INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_rrtm_TROP-spc 
cp out_rrtm_TROP-spc out_trp_spc

cp input_trp_brd INPUT_RRTM
rrtmg_sw
cp OUTPUT_RRTM out_rrtm_TROP-brd
cp out_rrtm_TROP-brd out_trp_brd


